class TranslationsManager::CharacterReplacer
  def self.replace_in_file!(filename)
    file_content = File.read(filename)

    if replace_in_text!(file_content)
      File.write(filename, file_content)
    end
  end

  def self.replace_in_text!(text)
    !replace_control_characters!(text).nil? | !replace_unicode_surrogates!(text).nil?
  end

  def self.replace_control_characters!(text)
    text.gsub!(/\p{Cntrl}/, '')
  end

  def self.replace_unicode_surrogates!(text)
    text.gsub!(/\\u([0-9a-f]{4})\\u([0-9a-f]{4})/i) do
      # adapted from http://www.russellcottrell.com/greek/utilities/surrogatepaircalculator.htm
      high = $1.to_i(16)
      low = $2.to_i(16)
      decimal = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000
      decimal.chr(Encoding::UTF_8)
    end
  end
end
