PShader bgShader, objShader;
PShape s;

PMatrix3D rotY=new PMatrix3D();
PMatrix3D model = new PMatrix3D();
PMatrix3D modelview = new PMatrix3D(); 

void setup() {
  size(856,480,P3D);
  
  //performance wise
  noLights();
  noStroke();
  noSmooth();
  rectMode(RADIUS);
  
  //load the .obj and rotate it
  s=loadShape("https://"+"raw.githubusercontent.com/tolkanabroski/coding/master/pshader-processing/EnvironmentMapping/data/test_terrain.obj");
  s.rotateX(.09);
  
  //loading Matrix in setup and than into draw (model Matrix)
  modelview=((PGraphicsOpenGL)g).modelview;
  
  //Shader for Environment Mapping
  bgShader=new PShader(this, 
    new String[]{"#version 150  \n"
    + "in vec4 position; "
    + "uniform mat4 view;"
    + "out vec4 refDir;"
    + "void main() {"
    + "gl_Position = vec4(position.xy,.0, 1.);"
    + "refDir =view*vec4(position.xy,1.,0);"
    + "}"
    }, new String[] {"#version 150  \n"
      + "in vec4 refDir;"
      + "uniform sampler2D envmap;"
      + "out vec4 fragColor;"
      + "const float PI ="+(double)PI+";"
      + "void main () {"
        //reindelsoftware.com/Documents/Mapping/Mapping.html
      + "fragColor = texture(envmap,"
      +                "vec2(.5+atan(refDir.z,refDir.x)/(2.0*PI),"
      +                        "acos(refDir.y/length(refDir))/PI));"
      + "}"
    }){
      PShader run(){
        //mode: nearest
        ((PGraphicsOpenGL)g).textureSampling(2);
         this.set("envmap", loadImage( "https://"+"github.com/tolkanabroski/coding/raw/master/pshader-processing/EnvironmentMapping/data/envmap_2.jpg"));
        return this;
      }
    }.run();

  //Shader for the Processing Shape (.obj)
  objShader=new PShader(this, 
     new String[]{ "#version 150  \n"
      + "in vec3 position,normal;"
      + "uniform mat4 view,projection;"
      + "out vec3 refDir;"
      + "void main () {"
      + "vec4 camPos =view*vec4(position, 1);"
      
        //flipping normals, in this case the viewdirection
      + "refDir = -normalize(normal);"
      
      + "gl_Position =projection*camPos;"
    + "}"
     }, new String[]{"#version 150  \n"
        + "in vec3 refDir;"
        + "uniform sampler2D envmap;"
        + "out vec4 fragColor;"
        + "const float PI ="+(double)PI+";"
        + "void main () {"
        
         //thought to work best on curved surfaces
        + "fragColor = texture(envmap,.5+vec2(refDir/PI).xy);"
        
       +"}"
      }){
        PShader run(){
        this.set("projection", ((PGraphicsOpenGL)g).projection);
        return this;
       }
     }.run();
}

float t=0.f;

void draw() {
  
  //for better processing internal behavior use frameCount
  t=frameCount*.025f;
  
  //to make sure we loading all the data with matrixtransformation etc. in the default camera at the right point
  camera();
  
  //
  hint(DISABLE_DEPTH_MASK); 
  shader(bgShader); 
  
  //draw bgShader shader to a rect
  rect(0, 0, width, height);
  
  //copy pixels to texture
  objShader.set("envmap", get());

  //enable again: to archive back/front faces of the model
  hint(ENABLE_DEPTH_MASK);
  shader(objShader);
  
  //push and pop for better handling by processing
  pushMatrix();
  translate(width/2, height/2, 0);
  
  rotateY(t/PI);
  
  //this particular model is very small
  scale(40);

  shape(s);
  
  //reset to  IdentityMatrix & reset the stack
  model.reset();
  model.apply(modelview.m00, modelview.m10, modelview.m20, modelview.m30, 
                             modelview.m01, modelview.m11, modelview.m21, modelview.m31, 
                             modelview.m02, modelview.m12, modelview.m22, modelview.m32, 
                             modelview.m03, modelview.m13, modelview.m23, modelview.m33);
    
  //load the modelview from stack and update it
  bgShader.set("view", model);
  objShader.set("view", model); 
  
  popMatrix();

  //enable for debug
  //if(keyPressed||mousePressed)exit();
}
