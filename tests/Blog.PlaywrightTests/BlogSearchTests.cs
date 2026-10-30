using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.Playwright;
using Xunit;
using static Microsoft.Playwright.Assertions;

[assembly: CollectionBehavior(DisableTestParallelization = true)]

namespace Blog.PlaywrightTests;

public sealed class BlogSearchTests
{
    private sealed record Card(string Id, string Title, string Description, string Category, string Tags);

    [Fact]
    public Task SearchInputAndClear() => RunAsync(nameof(SearchInputAndClear), async (page, cards, log) =>
    {
        var input = page.GetByRole(AriaRole.Searchbox, new() { Name = "게시물 검색" });
        await CheckAsync(page, cards, "", "all", log);
        var korean = cards.Select(card => Regex.Match(card.Title + " " + card.Description, "[가-힣]{2,4}"))
            .FirstOrDefault(match => match.Success)?.Value;
        Assert.True(korean is not null, "BLOCKED: Korean fixture missing");
        Assert.Contains(cards, card => Matches(card, "blazor"));
        foreach (var query in new[] { "blazor", korean! })
        {
            await input.FillAsync("");
            await CheckAsync(page, cards, "", "all", log);
            var prefix = "";
            foreach (var character in query)
            {
                prefix += character;
                await input.PressSequentiallyAsync(character.ToString());
                await CheckAsync(page, cards, prefix, "all", log);
            }
            await input.FillAsync(query);
            await CheckAsync(page, cards, query, "all", log);
            await input.FillAsync("");
            await CheckAsync(page, cards, "", "all", log);
        }
    });

    [Fact]
    public Task CategoryAndEmptyState() => RunAsync(nameof(CategoryAndEmptyState), async (page, cards, log) =>
    {
        var input = page.GetByRole(AriaRole.Searchbox, new() { Name = "게시물 검색" });
        var missing = "없는검색어" + Guid.NewGuid().ToString("N");
        Assert.DoesNotContain(cards, card => Matches(card, missing));
        await input.FillAsync(missing);
        await CheckAsync(page, cards, missing, "all", log);
        await input.FillAsync("");
        await page.Locator("button[data-category='dotnet']").ClickAsync();
        await input.FillAsync("blazor");
        await CheckAsync(page, cards, "blazor", "dotnet", log);
        foreach (var button in await page.Locator("button[data-category]").AllAsync())
        {
            var category = await button.GetAttributeAsync("data-category");
            await Expect(button).ToHaveAttributeAsync("aria-pressed", category == "dotnet" ? "true" : "false");
        }
        await Expect(page.Locator("button[data-tag='all']")).ToHaveAttributeAsync("aria-pressed", "true");
    });

    [Fact]
    public Task TagOnlyFiltering() => RunAsync(nameof(TagOnlyFiltering), async (page, cards, log) =>
    {
        var tag = cards
            .SelectMany(card => Tags(card))
            .GroupBy(tag => tag, StringComparer.Ordinal)
            .Select(group => new { Tag = group.Key, Count = group.Count() })
            .Where(candidate => candidate.Count > 0 && candidate.Count < cards.Length)
            .OrderBy(candidate => candidate.Tag, StringComparer.Ordinal)
            .FirstOrDefault();
        Assert.NotNull(tag);

        await page.Locator($"button[data-tag='{tag!.Tag}']").ClickAsync();
        await CheckTagAsync(page, cards, "all", tag.Tag, log);
    });

    [Fact]
    public Task CategoryTagIntersection() => RunAsync(nameof(CategoryTagIntersection), async (page, cards, log) =>
    {
        var selection = FindIntersection(cards);
        Assert.NotNull(selection);

        var value = selection!.Value;
        await page.Locator($"button[data-category='{value.Category}']").ClickAsync();
        await page.Locator($"button[data-tag='{value.Tag}']").ClickAsync();
        await CheckTagAsync(page, cards, value.Category, value.Tag, log);
        await page.Locator("button[data-tag='all']").ClickAsync();
        await CheckTagAsync(page, cards, value.Category, "all", log);
    });

