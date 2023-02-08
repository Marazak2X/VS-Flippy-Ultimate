package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.graphics.FlxGraphic;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var curSelected:Int = 1;
	//public static var curWeek:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	//var upArrow:FlxSprite;
	//var downArrow:FlxSprite;
	
	var optionShit:Array<String> = [
		'freeplay',
		'story_mode',
		'options'
	];

	var bg:FlxSprite;
	var spark:FlxSprite;
	var flipster:FlxSprite;
	var side:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var fullKeys:Array<FlxKey>;

	override function create()
	{
		openfl.Lib.application.window.title = Main.gameTitle + " - " + "Main Menu";
		//i dont know how to do week selectors IDONTKNOW!! :( - mrzk
		WeekData.loadTheFirstEnabledMod();

		if (!FlxG.sound.music.playing)
		{	
			FlxG.sound.playMusic(Paths.music("freakyMenu"));
		}

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		fullKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('fullscreen'));

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 2)), 0.1);
		bg = new FlxSprite(-80, 760).loadGraphic(Paths.image('mainmenu/menuBG'));
		bg.scrollFactor.set(yScroll, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		spark = new FlxSprite(0, 760).loadGraphic(Paths.image('mainmenu/menuSpark'));
		spark.scrollFactor.set(0, 0);
		spark.visible = false;
		spark.updateHitbox();
		spark.screenCenter();
		spark.antialiasing = ClientPrefs.globalAntialiasing;
		add(spark);

		flipster = new FlxSprite(0, 760).loadGraphic(Paths.image('mainmenu/menuFlip'));
		flipster.screenCenter();
		flipster.scrollFactor.set(0, 0);
		flipster.updateHitbox();
		flipster.antialiasing = ClientPrefs.globalAntialiasing;
		add(flipster);

		if(FlxG.random.bool(58.43))
		{
			bg.loadGraphic(Paths.image('mainmenu/menu2BG'));
			spark.visible = true;
			flipster.loadGraphic(Paths.image('mainmenu/menu2Flip'));
		}

		side = new FlxSprite(0, 760).loadGraphic(Paths.image('mainmenu/menuBottom'));
		side.screenCenter();
		side.scrollFactor.set(0, 0);
		side.updateHitbox();
		side.antialiasing = ClientPrefs.globalAntialiasing;
		add(side);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		/*upArrow = new FlxSprite(0, 0);
		upArrow.frames = Paths.getSparrowAtlas('weekSelector');
		upArrow.animation.addByPrefix('idle', "uparrow");
		upArrow.animation.addByPrefix('press', "upselect");
		upArrow.animation.play('idle');
		upArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(upArrow);

		downArrow = new FlxSprite(0, 0);
		downArrow.frames = Paths.getSparrowAtlas('weekSelector');
		downArrow.animation.addByPrefix('idle', "downarrow");
		downArrow.animation.addByPrefix('press', "downselect");
		downArrow.animation.play('idle');
		downArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(downArrow);*/

		//var scale:Float = 1;
		var scaleItem:Float = 0.65;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)

			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;

			var menuItem:FlxSprite = new FlxSprite(50, 600);
			menuItem.scale.x = scaleItem;
			menuItem.scale.y = scaleItem;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[0]);
			menuItem.animation.addByPrefix('idle', optionShit[0] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[0] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 0;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();

			var menuItem:FlxSprite = new FlxSprite(450, 600);
			menuItem.scale.x = scaleItem;
			menuItem.scale.y = scaleItem;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[1]);
			menuItem.animation.addByPrefix('idle', optionShit[1] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[1] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 1;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();

			var menuItem:FlxSprite = new FlxSprite(920, 600);
			menuItem.scale.x = scaleItem;
			menuItem.scale.y = scaleItem;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[2]);
			menuItem.animation.addByPrefix('idle', optionShit[2] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[2] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 2;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();

		menuItems.cameras = [camHUD];

		new FlxTimer().start(1, function(tmr:FlxTimer) {
			FlxTween.tween(bg,{y: 0}, 0.55 ,{ease: FlxEase.expoInOut});
			FlxTween.tween(spark,{y: 0}, 0.55 ,{ease: FlxEase.expoInOut});
			FlxTween.tween(side,{y: 0}, 0.55 ,{ease: FlxEase.expoInOut});
			FlxTween.tween(flipster,{y: 0}, 0.55 ,{ease: FlxEase.expoInOut});
		});

		FlxG.camera.follow(camFollowPos, null, 1);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			/*if (controls.UI_UP_P)
			{
				changeWeek(-1);
			}

			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
			}*/

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					//CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							new FlxTimer().start(0.55, function(tmr:FlxTimer)
							{
								FlxTween.tween(bg,{y: 760}, 0.55 ,{ease: FlxEase.expoInOut});
								FlxTween.tween(spark,{y: 760}, 0.55 ,{ease: FlxEase.expoInOut});
								FlxTween.tween(side,{y: 760}, 0.55 ,{ease: FlxEase.expoInOut});
								FlxTween.tween(flipster,{y: 760}, 0.55 ,{ease: FlxEase.expoInOut});
							});
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										FlxG.sound.music.stop();
										MusicBeatState.switchState(new FreeplayState());
									case 'options':
										FlxG.sound.music.stop();
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			else if (FlxG.keys.anyJustPressed(fullKeys))
			{
				FlxG.fullscreen = !FlxG.fullscreen;
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			else if (FlxG.keys.justPressed.EIGHT)
			{
				selectedSomethin = true;
				var songLowercase:String = Paths.formatToSongPath('funny');
				var poop:String = Highscore.formatSong(songLowercase, 1);

				trace(poop);

			    PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			    PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.stop();
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
