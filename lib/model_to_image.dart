import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

Float32List flattenModels(List<List<Vector3>> model) {
  List<double> points = [];
  for (int i = 0; i < model.length; i++) {
    for (int j = 0; j < model[i].length; j++) {
      points.add(model[i][j].x);
      points.add(model[i][j].y);
      points.add(model[i][j].z);
    }
  }
  return Float32List.fromList(points);
}

Future<Image> createImageFromNormalizedData(
    Float32List normalizedData) async {
  int numPixels = (normalizedData.length / 3).floor();
  assert(normalizedData.length / 3 <= numPixels);

  Uint8List pixelData = Uint8List(numPixels * 4);
  for (int i = 0; i < normalizedData.length; i += 3) {
    int j = (i / 3).floor() * 4;
    // Mapping x, y, z to R, G, B
    pixelData[j] = (normalizedData[i]).toInt(); // R
    pixelData[j + 1] = (normalizedData[i + 1]).toInt(); // G
    pixelData[j + 2] = (normalizedData[i + 2]).toInt(); // B
    pixelData[j + 3] = 0; // A (full opacity)
  }

  ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(pixelData);

  ImageDescriptor imageDescription = ImageDescriptor.raw(buffer,
      height: numPixels, width: 1, pixelFormat: PixelFormat.rgba8888);
  var codec = await imageDescription.instantiateCodec(targetWidth: 1);
  var frame = await codec.getNextFrame();
  //print((await frame.image
  //    .toByteData()
  //    .then((value) => value!.buffer.asInt8List())));
  if (kDebugMode) {
    print("model created");
  }
  return frame.image;
}