void setup() 
{
    size(640, 360, P3D);
    final String version = "#version 460 core", 
                 extension = ""; //"#extension GL_EXT_gpu_shader5: require";
           
    shader(new PShader(this, 
      new String[]{version // vert
        , extension
        , "out vec2 uv;"
        + "void main() {"
        +    "gl_Position = vec4(uv = 2 * ivec2((gl_VertexID << 1) & 2, gl_VertexID & 2) - 1, 0., 1.);"
        +  "}"
      }, 
      new String[]{version// frag 
        , extension
        , "in vec2 uv;"
        + "uniform float aspect;"
        + "out vec4 fragColor;"
        + "void main() {"
        + "fragColor = vec4(vec3(1. - length(vec2(uv.x * aspect, uv.y))), 1.);"
        +"}"
      }
      ){
        PShader r()
          {
            this.set("aspect",(float)(width*1.0001/height));
            // bufferless giant triangel 
            this.bind();
            ((PJOGL) beginPGL()).gl.getGL4().glDrawArrays(com.jogamp.opengl.GL4.GL_TRIANGLE_STRIP, 0, 3);  
            this.unbind();
            return this;
          }
         }.r()
        );
        
        
}
