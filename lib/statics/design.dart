import './screen.dart';

class Design {
  static double height = 920;
  static double width = 500;
  static double get hScale =>
      (Screen.isPortrait ? height : width) / Screen.height;
  static double get wScale =>
      (Screen.isPortrait ? width : height) / Screen.width;
}
