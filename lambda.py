#!/usr/bin/env python

import time

from datetime import datetime

import boto3
import feedparser
import yaml

from jinja2 import Template


class RSSGrid:
    def __init__(self):
        with open("config.yaml", "r") as stream:
            self.config = yaml.safe_load(stream)

    def __new_post(self, post_time):
        parsed_post_time = time.mktime(post_time)
        current_time = time.mktime(datetime.now().timetuple())
        return abs(current_time - parsed_post_time) < self.config["new_post_age_threshold"]

    def get_feeds(self):
        for feed in self.config["feeds"]:
            feed["posts"] = []
            feed_data = feedparser.parse(feed["rss_url"])
            for entry in feed_data.entries[: self.config["posts"]]:
                feed["posts"].append(
                    {
                        "title": entry["title"],
                        "link": entry["link"],
                        "new": self.__new_post(entry.get("published_parsed", datetime.now().timetuple())),
                    }
                )
            print(f"added {len(feed['posts'])} posts for {feed['name']}")

    def render_template(self):
        template = Template(open("template.html.j2").read())
        with open("/tmp/index.html", "w") as f:
            f.write(template.render(data=self.config))
        print("template rendered locally")

    def upload_rendered(self):
        s3 = boto3.client("s3")
        s3.upload_file("/tmp/index.html", self.config["bucket"], "index.html", ExtraArgs={"ContentType": "text/html"})
        print("rendered file uploaded to s3")


def handler(*_):
    rg = RSSGrid()
    rg.get_feeds()
    rg.render_template()
    rg.upload_rendered()


if __name__ == "__main__":
    handler()
