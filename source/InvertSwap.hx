package;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

class InvertSwap {
	public var shader(default, null):InvertShader = new InvertShader();

	public function new()
	{
	}
}

class InvertShader extends FlxShader // BLOOM SHADER BY BBPANZU
{
	@:glFragmentSource('
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
	')
	public function new()
	{
		super();
	}
}