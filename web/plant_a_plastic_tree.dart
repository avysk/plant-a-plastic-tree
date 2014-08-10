import 'dart:html';
import 'dart:math' as math;
import 'package:polymer/polymer.dart';

math.Random r = new math.Random(2014);

const int MAX_BRANCHES = 2500000;
int branchesDrawn = 0;

void main() {
  querySelector("#go").onClick.listen(renderTree);
  initPolymer();

  // Looks like we have a bug in Chromium; range inputs with step not equal
  // to 1.0 do not setup their position correctly from HTML
  var elt = querySelector("#prob");
  elt.value = "0.25";

  elt = querySelector("#mult");
  elt.min_v = "0.1";
  elt.max_v = "0.65";

  elt = querySelector("#cont");
  elt.value = "0.8";

  elt = querySelector("#contmult");
  elt.min_v = "0.5";
  elt.max_v = "0.8";

  elt = querySelector("#smooth0");
  elt.value = "0.3";

  elt = querySelector("#smooth1");
  elt.value = "0.2";

  elt = querySelector("#red");
  elt.min_v = "0.1";
  elt.max_v = "0.2";

  elt = querySelector("#green");
  elt.min_v = "0.7";
  elt.max_v = "1.0";

  elt = querySelector("#blue");
  elt.min_v = "0.0";
  elt.max_v = "0.1";
}

void renderTree(e) {
  // Change the button text
  var elt = querySelector("#go");
  elt.text = "Wait!";
  var c = querySelector("#c");
  CanvasRenderingContext2D ctx = c.getContext("2d");
  ctx.clearRect(0, 0, c.width, c.height);
  window.animationFrame.then(renderTreeImpl);
}

void finishRender(ignored_delta) {
  // Change the button text back
  var elt = querySelector("#go");
  elt.text = "Draw!";
}

void renderTreeImpl(ignored_delta) {

  // Get the parameters
  //
  // Number of branches
  var elt = querySelector("#levels");
  var nMin = int.parse(elt.min_v);
  var nMax = int.parse(elt.max_v);

  // Probability of not branching
  elt = querySelector("#prob");
  var pTerm = double.parse(elt.value);

  // Number of branches
  elt = querySelector("#branches");
  var branchesMin = int.parse(elt.min_v);
  var branchesMax = int.parse(elt.max_v);

  // Angle of branches
  elt = querySelector("#angles");
  var angleMin = toRad(int.parse(elt.min_v));
  var angleMax = toRad(int.parse(elt.max_v));

  // Length multiplier
  elt = querySelector("#mult");
  var multMin = double.parse(elt.min_v);
  var multMax = double.parse(elt.max_v);

  // Probability of continuation
  elt = querySelector("#cont");
  var pCont = double.parse(elt.value);

  // Length multiplier for continuation
  elt = querySelector("#contmult");
  var contMultMin = double.parse(elt.min_v);
  var contMultMax = double.parse(elt.max_v);

  // Smoothness of branches
  elt = querySelector("#smooth0");
  var lambda0 = double.parse(elt.value);
  elt = querySelector("#smooth1");
  var lambda1 = double.parse(elt.value);

  // Leaf colors
  var colors = new Map();
  for (var col in ["red", "green", "blue"]) {
    elt = querySelector("#$col");
    var colMin = double.parse(elt.min_v);
    var colMax = double.parse(elt.max_v);
    colors["$col-min"] = colMin;
    colors["$col-max"] = colMax;
  }

  var c = querySelector("#c");
  CanvasRenderingContext2D ctx = c.getContext("2d");
  ctx.clearRect(0, 0, c.width, c.height);

  branchesDrawn = 0;

  DateTime begin = new DateTime.now();
  drawTree(ctx,
      c.width / 2, c.height - 10, // root position
      -math.PI / 2, -math.PI / 2, // start growing up (screen coordinate system!)
      180.0, // first branch length
      1, // this is the first branch
      nMin, nMax, // number of layers
      pTerm, // probability of non-branching
      branchesMin, branchesMax, // number of branches
      angleMin, angleMax, // angles for branches
      multMin, multMax, // multiplier for branch length
      pCont, contMultMin, contMultMax, // continuation parameters
      lambda0, lambda1, // smoothness of branches
      colors);
  DateTime end = new DateTime.now();
  Duration elapsed = end.difference(begin);

  var info = querySelector("#info");
  info.text ="Branches: $branchesDrawn Elapsed time: ${elapsed.inSeconds}s";

  window.animationFrame.then(finishRender);
}

