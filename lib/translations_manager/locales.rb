module TranslationsManager
  # list of locales that will break Discourse and need to be fixed
  # by translators in Transifex
  BROKEN_LOCALES = []

  # all the locales supported by Discourse
  SUPPORTED_LOCALES = [
    'ar',
    'bg',
    'bs_BA',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'es',
    'et',
    'fa_IR',
    'fi',
    'fr',
    'gl',
    'he',
    'hi',
    'hu',
    'hy',
    'id',
    'it',
    'ja',
    'ko',
    'lt',
    'lv',
    'nb_NO',
    'nl',
    'pl_PL',
    'pt',
    'pt_BR',
    'ro',
    'ru',
    'sk',
    'sl',
    'sq',
    'sr',
    'sv',
    'sw',
    'te',
    'th',
    'tr_TR',
    'uk',
    'ur',
    'vi',
    'zh_CN',
    'zh_TW'
  ] - BROKEN_LOCALES

  # 'language code in transifex' => 'language code in Discourse'
  LANGUAGE_MAP = {
    'el_GR' => 'el',
    'es_ES' => 'es',
    'fr_FR' => 'fr',
    'hu_HU' => 'hu',
    'ko_KR' => 'ko',
    'pt_PT' => 'pt',
    'sk_SK' => 'sk',
    'vi_VN' => 'vi'
  }
end
