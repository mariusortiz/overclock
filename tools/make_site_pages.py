#!/usr/bin/env python3
"""Generates the website's extra pages at each publication (see build.yml):

  - site/c/<card id>.html: a page per card, with its picture as the preview
    when the link is shared (Open Graph), from site/cards.json;
  - site/nouveautes.html: the update log, from the repository's history
    (one entry per commit since LOG_START, grouped by day, technical
    commits left out);
  - sitemap.xml and robots.txt at the root;
  - share previews (Open Graph) on the trailer and episode pages, which their
    own workflows publish without them.

    python3 tools/make_site_pages.py --site <published dir> --repo <repository>
"""
import argparse
import glob
import html
import json
import os
import re
import subprocess

URL = "https://overclock.randomlabs.dev"
MONTHS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août",
          "septembre", "octobre", "novembre", "décembre"]
# Commits that change nothing a player sees.
TECHNICAL = re.compile(r"^(CI\b|Build\b|Merge\b|Revert\b|.*fichiers d'import|.*\bworkflow)", re.IGNORECASE)
# The log starts after this commit: the subjects before it are in English.
LOG_START = "9e70584"

STYLE = """
  @font-face { font-family: "Kenney Mini Square Mono"; src: url("%(root)skenney_mini_square_mono.ttf") format("truetype"); font-display: swap; }
  :root { --bg: #060b2a; --panel: #0c1440; --line: #1d2a6b; --text: #e8ecff; --muted: #9aa6d8; --cyan: #29d4ff; --magenta: #ff3df2;
          --title: "Kenney Mini Square Mono", ui-monospace, monospace; }
  * { box-sizing: border-box; }
  body { margin: 0; background: var(--bg); color: var(--text); font: 17px/1.55 system-ui, -apple-system, "Segoe UI", sans-serif; }
  a { color: var(--cyan); }
  h1, h2, .tag { font-family: var(--title); font-weight: 400; letter-spacing: 0.04em; text-transform: uppercase; }
  .wrap { width: min(860px, 100%% - 32px); margin-inline: auto; padding-block: 32px 56px; }
  nav { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 24px; }
"""


def meta(title, description, image, path, kind="website"):
    tags = [
        f'<meta name="description" content="{html.escape(description)}">',
        f'<meta property="og:type" content="{kind}">',
        '<meta property="og:site_name" content="Overclock">',
        f'<meta property="og:title" content="{html.escape(title)}">',
        f'<meta property="og:description" content="{html.escape(description)}">',
        f'<meta property="og:image" content="{image}">',
        f'<meta property="og:url" content="{URL}/{path}">',
        '<meta name="twitter:card" content="summary_large_image">',
    ]
    return "\n".join(tags)


def card_pages(site):
    cards = json.load(open(os.path.join(site, "site", "cards.json"), encoding="utf-8"))
    out = os.path.join(site, "site", "c")
    os.makedirs(out, exist_ok=True)
    for card in cards:
        ability = card.get("ability") or ["", ""]
        description = f"{card['rarity_name']} · série {card['series']} · {card['number']}. {ability[1]}".strip()
        title = f"{card['name']} · carte Overclock"
        image = f"{URL}/site/img/cards/{card['id']}.jpg"
        page = f"""<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
{meta(title, description, image, f"site/c/{card['id']}.html", "article")}
<link rel="icon" href="../../index.icon.png">
<style>{STYLE % {"root": "../"}}
  .card {{ display: grid; grid-template-columns: minmax(0, 320px) 1fr; gap: 28px; align-items: start; }}
  .card img {{ width: 100%; border: 4px solid #{card['color']}; }}
  h1 {{ margin: 0 0 8px; color: var(--cyan); }}
  .tag {{ display: inline-block; padding: 3px 10px; background: #{card['color']}; color: var(--bg); font-size: 0.85rem; }}
  dl {{ display: grid; grid-template-columns: auto 1fr; gap: 4px 16px; color: var(--muted); }}
  dd {{ margin: 0; color: var(--text); }}
  @media (max-width: 640px) {{ .card {{ grid-template-columns: 1fr; }} }}
</style>
</head>
<body>
  <div class="wrap">
    <nav><a href="../codex.html#cards">Toutes les cartes</a><a href="../">Le site</a><a href="../../">Jouer</a></nav>
    <div class="card">
      <img src="../img/cards/{card['id']}.jpg" alt="{html.escape(card['name'])}">
      <div>
        <span class="tag">{html.escape(card['rarity_name'])}</span>
        <h1>{html.escape(card['name'])}</h1>
        <p>{html.escape(ability[0])}{' : ' if ability[0] and ability[1] else ''}{html.escape(ability[1])}</p>
        <dl><dt>Série</dt><dd>{html.escape(card['series'])}</dd><dt>Numéro</dt><dd>{card['number']}</dd>
          <dt>Puissance</dt><dd>{card['power']}</dd></dl>
        <p>On l'obtient dans les boosters du jeu, ou par échange de code avec un ami.</p>
      </div>
    </div>
  </div>
</body>
</html>
"""
        with open(os.path.join(out, card["id"] + ".html"), "w", encoding="utf-8") as f:
            f.write(page)
    return [f"site/c/{card['id']}.html" for card in cards]


