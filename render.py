#!/usr/bin/env python

import time

from datetime import datetime

import feedparser
import yaml

from jinja2 import Template


def chunk_list(lst, rows):
    return list((lst[i:i+rows] for i in range(0, len(lst), rows)))


def new_post(post_time, new_post_age_threshold):
    if post_time is None:
        parsed_post_time = time.mktime(datetime.now().timetuple())
    else:
        parsed_post_time = time.mktime(post_time)

    current_time = time.mktime(datetime.now().timetuple())
    if abs(current_time - parsed_post_time) < new_post_age_threshold:
        return True
    else:
        return False


def get_feeds(config):
    feeds = chunk_list(config['feeds'], config['rows'])

    for group in feeds:
        for feed in group:
            feed['posts'] = []
            feed_data = feedparser.parse(feed['rss_url'])
            for entry in feed_data.entries[:config['posts']]:
                new = new_post(
                    entry.get('published_parsed'),
                    config['new_post_age_threshold']
                )
                feed['posts'].append({
                    'title': entry['title'],
                    'link': entry['link'],
                    'new': new
                })
            print(f"added {len(feed['posts'])} posts for {feed['name']}")

    return feeds


def render_template(data):
    template = Template(open('template.html.j2').read())
    with open('index.html', 'w') as f:
        f.write(template.render(data=data))


def main():
    with open('config.yaml', 'r') as stream:
        config = yaml.safe_load(stream)

    data = {}
    data['title'] = config['site_title']
    data['feeds'] = get_feeds(config)
    data['extra_links'] = chunk_list(config['extra_links'], config['rows'])

    render_template(data)


if __name__ == "__main__":
    main()
