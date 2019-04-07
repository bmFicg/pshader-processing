import com.jogamp.opengl.GL3;


import com.jogamp.opengl.util.GLBuffers;
import ddf.minim.*;

Minim minim;
AudioInput in ;

final int w = 1;
java.nio.FloatBuffer mBuf = GLBuffers.newDirectFloatBuffer(1); 

PShader shdr;

void settings() 
{
    size(640, 360, P3D);
    PJOGL.profile = 3;
}

void setup() 
{
    GL3 gl = ((PJOGL) beginPGL()).gl.getGL3();endPGL();

    minim = new Minim(this);
    in = minim.getLineIn();

    shdr = new PShader(this,
        new String[] { // vert
            "#version 330 core", "out vec2 uv; void main(){gl_Position = vec4(uv = 2 * ivec2((gl_VertexID << 1) & 2, gl_VertexID & 2) - 1, 0, 1);}"
          },
        new String[] { // frag 
            "#version 330 core"
            , "in vec2 uv;"
            + "uniform sampler1D texFFT;"
            + "out vec4 fragColor;" 
            + "void main() {" 
            + "float l = texelFetch( texFFT, 0,0).r;" 
            + "fragColor.rgb = vec3(0.02) / abs( uv.y + l * sin( uv.x * 10. + l ) -.25 ); " 
            + "fragColor.a =1.;"
          +"}"
        });
    
    java.nio.IntBuffer fftTex = GLBuffers.newDirectIntBuffer(1);

    shdr.bind();
    gl.glGenTextures(1, fftTex);
    gl.glBindTexture(GL3.GL_TEXTURE_1D, fftTex.get(0) );
    gl.glTexImage1D(GL3.GL_TEXTURE_1D, 0, GL3.GL_R32F, w, 0, GL3.GL_RED, GL3.GL_FLOAT, mBuf);
    shdr.unbind();
}

void draw() 
{
    GL3 gl = ((PJOGL) beginPGL()).gl.getGL3();endPGL();
    
    shdr.bind();

    for (int i = in.bufferSize() - 1; --i >= 0;)
        mBuf.put( in.right.get(i)).rewind();

    gl.glTexSubImage1D(GL3.GL_TEXTURE_1D, 0, 0, w, GL3.GL_RED, GL3.GL_FLOAT, mBuf);

    gl.glDrawArrays(GL3.GL_TRIANGLE_STRIP, 0, 3);
    shdr.unbind();
}