    [Fact]
    public Task CategoryTagEmptyState() => RunAsync(nameof(CategoryTagEmptyState), async (page, cards, log) =>
    {
        var selection = FindEmptyIntersection(cards);
        Assert.NotNull(selection);

        var value = selection!.Value;
        await page.Locator($"button[data-category='{value.Category}']").ClickAsync();
        await page.Locator($"button[data-tag='{value.Tag}']").ClickAsync();
        await CheckTagAsync(page, cards, value.Category, value.Tag, log);
    });

    private static string Normalize(string value) => value.Normalize(NormalizationForm.FormC).Trim().ToLowerInvariant();

    private static bool Matches(Card card, string query) =>
        string.Join(" ", new[] { card.Title, card.Description, card.Category, card.Tags }.Select(Normalize))
            .Contains(Normalize(query), StringComparison.Ordinal);

    private static string[] Tags(Card card) => card.Tags
        .Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
        .Select(Normalize)
        .ToArray();

    private static (string Category, string Tag)? FindIntersection(Card[] cards)
    {
        foreach (var category in cards.Select(card => card.Category).Distinct().Order())
        {
            var categoryCards = cards.Where(card => card.Category == category).ToArray();
            var tag = categoryCards
                .SelectMany(Tags)
                .GroupBy(candidate => candidate, StringComparer.Ordinal)
                .Select(group => new { Tag = group.Key, Count = group.Count() })
                .Where(candidate => candidate.Count > 0 && candidate.Count < categoryCards.Length)
                .OrderBy(candidate => candidate.Tag, StringComparer.Ordinal)
                .FirstOrDefault();
            if (tag is not null)
                return (category, tag.Tag);
        }

        return null;
    }

    private static (string Category, string Tag)? FindEmptyIntersection(Card[] cards)
    {
        var tags = cards.SelectMany(Tags).Distinct().Order().ToArray();
        foreach (var category in cards.Select(card => card.Category).Distinct().Order())
        {
            var categoryTags = cards.Where(card => card.Category == category).SelectMany(Tags).ToHashSet(StringComparer.Ordinal);
            var tag = tags.FirstOrDefault(candidate => !categoryTags.Contains(candidate));
            if (tag is not null)
                return (category, tag);
        }

        return null;
    }

    private static async Task CheckTagAsync(IPage page, Card[] cards, string category, string tag, List<object> log)
    {
        var expected = cards.Where(card =>
                (category == "all" || card.Category == category) &&
                (tag == "all" || Tags(card).Contains(tag, StringComparer.Ordinal)))
            .Select(card => card.Id).Order().ToArray();
        await Expect(page.Locator(".post-card:visible")).ToHaveCountAsync(expected.Length);
        await Expect(page.GetByRole(AriaRole.Status)).ToHaveTextAsync($"게시물 {expected.Length}건");
        foreach (var card in cards)
        {
            var locator = page.Locator(".post-card").Nth(Array.IndexOf(cards, card));
            if (expected.Contains(card.Id))
                await Expect(locator).ToBeVisibleAsync();
            else
                await Expect(locator).ToBeHiddenAsync();
        }

        if (expected.Length == 0)
            await Expect(page.Locator("#search-empty")).ToBeVisibleAsync();
        else
            await Expect(page.Locator("#search-empty")).ToBeHiddenAsync();
        var actual = await page.Locator(".post-card:visible").EvaluateAllAsync<string[]>("els => els.map(e => e.getAttribute('href')).sort()");
        Assert.Equal(expected, actual);
        foreach (var button in await page.Locator("button[data-category]").AllAsync())
        {
            var value = await button.GetAttributeAsync("data-category");
            await Expect(button).ToHaveAttributeAsync("aria-pressed", value == category ? "true" : "false");
        }

        foreach (var button in await page.Locator("button[data-tag]").AllAsync())
        {
            var value = await button.GetAttributeAsync("data-tag");
            await Expect(button).ToHaveAttributeAsync("aria-pressed", value == tag ? "true" : "false");
        }

        log.Add(new { category, tag, expected, actual, status = await page.GetByRole(AriaRole.Status).InnerTextAsync() });
    }

