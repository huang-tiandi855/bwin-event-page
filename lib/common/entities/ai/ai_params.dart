import 'dart:convert';

/// AI Chip / Select 通用选项（对齐 H5 `AiOptionItem`）。
class AiOptionItem {
  const AiOptionItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

/// AI 生成参数 / Prompt 组装（对齐 H5 `src/utils/ai/aiParams.ts`）。
///
/// 挪项目时优先复用本文件，避免页面内散落提示词与序列化逻辑。
class AiParams {
  AiParams._();

  // ---------------------------------------------------------------------------
  // 路径 / 序列化
  // ---------------------------------------------------------------------------

  static String normalizeAiUploadPath(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '';
    if (!RegExp(r'^https?:\/\/', caseSensitive: false).hasMatch(raw)) {
      return raw.replaceFirst(RegExp(r'^/+'), '');
    }
    try {
      return Uri.parse(raw).path.replaceFirst(RegExp(r'^/+'), '');
    } catch (_) {
      return raw;
    }
  }

  static String serializeAiImages(List<String> paths) {
    final list = paths
        .map(normalizeAiUploadPath)
        .where((item) => item.isNotEmpty)
        .toList();
    if (list.isEmpty) return '';
    return jsonEncode(list);
  }

  static String serializeAiStyles(List<String> styles) {
    final list = styles
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (list.isEmpty) return '';
    return jsonEncode(list);
  }

  static String normalizeAiVideoSize(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return raw;
    if (RegExp(r'^\d+p$', caseSensitive: false).hasMatch(raw)) {
      return raw.toUpperCase();
    }
    return raw;
  }

  static String findAiOptionLabel(List<AiOptionItem> options, String value) {
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return value;
  }

  static List<String> pickOptionalStyleLabel(
    List<AiOptionItem> options,
    String value,
  ) {
    if (value.trim().isEmpty) return const [];
    final label = findAiOptionLabel(options, value);
    if (label.isEmpty) return const [];
    return [label];
  }

