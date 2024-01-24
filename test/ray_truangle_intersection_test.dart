import 'package:computer_graphics/camera.dart';
import 'package:computer_graphics/ray_triangle_intersection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('ray triangle intersection', () {
    var ray = Ray.originDirection(Vector3(0, 0, 0), Vector3(1, 0, 0));
    var triangle =
        Triangle.points(Vector3(1, 0, -1), Vector3(1, -1, 1), Vector3(1, 1, 1));
    var coord = intersection(ray, triangle);
    print(coord);
  });

  test('Camera', () {
    var camera = Camera(position: Vector3(0,0,0), forward: Vector3(1,0,0));
    var ray = camera.getRay(0, 0);
    print(ray.direction);
  });
}
