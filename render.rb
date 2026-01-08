#!/usr/bin/env ruby

require 'cgi'
require 'date'
require 'erb'
require 'net/http'
require 'open-uri'
require 'rss'
require 'time'
require 'yaml'

$stdout.sync = true

MAX_RETRIES = 3
DEFAULT_TIMEOUT = 10
SECONDS_IN_DAY = 86400
MAX_POSTS_PER_FEED = 5

def validate_feed_content(content, feed_url)
  return false if content.nil? || content.empty?

  # Check if content looks like HTML error page
  if content.strip.start_with?('<!DOCTYPE html>', '<html')
    puts "Feed returned HTML instead of RSS/Atom: #{feed_url}"
    return false
  end

  # Check if content looks like XML
  unless content.strip.start_with?('<?xml', '<rss', '<feed')
    puts "Feed content doesn't appear to be XML: #{feed_url}"
    return false
  end

  # Check for common malformed XML patterns
  if content.include?('<script') && !content.include?('<![CDATA[')
    puts "Feed contains unescaped script tags: #{feed_url}"
    return false
  end

  true
end

def get_feed(feed_url, timeout)
  MAX_RETRIES.times do
    begin
      feed_content = nil
      content_type = nil

      URI.open(feed_url, read_timeout: timeout, open_timeout: timeout) do |f|
        content_type = f.content_type
        feed_content = f.read
      end

      # Validate content type
      unless content_type&.match?(/xml|rss|atom|application\/xml|text\/xml/)
        puts "Invalid content-type '#{content_type}' for feed: #{feed_url}"
        next
      end

      # Validate content before parsing
      unless validate_feed_content(feed_content, feed_url)
        next
      end

      feed = RSS::Parser.parse(feed_content, false)
      return feed if feed && feed.items.any?
    rescue RSS::NotWellFormedError => e
      puts "Malformed XML in feed: #{feed_url}"
      puts "  #{e.message.lines.first&.strip}"
      return nil # Don't retry on XML errors
    rescue OpenURI::HTTPError => e
      puts "HTTP error fetching feed: #{feed_url}: #{e.message}"
      next
    rescue Timeout::Error => e
      puts "Timeout fetching feed: #{feed_url}"
      next
    rescue SocketError => e
      puts "Network error fetching feed: #{feed_url}: #{e.message}"
      next
    rescue RSS::Error => e
      puts "RSS parsing error for feed: #{feed_url}: #{e.message}"
      return nil # Don't retry on parsing errors
    rescue => e
      puts "Unexpected error fetching feed: #{feed_url}: #{e.class} - #{e.message}"
      next
    end
  end

  nil
end

def extract_post_date(entry)
  case entry
  when RSS::Atom::Feed::Entry
    entry.published ? Time.parse(entry.published.to_s).utc : Time.now.utc
  else
    entry.pubDate ? Time.parse(entry.pubDate.to_s).utc : Time.now.utc
  end
end

def process_feed(name, info)
  info['posts'] = []
  feed_data = get_feed(info['feed'], info['timeout'] || DEFAULT_TIMEOUT)

  return nil if feed_data.nil?

  feed_data.items.each do |entry|
    break if info['posts'].length >= MAX_POSTS_PER_FEED
    next if info['posts'].any? { |post| post['title'] == entry.title }

    post_date = extract_post_date(entry)

    info['posts'] << {
      'title' => CGI.unescapeHTML(entry.title.to_s.gsub(/<[^>]*>/, '')).strip,
      'link' => entry.link.respond_to?(:href) ? entry.link.href : entry.link.to_s,
      'date' => post_date,
      'new' => (Time.now.utc - post_date).abs < SECONDS_IN_DAY
    }
  end

  info['posts'].sort! { |a, b| b['date'] <=> a['date'] }
  puts "posts captured for #{name}"

  [name, info]
end

data = YAML.load_file('feeds.yaml')

threads = []
results = []
mutex = Mutex.new

data['feeds'].each do |name, info|
  threads << Thread.new do
    result = process_feed(name, info)
    mutex.synchronize { results << result }
  end
end

threads.each(&:join)

data['feeds'] = results.compact.to_h

template = ERB.new(File.read('template.html.erb'))
html = template.result(binding)

Dir.mkdir('rendered') unless Dir.exist?('rendered')

File.write('rendered/index.html', html)
puts "template rendered"
