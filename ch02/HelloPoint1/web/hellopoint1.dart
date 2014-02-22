import 'dart:html';
import 'dart:web_gl';

// Vertex shader program
var VSHADER_SOURCE = 
  'void main() {\n' +
  '  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);\n' + // Set the vertex coordinates of the point
  '  gl_PointSize = 10.0;\n' +                    // Set the point size
  '}\n';

// Fragment shader program
var FSHADER_SOURCE =
  'void main() {\n' +
  '  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n' + // Set the point color
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
  
  // Specify the color for clearing <canvas>
  gl.clearColor(0.0, 0.0, 0.0, 1.0);

  // Clear <canvas>
  gl.clear(COLOR_BUFFER_BIT);

  // Draw a point
  gl.drawArrays(POINTS, 0, 1);
}