    private static async Task CheckAsync(IPage page, Card[] cards, string query, string category, List<object> log)
    {
        var expected = cards.Where(card => (category == "all" || card.Category == category) && Matches(card, query))
            .Select(card => card.Id).Order().ToArray();
        await Expect(page.Locator(".post-card:visible")).ToHaveCountAsync(expected.Length);
        await Expect(page.GetByRole(AriaRole.Status)).ToHaveTextAsync($"게시물 {expected.Length}건");
        foreach (var card in cards)
        {
            var locator = page.Locator(".post-card").Nth(Array.IndexOf(cards, card));
            if (expected.Contains(card.Id))
                await Expect(locator).ToBeVisibleAsync();
            else
                await Expect(locator).ToBeHiddenAsync();
        }
        if (expected.Length == 0)
            await Expect(page.Locator("#search-empty")).ToBeVisibleAsync();
        else
            await Expect(page.Locator("#search-empty")).ToBeHiddenAsync();
        var actual = await page.Locator(".post-card:visible").EvaluateAllAsync<string[]>("els => els.map(e => e.getAttribute('href')).sort()");
        Assert.Equal(expected, actual);
        log.Add(new { query, category, expected, actual, status = await page.GetByRole(AriaRole.Status).InnerTextAsync() });
    }

    private static async Task RunAsync(string name, Func<IPage, Card[], List<object>, Task> scenario)
    {
        var root = Environment.GetEnvironmentVariable("BLOG_SEARCH_EVIDENCE_ROOT")
            ?? Path.Combine(Directory.GetCurrentDirectory(), ".artifacts", "blog-search", name);
        Directory.CreateDirectory(root);
        using var playwright = await Playwright.CreateAsync();
        var browser = await playwright.Chromium.ConnectOverCDPAsync("http://localhost:9222");
        var page = await browser.NewPageAsync(new() { ViewportSize = new() { Width = 1440, Height = 1000 } });
        var log = new List<object>();
        await page.Context.Tracing.StartAsync(new() { Screenshots = true, Snapshots = true, Sources = true });
        try
        {
            var response = await page.GotoAsync("https://blog.botanicsoft.com/", new() { WaitUntil = WaitUntilState.NetworkIdle, Timeout = 60000 });
            Assert.True(response?.Ok, $"BLOCKED: homepage HTTP {response?.Status}");
            await Expect(page.GetByRole(AriaRole.Searchbox, new() { Name = "게시물 검색" })).ToBeVisibleAsync();
            await page.Locator("button[data-category='all']").ClickAsync();
            await page.Locator("button[data-tag='all']").ClickAsync();
            var cardJson = await page.Locator(".post-card").EvaluateAllAsync<string>("els => JSON.stringify(els.map(e => ({Id:e.getAttribute('href'),Title:e.dataset.title,Description:e.dataset.description,Category:e.dataset.category,Tags:e.dataset.tags})))");
            var cards = JsonSerializer.Deserialize<Card[]>(cardJson)!;
            Assert.NotEmpty(cards);
            log.Add(new { url = page.Url, browser = browser.Version, observedAt = DateTimeOffset.UtcNow, headers = response!.Headers, cards });
            await scenario(page, cards, log);
        }
        catch
        {
            await page.ScreenshotAsync(new() { Path = Path.Combine(root, "failure.png"), FullPage = true });
            throw;
        }
        finally
        {
            await File.WriteAllTextAsync(Path.Combine(root, "observations.json"), JsonSerializer.Serialize(log, new JsonSerializerOptions { WriteIndented = true }));
            await page.Context.Tracing.StopAsync(new() { Path = Path.Combine(root, "trace.zip") });
            await page.CloseAsync();
        }
    }
}
