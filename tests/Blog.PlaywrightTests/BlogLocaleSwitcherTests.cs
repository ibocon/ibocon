using Microsoft.Playwright;
// keep: Xunit — [Fact]와 Assert 사용
using Xunit;
using static Microsoft.Playwright.Assertions;

namespace Blog.PlaywrightTests;

// ✅ 언어 드롭다운 열기·이동·닫기·모바일 폭 시나리오
public sealed class BlogLocaleSwitcherTests
{
    private static readonly string BaseUrl = Environment.GetEnvironmentVariable("BLOG_LOCALE_BASE_URL")
        ?? "http://127.0.0.1:4321";

    [Fact]
    public Task LocaleMenuSwitchesLanguage()
    {
        // Given
        return RunAsync(1440, "/about/", async page =>
        {
            var menu = page.Locator("[data-locale-menu]");
            await Expect(menu.Locator("summary")).ToContainTextAsync("한국어");

            // When
            await menu.Locator("summary").ClickAsync();
            await Expect(menu.Locator("li")).ToHaveCountAsync(2);
            await menu.Locator("a[lang='en']").ClickAsync();

            // Then
            await Expect(page).ToHaveURLAsync($"{BaseUrl}/en/about/");
            await Expect(page.Locator("html")).ToHaveAttributeAsync("lang", "en");
            await Expect(page.Locator("[data-locale-menu] summary")).ToContainTextAsync("English");
        });
    }

    [Fact]
    public Task LocaleMenuClosesWithEscapeAndOutsideClick()
    {
        // Given
        return RunAsync(1440, "/", async page =>
        {
            var menu = page.Locator("[data-locale-menu]");
            var trigger = menu.Locator("summary");
            await trigger.FocusAsync();

            // When
            await page.Keyboard.PressAsync("Enter");
            Assert.True(await menu.EvaluateAsync<bool>("element => element.open"));
            await page.Keyboard.PressAsync("Escape");

            // Then
            Assert.False(await menu.EvaluateAsync<bool>("element => element.open"));
            await Expect(trigger).ToBeFocusedAsync();

            await trigger.ClickAsync();
            await page.Mouse.ClickAsync(5, 500);
            Assert.False(await menu.EvaluateAsync<bool>("element => element.open"));
        });
    }

    [Fact]
    public Task LocaleMenuStaysInsideMobileViewport()
    {
        // Given
        return RunAsync(375, "/en/resume/", async page =>
        {
            var menu = page.Locator("[data-locale-menu]");

            // When
            await menu.Locator("summary").ClickAsync();
            var box = await menu.Locator(".locale-menu-list").BoundingBoxAsync();
            var scrollWidth = await page.EvaluateAsync<int>("document.documentElement.scrollWidth");

            // Then
            Assert.NotNull(box);
            Assert.True(box.X >= 0 && box.X + box.Width <= 375, $"locale menu overflows viewport: x={box.X}, width={box.Width}");
            Assert.True(scrollWidth <= 375, $"horizontal scroll introduced: scrollWidth={scrollWidth}");
        });
    }

    private static async Task RunAsync(int width, string path, Func<IPage, Task> scenario)
    {
        using var playwright = await Playwright.CreateAsync();
        var browser = await playwright.Chromium.ConnectOverCDPAsync("http://localhost:9222");
        var page = await browser.NewPageAsync(new() { ViewportSize = new() { Width = width, Height = 900 } });
        try
        {
            var response = await page.GotoAsync($"{BaseUrl}{path}", new() { WaitUntil = WaitUntilState.NetworkIdle });
            Assert.True(response?.Ok, $"BLOCKED: {path} HTTP {response?.Status}");
            await scenario(page);
        }
        finally
        {
            await page.CloseAsync();
        }
    }
}
