import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

import 'gl_utils.dart';
import 'gl_matrix.dart';

class RotatingTranslatedTriangle {
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
  
  // Model matrix
  UniformLocation u_ModelMatrix;
  
  //The number of vertices
  int n;
  
  // Rotation angle (degrees/second)
  num ANGLE_STEP = 45.0;
  
  // The translation distance for x, y, and z direction
  num Tx = 0.5, Ty = 0.5, Tz = 0.0;

  DateTime g_last;
  
  // Current rotation angle
  num currentAngle;
  
  // Model matrix
  Matrix4 modelMatrix;
  
  RotatingTranslatedTriangle() {
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

    // Specify the color for clearing <canvas>
    gl.clearColor(0, 0, 0, 1);

    // Pass the model matrix to the vertex shader
    u_ModelMatrix = gl.getUniformLocation(program, 'u_ModelMatrix');
    if (u_ModelMatrix == null) {
      print('Failed to get the storage location of u_xformMatrix');
      return;
    }
    
    // Current rotation angle
    currentAngle = 0.0;
    // Model matrix
    modelMatrix = new Matrix4();
    
    // Last time that this function was called
    g_last = new DateTime.now();
    
    window.requestAnimationFrame(tick);   // Request that the browser calls tick
  }
  
  // https://github.com/dart-lang/dart-samples/blob/master/web/html5/speed/animations/animations.dart
  void tick(num time) {
    currentAngle = animate(currentAngle);  // Update the rotation angle
    draw(gl, n, currentAngle, modelMatrix, u_ModelMatrix);   // Draw the triangle
    window.requestAnimationFrame(tick);   // Request that the browser calls tick
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
  
  void draw(gl, n, currentAngle, modelMatrix, u_ModelMatrix) {
    // Set the rotation matrix
    modelMatrix.setRotate(currentAngle, 0, 0, 1); // Rotation angle, rotation axis (0, 0, 1)
    modelMatrix.translate(0.35, 0, 0);
    
    // Pass the rotation matrix to the vertex shader
    gl.uniformMatrix4fv(u_ModelMatrix, false, modelMatrix.elements);

    // Clear <canvas>
    gl.clear(COLOR_BUFFER_BIT);

    // Draw the rectangle
    gl.drawArrays(TRIANGLES, 0, n);
  }

  num animate(angle) {
    // Calculate the elapsed time
    DateTime now = new DateTime.now();
    Duration elapsed = now.difference(g_last);
    g_last = now;
    
    // Update the current rotation angle (adjusted by the elapsed time)
    var newAngle = angle + (ANGLE_STEP * elapsed.inMilliseconds) / 1000.0;
    return newAngle %= 360;
  }
}

void main() {
  new RotatingTranslatedTriangle();
}

