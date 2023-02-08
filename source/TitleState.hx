package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	var fullKeys:Array<FlxKey>;

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	var loadingText:FlxText;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		fullKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('fullscreen'));

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end

		openfl.Lib.application.window.title = Main.gameTitle + " - " + "Title";
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		loadingText = new FlxText(12, FlxG.height - 100, 0, "Loading...", 12);
		loadingText.scrollFactor.set();
		loadingText.visible = true;
		loadingText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadingText);

		//debug
	/*	
		new FlxTimer().start(0.6, function(tmr:FlxTimer)
		{
			Paths.returnGraphic("titleBG");
			Paths.returnGraphic("FLIPPY");
			Paths.returnGraphic("logoBumpin");
			Paths.returnGraphic("titleEnter");
			Paths.returnGraphic("freeplay/fallen-soldier/alt-bg");
			Paths.returnGraphic("freeplay/fallen-soldier/alt-fg");
			Paths.returnGraphic("freeplay/fallen-soldier/bloody-bg");
			Paths.returnGraphic("freeplay/fallen-soldier/bloody-fg");
			Paths.returnGraphic("freeplay/fallen-soldier/fearful-bg");
			Paths.returnGraphic("freeplay/fallen-soldier/fearful-fg");
			Paths.returnGraphic("freeplay/fallen-soldier/insane-bg");
			Paths.returnGraphic("freeplay/fallen-soldier/insane-fg");
			Paths.returnGraphic("freeplay/fallen-soldier/kapow-bg");
			Paths.returnGraphic("freeplay/fallen-soldier/kapow-fg");
			Paths.returnGraphic("freeplay/fallen-soldier/minus-bg");
			Paths.returnGraphic("freeplay/fallen-soldier/minus-fg");
			Paths.returnGraphic("freeplay/fallen-soldier/og-bg");
			Paths.returnGraphic("freeplay/fallen-soldier/og-fg");
			Paths.returnGraphic("freeplay/fallen-soldier/shanked-bg");
			Paths.returnGraphic("freeplay/fallen-soldier/shanked-fg");
			Paths.returnGraphic("freeplay/bymrzk/bloody-bg");
			Paths.returnGraphic("freeplay/bymrzk/bloody-fg");
			Paths.returnGraphic("freeplay/bymrzk/fearful-bg");
			Paths.returnGraphic("freeplay/bymrzk/fearful-fg");
			Paths.returnGraphic("freeplay/bymrzk/insane-bg");
			Paths.returnGraphic("freeplay/bymrzk/insane-fg");
			Paths.returnGraphic("freeplay/bymrzk/kapow-bg");
			Paths.returnGraphic("freeplay/bymrzk/kapow-fg");
			Paths.returnGraphic("freeplay/bymrzk/minus-bg");
			Paths.returnGraphic("freeplay/bymrzk/minus-fg");
			Paths.returnGraphic("freeplay/bymrzk/og-bg");
			Paths.returnGraphic("freeplay/bymrzk/og-fg");
			Paths.returnGraphic("freeplay/bymrzk/shanked-bg");
			Paths.returnGraphic("freeplay/bymrzk/shanked-fg");
			Paths.returnGraphic("options/optionsbg");
			Paths.returnGraphic("characters/BF_Carry");
			Paths.returnGraphic("characters/Bf_carry_fla");
			Paths.returnGraphic("characters/bfHoldingGF-DEAD");
			Paths.returnGraphic("characters/BOYFRIEND");
			Paths.returnGraphic("characters/BOYFRIEND_DEAD");
			Paths.returnGraphic("characters/BOYFRIEND_MINUS");
			Paths.returnGraphic("characters/DADDY_DEAREST");
			Paths.returnGraphic("characters/FLIPPY");
			Paths.returnGraphic("characters/FLIPPY_kapow");
			Paths.returnGraphic("characters/FLIPPY_bloody");
			Paths.returnGraphic("characters/FLIPPY_crazy");
			Paths.returnGraphic("characters/FLIPPY_blood");
			Paths.returnGraphic("characters/FLIPPY_minus");
			Paths.returnGraphic("characters/FLIPPY_alt");
			Paths.returnGraphic("characters/flippy_phase_4");
			Paths.returnGraphic("characters/GF_assets");
			Paths.returnGraphic("characters/Shell_Shanked");
			Paths.returnGraphic("characters/tigerbf");
			Paths.returnGraphic("bomb");
			Paths.returnGraphic("burn");
			Paths.returnGraphic("blackstuff");
			Paths.returnGraphic("alt/sky");
			Paths.returnGraphic("alt/skyline");
			Paths.returnGraphic("alt/ground");
			Paths.returnGraphic("alt/stump");
			Paths.returnGraphic("phase1/sky");
			Paths.returnGraphic("phase1/trees");
			Paths.returnGraphic("phase1/backtrees");
			Paths.returnGraphic("phase1/ground");
			Paths.returnGraphic("phase1/table");
			Paths.returnGraphic("phase2/sky");
			Paths.returnGraphic("phase2/backtrees");
			Paths.returnGraphic("phase2/table");
			Paths.returnGraphic("phase2/ground");
			Paths.returnGraphic("phase2/trees");
			Paths.returnGraphic("phase3/sky");
			Paths.returnGraphic("phase3/more tree");
			Paths.returnGraphic("phase3/table");
			Paths.returnGraphic('phase3/Fire');
			Paths.returnGraphic("phase3/ground");
			Paths.returnGraphic("phase3/treee");
			Paths.returnGraphic("phase4/backorangetrees");
			Paths.returnGraphic("phase4/backtrees");
			Paths.returnGraphic("phase4/orangetrees");
			Paths.returnGraphic("phase4/ground");
			Paths.returnGraphic("phase4/trees");
			Paths.returnGraphic("Fire");
			Paths.returnGraphic('Scared_Flaky');
			Paths.returnGraphic('Speaker');
			Paths.returnGraphic('Speaker2');
			Paths.returnGraphic("kapow/sky");
			Paths.returnGraphic("kapow/scene");
			Paths.returnGraphic("kapow/bwall");
			Paths.returnGraphic("kapow/lights");
			Paths.returnGraphic("cleave/sky");
			Paths.returnGraphic("cleave/trees");
			Paths.returnGraphic("cleave/ground");
			Paths.returnGraphic("cleave/lilboi");
			Paths.returnGraphic("shanked/alleyway");
			Paths.returnGraphic("shanked/sky");
			Paths.returnGraphic("shanked/road");
	
			CoolUtil.precacheSound("beep");
			CoolUtil.precacheSound("boom");
			CoolUtil.precacheSound("boomNote");
			CoolUtil.precacheSound("burnSoundNote");
			CoolUtil.precacheSound("disarmed");
			CoolUtil.precacheSound("fall");
			CoolUtil.precacheSound("cancelMenu");
			CoolUtil.precacheSound("confirmMenu");
			CoolUtil.precacheSound("scrollMenu");
			CoolUtil.precacheSound("dialogue");
			CoolUtil.precacheSound("dialogueClose");
			CoolUtil.precacheSound("fnf_loss_sfx");
			CoolUtil.precacheSound("hitsound");
			CoolUtil.precacheSound("intro1");
			CoolUtil.precacheSound("intro2");
			CoolUtil.precacheSound("intro3");
			CoolUtil.precacheSound("introGo");
			CoolUtil.precacheSound("Metronome_Tick");
			CoolUtil.precacheSound('missnote1');
			CoolUtil.precacheSound('missnote2');
			CoolUtil.precacheSound('missnote3');
	
			CoolUtil.precacheMusic('configMenu');
			CoolUtil.precacheMusic('freakyMenu');
			CoolUtil.precacheMusic('offsetSong');
			CoolUtil.precacheMusic('breakfast');
			CoolUtil.precacheMusic('flippy-pause');
			CoolUtil.precacheMusic('gameOver');
			CoolUtil.precacheMusic('gameOverEnd');
			CoolUtil.precacheMusic('tea-time');
	
			CoolUtil.precacheInst("assault");
			CoolUtil.precacheInst("bombshell");
			CoolUtil.precacheInst("real");
			CoolUtil.precacheInst("fliphardy");
			CoolUtil.precacheInst("triggered");
			CoolUtil.precacheInst("slaughter");
			CoolUtil.precacheInst("shell-shanked");
			CoolUtil.precacheInst("kapow");
			CoolUtil.precacheInst("meltdown");
			CoolUtil.precacheInst("overkill");
			CoolUtil.precacheInst("fallout");
			CoolUtil.precacheInst("tags");
			CoolUtil.precacheInst("unhinged");
			CoolUtil.precacheInst("unseized");
			CoolUtil.precacheInst("disclosed");
			CoolUtil.precacheInst("disturbed");
			CoolUtil.precacheInst("cleave");
			CoolUtil.precacheInst("slasher");
			CoolUtil.precacheInst("compass");
			CoolUtil.precacheInst("the-rumbling");
			CoolUtil.precacheInst("slaughter-guerrilla");
			CoolUtil.precacheInst("triggered-guerrilla");
			CoolUtil.precacheInst("playdate");
			CoolUtil.precacheInst("lsd");
			CoolUtil.precacheInst("extinction");
			CoolUtil.precacheInst("funny");	
		}); */

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end

			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					loadingText.visible = false;
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}
		loadingText.visible = false;

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image('titleBG'));
		add(bg);

		logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		logoBl.scale.set(0.7, 0.7);
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		swagShader = new ColorSwap();
		gfDance = new FlxSprite(-30,15);
		gfDance.frames = Paths.getSparrowAtlas('FLIPPY');
		gfDance.scale.set(0.7, 0.7);
		gfDance.animation.addByPrefix('idle', 'idle', 24, false);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		add(gfDance);
		gfDance.shader = swagShader.shader;
		add(logoBl);
		logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "assets/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else

		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (animFrames.length > 0) {
			newTitle = true;
			
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else {
			newTitle = false;
			
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (FlxG.keys.anyJustPressed(fullKeys))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			gfDance.animation.play('idle', true);
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
				case 4:
					addMoreText('present');
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['In association', 'with'], -40);
				case 8:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 10:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 12:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 13:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 14:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 15:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 16:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if (playJingle) //Ignore deez
			{
				var sound:FlxSound = null;
				transitioning = true;
				remove(ngSpr);
				remove(credGroup);
				FlxG.camera.flash(FlxColor.WHITE, 3);
				sound.onComplete = function() {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					transitioning = false;
				};
			playJingle = false;
		}
		else
			remove(ngSpr);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			skippedIntro = true;
		}
	}
}
