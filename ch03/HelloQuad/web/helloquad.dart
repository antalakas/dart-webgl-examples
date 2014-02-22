import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

import 'gl_lib.dart';

// Vertex shader program
var VSHADER_SOURCE =
  'attribute vec4 a_Position;\n' +
  'void main() {\n' +
  '  gl_Position = a_Position;\n' +
  '}\n';

// Fragment shader program
var FSHADER_SOURCE =
  'void main() {\n' +
  '  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n' +
  '}\n';

int initVertexBuffers(gl, program) {
  
  Float32List vertices = new Float32List(8);
  vertices.setAll(0, [-0.5, 0.5,  -0.5, -0.5,  0.5, 0.5,  0.5, -0.5]);
  
  var n = 4; // The number of vertices

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

  // Specify the color for clearing <canvas>
  gl.clearColor(0, 0, 0, 1);

  // Clear <canvas>
  gl.clear(COLOR_BUFFER_BIT);

  // Draw three points
  gl.drawArrays(TRIANGLE_STRIP, 0, n);
}