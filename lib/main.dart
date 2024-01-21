import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: CustomPaint(
          painter: MyCustomPainter(HermiteBasis(0, 1, 1, 2)..animate()),
        ));
  }
}

class MyCustomPainter extends CustomPainter {

  final HermiteBasis hermiteBasis;

  MyCustomPainter(this.hermiteBasis) : super(repaint: hermiteBasis);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(100, 200);
    canvas.scale(512, 512);
    for (var t = 0.0; t <= 1.01; t += 0.01) {
      var y = hermiteBasis.calculate(t);
      canvas.drawCircle(Offset(t, y), 0.05, Paint()..color = Colors.red);
    }
    canvas.drawCircle(Offset(0,hermiteBasis.h0), 0.02, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(1,hermiteBasis.h1), 0.02, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
    return h1 * (- 2 * t * t * t + 3 * t * t);
  }

  double _h2(double t) {
    return h2 * (t * t * t - 2 * t * t + t);
  }

  double _h3(double t) {
    return h3 * (t * t * t - t * t);
  }
}
