require 'minitest/spec'
require 'minitest/autorun'
require 'translations_manager/locale_file_cleaner'

describe TranslationsManager::LocaleFileCleaner do
  def fixture(filename)
    File.join('spec', 'fixtures', filename)
  end

  def clean(name)
    filename = fixture("#{name}_example.yml")
    TranslationsManager::LocaleFileCleaner.new(filename).clean
  end

  def expected(name)
    filename = fixture("#{name}_expected.yml")
    IO.read(filename)
  end

  it "correctly removes empty translations" do
    clean('complete').must_equal expected('complete')
  end

  it "works with empty locale files" do
    clean('empty').must_equal expected('empty')
  end
end