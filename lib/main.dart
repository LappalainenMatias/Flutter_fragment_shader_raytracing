import 'dart:math';
import 'dart:ui' as ui;
import 'package:computer_graphics/light.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'camera.dart';
import 'model_to_image.dart';

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
      Camera(position: vm.Vector3(-4, -5, -4), forward: vm.Vector3(1, 1, 1));

  Future<ui.Image> _createImage() async {
    final List<vm.Vector3> movedBox1 = box.map((v) {
      return vm.Vector3(v.x + 2, v.y, v.z);
    }).toList();
    final List<vm.Vector3> movedBox2 = box.map((v) {
      return vm.Vector3(v.x + 2, v.y + 2, v.z);
    }).toList();
    final List<vm.Vector3> movedBox3 = box.map((v) {
      return vm.Vector3(v.x, v.y + 2, v.z);
    }).toList();
    final List<vm.Vector3> movedBox4 = box.map((v) {
      return vm.Vector3(v.x, v.y, v.z + 2);
    }).toList();
    final List<vm.Vector3> movedBox5 = box.map((v) {
      return vm.Vector3(v.x + 2, v.y, v.z + 2);
    }).toList();
    final List<vm.Vector3> movedBox6 = box.map((v) {
      return vm.Vector3(v.x, v.y + 2, v.z + 2);
    }).toList();
    final List<vm.Vector3> movedBox7 = box.map((v) {
      return vm.Vector3(v.x + 2, v.y + 2, v.z + 2);
    }).toList();
    var allModelsFlattened = flattenModels([
      box,
      movedBox1,
      //movedBox2,
      //movedBox3,
      //movedBox4,
      //movedBox5,
      //movedBox6,
      //movedBox7
    ]);
    //var normalized = normalizeValues(flattenBox);
    return await createImageFromNormalizedData(allModelsFlattened);
  }

  final List<vm.Vector3> box = [
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
            camera.rotateRight(details.delta.dx * 0.001);
            camera.rotateUp(details.delta.dy * 0.001);
          },
          child: FutureBuilder<ui.Image>(
            future: _createImage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                var modelImage = snapshot.data as ui.Image;
                return ShaderBuilder(
                  assetKey: 'shaders/raytracing.frag',
                  (context, rayTracingShader, child) => SizedBox(
                    width: 500,
                    height: 500,
                    child: Viewer3D(
                      camera,
                      rayTracingShader,
                      modelImage,
                    ),
                  ),
                  child: const SizedBox(),
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: SelectableText(
                        "Error loading image${snapshot.error}"));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}

class Viewer3D extends StatefulWidget {
  final Camera camera;
  final FragmentShader rayTracingShader;
  final ui.Image modelImage;

  const Viewer3D(this.camera, this.rayTracingShader, this.modelImage, {super.key});

  @override
  Viewer3DState createState() => Viewer3DState();
}

class Viewer3DState extends State<Viewer3D>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(() {}))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MyCustomPainter(
        widget.camera,
        widget.rayTracingShader,
        widget.modelImage,
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final lightPoint = LightPoint(position: vm.Vector3(10, 10, 10));
  final Camera camera;
  final FragmentShader _rayTracingShader;
  final ui.Image _image;

  MyCustomPainter(this.camera, this._rayTracingShader, this._image);

  @override
  void paint(Canvas canvas, Size size) {
    camera.aspectRatio = size.width / size.height;
    _rayTracingShader.setFloat(0, camera.position.x);
    _rayTracingShader.setFloat(1, camera.position.y);
    _rayTracingShader.setFloat(2, camera.position.z);
    _rayTracingShader.setFloat(3, camera.forward.x);
    _rayTracingShader.setFloat(4, camera.forward.y);
    _rayTracingShader.setFloat(5, camera.forward.z);
    _rayTracingShader.setFloat(6, camera.right.x);
    _rayTracingShader.setFloat(7, camera.right.y);
    _rayTracingShader.setFloat(8, camera.right.z);
    _rayTracingShader.setFloat(9, camera.up.x);
    _rayTracingShader.setFloat(10, camera.up.y);
    _rayTracingShader.setFloat(11, camera.up.z);
    _rayTracingShader.setFloat(12, camera.fieldOfView);
    _rayTracingShader.setFloat(13, camera.aspectRatio);
    _rayTracingShader.setFloat(14, size.width);
    _rayTracingShader.setFloat(15, size.height);
    //_rayTracingShader.setFloat(17, lightPoint.position.x);
    //_rayTracingShader.setFloat(18, lightPoint.position.y);
    //_rayTracingShader.setFloat(19, lightPoint.position.z);
    _rayTracingShader.setImageSampler(0, _image);
    _rayTracingShader.setFloat(16, _image.height.toDouble() / 3);
    var paint = Paint()..color = Colors.green;
    paint.shader = _rayTracingShader;
    canvas.drawRect(Rect.fromLTWH(0, 0, 500, 500), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
