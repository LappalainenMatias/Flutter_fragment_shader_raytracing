#include <flutter/runtime_effect.glsl>

precision mediump float;
uniform vec3 uCameraPosition;
uniform vec3 uCameraForward;
uniform vec3 uCameraRight;
uniform vec3 uCameraUp;
uniform float uFieldOfView;
uniform float uAspectRatio;
uniform vec2 uResolution;
out vec4 fragColor;

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

// Function to find intersection of a ray and a triangle
vec3 intersection(vec3 rayO, vec3 rayD) {
    vec3 point0 = vec3(1.0, 0.0, -1.0);
    vec3 point1 = vec3(1.0, -1.0, 1.0);
    vec3 point2 = vec3(1.0, 1.0, 1.0);
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
    float t = tInCramersRule(a, b, c, d, e, f, g, h, i, j, k, l);
    if (t < 0) {
        //print('t = $t');
        return vec3(-1.0);
    }
    float y = yInCramersRule(a, b, c, d, e, f, g, h, i, j, k, l);
    if (y < 0 || y > 1) {
        //print('y = $y');
        return vec3(-1.0);
    }
    float beta = bInCramersRule(a, b, c, d, e, f, g, h, i, j, k, l);
    if (beta < 0 || beta > 1 - y) {
        //print('beta = $beta');
        return vec3(-1.0);
    }
    return rayO + rayD * t;//
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


void main() {
    // Generate the ray for the current fragment
    float normalizedX = gl_FragCoord.xy.x / uResolution.x;
    float normalizedY = gl_FragCoord.xy.y / uResolution.y;
    vec2 normalized = vec2(normalizedX, normalizedY);
    vec3 direction = getRay(normalized);

    // Check for intersection with the triangle
    vec3 intersectionPoint = intersection(uCameraPosition, direction);
    bool hit = intersectionPoint.x != -1.0;

    // Set fragment color based on intersection
    if (hit) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);// Black for intersection
    } else {
        fragColor = vec4(0.0, 0.0, 1.0, 1.0);// Blue for no intersection
    }
}
