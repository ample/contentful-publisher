#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

class Republish

  def initialize
    @client = Contentful::Management::Client.new(ENV['CONTENTFUL_MANAGEMENT_TOKEN'])
    @space = @client.environments(ENV['CONTENTFUL_SPACE_ID']).find('master')
    @types = %w(article episode message song video)
    @entries = {}
  end

  def process!
    @types.each do |type|
      entries = fetch_entries(type)
      entries.each do |entry|
        STDOUT.write '.' if entry.publish
      end
      STDOUT.write "\n\n"
    end
  end

  private

    def fetch_entries(type)
      @entries[type] ||= []
      params = {
        limit: 1000,
        skip: @entries[type].count,
        content_type: type
      }
      STDOUT.write "Querying '#{type}' with the following parameters...\n"
      STDOUT.write "#{params.to_json}\n"

      this_page = @space.entries.all(params).to_a
      @entries[type].concat(this_page)

      if this_page.size == 1000
        fetch_entries(type)
      else
        STDOUT.write "#{@entries[type].count} returned for #{type}.\n\n"
        @entries[type]
      end
    end

end

Republish.new().process!