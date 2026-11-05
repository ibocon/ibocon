---
title: "Xamarin ResourceDictionary를 관리하는 방법: 리소스 공유"
description: "ResourceDictionary Xamarin 개발에서 Resource Dictionary는 반드시 사용하게 되는 클래스입니다. 특히 XAML 에서 Style 이나 IValueConverter, ContentTemplate, DataTemplate 등을 사용할 때 Resource Di"
pubDate: 2020-06-13
tags: ["maui"]
source: "tistory"

originalUrl: "https://ibocon.tistory.com/180"
draft: false
---

![ResourceDictionary 관리](/blog-images/180/1.png)

XAML

# ResourceDictionary

Xamarin 개발에서 [Resource Dictionary](https://docs.microsoft.com/ko-kr/xamarin/xamarin-forms/xaml/resource-dictionaries)는 반드시 사용하게 되는 클래스입니다. 특히 XAML 에서 Style 이나 IValueConverter, ContentTemplate, DataTemplate 등을 사용할 때 Resource Dictionary 를 사용하면 다른 XAML에서 공유하여 사용할 수 있습니다. 문제는 ResourceDictionary 를 분리하거나 합치는 방법을 모르면 하나의 파일 안에 모든 XAML 리소스를 관리해야 해서 Resoucre Dictionary가 매우 복잡해집니다. 이를 해결하기 위해 Resource Dictionary 가 다른 Resource Dictionary 를 참조하는 방법을 알려드리도록 하겠습니다.

## 

아래 코드 한 줄을 반드시 Resource Dictionary 에 포함시켜야 합니다.

> 

```text

```

## 새로운 IValueConverter 클래스를 XAML에서 사용해보자!

### 1. ColorValueConverter 만들기

```csharp
namespace Solution.Project
{
    class ColorValueConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            var color = (System.Drawing.Color)value;
            return new SKColor(color.R, color.G, color.B, color.A);
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            var skcolor = (SKColor)value;
            return System.Drawing.Color.FromArgb(skcolor.Alpha, skcolor.Red, skcolor.Green, skcolor.Blue);
        }
    }
}
```

### 2. ColorValueConverter를 Converter.xaml 에 정의하기

```text

    

```

### 3. Converter.xaml 을 DataTemplate.xaml 에서 사용하기

```text

      
    
        
    
      
    
        
    

```

### 4. ContentView.xaml 에서 DataTemplate.xaml 사용하기

```text

    
        
    
    
                           
            
            
    

```
