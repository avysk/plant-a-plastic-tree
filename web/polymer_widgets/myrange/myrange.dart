import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('my-range')
class MyRange extends PolymerElement {
  @published String title = "unnamed element";
  @published String min = "0.0";
  @published String max = "1.0";
  @published String step = "0.1";
  @published String value = "0.5";

  MyRange.created() : super.created();
  void changed(Event e, var detail, Node target) {

  }
}
