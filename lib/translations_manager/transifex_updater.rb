require 'open3'
require 'psych'
require 'set'
require 'fileutils'
require_relative 'locale_file_cleaner'
require_relative 'locales'
require_relative 'transifex_config_file_updater'

module TranslationsManager
  class TransifexUpdater

    YML_FILE_HEADER = <<~HEADER
      # encoding: utf-8
      #
      # Never edit this file. It will be overwritten when translations are pulled from Transifex.
      #
      # To work with us on translations, join this project:
      # https://www.transifex.com/projects/p/discourse-org/
    HEADER

    def initialize(yml_dirs, yml_file_prefixes, *languages)

      if `which tx`.strip.empty?
        STDERR.puts <<~USAGE

          The Transifex client needs to be installed to use this script.
          Instructions are here: https://docs.transifex.com/client/installing-the-client

          On Mac:
            sudo easy_install pip
            sudo pip install transifex-client

        USAGE

        raise RuntimeError.new("Transifex client needs to be installed")
      end

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
              remove_empty_translations(filename)
              update_file_header(filename, language)
            end
          end
        end
      end
    end

    def update_tx_config(filename)
      if !File.exists?(filename)
        STDERR.puts "Can't find tx configuration file at #{filename}", ''
        exit 1
      end

      File.open(filename, 'r+') do |file|
        TranslationsManager::TransifexConfigFileUpdater.update_lang_map(file, LANGUAGE_MAP)
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

      return_value = Open3.popen2e(command) do |_, stdout_err, wait_thr|
        while (line = stdout_err.gets)
          puts line
        end
        wait_thr.value
      end

      puts ''

      unless return_value.success?
        STDERR.puts 'Something failed. Check the output above.', ''
        exit return_value.exitstatus
      end
    end

    def yml_path(dir, prefix, language)
      File.join(dir, "#{prefix}.#{language}.yml")
    end

    def yml_path_if_exists(dir, prefix, language)
      path = yml_path(dir, prefix, language)
      File.exists?(path) ? path : nil
    end

    def remove_empty_translations(filename)
      TranslationsManager::LocaleFileCleaner.new(filename).clean!
    end

    # Add comments to the top of files and replace the language (first key in YAML file)
    def update_file_header(filename, language)
      lines = File.readlines(filename)
      lines.collect! { |line| line.gsub!(/^[a-z_]+:( {})?$/i, "#{language}:\\1") || line }

      File.open(filename, 'w+') do |f|
        f.puts(YML_FILE_HEADER, '') unless lines[0][0] == '#'
        f.puts(lines)
      end
    end
  end
end
