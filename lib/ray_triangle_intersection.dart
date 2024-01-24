import 'package:vector_math/vector_math.dart';

Vector3? intersection(Ray ray, Triangle triangle) {
  double a = triangle.point0.x - triangle.point1.x;
  double b = triangle.point0.y - triangle.point1.y;
  double c = triangle.point0.z - triangle.point1.z;
  double d = triangle.point0.x - triangle.point2.x;
  double e = triangle.point0.y - triangle.point2.y;
  double f = triangle.point0.z - triangle.point2.z;
  double g = ray.direction.x;
  double h = ray.direction.y;
  double i = ray.direction.z;
  double j = triangle.point0.x - ray.origin.x;
  double k = triangle.point0.y - ray.origin.y;
  double l = triangle.point0.z - ray.origin.z;
  var t = tInCramersRule(a, b, c, d, e, f, g, h, i, j, k, l);
  if (t < 0) {
    //print('t = $t');
    return null;
  }
  var y = yInCramersRule(a, b, c, d, e, f, g, h, i, j, k, l);
  if (y < 0 || y > 1) {
    //print('y = $y');
    return null;
  }
  var beta = bInCramersRule(a, b, c, d, e, f, g, h, i, j, k, l);
  if (beta < 0 || beta > 1 - y) {
    //print('beta = $beta');
    return null;
  }
  return ray.origin + ray.direction * t;
}

double tInCramersRule(double a, double b, double c, double d, double e,
    double f, double g, double h, double i, double j, double k, double l) {
  return -(f * (a * k - j * b) + e * (j * c - a * l) + d * (b * l - k * c)) /
      mInCramersRule(a, b, c, d, e, f, g, h, i);
}

double yInCramersRule(double a, double b, double c, double d, double e,
    double f, double g, double h, double i, double j, double k, double l) {
  return (i * (a * k - j * b) + h * (j * c - a * l) + g * (b * l - k * c)) /
      mInCramersRule(a, b, c, d, e, f, g, h, i);
}

double bInCramersRule(double a, double b, double c, double d, double e,
    double f, double g, double h, double i, double j, double k, double l) {
  return (j * (e * i - h * f) + k * (g * f - d * i) + l * (d * h - e * g)) /
      mInCramersRule(a, b, c, d, e, f, g, h, i);
}

double mInCramersRule(double a, double b, double c, double d, double e,
    double f, double g, double h, double i) {
  return a * (e * i - h * f) + b * (g * f - d * i) + c * (d * h - e * g);
}
