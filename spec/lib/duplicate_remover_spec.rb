# frozen_string_literal: true

require 'minitest/spec'
require 'minitest/autorun'
require 'translations_manager/duplicate_remover'

describe TranslationsManager::DuplicateRemover do
  def fixture(filename)
    File.join('spec', 'fixtures', filename)
  end

  def remove_duplicates(source_name, target_name)
    TranslationsManager::DuplicateRemover.new(fixture(source_name), fixture(target_name)).clean
  end

  def expected(name)
    IO.read(fixture(name))
  end

  it "correctly removes duplicate translations" do
    remove_duplicates('duplicates_original.yml', 'duplicates_copy.yml')
      .must_equal expected('duplicates_expected.yml')
  end
end
