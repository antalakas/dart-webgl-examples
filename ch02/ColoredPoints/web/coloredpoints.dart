import 'dart:html';
import 'dart:web_gl';

// Vertex shader program
var VSHADER_SOURCE =
  'attribute vec4 a_Position;\n' +
  'void main() {\n' +
  '  gl_Position = a_Position;\n' +
  '  gl_PointSize = 10.0;\n' +
  '}\n';

// Fragment shader program
var FSHADER_SOURCE =
  'precision mediump float;\n' +
  'uniform vec4 u_FragColor;\n' +  // uniform
  'void main() {\n' +
  '  gl_FragColor = u_FragColor;\n' +
  '}\n';

class Point2f {
  final num x, y;
  Point2f(this.x, this.y);
  Point2f operator +(Point other) {
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

// Create a shader object
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

// Create the linked program object
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

// Create a program object and make current
Program initShaders(gl, vshader, fshader) {
  Program program = createProgram(gl, vshader, fshader);
  if (program == null) {
    print('Failed to create program');
    return null;
  }

  gl.useProgram(program);

  return program;
}

// The array for the position of a mouse press
List<Point2f> g_points = new List<Point2f>();
// The array to store the color of a point
List<ColorA> g_colors = new List<ColorA>();

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
  
  // Get the storage location of a_Position
  var a_Position = gl.getAttribLocation(program, 'a_Position');
  if (a_Position < 0) {
    print('Failed to get the storage location of a_Position');
    return;
  }
  
  // Get the storage location of u_FragColor
  var u_FragColor = gl.getUniformLocation(program, 'u_FragColor');
  if (u_FragColor == null) {
    print('Failed to get the storage location of u_FragColor');
    return;
  }
  
  canvas.onMouseDown.listen((ev) => click(ev, gl, canvas, a_Position, u_FragColor));
  
  // Specify the color for clearing <canvas>
  gl.clearColor(0.0, 0.0, 0.0, 1.0);

  // Clear <canvas>
  gl.clear(COLOR_BUFFER_BIT);
}

void click(ev, gl, canvas, a_Position, u_FragColor) {
  var x = ev.clientX; // x coordinate of a mouse pointer
  var y = ev.clientY; // y coordinate of a mouse pointer
  var rect = ev.target.getBoundingClientRect();

  x = ((x - rect.left) - canvas.width/2)/(canvas.width/2);
  y = (canvas.height/2 - (y - rect.top))/(canvas.height/2);

  // Store the coordinates to g_points array
  g_points.add(new Point2f(x, y));
  
  // Store the color of g_colors array
  if (x >= 0.0 && y >= 0.0) {      // First quadrant
    g_colors.add(new ColorA(1.0, 0.0, 0.0, 1.0));  // Red
  } else if (x < 0.0 && y < 0.0) { // Third quadrant
    g_colors.add(new ColorA(0.0, 1.0, 0.0, 1.0));  // Green
  } else {                         // Others
    g_colors.add(new ColorA(1.0, 1.0, 1.0, 1.0));  // White
  }

  // Clear <canvas>
  gl.clear(COLOR_BUFFER_BIT);

  var len = g_points.length;
  for(var i = 0; i < len; i++) {
    Point2f point = g_points[i];
    ColorA rgba = g_colors[i];

    // Pass the position of a point to a_Position variable
    gl.vertexAttrib3f(a_Position, point.x, point.y, 0.0);
    // Pass the color of a point to u_FragColor variable
    gl.uniform4f(u_FragColor, rgba.r, rgba.g, rgba.b, rgba.a);
    // Draw
    gl.drawArrays(POINTS, 0, 1);
  }
}























