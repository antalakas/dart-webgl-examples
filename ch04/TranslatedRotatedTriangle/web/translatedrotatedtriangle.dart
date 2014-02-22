import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

import 'gl_utils.dart';
import 'gl_matrix.dart';

// Vertex shader program
var VSHADER_SOURCE =
  'attribute vec4 a_Position;\n' +
  'uniform mat4 u_ModelMatrix;\n' +
  'void main() {\n' +
  '  gl_Position = u_ModelMatrix * a_Position;\n' +
  '}\n';

// Fragment shader program
var FSHADER_SOURCE =
  'void main() {\n' +
  '  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n' +
  '}\n';

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

// The translation distance for x, y, and z direction
var Tx = 0.5, Ty = 0.5, Tz = 0.0;

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

  // Create Matrix4 object for model transformation    
  var modelMatrix = new Matrix4();

  // Calculate a model matrix
  var ANGLE = 60.0; // The rotation angle
  var Tx = 0.5;     // Translation distance
  modelMatrix.setTranslate(Tx, 0.0, 0.0);  // Set translation matrix
  modelMatrix.setRotate(ANGLE, 0.0, 0.0, 1.0);  // Multiply modelMatrix by the calculated rotation matrix

  // Pass the model matrix to the vertex shader
  UniformLocation u_ModelMatrix = gl.getUniformLocation(program, 'u_ModelMatrix');
  if (u_ModelMatrix == null) {
    print('Failed to get the storage location of u_xformMatrix');
    return;
  }
  gl.uniformMatrix4fv(u_ModelMatrix, false, modelMatrix.elements);
  
  // Specify the color for clearing <canvas>
  gl.clearColor(0, 0, 0, 1);

  // Clear <canvas>
  gl.clear(COLOR_BUFFER_BIT);

  // Draw three points
  gl.drawArrays(TRIANGLES, 0, n);
}