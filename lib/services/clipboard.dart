import 'package:clipboard/clipboard.dart';

class MyClipboard {
  static void copy({required String text}) {
    FlutterClipboard.copy(text).then((value) => print('copied'));
  }
}
