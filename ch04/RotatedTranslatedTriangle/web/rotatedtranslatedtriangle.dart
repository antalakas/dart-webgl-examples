import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

import 'gl_utils.dart';
import 'gl_matrix.dart';

class RotatedTranslatedTriangle {
  // Vertex shader program
  String VSHADER_SOURCE =
    'attribute vec4 a_Position;\n' +
    'uniform mat4 u_ModelMatrix;\n' +
    'void main() {\n' +
    '  gl_Position = u_ModelMatrix * a_Position;\n' +
    '}\n';
  
  // Fragment shader program
  String FSHADER_SOURCE =
    'void main() {\n' +
    '  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n' +
    '}\n';
  
  // gl
  RenderingContext gl;
  
  //The number of vertices
  int n;
  
  RotatedTranslatedTriangle() {
    // Retrieve <canvas> element
    var canvas = querySelector("#webgl");
    
    if (canvas == null) {
      print('Failed to retrieve the <canvas> element');
    }
    
    // Get the rendering context for WebGL
    gl = canvas.getContext3d();
    
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
    n = initVertexBuffers(gl, program);
    if (n < 0) {
      print('Failed to set the positions of the vertices');
      return;
    }

    // Create Matrix4 object for model transformation
    Matrix4 modelMatrix = new Matrix4();

    // Calculate a model matrix
    num ANGLE = 60.0; // The rotation angle
    num Tx = 0.5;     // Translation distance
    modelMatrix.setRotate(ANGLE, 0, 0, 1);  // Set rotation matrix
    modelMatrix.translate(Tx, 0, 0);        // Multiply modelMatrix by the calculated translation matrix

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

    // Draw the rectangle
    gl.drawArrays(TRIANGLES, 0, n);
  }
  
  int initVertexBuffers(RenderingContext gl, Program program) {
    
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

    // Assign the buffer object to a_Position variable
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
}

void main() {
  new RotatedTranslatedTriangle();
}

