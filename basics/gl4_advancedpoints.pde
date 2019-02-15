import  com.jogamp.opengl.GL4;
import com.jogamp.opengl.util.GLBuffers;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

int shaderProgram;
IntBuffer vao = GLBuffers.newDirectIntBuffer(1);

GL4 gl4;
  
void settings() {
  size(400, 400, P3D);
  PJOGL.profile = 4;
}

void setup() {
  
    // call once and hold the reference
    gl4 = ((PJOGL)beginPGL()).gl.getGL4();
    endPGL();
    
    //create the program object 
    shaderProgram = gl4.glCreateProgram();

    // create compile fragment Shader
    int fragShader = gl4.glCreateShader(GL4.GL_FRAGMENT_SHADER);
    gl4.glShaderSource(fragShader, 1, 
      new String[]{"#version 420 \n"
      +"out vec4 fragColor;"
      +"void main(void) {"
      +"fragColor = vec4(0.2, 0.2, 0.5, 1.0);}"}, null); 
    gl4.glCompileShader(fragShader);
    
    // create compile vertShader Shader
    int vertShader = gl4.glCreateShader(GL4.GL_VERTEX_SHADER);
    gl4.glShaderSource(vertShader, 1, 
      new String[]{"#version 420 \n"
      +"layout (location = 0) in vec4 offset;"
      +"void main(void){"
      +"vec3 points[3]=vec3[3](vec3(-0.5,0.8,0.0),vec3(0.2,.8,0.0),vec3(-0.5,0.25,0.0));"
      +"gl_Position = vec4(points[gl_VertexID],1.)+offset;}"}, null); 
    gl4.glCompileShader(vertShader);

    // attach and link
    gl4.glAttachShader(shaderProgram, vertShader);
    gl4.glAttachShader(shaderProgram, fragShader);
    gl4.glLinkProgram(shaderProgram);

    // program compiled we can free the object
    gl4.glDeleteShader(vertShader);
    gl4.glDeleteShader(fragShader);

    //create Buffers
    gl4.glGenVertexArrays(1, vao);
    gl4.glBindVertexArray(vao.get(0));
  
}
void draw() {

    // khronos.org/opengl/wiki/GLAPI/glClearBuffer
    // color: #CBE700
    gl4.glClearBufferfv(GL4.GL_COLOR, 0, GLBuffers.newDirectFloatBuffer(4).put(0, 0.79f).put(1, 0.90f).put(2, 0f).put(3, 1f));

    gl4.glUseProgram(shaderProgram);

    gl4.glPointSize(25.0f);

    gl4.glVertexAttrib4fv(0, GLBuffers.newDirectFloatBuffer(new float[]{sin(frameCount*.01f)*.5f+.5f, 
                                                                        cos(frameCount*.01f)*.5f+.5f, 0.0f, 1.0f} ));
    gl4.glDrawArrays(GL4.GL_POINTS, 0, 3);
    gl4.glDrawArrays(GL4.GL_TRIANGLES, 0, 3);
    
   if (!focused)  {
      println("cleanup... exit");
      gl4.glDeleteProgram(shaderProgram);
      
      //with a draw loop i get a black screen that indicates i really destroy the buffer with content
      gl4.glDeleteVertexArrays(1,vao);
      
      // noLoop: before exit call gets into the scope drawloop to exit the programm our program has no content
      // otherwise error message endofdraw
      // comment both out to get a black screen
      noLoop();
      exit();
    }
}
