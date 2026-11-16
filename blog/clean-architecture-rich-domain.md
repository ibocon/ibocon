---
title: "Rich Domain Model로 불변식을 지키는 설계 원칙"
description: "비즈니스 규칙이 서비스에 흩어지면 불변식 검증을 빠뜨리기 쉽습니다. 생성 시점 검증, 상태 전이 메서드, Result 패턴으로 규칙을 엔티티에 모으는 방법을 Orchid.Core의 실제 코드로 확인합니다."
pubDate: 2026-10-15
tags: ["dotnet", "csharp", "clean-architecture", "ddd"]
source: "tistory"
authoringVersion: 1
audience: "topic-new-developer"
articleType: "concept"
coverImage: "/post-covers/clean-architecture-rich-domain.svg"
draft: false
---

## 핵심 요약

비즈니스 규칙이 Application 레이어의 서비스와 핸들러에 흩어진 빈혈 도메인 모델은 시스템이 커질수록 불변식 검증을 빠뜨리게 만든다. 이 글은 엔티티를 생성 시점부터 항상 유효하게 만들고 상태 변경을 도메인 메서드로 한정하는 설계를 Orchid.Core의 실제 코드로 확인한다. 값 객체와 실패 표현은 처음부터 원칙대로였지만 엔티티는 SQLite ORM[^orm] 때문에 원칙을 어기고 있었고, 이를 고친 결과까지 다룬다. 저장 기술별 매핑 세부는 범위 밖이다.

## 알아야 할 최소 개념

빈혈 도메인 모델은 엔티티를 공개 setter만 가진 데이터 덩어리로 두고 규칙을 서비스에 두는 구조다. 규칙이 여러 서비스에 나뉘어 있으면 새 호출 경로가 생길 때마다 검증 하나가 빠질 수 있다. 이 구조를 고치자고 하면 "ORM이 공개 setter와 공개 기본 생성자를 요구하니 어쩔 수 없다"는 반론이 따라온다. 이 글은 세 가지 개념으로 그 반론에 답한다.

- **불변식**: 엔티티가 어떤 상태에서도 지켜야 하는 규칙이다. 삭제된 항목은 즐겨찾기에 고정될 수 없다는 규칙이 한 예다.
- **항상 유효한 엔티티(Always-Valid Entity)**: 생성자를 숨기고 팩토리 메서드가 규칙을 검증한 뒤에만 객체를 돌려주는 방식이다. 객체 참조를 들고 있다는 사실만으로 유효성을 믿을 수 있다.
- **Result 패턴**: 규칙 위반을 예외로 던지지 않고 성공 또는 실패를 담은 반환값으로 돌려주는 방식이다. 반환값의 성공 여부를 확인하지 않고 값에 접근하면 예외가 난다.

## 동작 원리

도메인 엔티티는 생성자와 팩토리 메서드로만 만들고, 상태 변경은 이름이 의도를 드러내는 도메인 행위 메서드로만 수행한다. 아래 `Order`는 이 원칙을 보여 주는 예시이며 Orchid의 실제 코드가 아니다. 생성자가 `private`이라 `Create`를 거치지 않고는 `Order`를 만들 수 없고, `Status`는 `private set`이라 밖에서 바꿀 수 없다.

```csharp
public sealed class Order : AggregateRoot<OrderId>
{
    private readonly List<OrderLine> _lines = [];

    private Order(OrderId id, CustomerId customerId)
        : base(id)
    {
        CustomerId = customerId;
        Status = OrderStatus.Draft;
    }

    public CustomerId CustomerId { get; }
    public OrderStatus Status { get; private set; }
    public IReadOnlyList<OrderLine> Lines => _lines;

    public static Result<Order> Create(CustomerId customerId)
    {
        if (customerId == CustomerId.Empty)
        {
            return Result.Failure<Order>(OrderErrors.InvalidCustomer);
        }

        return Result.Success(new Order(OrderId.New(), customerId));
    }
}
```

`Create`는 고객 식별자가 비어 있으면 예외 대신 `Result.Failure`를 돌려준다. 호출부는 성공 여부를 확인한 뒤에야 `Order`를 쓸 수 있다.

