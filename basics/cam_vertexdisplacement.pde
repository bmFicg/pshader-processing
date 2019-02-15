//WORK IN PROGRESS SHADER

//28.05.2017
//TO DO 
//IMPLEMENT A CAMERA
//VERTEX DISPLACEMENT
//SEE COMMENTS

import com.jogamp.opengl.GL3;
import com.jogamp.opengl.util.GLBuffers;
import java.nio.FloatBuffer;


import processing.video.*;

//to do: get a float array instead
PMatrix3D rotMat=new PMatrix3D();

Capture cam;
PShape grid;
PShader shdr;

{
  PJOGL.profile = 3;
}

void setup() {
  //NOTE: default for P2D is gl.Viewport(Centered) and OrhoCam!  
  size(640, 480, P2D);

  noSmooth();
  noStroke();

  //camera setup
  cam = new Capture(this, 640, 480);
  cam.start();

  //shape setup
  grid = createShape();
  grid.beginShape(QUAD);
  //Just to be sure i did nothing wrong disable everything
  grid.noStroke();  
  grid.noTexture();
  grid.noTint();
  //overloading the vertex direct to shader set Processing vertex.xy to NULL
  grid.attribPosition("vertPos", -1, -1, 0);
  grid.vertex(0,0);
  grid.attribPosition("vertPos",1, -1, 0);
  grid.vertex(0,0);
  grid.attribPosition("vertPos", 1, 1, 0); 
  grid.vertex(0,0);
  grid.attribPosition("vertPos", -1, 1, 0);
  grid.vertex(0,0);
  grid.endShape(); //END fullscreen QUAD

  //shader setup
  shdr=new PShader(this, 
    //vertex
    new String[]{"#version 150 \n"
    +"in vec4 vertPos;"
    +"uniform mat4 RotMat;"
    //for testing i got a time uniform in prev. versions
    //+"uniform float t;" 
    +"out vec2 vuv;"
    +"void main(){"
    +"gl_Position=RotMat*vec4(vertPos.xyz, 1.0);"
    +"vuv=vertPos.xy*vec2(0.5)+vec2(0.5);"
   +"}"
    //fragment
    }, new String[]{"#version 150 \n"
      +"in vec2 vuv;"
      +"uniform sampler2D tex;"
      +"out vec4 fragColor;"
      +"void main() {"
      + "fragColor = texture(tex,vuv);"
      //red
      //+ "fragColor = vec4(1.0,0.0,0.0,1.0);" 
     +"}"
    });
  shader(shdr);
}

FloatBuffer clearColor = GLBuffers.newDirectFloatBuffer(4);
float t =0f;
float mw=0;
void draw() {

  //to do deph test
  
  PJOGL pgl = (PJOGL) beginPGL();  
  GL3 gl = pgl.gl.getGL3();
  gl.glClearBufferfv(GL3.GL_COLOR, 0, clearColor.put(0, 0.2f).put(1, 0.2f).put(2, 0.5f).put(3, 0f));
  endPGL();

  float phi  =  map(mouseX, 0, width, PI, TWO_PI);
  float theta=  map(mouseY, 0, height,PI, TWO_PI);
  float psi =   mw/PI;

  shdr.set("RotMat",rotMat);
  
  //we just need a float array, for quick prototyping i use processing intern methods 
  
  //set to identity
  rotMat.reset(); 
  //basic matrix rotation we will do all the math in the vertexshader > GPU
  rotMat.apply(1., 0., 0., 0, 0., cos(phi), -sin(phi), 0., 0., sin(phi), cos(phi), 0., 0., 0., 0., 1.);
  rotMat.apply(cos(theta), 0., -sin(theta), 0, 0., 1., 0., 0., sin(theta), 0., cos(theta), 0., 0., 0., 0., 1.);
  rotMat.apply(cos(psi), -sin(psi), 0., 0, sin(psi), cos(psi), 0., 0., 0., 0., 1., 0., 0., 0., 0., 1.);

  if (cam.available()) cam.read();
  shdr.set("tex", cam);

  // see above
  grid.disableStyle();
  
  //draw shape
  shape(grid);
  t= frameCount*.01f;
}

void mouseWheel(MouseEvent event) {
  mw+=event.getCount();
}
