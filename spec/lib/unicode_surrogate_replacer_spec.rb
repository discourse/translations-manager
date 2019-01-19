require 'minitest/spec'
require 'minitest/autorun'
require 'translations_manager/unicode_surrogate_replacer'

describe TranslationsManager::UnicodeSurrogateReplacer do
  def replace(text)
    TranslationsManager::UnicodeSurrogateReplacer.replace(text)
  end

  it "correctly replaces Unicode surrogates" do
    replace('foo\uD83D\uDE2Dbar\uD83D\uDE09').must_equal 'foo😭bar😉'
  end
end
