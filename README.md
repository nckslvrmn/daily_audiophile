# Daily Audiophile 🎧

A modern RSS feed aggregator for audiophiles, bringing together the latest news, reviews, and articles from the world's leading high-fidelity audio publications in one beautifully simple interface.

## 🎵 About

Daily Audiophile is inspired by the original [Daily Audiophile](https://www.dailyaudiophile.com/) and serves as a centralized hub for audiophile content. It automatically fetches and aggregates the latest posts from over 40 high-end audio publications, making it easy to stay up-to-date with the audiophile community.

### Key Features

- **Real-time RSS aggregation** from 40+ leading audiophile publications
- **Clean, minimalist interface** optimized for readability
- **"NEW" indicators** for posts published within the last 24 hours
- **Automatic updates** via GitHub Actions
- **Mobile-responsive design** using Bootstrap 5
- **Static site generation** for fast loading and easy hosting

## 🚀 Getting Started

### Prerequisites

- Ruby 3.0 or higher

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/daily_audiophile.git
cd daily_audiophile
```

2. Install Ruby dependencies:
```bash
bundle install
```

### Running Locally

Execute the render script to generate the static HTML page:

```bash
./render.rb
```

Or:

```bash
ruby render.rb
```

This will:
1. Fetch the latest RSS feeds from all configured sources
2. Process and aggregate the posts
3. Generate a static HTML page at `rendered/index.html`
4. You can then open `rendered/index.html` in your browser to view the aggregated content

## 📋 Configuration

### Adding New Feeds

Edit `feeds.yaml` to add or modify RSS sources:

```yaml
feeds:
  Publication Name:
    home: https://example-audiophile-site.com
    feed: https://example-audiophile-site.com/rss
    timeout: 10  # optional, defaults to 10 seconds
```

### Extra Links

Static links to sites without RSS feeds can be added to the `extra_links` section:

```yaml
extra_links:
  Site Name: https://example-site.com
```

## 🛠️ Technical Details

### Architecture

- **`render.rb`**: Main Ruby script that fetches RSS feeds and generates HTML
- **`feeds.yaml`**: Configuration file containing all RSS feed URLs and site information
- **`template.html.erb`**: ERB template for generating the final HTML page
- **`rendered/index.html`**: Generated static HTML output

### How It Works

1. The script reads feed configurations from `feeds.yaml`
2. For each feed, it attempts to fetch and parse RSS/Atom content (with 3 retry attempts)
3. Extracts the 5 most recent posts from each feed
4. Marks posts published within the last 24 hours as "NEW"
5. Renders all data using the ERB template
6. Outputs a static HTML file ready for deployment

### GitHub Actions Deployment

The project includes GitHub Actions workflow for automatic updates and deployment to GitHub Pages. The site refreshes periodically to ensure content stays current.

## 📰 Included Publications

The aggregator includes feeds from premier audiophile publications such as:

- **Stereophile** - Industry-leading high-end audio magazine
- **The Absolute Sound** - Premium audio equipment reviews
- **Analog Planet** - Vinyl and analog audio coverage
- **Darko.Audio** - Modern audiophile perspectives
- **Part-Time Audiophile** - In-depth equipment reviews
- **Head-Fi** - Headphone enthusiast community
- And 35+ more...

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Add new audiophile RSS feeds
- Improve the UI/UX design
- Fix bugs or improve performance
- Add new features

Please submit a pull request with your changes.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Original design inspiration from [Daily Audiophile](https://www.dailyaudiophile.com/)
- All the fantastic audiophile publications that provide RSS feeds
- The Ruby community for excellent RSS parsing libraries

---

*Built with ❤️ for the audiophile community*
