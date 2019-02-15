
//edit fixed the bug, seems i did some nvidia settings in the control panel 
//running into a bug on nvidia and also intel i see a gl_point_smooth

import com.jogamp.opengl.util.GLBuffers;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import com.jogamp.opengl.GL4;

int shaderProgram;
int[] vao;
IntBuffer vaobuff = GLBuffers.newDirectIntBuffer(1);

void settings() {
  size(256, 256, P2D);
  PJOGL.profile = 4;
}

void setup() {
  GL4 gl4 = ((PJOGL)beginPGL()).gl.getGL4();
  
  shaderProgram = gl4.glCreateProgram();
  
  //create fragment Shader
  int fragShader = gl4.glCreateShader(GL4.GL_FRAGMENT_SHADER);
  gl4.glShaderSource(fragShader, 1, 
    new String[]{"#version 420 \n"
    +"out vec4 fragColor;"
    +"void main(void) {"
    +"fragColor = vec4(0.2, 0.2, 0.5, 1.0);}" }, null);
  gl4.glCompileShader(fragShader);

  //create vertShader Shader
  int vertShader = gl4.glCreateShader(GL4.GL_VERTEX_SHADER);
  gl4.glShaderSource(vertShader, 1, 
    new String[]{"#version 420 \n"
    +"void main(void) {"
    +"gl_Position = vec4(0.0,0.5,0.0,1.0);}" }, null);
  gl4.glCompileShader(vertShader);

  //attach and link
  gl4.glAttachShader(shaderProgram, vertShader);
  gl4.glAttachShader(shaderProgram, fragShader);
  gl4.glLinkProgram(shaderProgram);

  //program compiled free the shaders
  gl4.glDeleteShader(vertShader);
  gl4.glDeleteShader(fragShader);

  //dont really needed here one vertex of data stored in the shader, it runs (at least on my computer) we fine
  //create Buffers
  //vao = new int[1];
  //gl4.glGenBuffers(1, vao, 0);
  //gl4.glGenVertexArrays(1, vaobuff);
  //gl4.glBindVertexArray(vaobuff.get(0));

  endPGL();
}

FloatBuffer clearcolor = GLBuffers.newDirectFloatBuffer(4);

void draw() {
  GL4 gl4 = ((PJOGL)beginPGL()).gl.getGL4();
  gl4.glClearBufferfv(GL4.GL_COLOR, 0, clearcolor.put(0, 1f).put(1, 0f).put(2, 0f).put(3, 1f));
  gl4.glUseProgram(shaderProgram);
  gl4.glPointSize(25f);
  gl4.glDrawArrays(GL4.GL_POINTS, 0, 1);
  
  //click on an area outside will exit the scetch 
  if (!focused){
    println("cleanup... exit");
    gl4.glUseProgram(0);
    /*gl4.glDeleteBuffers(1,vao,0);
    gl4.glDeleteVertexArrays(1, vaobuff);
    gl4.glDeleteProgram(shaderProgram);*/
    exit();
  }
  endPGL();
}
