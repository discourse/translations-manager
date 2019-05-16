require 'minitest/spec'
require 'minitest/autorun'
require 'translations_manager/character_replacer'

describe TranslationsManager::CharacterReplacer do
  def replace_in_text!(text)
    TranslationsManager::CharacterReplacer.replace_in_text!(text)
  end

  it "correctly replaces Unicode surrogates" do
    text = "foo\b\\uD83D\\uDE2Dbar\\uD83D\\uDE09"

    replace_in_text!(text).must_equal true
    text.must_equal 'foo😭bar😉'
  end

  it "correctly replaces control characters" do
    text = "foo\bbar"

    replace_in_text!(text).must_equal true
    text.must_equal 'foobar'
  end

  it "doesn't replace anything" do
    text = 'foo bar'

    replace_in_text!(text).must_equal false
    text.must_equal 'foo bar'
  end
end
