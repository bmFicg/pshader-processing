//forum.processing.org/two/discussion/22353/simpel-tunnel-shader#latest
PShader shdr;
void setup() {
  size(620, 349, P2D);
  shdr=new PShader(this,new String[]{"#version 150 \n"
    + "in vec4 position;"
    + "void main(){"
    + "gl_Position=vec4(position.xy*.5-1.,0.,1.);"
   + "}"
    },new String[]{"#version 150 \n"
      +"out vec4 m;"
      +"uniform vec2 res;"
      +"uniform float t;"
      +"void main(){"
      +"vec2 p=(gl_FragCoord.xy-.5*res)/res.y;"
      +"float it=.2/sqrt(dot(p, p)),"
      +"i=float(fract(1./it+t)>=.02/fract(it+sin(t))),"
      +"l=float(.5<fract(it+sin(t*1.)+atan(p.x, p.y)*3.));"
      +"m=vec4(i<l||it<.05);"
     +"}"
     });
  shdr.set("res", float(width), float(height));
}
void draw() {
  shdr.set("t", millis()/1000.0);
  filter(shdr);
}
