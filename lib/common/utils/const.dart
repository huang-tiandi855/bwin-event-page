
class KindConst{
  static const int CARTTONKIND = 0;
  static const int COMMICKIND = 1;
  static const int REALPERSON = 3;
  static const int PORTRAYKIND = 5;
  static const int NOVELKIND = 4;
  static const int AUDIOKIND = 7;
  static const int JUCHANGKIND = 8;
  static const int QUANZI = -1;
}

enum CacheMediaType {
  video(0),
  short(1),
  cartoon(2);

  final int value;
  const CacheMediaType(this.value);
}
/**
    MediaKindCartoon = iota //动漫
    MediaKindComics      = 1 //漫画
    MediaKindCosPlay     = 2 //角色扮演
    MediaKindRealPerson  = 3 //真人
    MediaKindRealFiction = 4 //小说
    MediaKindRealPhoto   = 5 //写真
    MediaKindRealBanned  = 6 //禁播
    // **/