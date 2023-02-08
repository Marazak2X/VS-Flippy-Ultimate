#pragma header

int invert = 1;
    
void main(){
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    if(invert == 0) {
        gl_FragColor = color;
    } else {
    gl_FragColor = vec4(1.0-color.rgb,1.0);
    }
}