def changelog(site, repo):
    log = subprocess.run(["git", "-C", repo, "log", f"{LOG_START}..HEAD", "--date=short", "--pretty=%ad%x09%s"],
                         capture_output=True, text=True, check=True).stdout
    days = {}
    for line in log.splitlines():
        date, _, subject = line.partition("\t")
        if not subject or TECHNICAL.match(subject):
            continue
        days.setdefault(date, []).append(subject)
    sections = []
    for date in sorted(days, reverse=True):
        year, month, day = (int(part) for part in date.split("-"))
        items = "".join(f"<li>{html.escape(subject)}</li>" for subject in days[date])
        sections.append(f'<section><h2>{day} {MONTHS[month - 1]} {year}</h2><ul>{items}</ul></section>')
    title = "Nouveautés · Overclock"
    page = f"""<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
{meta(title, "Toutes les nouveautés d'Overclock, jour après jour.", URL + "/site/img/hero-large.jpg", "site/nouveautes.html")}
<link rel="icon" href="../index.icon.png">
<style>{STYLE % {"root": ""}}
  h1 {{ margin: 0 0 8px; color: var(--cyan); font-size: clamp(1.8rem, 5vw, 2.6rem); }}
  h2 {{ margin: 32px 0 8px; color: var(--magenta); font-size: 1.1rem; }}
  ul {{ margin: 0; padding-left: 20px; }}
  li {{ margin-block: 4px; }}
  .lead {{ color: var(--muted); }}
</style>
</head>
<body>
  <div class="wrap">
    <nav><a href="./">Le site</a><a href="codex.html">Codex</a><a href="../">Jouer</a></nav>
    <h1>Nouveautés</h1>
    <p class="lead">Ce qui a changé dans le jeu, le plus récent en haut.</p>
    {"".join(sections) or "<p>Rien pour l'instant.</p>"}
  </div>
</body>
</html>
"""
    with open(os.path.join(site, "site", "nouveautes.html"), "w", encoding="utf-8") as f:
        f.write(page)


def previews(site):
    """Share previews on the pages the trailer and anime workflows publish."""
    pages = [("trailer.html", "Trailer d'Overclock", "Le trailer du jeu : arènes, boss, héros, courses, combat.", "trailer.jpg")]
    for path in glob.glob(os.path.join(site, "anime*.html")):
        name = os.path.basename(path)
        text = open(path, encoding="utf-8").read()
        found = re.search(r"<title>(.*?)</title>", text)
        pages.append((name, found.group(1) if found else "L'anime Overclock", "Un épisode de l'anime Overclock.",
                      name.replace(".html", ".jpg")))
    for name, title, description, image in pages:
        path = os.path.join(site, name)
        if not os.path.exists(path):
            continue
        text = open(path, encoding="utf-8").read()
        if 'property="og:title"' in text:
            continue
        tags = meta(title, description, f"{URL}/{image}", name, "video.other")
        text = text.replace("</title>", "</title>\n" + tags, 1)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
    return [name for name, *_ in pages if os.path.exists(os.path.join(site, name))]


def sitemap(site, paths):
    urls = "".join(f"<url><loc>{URL}/{html.escape(path)}</loc></url>" for path in paths)
    with open(os.path.join(site, "sitemap.xml"), "w", encoding="utf-8") as f:
        f.write(f'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">{urls}</urlset>')
    with open(os.path.join(site, "robots.txt"), "w", encoding="utf-8") as f:
        f.write(f"User-agent: *\nAllow: /\nSitemap: {URL}/sitemap.xml\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--site", required=True)
    parser.add_argument("--repo", default=".")
    args = parser.parse_args()
    paths = ["", "site/", "site/codex.html", "site/nouveautes.html", "site/boutique.html"]
    paths += card_pages(args.site)
    changelog(args.site, args.repo)
    paths += previews(args.site)
    sitemap(args.site, paths)
    print(f"site pages: {len(paths)} urls")


if __name__ == "__main__":
    main()
