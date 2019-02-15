//based on:
//https://github.com/integeruser/jgltut
//https://raw.githubusercontent.com/xranby/jogl-demos/master/src/demos/es2/RawGL2ES2demo.java

import com.jogamp.opengl.util.GLBuffers;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import  com.jogamp.opengl.GL3;

GL3 gl3;

int[] vboHandles;
int shaderProgram, vertShader, fragShader;
int vertexBufferObject;

IntBuffer vao = GLBuffers.newDirectIntBuffer(1);  

void settings() {
  size(400, 400, P3D);
  PJOGL.profile = 3;
}

void setup() {
  gl3 = ((PJOGL)beginPGL()).gl.getGL3();
  endPGL();

  // initializeProgram
  shaderProgram = gl3.glCreateProgram();

  fragShader = gl3.glCreateShader(GL3.GL_FRAGMENT_SHADER);
  gl3.glShaderSource(fragShader, 1, 
    new String[]{
    "#version 330 \n"
    +"smooth in vec4 theColor;"
    +"out vec4 outputColor;"
    +"void main(){"
    +"outputColor = theColor;"
    +"}"
    }, null); 
  gl3.glCompileShader(fragShader);

  vertShader = gl3.glCreateShader(GL3.GL_VERTEX_SHADER);
  gl3.glShaderSource(vertShader, 1, 
    new String[]{
    "#version 330 \n"
    +"layout (location = 0) in vec4 position;"
    +"layout (location = 1) in vec4 color;"
    +"smooth out vec4 theColor;"
    +"void main(){"
    +"gl_Position = position;"
    +"theColor = color;"
    +"}"
    }, null); 
  gl3.glCompileShader(vertShader);


  int[] compiled = new int[1];

  // Check compile status fragShader
  gl3.glGetShaderiv(fragShader, GL3.GL_COMPILE_STATUS, compiled, 0);
  if (compiled[0]!=0) {
    println("Horray! fragment shader compiled");
  } else {
    int[] logLength = new int[1];
    gl3.glGetShaderiv(fragShader, GL3.GL_INFO_LOG_LENGTH, logLength, 0);
    byte[] log = new byte[logLength[0]];
    gl3.glGetShaderInfoLog(fragShader, logLength[0], (int[])null, 0, log, 0);
    println("Error compiling the fragment shader: " + new String(log));
    exit();
  }
  // Check compile status vertShader
  gl3.glGetShaderiv(vertShader, GL3.GL_COMPILE_STATUS, compiled, 0);
  if (compiled[0]!=0) {
    System.out.println("Horray! vertex shader compiled");
  } else {
    int[] logLength = new int[1];
    gl3.glGetShaderiv(vertShader, GL3.GL_INFO_LOG_LENGTH, logLength, 0);
    byte[] log = new byte[logLength[0]];
    gl3.glGetShaderInfoLog(vertShader, logLength[0], (int[])null, 0, log, 0);
    println("Error compiling the vertex shader: " + new String(log));
    exit();
  }

  // attach and link
  gl3.glAttachShader(shaderProgram, vertShader);
  gl3.glAttachShader(shaderProgram, fragShader);
  gl3.glLinkProgram(shaderProgram);
  
  // program compiled we can free the object
  gl3.glDeleteShader(vertShader);
  gl3.glDeleteShader(fragShader);

  // set up vertex Data to display

  final float[] vertexData = {
    0.0f, 0.5f, 0.0f, 1.0f, 
    0.5f, -0.366f, 0.0f, 1.0f, 
    -0.5f, -0.366f, 0.0f, 1.0f, 
    1.0f, 0.0f, 0.0f, 1.0f, 
    0.0f, 1.0f, 0.0f, 1.0f, 
    0.0f, 0.0f, 1.0f, 1.0f
  };

  // initializeVertexBuffer
  FloatBuffer vertexDataBuffer = GLBuffers.newDirectFloatBuffer(vertexData);

  vboHandles = new int[1];
  gl3.glGenBuffers(1, vboHandles, 0);

  gl3.glBindBuffer(GL3.GL_ARRAY_BUFFER, vboHandles[0]);
  gl3.glBufferData(GL3.GL_ARRAY_BUFFER, vertexDataBuffer.capacity()*4, vertexDataBuffer, GL3.GL_STATIC_DRAW);
  gl3.glBindBuffer(GL3.GL_ARRAY_BUFFER, 0);
  vertexDataBuffer = null;

  gl3.glGenVertexArrays(1, vao);
  gl3.glBindVertexArray(vao.get(0));
}

void draw() {
  gl3.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
  gl3.glClear(GL3.GL_COLOR_BUFFER_BIT);

  gl3.glUseProgram(shaderProgram);

  gl3.glBindBuffer(GL3.GL_ARRAY_BUFFER, vboHandles[0]);
  gl3.glEnableVertexAttribArray(0);
  gl3.glEnableVertexAttribArray(1);
  gl3.glVertexAttribPointer(0, 4, GL3.GL_FLOAT, false, 0, 0);
  gl3.glVertexAttribPointer(1, 4, GL3.GL_FLOAT, false, 0, 48);

  gl3.glDrawArrays(GL3.GL_TRIANGLES, 0, 3);
  gl3.glDisableVertexAttribArray(0);
  gl3.glDisableVertexAttribArray(1);
  
  if (!focused) {
    println("cleanup... exit");
    gl3.glUseProgram(0);
    gl3.glDeleteProgram(shaderProgram);
    gl3.glDeleteVertexArrays(1, vao);
    noLoop();
    exit();
  }
}
