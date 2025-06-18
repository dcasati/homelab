#!/usr/bin/env python3

import feedparser
import re
import os
import sys

# Configurable Feed URL and Area ID
FEED_URL = os.getenv("FEED_URL") or (sys.argv[1] if len(sys.argv) > 1 else None)
AREA = os.getenv("ALERT_AREA", "unknown")

if not FEED_URL:
    print("Error: Feed URL not specified via FEED_URL env or CLI arg", file=sys.stderr)
    sys.exit(1)

feed = feedparser.parse(FEED_URL)

if feed.entries:
    entry = feed.entries[0]
    title = entry.title
    link = entry.link
    summary = entry.get("summary", "").strip()
else:
    title = "No alerts"
    link = ""
    summary = ""

# Clean text: remove quotes and commas
def sanitize(text):
    return re.sub(r'[",]', '', text.replace("\n", " ")).strip()

title = sanitize(title)
link = sanitize(link)
summary = sanitize(summary)

# Influx line protocol
print(f'rss_weather_alert,area={AREA} title=\"{title}\",link=\"{link}\",summary=\"{summary}\"')