ORM이 공개 setter를 강제한다는 반론에는 Milan Jovanović의 [Persisting a Rich Domain Model With EF Core](https://milanjovanovic.tech/blog/persisting-a-rich-domain-model-with-ef-core)가 답한다. 2026년 8월 8일 글에 따르면 EF Core는 `private` 생성자와 backing field[^backingfield]로 엔티티를 만들고 상태를 읽고 쓰므로, 완전히 캡슐화한 애그리게이트[^aggregate]도 저장할 수 있다. 매핑 선언은 도메인 밖의 설정 클래스로 옮긴다. 저장소에서 읽어 객체를 복원할 때는 팩토리 검증을 다시 실행하지 않는다. 규칙이 바뀐 뒤에는 과거 행을 읽지 못하게 되기 때문이다.

## 적용할 때 확인할 점

위 원칙이 실제 코드에서 어디까지 지켜지는지 [Orchid.Core](https://github.com/ibocon/Orchid.Core)에서 발췌해 확인했다. 각 블록 첫 줄의 주석이 해당 코드의 permalink[^permalink]다. Orchid.Core는 EF Core가 아니라 SQLite ORM으로 저장한다. 처음 네 블록은 커밋 `78bd7bb` 기준이고, 마지막 블록은 개선한 뒤의 커밋 `b932549` 기준이다.

### 잘못된 조합은 생성자에서 거부한다

`Result`의 생성자는 성공인데 오류가 있는 상태와 실패인데 오류가 없는 상태를 만들지 못하게 막는다. 규칙이 생성자 한 곳에 있어서 호출부는 상태가 유효하다고 믿고 쓸 수 있다.

```csharp
// https://github.com/ibocon/Orchid.Core/blob/78bd7bbf05baaa74877b9f270d077cc7ed5683db/src/Entity/Common/Result.cs#L15-L29
protected Result(bool isSuccess, Error? error)
{
    if (isSuccess && error != null && error != Error.None)
    {
        throw new InvalidOperationException("Successful result cannot have an error.");
    }

    if (!isSuccess && (error == null || error == Error.None))
    {
        throw new InvalidOperationException("Failure result must have an error.");
    }

    IsSuccess = isSuccess;
    Error = error ?? Error.None;
}
```

이 생성자가 던지는 예외는 개발자의 실수를 알리는 용도다. 사용자 입력 같은 정상적인 실패는 아래처럼 `Result`로 돌려준다.

### 값 객체는 private 생성자와 팩토리로만 만든다

`PayloadHash`는 값 객체[^valueobject]이고 생성자를 숨겨 `FromBytes`로만 만들 수 있다. 값은 항상 SHA-256 결과이고, 만든 뒤에는 바뀌지 않는다.

```csharp
// https://github.com/ibocon/Orchid.Core/blob/78bd7bbf05baaa74877b9f270d077cc7ed5683db/src/Entity/ClipboardItem/PayloadHash.cs#L8-L30 (XML 주석 생략)
public sealed record PayloadHash
{
    private PayloadHash(string value)
    {
        Value = value;
    }

    public string Value { get; }

    public static PayloadHash FromBytes(byte[] data)
    {
        ArgumentNullException.ThrowIfNull(data);
        byte[] hashBytes = SHA256.HashData(data);
        return new PayloadHash(Convert.ToHexStringLower(hashBytes));
    }
}
```

### 규칙 위반은 예외 대신 Result로 돌려준다

`ProcessLocalClipboardAsync`는 빈 입력, 중복 내용, 암호화 실패를 모두 `Failure`로 반환한다. 호출부는 반환값의 `IsFailure`를 확인한 뒤에 `Value`에 접근한다.

```csharp
// https://github.com/ibocon/Orchid.Core/blob/78bd7bbf05baaa74877b9f270d077cc7ed5683db/src/Service/Sync/SyncEngine.cs#L35-L53
public async Task<Result<EncryptedPayload>> ProcessLocalClipboardAsync(string plainText, Guid deviceId, byte[] key)
{
    if (string.IsNullOrEmpty(plainText))
    {
        return Result<EncryptedPayload>.Failure("Clipboard text cannot be empty.");
    }

    string hash = PayloadHash.FromString(plainText).Value;
    if (await _repository.ExistsByHashAsync(hash).ConfigureAwait(false))
    {
        return Result<EncryptedPayload>.Failure(DuplicateContent);
    }

    byte[] plainBytes = Encoding.UTF8.GetBytes(plainText);
    Result<(byte[] CipherText, byte[] Nonce, byte[] Tag)> encryptResult = _cryptoService.Encrypt(plainBytes, key);
    if (encryptResult.IsFailure)
    {
        return Result<EncryptedPayload>.Failure(encryptResult.Error);
    }
```

다만 실패한 결과의 `Value`에 접근하면 예외가 나는 방식이라 컴파일러가 분기를 강제하지는 않는다. 확인을 빠뜨린 호출은 실행 시점에 드러난다.

### 엔티티는 원칙을 지키지 못하고 있었다

`ClipboardItem`은 원칙에서 벗어나 있었다. 코드 주석이 밝히듯 공개 기본 생성자는 SQLite ORM의 역직렬화용이었고, `IsPinned`와 `IsDeleted`는 공개 setter라서 어디서든 상태를 바꿀 수 있었다. 실제로 저장소의 `DeleteAsync`가 `IsDeleted`를 직접 대입했다.

```csharp
// https://github.com/ibocon/Orchid.Core/blob/78bd7bbf05baaa74877b9f270d077cc7ed5683db/src/Entity/ClipboardItem/ClipboardItem.cs#L38-L47
/// <summary>
/// 기본 생성자 (SQLite ORM 역직렬화용)
/// </summary>
public ClipboardItem()
{
    CipherText = [];
    Nonce = [];
    Tag = [];
    PayloadHash = string.Empty;
}

// https://github.com/ibocon/Orchid.Core/blob/78bd7bbf05baaa74877b9f270d077cc7ed5683db/src/Entity/ClipboardItem/ClipboardItem.cs#L94-L99
public bool IsPinned { get; set; }

public bool IsDeleted { get; set; }
```

같은 파일의 `[PrimaryKey]`와 `[Indexed]` 특성은 `using SQLite;`에서 오므로 Domain 레이어가 ORM에 의존하고 있었다. 삭제된 항목은 고정될 수 없다는 불변식도 어디에서도 강제되지 않았다.

### 생성, 상태 전이, 매핑을 분리해 고쳤다

고친 결과는 세 갈래다. 생성자는 `private`으로 숨기고 `Create`가 논스 12바이트와 태그 16바이트 같은 규칙을 검증한 뒤 `Result`로 돌려준다. 상태 변경은 `Pin`, `Unpin`, `Delete`로만 하며, 삭제하면 고정도 함께 풀려 불변식이 지켜진다. 저장소에서 읽을 때 쓰는 `Rehydrate`는 검증을 다시 하지 않는다.

```csharp
// https://github.com/ibocon/Orchid.Core/blob/b9325498ad5c78d6ba5d48b3b317fc90488d7989/src/Entity/ClipboardItem/ClipboardItem.cs#L205-L231
public Result Pin()
{
    if (IsDeleted)
    {
        return Result.Failure(ClipboardItemErrors.DeletedItemCannotBePinned);
    }

    IsPinned = true;
    return Result.Success();
}

/// <summary>
/// 항목의 즐겨찾기 고정을 해제합니다.
/// </summary>
public void Unpin()
{
    IsPinned = false;
}

/// <summary>
/// 항목을 소프트 삭제합니다. 삭제하면 고정도 함께 해제해 삭제된 항목은 고정되지 않는다는 불변식을 지킵니다.
/// </summary>
public void Delete()
{
    IsDeleted = true;
    IsPinned = false;
}
```

SQLite 매핑은 저장소 레이어의 `internal` Row 타입으로 옮겼다. Row에 `[Table("ClipboardItem")]`를 붙여 기존 테이블과 컬럼 이름을 유지했기 때문에 이미 저장된 데이터를 그대로 읽는다. 도메인이 SQLite에 의존하지 않는다는 규칙과 엔티티가 공개 생성자와 공개 setter를 노출하지 않는다는 규칙은 아키텍처 테스트로 강제한다. 남은 한계도 있다. 화면이 암호문 길이를 읽기 때문에 `CipherText` 같은 배열 속성은 그대로 노출하며 호출자가 내용을 바꿀 수 있다. 공개 생성자를 없앤 것은 파괴적 변경이라 패키지 버전을 올렸고, 소비하는 앱은 팩토리로 전환해야 한다.

## 마무리

- **계층 분리**: Domain 레이어는 외부 인프라나 프레임워크에 의존하지 않는 순수 C# 코드로 유지한다. 매핑 정보는 저장소 레이어로 옮긴다.
- **명시적 실패 처리**: 비즈니스 규칙 위반은 예외 대신 `Result<T>` 패턴으로 표현해 호출부가 분기하도록 유도한다. 컴파일러가 강제하지는 않는다는 한계를 알고 쓴다.
- **다음 행동**: 자신의 코드에서 공개 setter가 있는 엔티티 하나를 골라 어떤 불변식이 호출부에 흩어져 있는지 찾는다. 그 규칙을 `Create`와 상태 전이 메서드로 옮기는 것이 첫 단계다.

### 참고 자료

- Milan Jovanović, [Persisting a Rich Domain Model With EF Core](https://milanjovanovic.tech/blog/persisting-a-rich-domain-model-with-ef-core), 2026년 8월 8일.
- [ibocon/Orchid.Core](https://github.com/ibocon/Orchid.Core) 커밋 [`78bd7bb`](https://github.com/ibocon/Orchid.Core/tree/78bd7bbf05baaa74877b9f270d077cc7ed5683db)와 [`b932549`](https://github.com/ibocon/Orchid.Core/tree/b9325498ad5c78d6ba5d48b3b317fc90488d7989).

[^orm]: 객체와 데이터베이스 테이블 사이의 변환을 맡는 라이브러리다.
[^backingfield]: 속성 뒤에서 값을 실제로 담는 필드다.
[^aggregate]: 함께 저장되고 하나의 규칙으로 묶이는 엔티티 묶음이며 루트 엔티티를 통해서만 접근한다.
[^permalink]: 특정 커밋에 고정되어 코드가 바뀌어도 같은 내용을 가리키는 주소다.
[^valueobject]: 식별자 없이 값 자체로 동등성을 판단하는 불변 객체다.
