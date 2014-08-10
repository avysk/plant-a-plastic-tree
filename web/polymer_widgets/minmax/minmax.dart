import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('min-max')
class MinMax extends PolymerElement {
  @published String title = "unnamed element";
  @published String min = "0";
  @published String max = "10";
  @published String step = "1.0";
  @published String min_v = "1";
  @published String max_v = "9";

  MinMax.created() : super.created();
  void changed(Event e, var detail, Node target) {
    // We need some callback, or data binding won't work
  }
}
