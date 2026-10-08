---
name: release-gate
description: >-
  Runs the Project Setup Guide's (Proje Kurulum Rehberi) release gate before a mobile store release, a
  production deploy or any change that affects users, and gives an evidence-backed ship / no-ship
  list. Use it whenever we are about to release, build, submit to a store, merge to main, run a
  migration, switch on forced update, or when someone asks "will this change break users".
---

# Release gate

The release decision belongs to the product owner. This skill feeds it with evidence: what is ready, what is missing, and what users will see if we ship with a gap. It never builds, submits, deploys or changes version numbers.

The guide sections under `references/` are in Turkish. Read them as they are and answer in the language the user writes in.

## Which list

- **Mobile store release:** the release gate in `references/mobil-kit.md` and the checklist in `references/mobil-dagitim.md`.
- **Production deploy:** the CI/CD and environments section in `references/katmanlar-5-9-ve-botlar.md`, and `references/kontrol-listesi.md`.
- **Any user-facing change:** `references/kullaniciyi-kirmadan-degistirmek.md` (the API only grows by adding, old app versions, the rollback path, the time of release).

## Flow

1. Classify the change: JS only or native, does the API contract change, is there a migration, who is affected.
2. Tick the relevant list item by item, with evidence for each: command output, log line, screenshot, test result. An item without evidence counts as not done.
3. For a mobile release, count the remaining builds per platform with `eas account:usage`. In the last week of the month, if fewer than 3 builds remain on a platform, no new-feature build is taken; the rest is kept for bug fixes.
4. Think of users on old versions: what the new flow shows to an old build, whether a server-driven notice can explain it, and if forced update is switched on, whether the new version is live for everyone in the store.
5. Write the rollback path: to which revision, with which command, whether data rolls back.

## Result

```
Recommendation: SHIP / NO SHIP / CONDITIONAL
Gaps: <item, impact, time to fix>
Evidence: <item: evidence>
Rollback: <path>
Needs owner approval: <list>
```

## Take care

- Do not propose switching on forced update before the Play rollout is at 100% and the App Store version is live.
- Make sure the forced screen was seen on a real phone in the previous store build.
- Propose releasing on a weekday at the start of working hours; never on Friday evening or before a holiday.
