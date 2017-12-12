require 'open3'
require 'psych'
require 'set'
require 'fileutils'

module TranslationsManager
  class TransifexUpdater

    YML_FILE_COMMENTS = <<END
# encoding: utf-8
#
# Never edit this file. It will be overwritten when translations are pulled from Transifex.
#
# To work with us on translations, join this project:
# https://www.transifex.com/projects/p/discourse-org/
END

    SUPPORTED_LOCALES = ["ar", "bs_BA", "ca", "cs", "da", "de", "el", "en", "es", "et", "fa_IR", "fi", "fr", "gl", "he", "id", "it", "ja", "ko", "lv", "nb_NO", "nl", "pl_PL", "pt", "pt_BR", "ro", "ru", "sk", "sq", "sv", "te", "th", "tr_TR", "uk", "ur", "vi", "zh_CN", "zh_TW"]

    def initialize(yml_dirs, yml_file_prefixes, *languages)

      if `which tx`.strip.empty?
        puts '', 'The Transifex client needs to be installed to use this script.'
        puts 'Instructions are here: http://docs.transifex.com/client/setup/'
        puts '', 'On Mac:', ''
        puts '  sudo easy_install pip'
        puts '  sudo pip install transifex-client', ''
        raise RuntimeError.new("Transifex client needs to be installed")
      end

      @yml_dirs = yml_dirs
      @yml_file_prefixes = yml_file_prefixes
      @languages = (languages.empty? ? SUPPORTED_LOCALES : languages).select { |x| x != 'en' }.sort
    end

    def perform
      # ensure that all locale files exists. tx doesn't create missing locale files during pull
      @yml_dirs.each do |dir|
        @yml_file_prefixes.each do |prefix|
          @languages.each do |language|
            filename = yml_path(dir, prefix, language)
            FileUtils.touch(filename) unless File.exists?(filename)
          end
        end
      end

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

      @yml_dirs.each do |dir|
        @yml_file_prefixes.each do |prefix|
          @languages.each do |language|
            filename = yml_path_if_exists(dir, prefix, language)

            if filename
              update_file_header(filename, language)
            end
          end
        end
      end
    end

    def yml_path(dir, prefix, language)
      File.join(dir, "#{prefix}.#{language}.yml")
    end

    def yml_path_if_exists(dir, prefix, language)
      path = yml_path(dir, prefix, language)
      File.exists?(path) ? path : nil
    end

    # Add comments to the top of files and replace the language (first key in YAML file)
    def update_file_header(filename, language)
      lines = File.readlines(filename)
      lines.collect! { |line| line.gsub!(/^[a-z_]+:( {})?$/i, "#{language}:\\1") || line }

      File.open(filename, 'w+') do |f|
        f.puts(YML_FILE_COMMENTS, '') unless lines[0][0] == '#'
        f.puts(lines)
      end
    end
  end
end
