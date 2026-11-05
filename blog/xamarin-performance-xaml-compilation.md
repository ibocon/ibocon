---
title: "Xamarin XAML 컴파일로 성능을 높이는 방법: 빌드"
description: "성능 개선 - XAML 컴파일 XAML 코드는 View 의 디자인을 위해 사용하는 마크업 언어라, 컴파일하여 배포하는 언어가 아닙니다. 그래서 Xamarin 앱을 배포하면 XAML 코드는 .xaml 파일 그대로 배포되고, 런타임에 동적으로 해석해서 View 를 만듭니다. 개발자 입장에서"
pubDate: 2020-08-05
tags: ["maui"]
source: "tistory"

originalUrl: "https://ibocon.tistory.com/195"
draft: false
---

![XAML Comilation](/blog-images/195/1.png)

XAML Compilation

# 성능 개선 - XAML 컴파일

XAML 코드는 View 의 디자인을 위해 사용하는 마크업 언어라, 컴파일하여 배포하는 언어가 아닙니다. 그래서 Xamarin 앱을 배포하면 XAML 코드는 .xaml 파일 그대로 배포되고, 런타임에 동적으로 해석해서 View 를 만듭니다. 개발자 입장에서 런타임에 동적으로 XAML 코드를 해석하는건 Hot Reload 같이 디버깅을 하는 경우를 제외하고는 성능을 희생해서 얻는 메리트가 없습니다. 따라서 XAML 코드를 CLR 이 해석할 수 있는 IL (Intermediate Language) 코드로 변환하도록 설정하여 간단하게 성능을 개선하여 봅시다.

## Assembly 단위로 XAML 코드를 컴파일하도록 설정

```text
[assembly: XamlCompilation (XamlCompilationOptions.Compile)]
namespace App
{
  //...
}
```

### Class 단위로 XAML 코드를 컴파일하도록 설정

```kotlin
[XamlCompilation (XamlCompilationOptions.Compile)]
public class HomePage : ContentPage
{
  //...
}
```

> XAML 코드를 컴파일하면 런타임에 발생했을 수도 있는 오류를 배포하기 전에 점검할 수도 있습니다.

XAML 코드 컴파일만으로 얻는 성능 개선보다 [Compiled Binding](https://ibocon.tistory.com/196)을 같이 활용하면 배이상의 성능 개선 효과를 얻으실 수 있습니다.
