#version 460 core

#include <flutter/runtime_effect.glsl>

precision mediump float;
uniform vec3 uCameraPosition;
uniform vec3 uCameraForward;
uniform vec3 uCameraRight;
uniform vec3 uCameraUp;
uniform float uFieldOfView;
uniform float uAspectRatio;
uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform float triangleCount;
out vec4 fragColor;

float minDistance = 1000000.0; // Large initial value
int closestTriangle = -1; // -1 indicates no intersection

float mInCramersRule(float a, float b, float c, float d, float e, float f, float g, float h, float i) {
    return a * (e * i - h * f) + b * (g * f - d * i) + c * (d * h - e * g);
}

float tInCramersRule(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l) {
    return -(f * (a * k - j * b) + e * (j * c - a * l) + d * (b * l - k * c)) / mInCramersRule(a, b, c, d, e, f, g, h, i);
}

float yInCramersRule(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l) {
    return (i * (a * k - j * b) + h * (j * c - a * l) + g * (b * l - k * c)) / mInCramersRule(a, b, c, d, e, f, g, h, i);
}

float bInCramersRule(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l) {
    return (j * (e * i - h * f) + k * (g * f - d * i) + l * (d * h - e * g)) / mInCramersRule(a, b, c, d, e, f, g, h, i);
}

vec3 getPointFromPixel(int index) {
    float yCoord = (float(index) * 2 + 1) / float(triangleCount * 3 * 2);
    return texture(uTexture, vec2(0.5, yCoord)).xyz * 255.0;
}

vec3 intersection(vec3 rayO, vec3 rayD, int triangle) {
    vec3 point0 = getPointFromPixel(triangle + 0);
    vec3 point1 = getPointFromPixel(triangle + 1);
    vec3 point2 = getPointFromPixel(triangle + 2);
    float a = point0.x - point1.x;
    float b = point0.y - point1.y;
    float c = point0.z - point1.z;
    float d = point0.x - point2.x;
    float e = point0.y - point2.y;
    float f = point0.z - point2.z;
    float g = rayD.x;
    float h = rayD.y;
    float i = rayD.z;
    float j = point0.x - rayO.x;
    float k = point0.y - rayO.y;
    float l = point0.z - rayO.z;
    float m = a * (e * i - h * f) + b * (g * f - d * i) + c * (d * h - e * g);
    float t = -(f * (a * k - j * b) + e * (j * c - a * l) + d * (b * l - k * c)) / m;
    vec3 res = vec3(-1.0);
    if (t < 0) {
        return vec3(-1.0);
    }
    float y = (i * (a * k - j * b) + h * (j * c - a * l) + g * (b * l - k * c)) / m;
    if (y < 0 || y > 1) {
        return vec3(-1.0);
    }
    float beta = (j * (e * i - h * f) + k * (g * f - d * i) + l * (d * h - e * g)) / m;
    if (beta < 0 || beta > 1 - y) {
        return vec3(-1.0);
    }
    return rayO + rayD * t;
}

vec3 getRay(vec2 fragCoord) {
    // Use fragment coordinates directly for ray direction calculations
    // Assuming fragCoord is already in the range you need for your scene

    // Calculate the screen space coordinates
    float screenX = (fragCoord.x - 0.5) * tan(radians(uFieldOfView) * 0.5);
    float screenY = (fragCoord.y - 0.5);

    // Calculate the direction of the ray
    vec3 direction = normalize(uCameraForward + uCameraRight * screenX + uCameraUp * screenY);

    return direction;
}

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main() {
    // Generate the ray for the current fragment
    float normalizedX = gl_FragCoord.xy.x / uResolution.x;
    float normalizedY = gl_FragCoord.xy.y / uResolution.y;
    vec2 normalized = vec2(normalizedX, normalizedY);
    vec3 direction = getRay(normalized);

    float minDistance = 1000000.0;
    int closestTriangle = -1;

    for (int triangle = 0; triangle < 256; triangle++) {
        if (triangle >= triangleCount) {
            break;
        }
        vec3 ip = intersection(uCameraPosition, direction, triangle * 3);

        // Check for the closest intersection
        if (ip.x != -1.0) {
            float distance = length(ip - uCameraPosition);
            if (distance < minDistance) {
                minDistance = distance;
                closestTriangle = triangle + 1;
            }
        }
    }

    if (closestTriangle > 0) {
        float r = hash(float(closestTriangle) * 12.9898);
        float g = hash(float(closestTriangle) * 78.233);
        float b = hash(float(closestTriangle) * 45.164);

        fragColor = vec4(r, g, b, 1.0);
    } else {
        fragColor = vec4(0, 0, 0, 1.0);
    }
}
