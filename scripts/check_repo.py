#!/usr/bin/env python3
"""Smoke test for the repository: manifests, skills, references, links and names.

    python3 scripts/check_repo.py

Exits non-zero and lists every problem. Needs only the Python standard library.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GUIDE = ROOT / "guide" / "project-setup-guide.md"
TURKISH = re.compile(r"[çğıöşüÇĞİÖŞÜ]")
problems = []


def fail(msg):
    problems.append(msg)


def frontmatter(text):
    """Reads the name and description of a SKILL.md (single line or a '>-' folded block)."""
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None
    fields, key = {}, None
    for line in m.group(1).split("\n"):
        kv = re.match(r"([a-z_-]+):\s*(.*)$", line)
        if kv and not line.startswith(" "):
            key, value = kv.group(1), kv.group(2)
            fields[key] = "" if value in (">-", ">", "|", "|-") else value
        elif key and line.startswith("  "):
            fields[key] = (fields[key] + " " + line.strip()).strip()
    return fields


def check_manifests():
    market = json.loads((ROOT / ".claude-plugin" / "marketplace.json").read_text())
    for key in ("name", "owner", "plugins"):
        if key not in market:
            fail(f"marketplace.json: missing '{key}'")
    for plugin in market.get("plugins", []):
        src = ROOT / plugin["source"]
        manifest = src / ".claude-plugin" / "plugin.json"
        if not manifest.exists():
            fail(f"marketplace.json: plugin '{plugin['name']}' source has no plugin.json")
            continue
        data = json.loads(manifest.read_text())
        if data.get("name") != plugin["name"]:
            fail(f"{manifest.relative_to(ROOT)}: name '{data.get('name')}' differs from marketplace entry '{plugin['name']}'")
        if not (src / "skills").is_dir():
            fail(f"{plugin['name']}: no skills/ folder")
    return market


def check_skills(market):
    guide = GUIDE.read_text()
    sets = {}
    for plugin in market.get("plugins", []):
        skills = ROOT / plugin["source"] / "skills"
        sets[plugin["name"]] = {}
        for folder in sorted(p for p in skills.iterdir() if p.is_dir()):
            skill_md = folder / "SKILL.md"
            rel = skill_md.relative_to(ROOT)
            if not skill_md.exists():
                fail(f"{folder.relative_to(ROOT)}: no SKILL.md")
                continue
            text = skill_md.read_text()
            fm = frontmatter(text)
            if not fm:
                fail(f"{rel}: no frontmatter")
                continue
            if fm.get("name") != folder.name:
                fail(f"{rel}: name '{fm.get('name')}' differs from folder '{folder.name}'")
            desc = fm.get("description", "")
            if not desc or len(desc) > 1024:
                fail(f"{rel}: description is empty or longer than 1024 characters ({len(desc)})")
            refs = folder / "references"
            have = {p.name for p in refs.glob("*.md")} if refs.is_dir() else set()
            sets[plugin["name"]][folder.name] = have
            for name in sorted(set(re.findall(r"references/([a-z0-9-]+\.md)", text))):
                if name not in have:
                    fail(f"{rel}: mentions references/{name}, which does not exist")
            for ref in sorted(refs.glob("*.md")) if refs.is_dir() else []:
                body = ref.read_text()
                if ref.name == "full-guide.md":
                    if body != guide:
                        fail(f"{ref.relative_to(ROOT)}: differs from guide/project-setup-guide.md")
                    continue
                body = re.sub(r"^<!--.*?-->\n\n", "", body, count=1, flags=re.S).strip()
                if body not in guide:
                    fail(f"{ref.relative_to(ROOT)}: is not an exact excerpt of the current guide")
    names = list(sets.values())
    for other in names[1:]:
        if other != names[0]:
            fail("plugins differ in skill names or reference files: " + ", ".join(sets))


def check_links():
    for readme in ("README.md", "README.en.md"):
        text = (ROOT / readme).read_text()
        anchors = set(re.findall(r'<a id="([^"]+)"', text))
        for target in re.findall(r'(?:href|src)="([^"#:]+)"', text) + re.findall(r"\]\(([^)#:]+)\)", text):
            if not (ROOT / target).exists():
                fail(f"{readme}: link target '{target}' does not exist")
        for anchor in re.findall(r'href="#([^"]+)"', text) + re.findall(r"\]\(#([^)]+)\)", text):
            if anchor not in anchors:
                fail(f"{readme}: anchor '#{anchor}' does not exist")
    guide = GUIDE.read_text()
    ids = set(re.findall(r'<a id="([^"]+)"', guide))
    dead = sorted({a for a in re.findall(r"\]\(#([^)]+)\)", guide)} - ids)
    if dead:
        fail(f"guide/project-setup-guide.md: {len(dead)} internal links without a target, e.g. {dead[:5]}")


def check_names():
    for path in ROOT.rglob("*"):
        if ".git" in path.parts:
            continue
        if TURKISH.search(path.name):
            fail(f"Turkish characters in a file or folder name: {path.relative_to(ROOT)}")


if __name__ == "__main__":
    market = check_manifests()
    check_skills(market)
    check_links()
    check_names()
    if problems:
        print(f"{len(problems)} problem(s):")
        for p in problems:
            print(" -", p)
        sys.exit(1)
    print("All checks passed.")
