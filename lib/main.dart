import 'dart:ui';

import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:computer_graphics/ray_triangle_intersection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'camera.dart';

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
  var camera =
      Camera(position: vm.Vector3(-2, 0, 0), forward: vm.Vector3(1, 0, 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyA) {
              camera.rotateLeft();
            } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
              camera.rotateRight();
            } if (event.logicalKey == LogicalKeyboardKey.keyW) {
              camera.rotateUp();
            } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
              camera.rotateDown();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              camera.moveForward();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              camera.moveBackward();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              camera.moveRight();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              camera.moveLeft();
            }
          }
        },
        child: ShaderBuilder(
          assetKey: 'shaders/raytracing.frag',
          (context, rayTracingShader, child) => CustomPaint(
            size: Size.infinite,
            painter: MyCustomPainter(HermiteBasis(0, 1, 1, 2)..animate(),
                camera, rayTracingShader),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Camera camera;
  final HermiteBasis hermiteBasis;
  final BezierCurve bezierCurve = BezierCurve(0, 1.5, -1, 0);
  final FragmentShader _rayTracing;

  MyCustomPainter(this.hermiteBasis, this.camera, this._rayTracing)
      : super(repaint: hermiteBasis);

  @override
  void paint(Canvas canvas, Size size) {
    camera.aspectRatio = size.width / size.height;
    //uniform vec3 uCameraPosition;
    _rayTracing.setFloat(0, camera.position.x);
    _rayTracing.setFloat(1, camera.position.y);
    _rayTracing.setFloat(2, camera.position.z);
    //uniform vec3 uCameraForward;
    _rayTracing.setFloat(3, camera.forward.x);
    _rayTracing.setFloat(4, camera.forward.y);
    _rayTracing.setFloat(5, camera.forward.z);
    //uniform vec3 uCameraRight;
    _rayTracing.setFloat(6, camera.right.x);
    _rayTracing.setFloat(7, camera.right.y);
    _rayTracing.setFloat(8, camera.right.z);
    //uniform vec3 uCameraUp;
    _rayTracing.setFloat(9, camera.up.x);
    _rayTracing.setFloat(10, camera.up.y);
    _rayTracing.setFloat(11, camera.up.z);
    //uniform float uFieldOfView;
    _rayTracing.setFloat(12, camera.fieldOfView);
    //uniform float uAspectRatio;
    _rayTracing.setFloat(13, camera.aspectRatio);
    //uniform vec2 uResolution;
    _rayTracing.setFloat(14, size.width);
    _rayTracing.setFloat(15, size.height);
    var paint = Paint()..color = Colors.green;
    paint.shader = _rayTracing;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    //for (int y = 0; y < size.height; y++) {
    //  for (int x = 0; x < size.width; x++) {
    //    // Normalize x and y to be between 0 and 1
    //    double normalizedX = x / size.width;
    //    double normalizedY = y / size.height;
    //
    //    // Get the ray from the camera for this pixel
    //    vm.Ray ray = camera.getRay(normalizedX, normalizedY);
    //
    //    // Check for intersections with the scene
    //    vm.Vector3? coord = intersection(ray, triangle);
    //
    //    if (coord != null) {
    //      // Draw the pixel
    //      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 1.0,
    //          Paint()..color = Colors.red);
    //    } else {
    //      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 1.0,
    //          Paint()..color = Colors.blue);
    //    }
    //  }
    //}
    //canvas.translate(100, 200);
    //canvas.scale(100, -100);
    //for (var t = 0.0; t <= 1.01; t += 0.01) {
    //  var y = bezierCurve.calculate(t);
    //  canvas.drawCircle(Offset(t, y), 0.05, Paint()..color = Colors.red);
    //}
    //canvas.drawCircle(Offset(0, bezierCurve.p1), 0.05, Paint()..color = Colors.black);
    //canvas.drawCircle(Offset(0.33, bezierCurve.p2), 0.05, Paint()..color = Colors.black);
    //canvas.drawCircle(Offset(0.67, bezierCurve.p3), 0.05, Paint()..color = Colors.black);
    //canvas.drawCircle(Offset(1, bezierCurve.p4), 0.05, Paint()..color = Colors.black);
    //
    //Path2D path = Path2D();
    //path.bezierCurveTo(0, 1.5, -1, 0, 0, 0);
    //print(path);
    //canvas.drawPath(path, Paint()..color = Colors.green);
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
