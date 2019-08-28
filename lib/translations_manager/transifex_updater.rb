# frozen_string_literal: true

require 'psych'
require 'set'
require 'fileutils'
require_relative 'common'
require_relative 'locale_file_cleaner'
require_relative 'locales'
require_relative 'character_replacer'

module TranslationsManager
  class TransifexUpdater
    include Common

    YML_FILE_HEADER = <<~HEADER
      # encoding: utf-8
      #
      # Never edit this file. It will be overwritten when translations are pulled from Transifex.
      #
      # To work with us on translations, join this project:
      # https://www.transifex.com/projects/p/discourse-org/
    HEADER

    def initialize(yml_dirs, yml_file_prefixes, *languages)
      check_tx_client

      @yml_dirs = yml_dirs
      @yml_file_prefixes = yml_file_prefixes
      @languages = (languages.empty? ? SUPPORTED_LOCALES : languages).select { |x| x != 'en' }.sort
    end

    def perform(pull: true, update_tx_config: true, tx_config_filename: '.tx/config', language_map: {})
      @additional_language_map = language_map

      update_tx_config(tx_config_filename) if update_tx_config
      create_missing_locale_files
      pull_translations if pull

      @yml_dirs.each do |dir|
        @yml_file_prefixes.each do |prefix|
          mapped_languages.each do |language|
            filename = yml_path_if_exists(dir, prefix, language)

            if filename
              replace_invalid_characters(filename)
              remove_empty_translations(filename)
              update_file_header(filename, language)
            end
          end
        end
      end
    end

    def create_missing_locale_files
      # ensure that all locale files exists. tx doesn't create missing locale files during pull
      @yml_dirs.each do |dir|
        @yml_file_prefixes.each do |prefix|
          next unless yml_path_if_exists(dir, prefix, 'en')

          @languages.each do |language|
            filename = yml_path(dir, prefix, language)
            FileUtils.touch(filename) unless File.exists?(filename)
          end
        end
      end
    end

    def pull_translations
      puts 'Pulling new translations...', ''
      command = "tx pull --mode=developer --language=#{@languages.join(',')} --force --parallel"

      execute_tx_command(command)
    end

    def remove_empty_translations(filename)
      TranslationsManager::LocaleFileCleaner.new(filename).clean!
    end

    def replace_invalid_characters(filename)
      TranslationsManager::CharacterReplacer.replace_in_file!(filename)
    end

    # Add comments to the top of files and replace the language (first key in YAML file)
    def update_file_header(filename, language)
      lines = read_yaml_and_update_language_key(filename, language)

      File.open(filename, 'w+') do |f|
        f.puts(YML_FILE_HEADER, '') unless lines[0][0] == '#'
        f.puts(lines)
      end
    end

    def mapped_languages
      language_map = LANGUAGE_MAP.merge(@additional_language_map)

      @languages.map do |language|
        language_map.fetch(language, language)
      end
    end
  end
end
