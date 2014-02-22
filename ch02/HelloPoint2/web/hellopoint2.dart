import 'dart:html';
import 'dart:web_gl';

// Vertex shader program
var VSHADER_SOURCE = 
  'attribute vec4 a_Position;\n' + // attribute variable
  'void main() {\n' +
  '  gl_Position = a_Position;\n' +
  '  gl_PointSize = 10.0;\n' +
  '}\n'; 

// Fragment shader program
var FSHADER_SOURCE = 
  'void main() {\n' +
  '  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n' +
  '}\n';

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
  
  Shader fragShader = gl.createShader(FRAGMENT_SHADER);
  gl.shaderSource(fragShader, FSHADER_SOURCE);
  gl.compileShader(fragShader);

  Shader vertShader = gl.createShader(VERTEX_SHADER);
  gl.shaderSource(vertShader, VSHADER_SOURCE);
  gl.compileShader(vertShader);

  Program program = gl.createProgram();
  gl.attachShader(program, vertShader);
  gl.attachShader(program, fragShader);
  gl.linkProgram(program);

  if (!gl.getProgramParameter(program, LINK_STATUS)) {
    print("Could not initialise shaders");
    return;
  }

  gl.useProgram(program);
  
  // Get the storage location of a_Position
  var a_Position = gl.getAttribLocation(program, 'a_Position');
  if (a_Position < 0) {
    print('Failed to get the storage location of a_Position');
    return;
  }

  // Pass vertex position to attribute variable
  gl.vertexAttrib3f(a_Position, 0.0, 0.0, 0.0);
  
  // Specify the color for clearing <canvas>
  gl.clearColor(0.0, 0.0, 0.0, 1.0);

  // Clear <canvas>
  gl.clear(COLOR_BUFFER_BIT);

  // Draw a point
  gl.drawArrays(POINTS, 0, 1);
}