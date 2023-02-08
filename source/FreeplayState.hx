package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import openfl.Lib;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var invertEffect:InvertSwap = null;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	var chromeValue:Float = 0;
	var songTimer:FlxTimer;
	var bg:FlxSprite;
	var flipbg:FlxSprite;
	var barrier:FlxSprite;
	var intendedColor:Int;
	var fullKeys:Array<FlxKey>;
	var flipps:FlxSprite;
	var flipbgin:FlxSprite;
	var flippsinvert:FlxSprite;
	var colorTween:FlxTween;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		CoolUtil.precacheMusic('freakyMenu');
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		Lib.application.window.title = Main.gameTitle + " - " + "Freeplay";

		fullKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('fullscreen'));

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		flipbg = new FlxSprite().loadGraphic(Paths.image('freeplay/fallen-soldier/og-bg'));
		flipbg.antialiasing = ClientPrefs.globalAntialiasing;
		add(flipbg);
		//flipbg.screenCenter();

		flipps = new FlxSprite(0, 700).loadGraphic('assets/images/freeplay/fallen-soldier/og-fg.png');
		add(flipps);

		flipbgin = new FlxSprite().loadGraphic(Paths.image('freeplay/fallen-soldier/og-bg'));
		flipbgin.antialiasing = ClientPrefs.globalAntialiasing;
		add(flipbgin);
		//flipbg.screenCenter();

		flippsinvert = new FlxSprite(0, 700).loadGraphic('assets/images/freeplay/fallen-soldier/invert.png');
		add(flippsinvert);

		flipbgin.visible = false;
		flippsinvert.visible = false;

		barrier = new FlxSprite().loadGraphic(Paths.image('freeplay/menuSide'));
		barrier.antialiasing = ClientPrefs.globalAntialiasing;
		add(barrier);
		barrier.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.isMenuItem = true;
			songText.targetY = i - curSelected;
			grpSongs.add(songText);

			var maxWidth = 980;
			if (songText.width > maxWidth)
			{
				songText.scaleX = maxWidth / songText.width;
			}
			songText.snapToPosition();

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());

	public static function setChrome(chromeOffset:Float):Void
	{
		if (ClientPrefs.shaders)
		{
			chromeOffset = 0.0;
		}
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}

	var instPlaying:Int = -1;
	private static var flipString:String = 'og';
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		setChrome(chromeValue);

		switch (flipString)
		{
			case 'og':
				flipbgin.visible = false;
				flippsinvert.visible = false;
			if(ClientPrefs.freeplayMenu == 'Original')
			{				
				flipbg.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-fg.png');
			}
			if(ClientPrefs.freeplayMenu == 'Marazak Version')
			{				
				flipbg.loadGraphic('assets/images/freeplay/bymrzk/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/bymrzk/$flipString-fg.png');
			}
			case 'bloody':
				flipbgin.visible = false;
				flippsinvert.visible = false;
			if(ClientPrefs.freeplayMenu == 'Original')
			{				
				flipbg.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-fg.png');
			}
			if(ClientPrefs.freeplayMenu == 'Marazak Version')
			{				
				flipbg.loadGraphic('assets/images/freeplay/bymrzk/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/bymrzk/$flipString-fg.png');
			}
			case 'insane':
				flipbgin.visible = false;
				flippsinvert.visible = false;
			if(ClientPrefs.freeplayMenu == 'Original')
			{				
				flipbg.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-fg.png');
			}
			if(ClientPrefs.freeplayMenu == 'Marazak Version')
			{				
				flipbg.loadGraphic('assets/images/freeplay/bymrzk/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/bymrzk/$flipString-fg.png');
			}
			case 'fearful':
				flipbgin.visible = false;
				flippsinvert.visible = false;
			if(ClientPrefs.freeplayMenu == 'Original')
			{				
				flipbg.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-fg.png');
			}
			if(ClientPrefs.freeplayMenu == 'Marazak Version')
			{				
				flipbg.loadGraphic('assets/images/freeplay/bymrzk/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/bymrzk/$flipString-fg.png');
			}
			case 'alt':
				flipbgin.visible = false;
				flippsinvert.visible = false;
				flipbg.x = 0;
			if(ClientPrefs.freeplayMenu == 'Original')
			{
				flipbg.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-fg.png');
			}
			if(ClientPrefs.freeplayMenu == 'Marazak Version')
			{
				flipbg.loadGraphic('assets/images/freeplay/bymrzk/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/bymrzk/$flipString-fg.png');
			}
			case 'minus':
				flipbgin.visible = false;
				flippsinvert.visible = false;
			if(ClientPrefs.freeplayMenu == 'Original')
			{				
				flipbg.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-fg.png');
			}
			if(ClientPrefs.freeplayMenu == 'Marazak Version')
			{				
				flipbg.loadGraphic('assets/images/freeplay/bymrzk/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/bymrzk/$flipString-fg.png');
			}
			case 'kapow':
				flipbgin.visible = false;
				flippsinvert.visible = false;
			if(ClientPrefs.freeplayMenu == 'Original')
			{				
				flipbg.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-fg.png');
			}
			if(ClientPrefs.freeplayMenu == 'Marazak Version')
			{				
				flipbg.loadGraphic('assets/images/freeplay/bymrzk/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/bymrzk/$flipString-fg.png');
			}
			case 'shanked':
				flipbgin.visible = false;
				flippsinvert.visible = false;
			if(ClientPrefs.freeplayMenu == 'Original')
			{				
				flipbg.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-fg.png');
			}
			if(ClientPrefs.freeplayMenu == 'Marazak Version')
			{				
				flipbg.loadGraphic('assets/images/freeplay/fallen-soldier/$flipString-bg.png');
				flipps.loadGraphic('assets/images/freeplay/bymrzk/$flipString-fg.png');
			}
			case 'invert':
				flipbgin.visible = true;
				flippsinvert.visible = true;
			if(ClientPrefs.freeplayMenu == 'Original')
			{				
				flipbgin.loadGraphic('assets/images/freeplay/fallen-soldier/og-bg.png');
			}
			if(ClientPrefs.freeplayMenu == 'Marazak Version')
			{				
				flipbgin.loadGraphic('assets/images/freeplay/bymrzk/og-bg.png');
			}
			case 'default':
				flipbgin.visible = false;
				flippsinvert.visible = false;
				flipbg.loadGraphic('assets/images/freeplay/$flipString.png');
				flipps.loadGraphic('assets/images/freeplay/blank.png');
			default:
				flipbg.loadGraphic('assets/images/freeplay/$flipString.png');
				flipps.loadGraphic('assets/images/freeplay/blank.png');
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (FlxG.keys.anyJustPressed(fullKeys))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;			
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		flipps.y = 700;
		flippsinvert.y = 700;

		if (curSelected == 0)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Triggered";
			flipString = "og";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 1)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Slaughter";
			flipString = "bloody";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 2)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Overkill";
			flipString = "insane";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 3)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Fallout";
			flipString = "fearful";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 4)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Compass";
			flipString = "alt";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 5)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Assault";
			flipString = "alt";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 6)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Bombshell";
			flipString = "alt";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 7)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Extinction";
			flipString = "alt";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 8)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Slasher";
			flipString = "minus";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 9)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Cleave";
			flipString = "minus";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 10)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Disturbed";
			flipString = "minus";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 11)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "KAPOW";
			flipString = "kapow";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 12)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Meltdown";
			flipString = "kapow";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 13)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Shell Shanked";
			flipString = "shanked";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 14)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Unseized";
			flipString = "og";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
	    }
		if (curSelected == 15)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "LSD";
			flipString = "invert";
			FlxTween.tween(flippsinvert,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 16)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Playdate";
	    	flipString = "og";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 17)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Fliphardy";
			flipString = "og";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 18)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Real";
			flipString = "default";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 19)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Tags";
			flipString = "og";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 20)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Disclosed";
			flipString = "bloody";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected == 21)
		{
			Lib.application.window.title = Main.gameTitle + " - " + "Freeplay" + " - " + "Unhinged";
			flipString = "insane";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		if (curSelected > 22)
		{
			flipString = "default";
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
									

		#if PRELOAD_ALL
		if (FlxG.sound.music.playing)
		{
			FlxG.sound.music.stop();
		}
		if (songTimer != null)
		{
			songTimer.cancel();
			songTimer.destroy();
		}
		songTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.stop();
			}
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
			Conductor.changeBPM(Song.loadFromJson(songs[curSelected].songName.toLowerCase(), songs[curSelected].songName.toLowerCase()).bpm);
		}, 1);
		#else
		Conductor.changeBPM(Song.loadFromJson(songs[curSelected].songName.toLowerCase(), songs[curSelected].songName.toLowerCase()).bpm);
		#end
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].animation.curAnim.curFrame = 0;
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].animation.curAnim.curFrame = 2;
		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	override function beatHit()
	{
		super.beatHit();
			
		if ([
		'triggered', 
		'slaughter', 
		'overkill', 
		'fallout', 
		'compass', 
		'assault',
	    'bombshell',
	    'extinction',
	    'slasher',
	    'cleave',
	    'disturbed',
	    'kapow',
	    'meltdown',
		'shell shanked',
	    'unseized',
	    'lsd',
		'playdate',
	    'fliphardy',
	    'real',
	    'tags',
	    'disclosed',
	    'unhinged'].contains(songs[curSelected].songName.toLowerCase()))
		{
			if(ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015;
				FlxTween.tween(FlxG.camera, { zoom: 1 }, 0.1);
			}
			if (songs[curSelected].songName.toLowerCase() == 'lsd')
			{
				if(curBeat == 16) {
				if(ClientPrefs.camZooms)
				{
					invertEffect = new InvertSwap();
					flipbgin.shader = invertEffect.shader;
					flippsinvert.shader = invertEffect.shader;
					FlxG.camera.zoom += 0.15;
				}
			    }
			}
			if (songs[curSelected].songName.toLowerCase() == 'overkill')
			{
				if(ClientPrefs.shaking)
				{
					FlxG.camera.shake(0.003, 0.1);
					chromeValue += 6 / 1000;
					FlxTween.tween(this, { chromeValue: 0 }, 0.15);
				}
			}
		else if (songs[curSelected].songName.toLowerCase() == 'unhinged')
			{
				if(ClientPrefs.shaking)
				{
					FlxG.camera.shake(0.003, 0.1);
					chromeValue += 6 / 1000;
					FlxTween.tween(this, { chromeValue: 0 }, 0.15);
				}
			}
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}