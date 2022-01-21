import 'package:fast/services/responsive_service.dart';

import '../statics/menu.dart';
import '../utils/typedef.dart';

class ScaffoldLayoutController extends Controller {
  bool isDocked = Menu.isDocked;
  late final Worker worker;

  @override
  void onInit() {
    worker = ever(ResponsiveService().displayMenu, (bool value) {
      if (value != isDocked) {
        isDocked = value;
        update();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    worker.dispose();
    super.onClose();
  }
}
