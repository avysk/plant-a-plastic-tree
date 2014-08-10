import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:math' as math;

@CustomTag('my-range')
class MyRange extends PolymerElement {
  @published String title = "unnamed element";
  @published String min = "0.0";
  @published String max = "1.0";
  @published String step = "0.1";
  @published String value = "0.5";
  @published String integer = "false";

  MyRange.created() : super.created();

  @published void randomize(math.Random r) {
    var dMin = double.parse(min);
    var dMax = double.parse(max);
    var s = double.parse(step);
    var steps = ((dMax - dMin) / s + 1).round();
    // XXX
    // Adding to 0 integer number of 0.05 steps we can get
    // something like 0.8500....01, so let's cut extra digits
    var tmp = (dMin + r.nextInt(steps) * s).toStringAsPrecision(5);
    // XXX and this removes unneeded 0s in the end
    value = "${double.parse(tmp)}";
    if (integer == "true")
      value = "${double.parse(value).round()}";
  }
}
