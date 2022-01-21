import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../services/responsive_service.dart';
import '../services/scaffold_service.dart';

class Menu {
  static final ScaffoldService _scaffoldService = ScaffoldService();
  static final ResponsiveService _responsiveService = ResponsiveService();

  static void open() => _scaffoldService.openDelegate?.call();
  static void close() => _scaffoldService.closeDelegate?.call();
  static void collapse() => _scaffoldService.navCollapsed.toggle();

  static bool get isDocked => _responsiveService.displayMenu.value;
  static bool get isCollapsed => _scaffoldService.navCollapsed.value;
  static bool get isOpen => _scaffoldService.isOpen;

  static double get width => _responsiveService.menuWidth.value;

  static int animationDuration = 250;

  static const double collapsedWidth = 66;
  static const double fullWidth = 250;
}
