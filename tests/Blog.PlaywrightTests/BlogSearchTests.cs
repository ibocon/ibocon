using System.Text;
using System.Text.Json;
using Microsoft.Playwright;
using Xunit;
using static Microsoft.Playwright.Assertions;

[assembly: CollectionBehavior(DisableTestParallelization = true)]

namespace Blog.PlaywrightTests;

public sealed class BlogSearchTests
{
    private sealed record Card(string Id, string Title, string Description, string Tags);

    [Fact]
    public Task SearchRelevanceAndClear() => RunAsync(nameof(SearchRelevanceAndClear), async (page, cards, log) =>
    {
        var input = page.GetByRole(AriaRole.Searchbox, new() { Name = "게시물 검색" });
        await CheckSearchAsync(page, cards, string.Empty, log);
        var query = cards
            .Select(card => card.Title.Split(' ', StringSplitOptions.RemoveEmptyEntries).FirstOrDefault())
            .FirstOrDefault(value => !string.IsNullOrWhiteSpace(value));
        Assert.False(string.IsNullOrWhiteSpace(query), "BLOCKED: title query fixture missing");

        await input.FillAsync(query!);
        await CheckSearchAsync(page, cards, query!, log);
        await Expect(page.GetByRole(AriaRole.Button, new() { Name = "검색 지우기" })).ToBeVisibleAsync();
        await page.GetByRole(AriaRole.Button, new() { Name = "검색 지우기" }).ClickAsync();
        await CheckSearchAsync(page, cards, string.Empty, log);
    });

    [Fact]
    public Task TagDisclosureAndAppliedFilter() => RunAsync(nameof(TagDisclosureAndAppliedFilter), async (page, cards, log) =>
    {
        var tag = cards
            .SelectMany(card => Tags(card))
            .GroupBy(value => value, StringComparer.Ordinal)
            .Select(group => new { Tag = group.Key, Count = group.Count() })
            .Where(candidate => candidate.Count > 0 && candidate.Count < cards.Length)
            .OrderBy(candidate => candidate.Tag, StringComparer.Ordinal)
            .FirstOrDefault();
        Assert.NotNull(tag);

        var filter = page.Locator("#tag-filter");
        await Expect(filter).Not.ToHaveAttributeAsync("open", "");
        await filter.Locator("summary").ClickAsync();
        await Expect(filter).ToHaveAttributeAsync("open", "");
        await page.Locator($"button[data-tag='{tag!.Tag}']").ClickAsync();
        await CheckTagAsync(page, cards, tag.Tag, log);
        await Expect(page.Locator("#active-filters")).ToContainTextAsync($"태그: {tag.Tag}");
    });

    private static string Normalize(string value) => value.Normalize(NormalizationForm.FormC).Trim().ToLowerInvariant();

    private static int SearchScore(Card card, string query)
    {
        var normalizedQuery = Normalize(query);
        if (normalizedQuery.Length == 0)
        {
            return 0;
        }

        if (Normalize(card.Title).Contains(normalizedQuery, StringComparison.Ordinal))
        {
            return 3;
        }

        if (Tags(card).Any(tag => tag.Contains(normalizedQuery, StringComparison.Ordinal)))
        {
            return 2;
        }

        return Normalize(card.Description).Contains(normalizedQuery, StringComparison.Ordinal) ? 1 : -1;
    }

    private static bool Matches(Card card, string query) => SearchScore(card, query) >= 0;

    private static string[] Tags(Card card) => card.Tags
        .Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
        .Select(Normalize)
        .ToArray();

    private static async Task CheckTagAsync(IPage page, Card[] cards, string tag, List<object> log)
    {
        var expected = cards
            .Where(card => Tags(card).Contains(tag, StringComparer.Ordinal))
            .Select(card => card.Id)
            .ToArray();
        await Expect(page.Locator(".post-card:visible")).ToHaveCountAsync(expected.Length);
        await Expect(page.GetByRole(AriaRole.Status)).ToContainTextAsync($"{expected.Length}건");
        var actual = await page.Locator(".post-card:visible")
            .EvaluateAllAsync<string[]>("els => els.map(e => e.getAttribute('href'))");
        Assert.Equal(expected, actual);
        foreach (var button in await page.Locator("button[data-tag]").AllAsync())
        {
            var value = await button.GetAttributeAsync("data-tag");
            await Expect(button).ToHaveAttributeAsync("aria-pressed", value == tag ? "true" : "false");
        }

        log.Add(new { tag, expected, actual, status = await page.GetByRole(AriaRole.Status).InnerTextAsync() });
    }

    private static async Task CheckSearchAsync(IPage page, Card[] cards, string query, List<object> log)
    {
        var expected = cards
            .Select((card, index) => new { Card = card, Index = index })
            .Where(item => Matches(item.Card, query))
            .OrderByDescending(item => SearchScore(item.Card, query))
            .ThenBy(item => item.Index)
            .Select(item => item.Card.Id)
            .ToArray();
        await Expect(page.Locator(".post-card:visible")).ToHaveCountAsync(expected.Length);
        await Expect(page.GetByRole(AriaRole.Status)).ToContainTextAsync($"{expected.Length}건");
        var actual = await page.Locator(".post-card:visible")
            .EvaluateAllAsync<string[]>("els => els.map(e => e.getAttribute('href'))");
        Assert.Equal(expected, actual);
        log.Add(new { query, expected, actual, status = await page.GetByRole(AriaRole.Status).InnerTextAsync() });
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
            await page.Locator("button[data-tag='all']").ClickAsync();
            var cardJson = await page.Locator(".post-card").EvaluateAllAsync<string>("els => JSON.stringify(els.map(e => ({Id:e.getAttribute('href'),Title:e.dataset.title,Description:e.dataset.description,Tags:e.dataset.tags})))");
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
