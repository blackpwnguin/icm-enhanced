# domain-templates/ — router

Templates cloned into a project when it first touches a domain. The Curator clones
`_TEMPLATE/` (the four standard files) then overlays `<domain>/` (its CONTEXT.md +
extras from `_config/taxonomy.md`).

```
_TEMPLATE/   00-setup · 10-change-log · 20-recommended-improvements · 30-market-research
seo/         + 40-keyword-research · 50-analytics-integration   (fully worked)
analytics/ security/ performance/ accessibility/ content/ infra/ data/  (specialized CONTEXT + base files)
```

Standard shape: how it's set up · changes by date · recommended improvements · market
research. See `_config/structure.md`.
