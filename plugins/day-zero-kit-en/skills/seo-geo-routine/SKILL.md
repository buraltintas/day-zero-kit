---
name: seo-geo-routine
description: >-
  Sets up and keeps running a project's SEO and GEO (being cited by AI answer engines) work per the
  Project Setup Guide (Proje Kurulum Rehberi): the day-0 technical list, Search Console measurement,
  counting AI traffic correctly, and the weekly and monthly jobs that never end. It first checks that
  the SEO surface does not wake the database. Use it for SEO, GEO, Search Console, indexing, sitemaps,
  robots.txt, canonical, structured data, llms.txt, showing up in ChatGPT or Perplexity, organic
  traffic or "why are there no clicks".
---

# SEO and GEO routine

First lesson: SEO invites bots, and bots wake the database. Every path a bot can reach (pages, sitemaps, llms.txt, share images) is served from memory or ISR and never touches the database. After a new SEO surface opens, wake-ups are watched for 48 hours.

The guide sections under `references/` are in Turkish. Read them as they are and answer in the language the user writes in.

## Read

- `references/seo-and-geo.md`: what we did, what came of it, the rules (day-0 technical, GEO, measurement), the jobs that never end, what could be done better, the day-0 list.
- `references/layers-1-4.md` (the Next.js web layer: full HTML on the server, ISR, the change marker), `references/layers-5-9-and-bots.md` (the stance on bots), `references/performance.md`.

## Flow

1. **Day 0 (once):** apply the day-0 list: full HTML on the server, one host with 308 redirects, sitemap, robots.txt, canonical, structured data, Search Console and Bing sign-up, a baseline measurement.
2. **Weekly:** Search Console coverage and queries, pages dropped from the index, canonical warnings, the database wake-up count.
3. **Monthly:** citation checks in answer engines with sample queries, refreshing dated data pages, refreshing crawler IP lists, link building.
4. **Count AI traffic correctly:** separate prefetches and bots first, then count real clicks. The first rough count misleads.

## Only the product owner does these

Verifying domain ownership in Search Console and Bing, adding DNS records, reaching out to other sites for links and submitting any form are the owner's work; stop and ask when you get there.

## Report

```
This week: <n> pages indexed, <n> clicks, <n> impressions; change: ...
Problems: <page | problem | fix>
Database: wake-ups caused by the SEO surface <n>
Next job: ...
```
