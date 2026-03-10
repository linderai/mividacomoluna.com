abstract class AppConfig {
  static const authBase = 'https://sar1a.lempyra.com';
  static const clientId = 'portal';
  static const clientSecret = '';  // password used as secret (sar1a convention)
  static const scope = 'payments,ink,profile';

  static const tokenKey   = 'luna_token';
  static const refreshKey = 'luna_refresh';
  static const userKey    = 'luna_user';
}
