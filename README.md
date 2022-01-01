# rss_grid

## Introduction
This repository contains a rendering script as well as a template for an RSS landing page. The concept is to create a config file containing all of the RSS feeds you want displayed and then render them to a landing page. Because this is a script rendering an HTML, it can be hosted and run asynchronously and then the website simply needs to be the rendered HTML file. The original design of the template was inspired by [daily audiophile](https://www.dailyaudiophile.com/)

## Dependencies
Python 3.6+ and pip are required. When those dependencies are met, you can `pip install -r requirements.txt` the rest of the Python dependencies.

## Configuration
In the repository is an example config file called `example_config.yaml`. Make a copy called `config.yaml` and then you can proceed to configure the site with a few options. The example configuration contains documentation for what each option does and how it should be structured.

## Usage
Once configured, run the `./render.py` script and it will write out a file called `index.html`. You can then take this and host it somewhere. This script also makes sense to run on a schedule so the output HTML file will stay up to date. I run mine in AWS Lambda, and then publish the file to a Cloudfront fronted S3 Bucket.
