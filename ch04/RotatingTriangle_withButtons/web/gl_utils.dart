// gl_utils.dart +antalakas
// adapted from : cuon-utils.js (c) 2012 kanda and matsuda

library gl_utils;

import 'dart:web_gl';

/**
 * Create a program object and make current
 * @param gl GL context
 * @param vshader a vertex shader program (string)
 * @param fshader a fragment shader program (string)
 * @return program, if the program object was created and successfully made current 
 */
Program initShaders(gl, vshader, fshader) {
  Program program = createProgram(gl, vshader, fshader);
  if (program == null) {
    print('Failed to create program');
    return null;
  }

  gl.useProgram(program);

  return program;
}

/**
 * Create the linked program object
 * @param gl GL context
 * @param vshader a vertex shader program (string)
 * @param fshader a fragment shader program (string)
 * @return created program object, or null if the creation has failed
 */
Program createProgram(gl, vshader, fshader) {
  // Create shader object
  var vertexShader = loadShader(gl, VERTEX_SHADER, vshader);
  var fragmentShader = loadShader(gl, FRAGMENT_SHADER, fshader);
  if ((vertexShader==null) || (fragmentShader==null)) {
    return null;
  }

  // Create a program object
  var program = gl.createProgram();
  if (program == null) {
    return null;
  }

  // Attach the shader objects
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);

  // Link the program object
  gl.linkProgram(program);

  // Check the result of linking
  var linked = gl.getProgramParameter(program, LINK_STATUS);
  if (!linked) {
    var error = gl.getProgramInfoLog(program);
    print('Failed to link program: ' + error);
    gl.deleteProgram(program);
    gl.deleteShader(fragmentShader);
    gl.deleteShader(vertexShader);
    return null;
  }
  
  return program;
}

/**
 * Create a shader object
 * @param gl GL context
 * @param type the type of the shader object to be created
 * @param source shader program (string)
 * @return created shader object, or null if the creation has failed.
 */
Shader loadShader(gl, type, source) {
  // Create shader object
  Shader shader = gl.createShader(type);
  if (shader == null) {
    print('unable to create shader');
    return null;
  }

  // Set the shader program
  gl.shaderSource(shader, source);

  // Compile the shader
  gl.compileShader(shader);

  // Check the result of compilation
  var compiled = gl.getShaderParameter(shader, COMPILE_STATUS);
  if (!compiled) {
    var error = gl.getShaderInfoLog(shader);
    print('Failed to compile shader: ' + error);
    gl.deleteShader(shader);
    return null;
  }

  return shader;
}

class Point2f {
  final num x, y;
  Point2f(this.x, this.y);
  Point2f operator +(Point2f other) {
    return new Point2f(x+other.x, y+other.y);
  }
  String toString() {
    return "x: $x, y: $y";
  }
}

class ColorA {
  final num r, g, b, a;
  ColorA(this.r, this.g, this.b, this.a);
  String toString() {
    return "r: $r, g: $g, b: $b, a: $a";
  }
}

