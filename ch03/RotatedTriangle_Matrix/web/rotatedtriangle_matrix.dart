import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:math';

import 'gl_lib.dart';

// Vertex shader program
var VSHADER_SOURCE =
  'attribute vec4 a_Position;\n' +
  'uniform mat4 u_xformMatrix;\n' +
  'void main() {\n' +
  '  gl_Position = u_xformMatrix * a_Position;\n' +
  '}\n';

// Fragment shader program
var FSHADER_SOURCE =
  'void main() {\n' +
  '  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n' +
  '}\n';

// The rotation angle
var ANGLE = 90.0;

int initVertexBuffers(gl, program) {
  
  Float32List vertices = new Float32List(6);
  vertices.setAll(0, [0.0, 0.5,   -0.5, -0.5,   0.5, -0.5]);
  
  var n = 3; // The number of vertices

  // Create a buffer object
  var vertexBuffer = gl.createBuffer();
  if (vertexBuffer == null) {
    print('Failed to create the buffer object');
    return -1;
  }

  // Bind the buffer object to target
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  // Write date into the buffer object
  gl.bufferData(ARRAY_BUFFER, vertices, STATIC_DRAW);

  var a_Position = gl.getAttribLocation(program, 'a_Position');
  if (a_Position < 0) {
    print('Failed to get the storage location of a_Position');
    return -1;
  }
  // Assign the buffer object to a_Position variable
  gl.vertexAttribPointer(a_Position, 2, FLOAT, false, 0, 0);

  // Enable the assignment to a_Position variable
  gl.enableVertexAttribArray(a_Position);

  return n;
}

void main() {
  
  // Retrieve <canvas> element
  var canvas = querySelector("#webgl");
  
  if (canvas == null) {
    print('Failed to retrieve the <canvas> element');
  }
  
  // Get the rendering context for WebGL
  RenderingContext gl = canvas.getContext3d();
  
  if (gl == null) {
    print('Failed to get the rendering context for WebGL');
    return;
  }

  // Initialize shaders
  Program program = initShaders(gl, VSHADER_SOURCE, FSHADER_SOURCE);
  if (program == null) {
    print('Failed to intialize shaders.');
    return;
  }  

  // Write the positions of vertices to a vertex shader
  var n = initVertexBuffers(gl, program);
  if (n < 0) {
    print('Failed to set the positions of the vertices');
    return;
  }

  // Create a rotation matrix
  var radian = PI * ANGLE / 180.0; // Convert to radians
  var cosB = cos(radian), sinB = sin(radian);
  
  Float32List xformMatrix = new Float32List(16);
  xformMatrix.setAll(0, [
   cosB, sinB, 0.0, 0.0,
   -sinB, cosB, 0.0, 0.0,
   0.0,  0.0, 1.0, 0.0,
   0.0,  0.0, 0.0, 1.0
   ]);
  
  // Pass the rotation matrix to the vertex shader
  UniformLocation u_xformMatrix = gl.getUniformLocation(program, 'u_xformMatrix');
  if (u_xformMatrix == null) {
    print('Failed to get the storage location of u_xformMatrix');
    return;
  }
  gl.uniformMatrix4fv(u_xformMatrix, false, xformMatrix);
  
  // Specify the color for clearing <canvas>
  gl.clearColor(0, 0, 0, 1);

  // Clear <canvas>
  gl.clear(COLOR_BUFFER_BIT);

  // Draw three points
  gl.drawArrays(TRIANGLES, 0, n);
}