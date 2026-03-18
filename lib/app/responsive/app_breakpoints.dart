import 'package:responsive_framework/responsive_framework.dart';

abstract final class AppBreakpoints {
  static const List<Breakpoint> items = [
    Breakpoint(start: 0, end: 480, name: MOBILE),
    Breakpoint(start: 481, end: 800, name: TABLET),
    Breakpoint(start: 801, end: 1200, name: DESKTOP),
    Breakpoint(start: 1201, end: double.infinity, name: '4K'),
  ];
}
