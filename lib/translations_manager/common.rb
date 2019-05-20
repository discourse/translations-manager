# frozen_string_literal: true

require_relative 'transifex_config_file_updater'

module TranslationsManager
  module Common
    def check_tx_client
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
    end

    def update_tx_config(filename)
      unless File.exists?(filename)
        STDERR.puts "Can't find tx configuration file at #{filename}", ''
        exit 1
      end

      File.open(filename, 'r+') do |file|
        TranslationsManager::TransifexConfigFileUpdater.update_lang_map(file, LANGUAGE_MAP)
      end
    end

    def execute_tx_command(command)
      unless system(command)
        STDERR.puts 'Something failed. Check the output above.', ''
        exit return_value.exitstatus
      end
    end

    def read_yaml_and_update_language_key(filename, language)
      lines = File.readlines(filename)
      lines.collect! { |line| line.gsub!(/^[a-z_]+:( {})?$/i, "#{language}:\\1") || line }
      lines
    end

    def yml_path(dir, prefix, language)
      File.join(dir, "#{prefix}.#{language}.yml")
    end

    def yml_path_if_exists(dir, prefix, language)
      path = yml_path(dir, prefix, language)
      File.exists?(path) ? path : nil
    end
  end
end