void drawTree(CanvasRenderingContext2D ctx, num x0, num y0,
    num alpha, num alpha0,
    num branchLength, int n, int nMin, int nMax,
    num pTerminate,
    int branchesMin, int branchesMax, num angleMin, num angleMax,
    num multMin, num multMax,
    num pCont, num contMultMin, num contMultMax,
    num lambda0, num lambda1, colors) {

  branchesDrawn += 1;
  if (branchesDrawn == MAX_BRANCHES) emergencyMessage();

  if (n > nMax) {
    drawLeaf(ctx, x0, y0, 1, colors);
  } else {

    // draw this branch

    // FIXME: something hardcoded for visuals
    ctx.lineWidth = (nMax - n + 1) / 2;
    var transparency = 0.2 + 0.8 * (nMax - n) / (nMax - 1);
    ctx.setStrokeColorRgb(0, 0, 0, transparency);

    // start path at branch start
    ctx.beginPath();
    ctx.moveTo(x0, y0);

    num ca = branchLength * math.cos(alpha);
    num sa = branchLength * math.sin(alpha);

    // determine the branch end
    num x1 = x0 + ca;
    num y1 = y0 + sa;

    // direction vectors
    num cp0x = x0 + branchLength * math.cos(alpha0) * lambda0;
    num cp0y = y0 + branchLength * math.sin(alpha0) * lambda0;
    num cp1x = x1 - ca * lambda1;
    num cp1y = y1 - sa * lambda1;

    ctx.bezierCurveTo(cp0x, cp0y, cp1x, cp1y, x1, y1);
    ctx.stroke();

    // check if we must to continue the branch
    if (r.nextDouble() <= pCont) {
      var mult = contMultMin + r.nextDouble() * (contMultMax - contMultMin);
      drawTree(ctx, x1, y1, alpha, alpha, branchLength * mult,
          n + 1, nMin, nMax, pTerminate, branchesMin, branchesMax,
          angleMin, angleMax, multMin, multMax,
          pCont, contMultMin, contMultMax,
          lambda0, lambda1, colors);
    }

    // terminate if we must
    if ((n > nMin) && (r.nextDouble() < pTerminate)) {
      drawLeaf(ctx, x1, y1, nMax - n + 1, colors);
      return;
    }

    var branches = r.nextInt(branchesMax - branchesMin + 1) + branchesMin;

    for (var i = 0; i < branches; i++) {

      // Check for emergency
      if (branchesDrawn >= MAX_BRANCHES) return;

      var mult = multMin + r.nextDouble() * (multMax - multMin);
      var beta = angleMin + r.nextDouble() * (angleMax - angleMin);
      if (r.nextBool()) beta = -beta;

      drawTree(ctx, x1, y1, alpha + beta, alpha, branchLength * mult, n + 1, nMin,
          nMax, pTerminate, branchesMin, branchesMax, angleMin, angleMax, multMin,
          multMax,
          pCont, contMultMin, contMultMax,
          lambda0, lambda1, colors);
    }
  }
}

double toRad(int degs) => math.PI / 180 * degs;

void drawLeaf(CanvasRenderingContext2D ctx, num x, num y, num radius, colors) {
  setRandomColor(ctx, colors);
  ctx.beginPath();
  ctx.arc(x, y, 2 * radius, 0, math.PI * 2, true);
  ctx.fill();
}

void setRandomColor(CanvasRenderingContext2D ctx, colors) {
  var res = new Map();
  for (var c in ["red", "green", "blue"]) {
    var cMin = colors["$c-min"];
    var cMax = colors["$c-max"];
    res["$c"] = (255 * (cMin + r.nextDouble() * (cMax - cMin))).round();
  }
  ctx.setFillColorRgb(res["red"], res["green"], res["blue"]);
}

void emergencyMessage() {
  window.alert("Stopped after $MAX_BRANCHES branches.");
}