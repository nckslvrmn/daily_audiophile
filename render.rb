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

def get_feed(feed_url, timeout)
  3.times do
    begin
      feed_content = nil

      URI.open(feed_url, read_timeout: timeout, open_timeout: timeout) do |f|
        feed_content = f.read
      end

      feed = RSS::Parser.parse(feed_content, false)
      return feed if feed && feed.items.any?
    rescue => e
      puts "Error while fetching feed: #{feed_url}: #{e}"
      next
    end
  end

  nil
end

data = YAML.load_file('feeds.yaml')

data['feeds'].each do |name, info|
  info['posts'] = []
  feed_data = get_feed(info['feed'], info['timeout'] || 10)

  if feed_data.nil?
    data['feeds'].delete(name)
    next
  end

  feed_data.items.each do |entry|
    next if info['posts'].any? { |post| post['title'] == entry.title }

    post_date = case entry
                when RSS::Atom::Feed::Entry
                  entry.published ? Time.parse(entry.published.to_s).utc : Time.now.utc
                else
                  entry.pubDate ? Time.parse(entry.pubDate.to_s).utc : Time.now.utc
                end

    info['posts'] << {
      'title' => CGI.unescapeHTML(entry.title.to_s.gsub(/<[^>]*>/, '')).strip,
      'link' => entry.link.respond_to?(:href) ? entry.link.href : entry.link.to_s,
      'date' => post_date,
      'new' => (Time.now.utc - post_date).abs < 86400
    }

    if info['posts'].length >= 5
      info['posts'].sort! { |a, b| b['date'] <=> a['date'] }
      break
    end
  end

  puts "posts captured for #{name}"
end

template = ERB.new(File.read('template.html.erb'))
html = template.result(binding)

Dir.mkdir('rendered') unless Dir.exist?('rendered')

File.write('rendered/index.html', html)
puts "template rendered"