  static List<String> labelsOf(List<AiOptionItem> options) {
    return options.map((e) => e.label).toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // 高级脱衣
  // ---------------------------------------------------------------------------

  static const List<AiOptionItem> advancedUndressModes = [
    AiOptionItem(label: '脱衣', value: 'undress'),
    AiOptionItem(label: '蕾丝内衣', value: 'lace'),
    AiOptionItem(label: '三点式', value: 'bikini'),
    AiOptionItem(label: '颜射', value: 'facial'),
    AiOptionItem(label: '捆绑SM套装', value: 'sm'),
    AiOptionItem(label: '口交', value: 'oral'),
    AiOptionItem(label: '乳交', value: 'breast'),
    AiOptionItem(label: '吃黑屌', value: 'bbc'),
  ];

  static const List<AiOptionItem> advancedUndressBreasts = [
    AiOptionItem(label: '默认', value: 'default'),
    AiOptionItem(label: '小奶', value: 'small'),
    AiOptionItem(label: '中奶', value: 'medium'),
    AiOptionItem(label: '大奶', value: 'large'),
  ];

  static const List<AiOptionItem> advancedUndressPubics = [
    AiOptionItem(label: '默认', value: 'default'),
    AiOptionItem(label: '无毛', value: 'none'),
    AiOptionItem(label: '有毛', value: 'normal'),
    AiOptionItem(label: '茂盛', value: 'thick'),
  ];

  static const String _advancedUndressBase =
      '移除所有水印。保持女人的面部一致，保持图片高清，肩宽，细腰，腿细， --lock-face 0.0 比例 1:1';

  static const String _advancedUndressQuality =
      '高清细节，真实皮肤质感，自然光影，无畸形，无多余肢体';

  static const Map<String, String> _advancedUndressModeMap = {
    'undress': '衣服脱光，全裸，一丝不挂，露出乳房',
    'lace': '穿着黑色蕾丝内衣，透明蕾丝文胸和内裤，隐约可见乳头和阴部轮廓',
    'bikini': '穿着极小三点式比基尼，仅遮住乳头和阴部，身体大部分裸露',
    'sm': '穿着黑色皮革捆绑SM套装，项圈、手铐、绳子缠绕身体，胸部和阴部完全露出',
    'facial': '全裸，一丝不挂，脸上和嘴边布满白色精液，表情迷离',
    'oral': '全裸跪着，张开嘴含住一根粗大的阴茎，正在进行口交',
    'breast': '全裸，用双手挤压丰满乳房夹住一根粗大的阴茎，正在进行乳交',
    'bbc':
        '全裸跪着，画面左边站着一个黑人的阴茎，画面右边站着一个黑人的阴茎，女人左手握住左边男人的阴茎，女人的右手握住右边男人的阴茎，左边男人的一只手放在女人的头上，女人张开腿，下方一个躺着黑男人的阴茎插入女人阴道',
  };

  static const Map<String, String> _advancedUndressBreastMap = {
    'default': '',
    'small': '小巧坚挺的乳房',
    'medium': '中等大小圆润的乳房',
    'large': '丰满硕大的乳房，乳沟明显',
  };

  static const Map<String, String> _advancedUndressPubicMap = {
    'default': '',
    'none': '女人的阴部光滑无毛，完全剃净',
    'normal': '女人的阴部有黑色阴毛',
    'thick': '女人的阴部有茂盛浓密的黑色阴毛',
  };

  /// 高级脱衣 Prompt：
  /// [基础保持] + [模式] + [奶子] + [阴毛] + [质量控制]
  static String buildAdvancedUndressPrompt({
    required String mode,
    required String breast,
    required String pubic,
  }) {
    return [
      _advancedUndressBase,
      _advancedUndressModeMap[mode] ?? '',
      _advancedUndressBreastMap[breast] ?? '',
      _advancedUndressPubicMap[pubic] ?? '',
      _advancedUndressQuality,
    ].where((part) => part.isNotEmpty).join('，');
  }

  // ---------------------------------------------------------------------------
  // 图片拓展
  // ---------------------------------------------------------------------------

  static const List<AiOptionItem> imageExpandStyles = [
    AiOptionItem(label: '脱衣', value: 'undress'),
    AiOptionItem(label: '乳交黑人', value: 'paizuri-bbc'),
    AiOptionItem(label: '前后夹击', value: 'double'),
    AiOptionItem(label: '回眸', value: 'look-back'),
    AiOptionItem(label: '左右开弓', value: 'double-hand'),
    AiOptionItem(label: '正入', value: 'front'),
    AiOptionItem(label: '锁链', value: 'chain'),
    AiOptionItem(label: '母狗', value: 'bitch'),
    AiOptionItem(label: '抱入', value: 'holding'),
    AiOptionItem(label: '肛交', value: 'anal'),
    AiOptionItem(label: '阿黑颜', value: 'ahegao'),
    AiOptionItem(label: '我是骚货', value: 'im-a-whore'),
    AiOptionItem(label: '黑人后入', value: 'bbc-back'),
  ];

  static const List<AiOptionItem> imageExpandSizes = [
    AiOptionItem(label: '512x512', value: '512x512'),
    AiOptionItem(label: '768x768', value: '768x768'),
    AiOptionItem(label: '1024x1024', value: '1024x1024'),
  ];

  static const String _imageExpandBase =
      '移除所有水印。保持女人的面部一致，保持图片高清，肩宽，细腰，腿细，真实皮肤质感， --lock-face 0.0 比例 1:1';

  static const String _imageExpandQuality =
      '高清细节，真实皮肤质感，自然光影，无畸形，无多余肢体';

  static const Map<String, String> _imageExpandStyleMap = {
    'undress': '衣服脱光，全裸，一丝不挂，露出乳房和阴部',
    'paizuri-bbc': '全裸，用双手挤压丰满乳房夹住一根粗大的黑人阴茎，正在进行乳交，黑人站在女人面前',
    'double': '全裸，一个男人从正面插入女人阴道，另一个男人从后面插入女人肛门，前后夹击，双人同时抽插',
    'look-back': '全裸跪着或趴着，回头看向镜头，露出诱人眼神和臀部，回眸一笑',
    'double-hand': '全裸，女人左右手各握住一根阴茎，左右开弓同时为两个男人手淫',
    'front': '全裸躺着，双腿张开，一个男人正面插入女人阴道，正常位抽插',
    'chain': '全裸，身上缠绕金属锁链，被锁链束缚双手或身体，SM调教氛围，胸部和阴部完全露出',
    'bitch': '全裸四肢着地，像母狗一样趴着，臀部高高抬起，回头看向镜头，等待被插入',
    'holding': '全裸被男人抱起，双腿缠绕男人腰部，男人站立插入女人阴道，抱操姿势',
    'anal': '全裸，一个男人从后面插入女人肛门，正在进行肛交，臀部高高抬起',
    'ahegao': '全裸，翻白眼，舌头伸出，口水直流，阿黑颜表情，高潮失控的样子',
    'im-a-whore': '全裸，表情淫荡，主动展示身体，双手分开阴唇或托起乳房，仿佛在说「我是骚货」',
    'bbc-back': '全裸跪着或趴着，一个黑人从后面大力插入女人阴道，后入式抽插，黑人双手抓住女人腰部',
  };

  /// 图片拓展 Prompt：
  /// [基础保持] + [风格] + [拓展描述] + [质量控制]
  static String buildImageExpandPrompt({
    required String style,
    String? extraDesc,
  }) {
    return [
      _imageExpandBase,
      _imageExpandStyleMap[style] ?? '',
      (extraDesc ?? '').trim(),
      _imageExpandQuality,
    ].where((part) => part.isNotEmpty).join('，');
  }

  // ---------------------------------------------------------------------------
  // 图生视频
  // ---------------------------------------------------------------------------

  static const List<AiOptionItem> imageToVideoStyles = [
    AiOptionItem(label: '脱衣', value: 'undress'),
    AiOptionItem(label: '捂嘴后入', value: 'gagged-back'),
    AiOptionItem(label: '颜射', value: 'facial'),
    AiOptionItem(label: '后入', value: 'back'),
    AiOptionItem(label: '巨屌冲天', value: 'giant-up'),
    AiOptionItem(label: '群射', value: 'group-shot'),
    AiOptionItem(label: '肛交', value: 'anal'),
    AiOptionItem(label: '裸舞', value: 'nude-dance'),
    AiOptionItem(label: '浮空抱入', value: 'floating-hold'),
    AiOptionItem(label: '放尿', value: 'urination'),
    AiOptionItem(label: '3p', value: 'threesome'),
    AiOptionItem(label: '左右逢源', value: 'both-sides'),
    AiOptionItem(label: '前后夹击', value: 'double'),
    AiOptionItem(label: '双飞', value: 'double-partner'),
    AiOptionItem(label: '坐莲', value: 'lotus'),
    AiOptionItem(label: '跪下夹击', value: 'kneeling-double'),
    AiOptionItem(label: '跪下后入', value: 'kneeling-back'),
    AiOptionItem(label: '口交', value: 'oral'),
  ];

  static const List<AiOptionItem> imageToVideoDurations = [
    AiOptionItem(label: '5秒', value: '5'),
  ];

  static const List<AiOptionItem> imageToVideoResolutions = [
    AiOptionItem(label: '横屏 768x512', value: '768x512'),
    AiOptionItem(label: '方形 512x512', value: '512x512'),
    AiOptionItem(label: '横屏 1024x576', value: '1024x576'),
  ];

  static const String _imageToVideoBase =
      '移除所有水印。保持女人的面部一致，保持画面高清流畅，肩宽，细腰，腿细，真实皮肤质感， --lock-face 0.0';

  static const String _imageToVideoQuality =
      '动作流畅自然，画面稳定无抖动，高清细节，真实皮肤质感，自然光影，无畸形，无多余肢体，连贯运动';

  static const Map<String, String> _imageToVideoStyleMap = {
    'undress': '女人缓慢脱掉衣服，一件一件脱下，直到全裸，一丝不挂，露出乳房和阴部，脱衣过程自然流畅',
    'gagged-back': '全裸跪着，一个男人从后面插入女人阴道，一只手捂住女人的嘴，大力后入抽插，女人身体前后晃动',
    'facial': '全裸跪着或坐着，男人将精液射在女人脸上和嘴边，白色精液顺着脸颊流下，女人表情迷离接受颜射',
    'back': '全裸跪着或趴着，一个男人从后面插入女人阴道，双手抓住女人腰部，大力后入抽插，臀部撞击',
    'giant-up': '全裸，一根巨大粗长的阴茎插入女人阴道，深深插入到最深处，大力抽插，女人身体剧烈晃动',
    'group-shot': '全裸跪着，多个男人同时将精液射在女人脸上、胸部和身上，大量白色精液覆盖身体，群射场面',
    'anal': '全裸跪着或趴着，一个男人从后面插入女人肛门，正在进行肛交，缓慢深入后开始抽插',
    'nude-dance': '全裸站立，扭动腰肢和臀部跳舞，乳房随着动作晃动，裸舞动作性感流畅',
    'floating-hold': '全裸被男人抱在空中，双腿缠绕男人腰部，男人站立或悬空插入女人阴道，浮空抱操，身体上下律动',
    'urination': '全裸蹲着或站着，从阴部流出透明黄色尿液，放尿过程清晰可见，尿液溅落',
    'threesome': '全裸，一个男人从正面插入女人阴道，另一个男人让女人口交，三人同时进行，3P动作连贯',
    'both-sides': '全裸，女人左右手各握住一根阴茎来回套弄，同时左右逢源为两个男人手淫，双手上下动作',
    'double': '全裸，一个男人从正面插入女人阴道，另一个男人从后面插入女人肛门，前后夹击同时抽插，身体被夹在中间晃动',
    'double-partner': '画面中有两个女人，全裸，与一个或两个男人进行双飞，两人同时被插入或互相配合，动作同步',
    'lotus': '全裸跨坐在男人身上，女人主动上下律动，坐莲女上位抽插，乳房上下晃动',
    'kneeling-double': '全裸跪着，一个男人从正面插入，另一个男人从侧面或后面同时插入，跪姿夹击，身体被左右推动',
    'kneeling-back': '全裸跪着，双手撑地，一个男人从后面插入女人阴道，跪下后入抽插，臀部随动作前后移动',
    'oral': '全裸跪着，张开嘴含住阴茎，头部前后移动进行口交，舌头舔舐，唾液拉丝',
  };

  /// 图生视频 Prompt：
  /// [基础保持] + [风格(可选)] + [运动描述] + [质量控制]
  static String buildImageToVideoPrompt({
    String? style,
    String? motionDesc,
  }) {
    final styleKey = (style ?? '').trim();
    return [
      _imageToVideoBase,
      styleKey.isEmpty ? '' : (_imageToVideoStyleMap[styleKey] ?? ''),
      (motionDesc ?? '').trim(),
      _imageToVideoQuality,
    ].where((part) => part.isNotEmpty).join('，');
  }
}
