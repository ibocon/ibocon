using System.Text.Json;
using Microsoft.Playwright;
using Xunit;
using static Microsoft.Playwright.Assertions;

namespace Blog.PlaywrightTests;

public sealed class BlogMermaidRenderTests
{
    [Fact]
    public Task MermaidBlocksRenderAsSvg()
    {
        // Given
        var root = Environment.GetEnvironmentVariable("BLOG_MERMAID_EVIDENCE_ROOT")
            ?? Path.Combine(Directory.GetCurrentDirectory(), ".artifacts", "blog-mermaid-render", "V1");
        Directory.CreateDirectory(root);
        var target = "http://127.0.0.1:4321/architecture/2026-10-27-postfix-open-relay-incident/";

        return RunAsync(target, root);
    }

    private static async Task RunAsync(string target, string root)
    {
        using var playwright = await Playwright.CreateAsync();
        var browser = await playwright.Chromium.ConnectOverCDPAsync("http://localhost:9222");
        var page = await browser.NewPageAsync(new() { ViewportSize = new() { Width = 1440, Height = 1000 } });
        var log = new List<object>();
        await page.Context.Tracing.StartAsync(new() { Screenshots = true, Snapshots = true, Sources = true });
        try
        {
            // When
            var response = await page.GotoAsync(target, new() { WaitUntil = WaitUntilState.NetworkIdle, Timeout = 60000 });
            Assert.True(response?.Ok, $"BLOCKED: target post HTTP {response?.Status}");

            var mermaidBlocks = page.Locator("pre[data-language='mermaid']");
            await Expect(mermaidBlocks).ToHaveCountAsync(2);

            // Then: normalized blocks gain the mermaid class and mermaid.run swaps in SVG diagrams.
            var rendered = page.Locator("pre.mermaid > svg");
            await Expect(rendered).ToHaveCountAsync(2, new() { Timeout = 30000 });

            log.Add(new
            {
                url = page.Url,
                browser = browser.Version,
                observedAt = DateTimeOffset.UtcNow,
                mermaidBlockCount = await mermaidBlocks.CountAsync(),
                renderedSvgCount = await rendered.CountAsync(),
            });
        }
        catch
        {
            await page.ScreenshotAsync(new() { Path = Path.Combine(root, "failure.png"), FullPage = true });
            throw;
        }
        finally
        {
            await File.WriteAllTextAsync(
                Path.Combine(root, "observations.json"),
                JsonSerializer.Serialize(log, new JsonSerializerOptions { WriteIndented = true }));
            await page.Context.Tracing.StopAsync(new() { Path = Path.Combine(root, "trace.zip") });
            await page.CloseAsync();
        }
    }
}
