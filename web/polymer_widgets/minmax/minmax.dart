import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:math' as math;

@CustomTag('min-max')
class MinMax extends PolymerElement {
  @published String title = "unnamed element";
  @published String min = "0";
  @published String max = "10";
  @published String step = "1.0";
  @published String min_v = "1";
  @published String max_v = "9";
  @published String integer = "false";

  MinMax.created() : super.created();

  @published void randomize(math.Random r) {
    var dMax = double.parse(max);
    var dMin = double.parse(min);
    var s = double.parse(step);
    var steps = ((dMax - dMin) / s + 1).round();
    var one = r.nextInt(steps);
    var two = r.nextInt(steps);
    // XXX
    // if we add to, e.g, 0.0 integer amount of 0.05 steps, we can
    // get something like 0.85000....001, so let's cut extra digits
    var tmp1 = (dMin + one * s).toStringAsPrecision(5);
    var tmp2 = (dMin + two * s).toStringAsPrecision(5);
    // XXX and double.parse would remove extra 0s at the end
    if (two > one) {
      min_v = "${double.parse(tmp1)}";
      max_v = "${double.parse(tmp2)}";
    } else {
      min_v = "${double.parse(tmp2)}";
      max_v = "${double.parse(tmp1)}";
    }
    if (integer == "true") {
      min_v = "${double.parse(min_v).round()}";
      max_v = "${double.parse(max_v).round()}";
    }
  }
}
