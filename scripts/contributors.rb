#!/usr/bin/env ruby
# # frozen_string_literal: true

require "bundler/inline"
require 'bundler/ui'

gemfile(true, ui: Bundler::UI::Silent.new) do
  source 'https://rubygems.org'

  gem 'httparty'
  gem 'inifile'
end

require 'date'
require 'httparty'
require 'inifile'

BASE_URL = 'https://api.transifex.com'
ORGANIZATION_SLUG = 'discourse'
PROJECT_SLUG = 'discourse-org'

def credentials
  @credentials ||= begin
    file = IniFile.load(File.expand_path('~/.transifexrc'))
    data = file['https://www.transifex.com']
    { username: data['username'], password: data['password'] }
  end
end

PAST_DAYS = 180
LANGUAGES = %w{fr_FR de zh_CN es ru pt_BR ja nl fa_IR ar}

class TransifexReport
  include HTTParty

  base_uri BASE_URL
  basic_auth credentials[:username], credentials[:password]

  def self.activity(language, from_date)
    params = { language_code: language, from_date: from_date, project_slug: PROJECT_SLUG }
    get("/organizations/#{ORGANIZATION_SLUG}/reports/activity/", query: params).parsed_response
  end
end

from_date = (Date.today - PAST_DAYS).to_s

LANGUAGES.each do |language|
  users = TransifexReport.activity(language, from_date).map do |username, stats|
    {
      username: username,
      new_words: stats[language]["new"],
      edited_words: stats[language]["edit"]
    }
  end.sort_by { |user| -user[:new_words] - user[:edited_words] }

  puts "", "### #{language}", ""
  puts "| Username | New words | Edited words |"
  puts "|----------|----------:|-------------:|"

  users.each do |user|
    username = user[:username]
    user_link = "https://www.transifex.com/user/profile/#{username}/"

    puts "| [#{username}](#{user_link}) | #{user[:new_words]} | #{user[:edited_words]} |"
  end
end

