import 'package:flutter/cupertino.dart';

class HermiteBasis extends ChangeNotifier {
  double h0;
  double h1;
  double h2;
  double h3;

  HermiteBasis(this.h0, this.h1, this.h2, this.h3);

  bool goUph0 = true;
  bool goUph1 = true;
  bool goUph3 = true;
  bool goUph2 = true;

  void animate() {
    if (h0 < 0) {
      goUph0 = true;
    }
    if (h0 > 1) {
      goUph0 = false;
    }
    if (goUph0) {
      h0 += 0.0025;
    } else {
      h0 -= 0.0025;
    }
    if (h1 < 0) {
      goUph1 = true;
    }
    if (h1 > 1) {
      goUph1 = false;
    }
    if (goUph1) {
      h1 += 0.005;
    } else {
      h1 -= 0.005;
    }
    if (h3 < -3) {
      goUph3 = true;
    }
    if (h3 > 3) {
      goUph3 = false;
    }
    if (goUph3) {
      h3 += 0.02;
    } else {
      h3 -= 0.02;
    }
    if (h2 < -3) {
      goUph2 = true;
    }
    if (h2 > 3) {
      goUph2 = false;
    }
    if (goUph2) {
      h2 += 0.03;
    } else {
      h2 -= 0.03;
    }

    Future.delayed(Duration(milliseconds: 16), animate);
    notifyListeners();
  }

  double calculate(double t) {
    return _h0(t) + _h1(t) + _h2(t) + _h3(t);
  }

  double _h0(double t) {
    return h0 * (2 * t * t * t - 3 * t * t + 1);
  }

  double _h1(double t) {
    return h1 * (-2 * t * t * t + 3 * t * t);
  }

  double _h2(double t) {
    return h2 * (t * t * t - 2 * t * t + t);
  }

  double _h3(double t) {
    return h3 * (t * t * t - t * t);
  }
}

class BezierCurve {
  double p1;
  double p2;
  double p3;
  double p4;

  BezierCurve(this.p1, this.p2, this.p3, this.p4);

  double calculate(double t) {
    return _p1(t) + _p2(t) + _p3(t) + _p4(t);
  }

  double _p1(double t) {
    return p1 * (1 - t) * (1 - t) * (1 - t);
  }

  double _p2(double t) {
    return p2 * 3 * t * (1 - t) * (1 - t);
  }

  double _p3(double t) {
    return p3 * 3 * t * t * (1 - t);
  }

  double _p4(double t) {
    return p4 * t * t * t;
  }
}