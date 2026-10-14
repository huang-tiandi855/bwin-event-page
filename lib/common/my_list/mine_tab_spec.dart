/// 「我的」列表页共用 Tab 配置（收藏 / 购买 / 喜欢 / 历史等）。
/// 各业务页在 `lib/pages/mine_index/` 下实现，本目录 `lib/common/my_list/` 放共用壳与 Logic 基类。
///
/// 具体 Tab 顺序与文案见 [kDefaultMineMediaTabs]；业务页如需删减 Tab，在
/// [MineMediaListBaseLogic.tabs] 中重写即可。
enum MineMediaPaneKind {
  /// 长视频（影片 Tab，对应 [MineMediaListBaseLogic.longVideoItems]）
  longVideo,

  /// 短视频（抖音 Tab，对应 [MineMediaListBaseLogic.shortVideoItems]）
  shortVideo,

  /// 动漫 Tab（横版宫格与影片相同，数据与接口独立，对应 [MineMediaListBaseLogic.animeItems]）
  anime,

  /// 帖子列表
  post,

  /// 漫画（小说区六宫格样式）
  comic,

  /// 图库（图集四宫格）
  gallery,

  /// 黄油（游戏四宫格）
  game,

  /// 约会（双列卡片）
  dating,
}

/// 单个 Tab 的展示名与内容类型。
class MineMediaTabSpec {
  const MineMediaTabSpec(this.label, this.kind);

  /// AppBar 下方横向 Tab 的文案。
  final String label;

  /// 决定该 Tab 的布局类型与绑定的数据源（见 [MineMediaListBaseLogic] 各 `*Items`）。
  final MineMediaPaneKind kind;
}

/// 我的购买：影片 / 抖音 / 帖子（对应接口 tabType 1 / 2 / 3）。
const List<MineMediaTabSpec> kMyPurchaseMineTabs = <MineMediaTabSpec>[
  MineMediaTabSpec('影片', MineMediaPaneKind.longVideo),
  MineMediaTabSpec('抖音', MineMediaPaneKind.shortVideo),
  MineMediaTabSpec('帖子', MineMediaPaneKind.post),
  MineMediaTabSpec('黄游', MineMediaPaneKind.game),
  MineMediaTabSpec('约会', MineMediaPaneKind.dating),
];

/// 我的收藏：影片 / 抖音 / 帖子（视频走 cms/favorites，帖子走 posting/favorites）。
const List<MineMediaTabSpec> kMyCollectionMineTabs = <MineMediaTabSpec>[
  MineMediaTabSpec('影片', MineMediaPaneKind.longVideo),
  MineMediaTabSpec('抖音', MineMediaPaneKind.shortVideo),
  MineMediaTabSpec('帖子', MineMediaPaneKind.post),
  MineMediaTabSpec('黄游', MineMediaPaneKind.game),
];

/// 我的喜欢：影片 / 抖音 / 帖子（视频 GET cms/favorites?like=true，videoType 0/2，帖子 POST cms/favorites）。
const List<MineMediaTabSpec> kMyLikesMineTabs = <MineMediaTabSpec>[
  MineMediaTabSpec('影片', MineMediaPaneKind.longVideo),
  MineMediaTabSpec('抖音', MineMediaPaneKind.shortVideo),
  MineMediaTabSpec('帖子', MineMediaPaneKind.post),
  MineMediaTabSpec('黄游', MineMediaPaneKind.game),
];

/// 历史记录：影片 / 抖音 / 帖子（本地 [HistoryOperation]）
const List<MineMediaTabSpec> kMyHistoryMineTabs = <MineMediaTabSpec>[
  MineMediaTabSpec('影片', MineMediaPaneKind.longVideo),
  MineMediaTabSpec('抖音', MineMediaPaneKind.shortVideo),
  MineMediaTabSpec('帖子', MineMediaPaneKind.post),
  MineMediaTabSpec('黄游', MineMediaPaneKind.game),
];

/// 默认 7 个 Tab，与产品 UI 一致；单页可通过 `Logic` 中重写 [MineMediaListBaseLogic.tabs] 减少数量。
const List<MineMediaTabSpec> kDefaultMineMediaTabs = <MineMediaTabSpec>[
  MineMediaTabSpec('影片', MineMediaPaneKind.longVideo),
  MineMediaTabSpec('抖音', MineMediaPaneKind.shortVideo),
  MineMediaTabSpec('帖子', MineMediaPaneKind.post),
  MineMediaTabSpec('漫画', MineMediaPaneKind.comic),
  MineMediaTabSpec('动漫', MineMediaPaneKind.anime),
  MineMediaTabSpec('图库', MineMediaPaneKind.gallery),
  MineMediaTabSpec('黄油', MineMediaPaneKind.game),
  MineMediaTabSpec('黄游', MineMediaPaneKind.game),
];
