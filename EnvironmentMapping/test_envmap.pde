//test_envmap.pde
//05232017
//@t_vaeringjarson
//scetch i made for testing

//It is not thought be a physically-accurate reflection shader
//you have to know about processing intern behavior to tweek values to fit your task

//vertex pre multiplication done by processing 
//forum.processing.org/two/discussion/11186/edit-stroke-position-and-stroke-color-of-a-pshape-using-shader
 
 
 
PShader bgShader, sphereShader;

PMatrix3D rotY=new PMatrix3D();
PMatrix3D model = new PMatrix3D();
PMatrix3D modelview = new PMatrix3D(); 


void setup(){
  size(856,480,P3D);
  
  //loading Matrix in setup and than into draw (model Matrix)
  modelview=((PGraphicsOpenGL)g).modelview;
 
  //Shader for Environment Mapping
  bgShader=new PShader(this, 
    new String[]{"#version 150  \n"
    + "in vec4 position; "
    + "uniform mat4 Ry,view;"
    + "out vec4 refDir;"
    + "void main() {"
    + "gl_Position = vec4(position.xy,.0, 1.);"
    + "refDir =Ry*view*vec4(position.xy,1.,0);"
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
        
        int x =0;
        //shader call chain: overload the texure at the higher shader object (bgShader)
        //background(0) =
        rectMode(RADIUS);
        fill(x);
        rect(x,x,width,height);
        
        //draw grid
        stroke(254);
        while(x<width){
        x+=20;  //at 1080p=96dpi 
        line(x,0,x,height);
        line(0,x,width,x);
        }//x=0;
        
        //copy pixels to texture
        this.set("envmap",get());
        
        //enable for debug
        //this.set("modelview",((PGraphicsOpenGL)g).modelview);
        
        return this;
        }
    }.run();
    
  //Shader for the Processing Shape (sphere)
  sphereShader=new PShader(this, 
      new String[]{ "#version 150  \n"
      +  "in vec3 position,normal;"
      + "uniform mat4 modelviewInv,view,projection;"
      + "uniform float time;"
      + "out vec3 refDir;"
      + "void main () {"
      + "vec4 camPos = view*vec4(position, 1);"
      + "vec3 eye = normalize(position.xyz-modelviewInv[3].xyz/modelviewInv[3].w);"
      
        //more accurate would be refDir=-normalize(normal);
      + "refDir = reflect(eye, normal);"
      
	//vertex animation
      + "camPos.z*=clamp(sin(time)*.5+.5,0,1.);"
	  
      + "gl_Position = projection*camPos;"
     + "}"
    },new String[]{"#version 150  \n"
        +  "in vec3 refDir;"
        + "uniform sampler2D envmap;"
        + "out vec4 fragColor;"
        + "const float PI ="+(double)PI+";"
        + "void main () {"
        
          //mvps.org/directx/articles/spheremap.htm
        + "fragColor = texture(envmap,vec2( .5+asin(refDir.x/PI) ,.5+ asin(refDir.y/PI) ));"
       +"}"
      }){
        PShader run(){
          this.set("modelviewInv",((PGraphicsOpenGL)g).modelviewInv);
          
          //enable for debug
          //this.set("modelview", ((PGraphicsOpenGL)g).modelview);
          
          this.set("projection", ((PGraphicsOpenGL)g).projection);
          return this;  
        }
    }.run();
 
   //debug: both options off/on
   //enable for debug
   
   //hint(DISABLE_OPTIMIZED_STROKE);

   //wireframe Mode
   noStroke();
}
float t=0; //time variable

void draw(){
  
  //millis()*.001f will fail becourse of a floating point error as I suspect rotateX(cos(
  //for better processing internal behavior use frameCount
  t=frameCount*.01f; 

  beginCamera();
  camera();
  //rotate Camera
  rotateX(cos(t)); 
  rotateZ(sin(t*.01f)/TWO_PI);
  endCamera();
  
  //rotation pitch
  bgShader.set("Ry", rotY); 
  
  //reset to  IdentityMatrix & reset the stack 
  rotY.reset(); 
  rotY.apply(cos(t), 0,sin(t), 0, 0, 1, 0, 0, -sin(t), 0, cos(t), 0, 0, 0, 0, 1);
 
  //set time
  sphereShader.set("time",t);
 
  //no depth testing
  hint(DISABLE_DEPTH_MASK); 
  shader(bgShader); 
 
  //enable for debug
  //background(0); 
 
  rect(0, 0, width, height);
  
  //readPixels for the previous shader bgShader
  sphereShader.set("envmap",get());
 
  //enable for debug
  //hint(ENABLE_DEPTH_MASK);
  
  shader(sphereShader);
 
  translate(width/2, height/2,-10);
  sphere(120); 
 
  //after we apply the transformation to the sphere we update the matrix
  //and going back to the begining of the draw loop -> camera
  
  //reset to IdentityMatrix & reset the stack
  model.reset();
  model.apply(modelview.m00, modelview.m10, modelview.m20, modelview.m30,
                             modelview.m01, modelview.m11, modelview.m21, modelview.m31,
                             modelview.m02, modelview.m12, modelview.m22, modelview.m32,
                             modelview.m03, modelview.m13, modelview.m23, modelview.m33);
                                    
  //load the modelview from stack & update it
  bgShader.set("view",model);
  sphereShader.set("view",model); 

  
  //enable for debug
  //if(keyPressed||mousePressed)exit();
}
