require 'open3'
require 'psych'
require 'set'
require 'fileutils'
require_relative 'common'
require_relative 'locale_file_cleaner'
require_relative 'locales'
require_relative 'unicode_surrogate_replacer'

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

    def perform(pull: true, tx_config_filename: '.tx/config')
      update_tx_config(tx_config_filename)
      create_missing_locale_files
      pull_translations if pull

      @yml_dirs.each do |dir|
        @yml_file_prefixes.each do |prefix|
          @languages.each do |language|
            filename = yml_path_if_exists(dir, prefix, language)

            if filename
              replace_unicode_surrogates(filename)
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
      command = "tx pull --mode=developer --language=#{@languages.join(',')} --force"

      execute_tx_command(command)
    end

    def remove_empty_translations(filename)
      TranslationsManager::LocaleFileCleaner.new(filename).clean!
    end

    def replace_unicode_surrogates(filename)
      TranslationsManager::UnicodeSurrogateReplacer.replace_in_file!(filename)
    end

    # Add comments to the top of files and replace the language (first key in YAML file)
    def update_file_header(filename, language)
      lines = read_yaml_and_update_language_key(filename, language)

      File.open(filename, 'w+') do |f|
        f.puts(YML_FILE_HEADER, '') unless lines[0][0] == '#'
        f.puts(lines)
      end
    end

  end
end
