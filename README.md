# daily_audiophile

## Introduction
This repository contains a rendering script as well as a template for the daily_audiophile page. The original design of the template was inspired by [daily audiophile](https://www.dailyaudiophile.com/)

## Dependencies
Python 3.12+ and pip are required. When those dependencies are met, you can `pip install -r requirements.txt` the rest of the Python dependencies.

## Usage
Run the `./render` script and it will write out a file called `rendered/index.html` for local testing. Runs in Github Actions and publishes to Github Pages otherwise.