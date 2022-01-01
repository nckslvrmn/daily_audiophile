# rss_grid

## Introduction

This repository contains a rendering script as well as a template for an RSS landing page. The concept is to create a config file containing all of the RSS feeds you want displayed and then render them to a landing page. Because this is a script rendering an HTML, it can be hosted and run asynchronously and then the website simply needs to be the rendered HTML file. The original design of the template was inspired by [daily audiophile](https://www.dailyaudiophile.com/)

## Dependencies

Python 3.6+ and pip are required. When those dependencies are met, you can `pip install -r requirements.txt` the rest of the Python dependencies.

## Configuration

In the repository is an example config file called `config.yaml.example`. Make a copy called `config.yaml` and then you can proceed to configure the site with a few options. The main global options are:
| Option | Purpose | Default |
| ------ | ------- | ------- |
| site_title | gives the website its title | My RSS Feeds |
| rows | tells the template how many rows of feeds to create in the final html | 3 |
| posts | tells the script how many posts to display per feed | 5 |
| new_post_age_threshold | tells the template whether to add a visual indicator for new posts | 604800 (1 day in seconds) |

From there, there are two data sections to fill out. First is the `feeds` list. Each element of the list should look like this:
```
feeds:
  - name: "my favorite RSS feed"
    front_page: "https://my_fav_rss.com/frontpage"
    rss_url: "https://my_fav_rss.com/rss.xml"
```
The `front_page` key is used as a link for the feed title. The `rss_url` key is the rss url from which the articles are actually pulled. Most RSS and Atom feed versions are supported.

The second data section is the `extra_links` list. This list is meant for presenting a number of sites that either may not have RSS, or for if you simply dont want to display posts. Each element of this list should look like this:
```
extra_links:
  - name: "A cool site"
    link: "https://a_cool_site.com"
```

## Usage

Once configured, run the `./render.py` script and it will write out a file called `index.html`. You can then take this and host it somewhere. This script also makes sense to run on a schedule so the output HTML file will stay up to date. I run mine in AWS Lambda, and then publish the file to a Cloudfront fronted S3 Bucket.
