class CardModel {
  String? idCard;
  String? idCardPwd;

  CardModel({this.idCard, this.idCardPwd});

  factory CardModel.fromJson(Map<String, dynamic> json) {
    final card = CardModel();
    card.idCard = json['idCard'];
    card.idCardPwd = json['idCardPwd'];
    return card;
  }

  Map<String, dynamic> toJson() {
    return {
      'idCard': idCard,
      'idCardPwd': idCardPwd,
    };
  }
}