require 'minitest/spec'
require 'minitest/autorun'
require 'stringio'
require 'translations_manager/transifex_config_file_updater'

describe TranslationsManager::TransifexConfigFileUpdater do
  def fixture(filename)
    File.join('spec', 'fixtures', filename)
  end

  it "reads the current lang_map from a config file" do
    lang_map = File.open(fixture('tx_config'), 'r') do |file|
      TranslationsManager::TransifexConfigFileUpdater.read_lang_map(file)
    end

    lang_map.must_equal('el_GR' => 'el', 'es_ES' => 'es', 'ko_KR' => 'ko')
  end

  it "updates the lang_map in a config_file" do
    file = StringIO.new(IO.read(fixture('tx_config')))
    languages = { 'el_GR' => 'el', 'vi_VN' => 'vi', 'es_ES' => 'es' }

    TranslationsManager::TransifexConfigFileUpdater.update_lang_map(file, languages)
    file.string.must_equal(IO.read(fixture('tx_config_expected')))
  end
end
