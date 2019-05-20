#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"
require 'bundler/ui'

gemfile(true, ui: Bundler::UI::Silent.new) do
  source 'https://rubygems.org'

  gem 'translations-manager', git: 'https://github.com/discourse/translations-manager.git'
end

require 'translations_manager/character_replacer'
require 'translations_manager/common'
require 'translations_manager/locale_file_cleaner'

class TransifexPuller
  include TranslationsManager::Common

  def self.pull
    puller = TransifexPuller.new

    puller.setup_tx_client
    puller.pull_files
    puller.modify_files
  end

  def setup_tx_client
    check_tx_client
    execute_tx_command('tx config mapping-remote https://www.transifex.com/discourse/discourse-org')
  end

  def pull_files
    execute_tx_command('tx pull --all --parallel --source')
  end

  def modify_files
    puts '', 'Cleaning up YML files...'

    Dir.glob('translations/**/*.yml').each do |path|
      next if File.basename(path) == 'en.yml'

      TranslationsManager::CharacterReplacer.replace_in_file!(path)
      TranslationsManager::LocaleFileCleaner.new(path).clean!
    end

    puts '', 'Done!'
  end
end

TransifexPuller.pull
