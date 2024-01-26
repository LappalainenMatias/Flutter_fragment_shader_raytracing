import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_shaders/flutter_shaders.dart';
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
      Camera(position: vm.Vector3(-400, -500, -400), forward: vm.Vector3(1, 1, 1));

  late ui.Image imageOfBox;

  Float32List flattenPoints(List<vm.Vector3> points) {
    Float32List floatList = Float32List(points.length * 3);
    for (int i = 0; i < points.length; i++) {
      floatList[i * 3] = points[i].x;
      floatList[i * 3 + 1] = points[i].y;
      floatList[i * 3 + 2] = points[i].z;
    }
    return floatList;
  }

  Future<ui.Image> _createImage() async {
    var flattenBox = flattenPoints(box); // Ensure box is defined and populated
    //var normalized = normalizeValues(flattenBox);
    return await createImageFromNormalizedData(flattenBox);
  }

  List<vm.Vector3> box = [
    // Front face
    vm.Vector3(0, 0, 1), vm.Vector3(1, 0, 1), vm.Vector3(1, 1, 1),
    vm.Vector3(0, 0, 1), vm.Vector3(1, 1, 1), vm.Vector3(0, 1, 1),

    // Back face
    vm.Vector3(1, 0, 0), vm.Vector3(0, 0, 0), vm.Vector3(0, 1, 0),
    vm.Vector3(1, 0, 0), vm.Vector3(0, 1, 0), vm.Vector3(1, 1, 0),
    //
    //// Left face
    vm.Vector3(0, 0, 0), vm.Vector3(0, 0, 1), vm.Vector3(0, 1, 1),
    vm.Vector3(0, 0, 0), vm.Vector3(0, 1, 1), vm.Vector3(0, 1, 0),
    //
    //// Right face
    vm.Vector3(1, 0, 1), vm.Vector3(1, 0, 0), vm.Vector3(1, 1, 0),
    vm.Vector3(1, 0, 1), vm.Vector3(1, 1, 0), vm.Vector3(1, 1, 1),
    //
    //// Top face
    vm.Vector3(0, 1, 1), vm.Vector3(1, 1, 1), vm.Vector3(1, 1, 0),
    vm.Vector3(0, 1, 1), vm.Vector3(1, 1, 0), vm.Vector3(0, 1, 0),
    //
    //// Bottom face
    vm.Vector3(0, 0, 0), vm.Vector3(1, 0, 0), vm.Vector3(1, 0, 1),
    vm.Vector3(0, 0, 0), vm.Vector3(1, 0, 1), vm.Vector3(0, 0, 1),
  ];


  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: 500,
        height: 500,
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
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
          child: GestureDetector(
            onPanUpdate: (details) {
              camera.rotateRight(details.delta.dx * 0.001); // sensitivity is a scaling factor for the movement
              camera.rotateUp(details.delta.dy * 0.001);
            },
            child: FutureBuilder<ui.Image>(
              future: _createImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  var image = snapshot.data as ui.Image;
                  return ShaderBuilder(
                    assetKey: 'shaders/raytracing.frag',
                    (context, rayTracingShader, child) => CustomPaint(
                      size: Size.infinite,
                      painter: MyCustomPainter(
                          HermiteBasis(0, 1, 1, 2)..animate(),
                          camera,
                          rayTracingShader,
                          image),
                    ),
                    child: const SizedBox(),
                  );
                } else if (snapshot.hasError) {
                  // Handle the error, e.g., show an error message
                  return Center(
                      child: SelectableText(
                          "Error loading image" + snapshot.error.toString()));
                } else {
                  // While the image is loading, show a progress indicator
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// One pixel contains one vertex with 3 floats (x, y, z) for the position
Future<ui.Image> createImageFromNormalizedData(Float32List normalizedData) async {
  int numPixels = (normalizedData.length / 3).floor();
  assert(normalizedData.length / 3 <= numPixels);

  Uint8List pixelData = Uint8List(numPixels * 4);
  for (int i = 0; i < normalizedData.length; i += 3) {
    int j = (i / 3).floor() * 4;
    // Mapping x, y, z to R, G, B
    pixelData[j] = (normalizedData[i] * 255).toInt(); // R
    pixelData[j + 1] = (normalizedData[i + 1] * 255).toInt(); // G
    pixelData[j + 2] = (normalizedData[i + 2] * 255).toInt(); // B
    pixelData[j + 3] = 0; // A (full opacity)
  }

  ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(pixelData);

  ui.ImageDescriptor imageDescription = ui.ImageDescriptor.raw(buffer,
      height: numPixels, width: 1, pixelFormat: ui.PixelFormat.rgba8888);
  var codec = await imageDescription.instantiateCodec(targetWidth: 1);
  var frame = await codec.getNextFrame();
  print((await frame.image.toByteData().then((value) => value!.buffer.asInt8List())));
  return frame.image;
}

class MyCustomPainter extends CustomPainter {
  final Camera camera;
  final HermiteBasis hermiteBasis;
  final BezierCurve bezierCurve = BezierCurve(0, 1.5, -1, 0);
  final FragmentShader _rayTracing;
  final ui.Image _image;

  MyCustomPainter(this.hermiteBasis, this.camera, this._rayTracing, this._image)
      : super(repaint: hermiteBasis);

  @override
  void paint(Canvas canvas, Size size) {
    camera.aspectRatio = size.width / size.height;
    _rayTracing.setFloat(0, camera.position.x);
    _rayTracing.setFloat(1, camera.position.y);
    _rayTracing.setFloat(2, camera.position.z);
    _rayTracing.setFloat(3, camera.forward.x);
    _rayTracing.setFloat(4, camera.forward.y);
    _rayTracing.setFloat(5, camera.forward.z);
    _rayTracing.setFloat(6, camera.right.x);
    _rayTracing.setFloat(7, camera.right.y);
    _rayTracing.setFloat(8, camera.right.z);
    _rayTracing.setFloat(9, camera.up.x);
    _rayTracing.setFloat(10, camera.up.y);
    _rayTracing.setFloat(11, camera.up.z);
    _rayTracing.setFloat(12, camera.fieldOfView);
    _rayTracing.setFloat(13, camera.aspectRatio);
    _rayTracing.setFloat(14, size.width);
    _rayTracing.setFloat(15, size.height);
    _rayTracing.setFloat(16, 12);
    _rayTracing.setImageSampler(0, _image);
    var paint = Paint()..color = Colors.green;
    paint.shader = _rayTracing;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
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
