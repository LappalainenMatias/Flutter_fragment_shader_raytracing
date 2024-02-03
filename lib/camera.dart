import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math' as Math;
class Camera {
  Vector3 position;
  late Vector3 forward;
  late Vector3 up;
  late Vector3 right;
  double fieldOfView;
  double aspectRatio;

  Camera({
    required this.position,
    required this.forward,
    Vector3? up,
    this.fieldOfView = 90, // Default field of view in degrees
    this.aspectRatio = 1.0, // Default aspect ratio
  }) {
    if (kDebugMode) {
      print("camera created");
    }
    forward.normalize();
    this.up = (up ?? Vector3(0, 1, 0)).normalized();
    right = forward.cross(this.up).normalized();
  }

  Ray getRay(double x, double y) {
    // Convert (x, y) from screen space to camera space
    var screenX = (2 * x - 1) * Math.tan(fieldOfView / 2 * Math.pi / 180) * aspectRatio;
    var screenY = 1 - 2 * y;
    var direction = (forward + right * screenX + up * screenY).normalized();

    return Ray.originDirection(position, direction);
  }

  void rotateRight(double amount) {
    var rotation = Matrix4.rotationY(amount);
    forward = rotation.transform3(forward).normalized();
    up = rotation.transform3(up).normalized();
    right = forward.cross(up).normalized();
  }

  void rotateUp(double amount) {
    var rotation = Matrix4.rotationX(amount);
    forward = rotation.transform3(forward).normalized();
    up = rotation.transform3(up).normalized();
    right = forward.cross(up).normalized();
  }

  void moveForward() {
    position += forward;
  }

  void moveBackward() {
    position -= forward;
  }

  void moveRight() {
    position += right;
  }

  void moveLeft() {
    position -= right;
  }
}
