package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OthersSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Others and Stuff';
		rpcTitle = 'Others and Stuff Settings'; //for Discord Rich Presence
		
		var option:Option = new Option('Freeplay Menu:',
			"Freeplay Menu",
			'freeplayMenu',
			'string',
			'Original',
			['Original', 'Marazak Version']);
		addOption(option);

		super();
	}
}
