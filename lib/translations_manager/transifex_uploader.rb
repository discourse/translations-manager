# frozen_string_literal: true

require_relative 'common'

module TranslationsManager
  class TransifexUploader
    include Common

    def initialize(yml_dirs, yml_file_prefixes, resource_names, languages)
      check_tx_client

      @yml_dirs = yml_dirs
      @yml_file_prefixes = yml_file_prefixes
      @resource_names = resource_names
      @languages = (languages.empty? ? SUPPORTED_LOCALES : languages).select { |x| x != 'en' }.sort
    end

    def perform(tx_config_filename: '.tx/config')
      update_tx_config(tx_config_filename)
      update_file_headers
      push_translations
    ensure
      update_file_headers(reset: true)
    end

    def push_translations
      puts 'Pushing translations...', ''
      resource_argument = @resource_names.empty? ? "" : "-r #{@resource_names.join(',')}"
      language_argument = "--language #{@languages.join(',')}"
      command = "tx push --translations --force --no-interactive --skip #{resource_argument} #{language_argument}"

      execute_tx_command(command)
    end

    def update_file_headers(reset: false)
      @yml_dirs.each do |dir|
        @yml_file_prefixes.each do |prefix|
          LANGUAGE_MAP.each do |transifex_language, discourse_language|
            filename = yml_path_if_exists(dir, prefix, discourse_language)

            if filename
              language = reset ? discourse_language : transifex_language
              lines = read_yaml_and_update_language_key(filename, language)
              File.write(filename, lines.join(""))
            end
          end
        end
      end
    end

  end
end
