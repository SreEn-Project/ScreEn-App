/// ML Kit 번역 지원 언어 (59개).
/// [ocrSupported]: ML Kit 문자 인식(라틴 · 한중일 · 데바나가리)으로 원문을 읽을 수 있는지.
/// false면 대상 언어로만 쓸 수 있다 (FL-05).
/// 언어 이름은 UI 문구가 아니라 데이터라서 ARB 대신 여기 둔다 (D-014).
class SupportedLanguage {
  const SupportedLanguage(
    this.code,
    this.nameKo,
    this.nameEn,
    this.nativeName, {
    this.ocrSupported = true,
  });

  final String code;
  final String nameKo;
  final String nameEn;
  final String nativeName;
  final bool ocrSupported;

  /// 앱 화면 언어([uiLanguageCode], 예: "ko")에 맞는 이름.
  String displayName(String uiLanguageCode) =>
      uiLanguageCode == 'ko' ? nameKo : nameEn;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return nameKo.contains(q) ||
        nameEn.toLowerCase().contains(q) ||
        nativeName.toLowerCase().contains(q) ||
        code == q;
  }

  static SupportedLanguage byCode(String code) =>
      all.firstWhere((l) => l.code == code, orElse: () => all.first);

  static const all = <SupportedLanguage>[
    SupportedLanguage('ko', '한국어', 'Korean', '한국어'),
    SupportedLanguage('en', '영어', 'English', 'English'),
    SupportedLanguage('ja', '일본어', 'Japanese', '日本語'),
    SupportedLanguage('zh', '중국어', 'Chinese', '中文'),
    SupportedLanguage('af', '아프리칸스어', 'Afrikaans', 'Afrikaans'),
    SupportedLanguage('ar', '아랍어', 'Arabic', 'العربية', ocrSupported: false),
    SupportedLanguage(
      'be',
      '벨라루스어',
      'Belarusian',
      'Беларуская',
      ocrSupported: false,
    ),
    SupportedLanguage(
      'bg',
      '불가리아어',
      'Bulgarian',
      'Български',
      ocrSupported: false,
    ),
    SupportedLanguage('bn', '벵골어', 'Bengali', 'বাংলা', ocrSupported: false),
    SupportedLanguage('ca', '카탈루냐어', 'Catalan', 'Català'),
    SupportedLanguage('cs', '체코어', 'Czech', 'Čeština'),
    SupportedLanguage('cy', '웨일스어', 'Welsh', 'Cymraeg'),
    SupportedLanguage('da', '덴마크어', 'Danish', 'Dansk'),
    SupportedLanguage('de', '독일어', 'German', 'Deutsch'),
    SupportedLanguage('el', '그리스어', 'Greek', 'Ελληνικά', ocrSupported: false),
    SupportedLanguage('eo', '에스페란토', 'Esperanto', 'Esperanto'),
    SupportedLanguage('es', '스페인어', 'Spanish', 'Español'),
    SupportedLanguage('et', '에스토니아어', 'Estonian', 'Eesti'),
    SupportedLanguage('fa', '페르시아어', 'Persian', 'فارسی', ocrSupported: false),
    SupportedLanguage('fi', '핀란드어', 'Finnish', 'Suomi'),
    SupportedLanguage('fr', '프랑스어', 'French', 'Français'),
    SupportedLanguage('ga', '아일랜드어', 'Irish', 'Gaeilge'),
    SupportedLanguage('gl', '갈리시아어', 'Galician', 'Galego'),
    SupportedLanguage(
      'gu',
      '구자라트어',
      'Gujarati',
      'ગુજરાતી',
      ocrSupported: false,
    ),
    SupportedLanguage('he', '히브리어', 'Hebrew', 'עברית', ocrSupported: false),
    SupportedLanguage('hi', '힌디어', 'Hindi', 'हिन्दी'),
    SupportedLanguage('hr', '크로아티아어', 'Croatian', 'Hrvatski'),
    SupportedLanguage('ht', '아이티 크리올어', 'Haitian Creole', 'Kreyòl ayisyen'),
    SupportedLanguage('hu', '헝가리어', 'Hungarian', 'Magyar'),
    SupportedLanguage('id', '인도네시아어', 'Indonesian', 'Bahasa Indonesia'),
    SupportedLanguage('is', '아이슬란드어', 'Icelandic', 'Íslenska'),
    SupportedLanguage('it', '이탈리아어', 'Italian', 'Italiano'),
    SupportedLanguage('ka', '조지아어', 'Georgian', 'ქართული', ocrSupported: false),
    SupportedLanguage('kn', '칸나다어', 'Kannada', 'ಕನ್ನಡ', ocrSupported: false),
    SupportedLanguage('lt', '리투아니아어', 'Lithuanian', 'Lietuvių'),
    SupportedLanguage('lv', '라트비아어', 'Latvian', 'Latviešu'),
    SupportedLanguage(
      'mk',
      '마케도니아어',
      'Macedonian',
      'Македонски',
      ocrSupported: false,
    ),
    SupportedLanguage('mr', '마라티어', 'Marathi', 'मराठी'),
    SupportedLanguage('ms', '말레이어', 'Malay', 'Bahasa Melayu'),
    SupportedLanguage('mt', '몰타어', 'Maltese', 'Malti'),
    SupportedLanguage('nl', '네덜란드어', 'Dutch', 'Nederlands'),
    SupportedLanguage('no', '노르웨이어', 'Norwegian', 'Norsk'),
    SupportedLanguage('pl', '폴란드어', 'Polish', 'Polski'),
    SupportedLanguage('pt', '포르투갈어', 'Portuguese', 'Português'),
    SupportedLanguage('ro', '루마니아어', 'Romanian', 'Română'),
    SupportedLanguage('ru', '러시아어', 'Russian', 'Русский', ocrSupported: false),
    SupportedLanguage('sk', '슬로바키아어', 'Slovak', 'Slovenčina'),
    SupportedLanguage('sl', '슬로베니아어', 'Slovenian', 'Slovenščina'),
    SupportedLanguage('sq', '알바니아어', 'Albanian', 'Shqip'),
    SupportedLanguage('sv', '스웨덴어', 'Swedish', 'Svenska'),
    SupportedLanguage('sw', '스와힐리어', 'Swahili', 'Kiswahili'),
    SupportedLanguage('ta', '타밀어', 'Tamil', 'தமிழ்', ocrSupported: false),
    SupportedLanguage('te', '텔루구어', 'Telugu', 'తెలుగు', ocrSupported: false),
    SupportedLanguage('th', '태국어', 'Thai', 'ไทย', ocrSupported: false),
    SupportedLanguage('tl', '타갈로그어', 'Tagalog', 'Tagalog'),
    SupportedLanguage('tr', '터키어', 'Turkish', 'Türkçe'),
    SupportedLanguage(
      'uk',
      '우크라이나어',
      'Ukrainian',
      'Українська',
      ocrSupported: false,
    ),
    SupportedLanguage('ur', '우르두어', 'Urdu', 'اردو', ocrSupported: false),
    SupportedLanguage('vi', '베트남어', 'Vietnamese', 'Tiếng Việt'),
  ];
}
