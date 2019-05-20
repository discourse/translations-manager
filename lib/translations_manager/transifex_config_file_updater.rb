# frozen_string_literal: true

module TranslationsManager
  class TransifexConfigFileUpdater
    def self.read_lang_map(file)
      file.each_line do |line|
        if line =~ /lang_map = (.*)/i
          return Hash[$1.split(',').sort.map { |x| x.split(':').map(&:strip) }]
        end
      end
    end

    def self.update_lang_map(file, languages)
      lines = []
      languages = languages.map { |k, v| "#{k}: #{v}" }.sort.join(', ')

      file.each_line do |line|
        if line =~ /lang_map = (.*)/i
          lines << "lang_map = #{languages}\n"
        else
          lines << line
        end
      end

      file.truncate(0)
      file.rewind

      lines.each do |line|
        file.puts line
      end
    end
  end
end
