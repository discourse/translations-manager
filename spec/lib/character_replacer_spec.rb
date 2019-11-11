# frozen_string_literal: true

require 'minitest/spec'
require 'minitest/autorun'
require 'translations_manager/character_replacer'

describe TranslationsManager::CharacterReplacer do
  def replace_in_text!(text)
    TranslationsManager::CharacterReplacer.replace_in_text!(text)
  end

  it "correctly replaces Unicode surrogates" do
    text = +'foo\uD83D\uDE2Dbar\uD83D\uDE09'

    replace_in_text!(text).must_equal true
    text.must_equal 'foo😭bar😉'
  end

  it "correctly replaces control characters" do
    text = +"foo\bbar"

    replace_in_text!(text).must_equal true
    text.must_equal 'foobar'
  end

  it "doesn't replace anything" do
    text = +'foo bar'

    replace_in_text!(text).must_equal false
    text.must_equal 'foo bar'
  end

  def fixture(filename)
    File.join('spec', 'fixtures', filename)
  end

  def replace_in_file!(name)
    original_filename = fixture("#{name}_example.yml")

    Tempfile.create do |file|
      file.write(IO.read(original_filename))
      file.close

      TranslationsManager::CharacterReplacer.replace_in_file!(file.path)
      IO.read(file.path)
    end
  end

  def expected(name)
    filename = fixture("#{name}_expected.yml")
    IO.read(filename)
  end

  it "correctly replaces characters in file" do
    replace_in_file!('characters').must_equal expected('characters')
  end
end
