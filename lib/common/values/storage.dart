class Storage {
  ///用户 token
  static const String token = 'user_token';

  ///用户 token 有效时间
  static const String tokenValidDate = 'user_token_valid_date';

  /// 文档：GET jwt-token 接口返回的 JwtToken（请求头 jwtToken），与登录会话 token 分离
  static const String jwtToken = 'app_jwt_token';

  /// 用户ID(web使用)
  static const String userUid = 'user_uid';

  static const String searchList = 'search_list';

  ///是否保存账号凭证
  static const String isSaveAccountCredentials = 'isSaveAccountCredentials';
}
