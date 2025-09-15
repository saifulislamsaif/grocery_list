part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SIGNUP = _Paths.SIGNUP;
  static const INVITATION = _Paths.INVITATION;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SIGNUP = '/signup';
  static const INVITATION = '/invitation';
}
