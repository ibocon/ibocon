---
title: "Rich Domain Model로 불변식을 지키는 설계 원칙"
description: "빈혈 도메인 모델을 탈피하고 불변식 캡슐화와 Result 패턴으로 테스트 가능한 .NET 백엔드를 구축하는 방법"
pubDate: 2026-10-15
tags: ["dotnet", "csharp", "clean-architecture", "ddd"]
source: "tistory"
coverImage: "/post-covers/clean-architecture-rich-domain.svg"

draft: false
---

## 1. 문제 배경

비즈니스 규칙이 Application 레이어의 서비스나 핸들러에 흩어지는 빈혈 도메인 모델은 시스템 규모가 커질수록 불변식 검증 누락을 유발합니다.

이런 모델을 고치자고 하면 "ORM이 공개 setter와 공개 기본 생성자를 요구하니 어쩔 수 없다"는 반론이 따라옵니다. Milan Jovanović의 [Persisting a Rich Domain Model With EF Core](https://milanjovanovic.tech/blog/persisting-a-rich-domain-model-with-ef-core)(2026-08-08)는 이 반론에 답합니다. EF Core는 private 생성자와 backing field로 엔티티를 만들고 상태를 읽고 쓰므로, 완전히 캡슐화한 애그리거트도 저장할 수 있다는 내용입니다. 이 글은 그 글의 원칙을 바탕으로 합니다.

## 2. Rich Domain Model과 불변식 보호

도메인 엔티티는 생성자 및 팩토리 메서드를 통해 항상 유효한 상태(Always-Valid Entity)로만 생성되어야 하며, 상태 변경은 명시적인 도메인 행위 메서드를 통해서만 수행합니다.

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

## 3. Orchid 코드로 보는 적용 상태

위 원칙이 실제 코드에서 어디까지 지켜지는지 [Orchid.Core](https://github.com/ibocon/Orchid.Core)에서 발췌해 확인합니다. 각 블록 첫 줄의 주석이 해당 코드의 GitHub permalink입니다. Orchid.Core는 EF Core가 아니라 SQLite ORM으로 저장하며, 아래 블록은 모두 커밋 `78bd7bb` 기준입니다.

### 3.1 잘못된 조합은 생성 시점에 거부합니다

`Result`의 생성자는 "성공인데 오류가 있음", "실패인데 오류가 없음"이라는 두 모순 상태를 만들지 못하게 막습니다. 규칙이 생성자 한 곳에 있어서 호출부는 상태가 유효하다고 믿고 쓸 수 있습니다.

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

생성자가 던지는 예외는 개발자의 실수를 알리는 용도이고, 사용자 입력 같은 정상적인 실패는 3.3처럼 `Result`로 돌려줍니다.

### 3.2 값 객체는 private 생성자와 팩토리로만 만듭니다

`PayloadHash`는 생성자를 숨기고 `FromBytes`로만 만들 수 있습니다. 값은 항상 SHA-256 결과이고, 만든 뒤에는 바뀌지 않습니다.

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

### 3.3 규칙 위반은 예외 대신 `Result`로 돌려줍니다

`ProcessLocalClipboardAsync`는 빈 입력, 중복 내용, 암호화 실패를 모두 `Failure`로 반환합니다. 호출부는 반환값의 `IsFailure`를 확인해야 `Value`에 접근할 수 있습니다.

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

다만 이 규칙은 `Result.Value`가 실패일 때 예외를 던지는 방식이라, 컴파일러가 분기를 강제하지는 않고 실행 시점에 어긴 호출을 드러냅니다.

### 3.4 아직 지키지 못한 곳: 엔티티

`ClipboardItem`은 원칙과 어긋나는 부분이 남아 있습니다. 코드 주석이 밝히듯 공개 기본 생성자는 SQLite ORM의 역직렬화용이고, `IsPinned`와 `IsDeleted`는 공개 setter라서 어디서든 상태를 바꿀 수 있습니다.

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

같은 파일의 `[PrimaryKey]`, `[Indexed]` 특성은 `using SQLite;`에서 오므로 Domain 레이어가 ORM에 의존합니다. 참고한 글은 이를 엔티티 밖의 매핑 설정 클래스로 옮기고 private 생성자만 남기라고 합니다. Orchid에서는 `Pin()`, `Delete()` 같은 행위 메서드와 매핑 분리가 다음 개선 대상입니다.

## 4. 정리

- **계층 분리**: Domain 레이어는 외부 인프라나 프레임워크에 의존하지 않는 순수 C# 코드로 유지합니다.
- **명시적 실패 처리**: 비즈니스 규칙 위반은 예외(`throw`) 대신 `Result<T>` 패턴으로 표현하여 호출부에서 분기 처리를 하도록 유도합니다.
- **Orchid 적용 상태**: `Result`와 `PayloadHash`는 원칙대로 생성 시점에 상태를 보장합니다. 엔티티는 ORM 때문에 공개 기본 생성자와 공개 setter가 남아 있어 개선이 필요합니다.

## 5. 참고 자료

- Milan Jovanović, [Persisting a Rich Domain Model With EF Core](https://milanjovanovic.tech/blog/persisting-a-rich-domain-model-with-ef-core), 2026-08-08.
- [ibocon/Orchid.Core](https://github.com/ibocon/Orchid.Core) 커밋 [`78bd7bb`](https://github.com/ibocon/Orchid.Core/tree/78bd7bbf05baaa74877b9f270d077cc7ed5683db).
