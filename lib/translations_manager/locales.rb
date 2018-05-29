module TranslationsManager
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
    'id',
    'it',
    'ja',
    'ko',
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
    'te',
    'th',
    'tr_TR',
    'uk',
    'ur',
    'vi',
    'zh_CN',
    'zh_TW'
  ]

  # 'language code in transifex' => 'language code in Discourse'
  LANGUAGE_MAP = {
    'el_GR' => 'el',
    'es_ES' => 'es',
    'fr_FR' => 'fr',
    'ko_KR' => 'ko',
    'pt_PT' => 'pt',
    'sk_SK' => 'sk',
    'vi_VN' => 'vi'
  }
end
