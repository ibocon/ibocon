---
title: "[.NET] Clean Architecture와 Rich Domain Model 실전 설계 원칙"
description: "빈혈 도메인 모델을 탈피하고 불변식 캡슐화와 Result 패턴으로 테스트 가능한 .NET 백엔드를 구축하는 방법"
pubDate: 2026-10-15
category: "dotnet"
tags: ["dotnet", "csharp", "clean-architecture", "ddd"]
draft: false
---

## 1. 문제 배경

비즈니스 규칙이 Application 레이어의 서비스나 핸들러에 흩어지는 빈혈 도메인 모델은 시스템 규모가 커질수록 불변식 검증 누락을 유발합니다.

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

## 3. 정리

- **계층 분리**: Domain 레이어는 외부 인프라나 프레임워크에 의존하지 않는 순수 C# 코드로 유지합니다.
- **명시적 실패 처리**: 비즈니스 규칙 위반은 예외(`throw`) 대신 `Result<T>` 패턴으로 표현하여 호출부에서 컴파일 타임에 분기 처리를 강제합니다.
