package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;
	var fullKeys:Array<FlxKey>;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

    var mainTracks:FlxText;
    var altTracks:FlxText;
    var bonusTracks:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var blackBarThingie:FlxSprite;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var mainWeek:FlxSprite;
	var altWeek:FlxSprite;
	var bonusWeek:FlxSprite;

	public var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		openfl.Lib.application.window.title = Main.gameTitle + " - " + "Story Mode";

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		fullKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('fullscreen'));

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		//var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		blackBarThingie = new FlxSprite().loadGraphic(Paths.image('menuweeks/menuBottom'));
		mainTracks = new FlxText(130, bgSprite.y + 485, 0, "Triggered, Slaughter, Overkill, Fallout", 32);
		mainTracks.alignment = LEFT;
		mainTracks.setFormat(Paths.font("consola.ttf"),32);
		mainTracks.color = 0xffff0000;
		altTracks = new FlxText(130, bgSprite.y + 485, 0, "Compass, Assault, Bombshell", 32);
		altTracks.alignment = LEFT;
		altTracks.setFormat(Paths.font("consola.ttf"),32);
		altTracks.color = 0xffff00ff;
        altTracks.visible = false;
        bonusTracks = new FlxText(130, bgSprite.y + 485, 0, "Slasher, Cleave, Disturbed", 32);
		bonusTracks.alignment = LEFT;
		bonusTracks.setFormat(Paths.font("consola.ttf"),32);
		bonusTracks.color = 0xffffee00;
        bonusTracks.visible = false;

		mainWeek = new FlxSprite(300, 610).loadGraphic(Paths.image('menuweeks/main'));
		altWeek = new FlxSprite(580, 610).loadGraphic(Paths.image('menuweeks/alt'));
		bonusWeek = new FlxSprite(800, 610).loadGraphic(Paths.image('menuweeks/bonus'));

		grpWeekText = new FlxTypedGroup<MenuItem>();
		//add(grpWeekText);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
				weekThing.y += ((weekThing.height + 50) * num);
				weekThing.targetY = num;
				grpWeekText.add(weekThing);

				//weekThing.screenCenter(X);
				weekThing.antialiasing = ClientPrefs.globalAntialiasing;
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					lock.antialiasing = ClientPrefs.globalAntialiasing;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(230, 600);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.visible = false;
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(1050, 600);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;

		//add(bgYellow);
		add(bgSprite);
		add(grpWeekCharacters);
		add(blackBarThingie);
        add(mainTracks);
        add(altTracks);
        add(bonusTracks);
		add(mainWeek);
		add(altWeek);
		add(bonusWeek);
		add(rightArrow);
		add(leftArrow);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		//add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		//add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		changeWeek();
		changeDifficulty();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_LEFT_P;
			var downP = controls.UI_RIGHT_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (FlxG.keys.anyJustPressed(fullKeys))
			{
				FlxG.fullscreen = !FlxG.fullscreen;
			}

			if (FlxG.keys.justPressed.SIX)
			{
				var songLowercase:String = Paths.formatToSongPath('the-rumbling');
				var poop:String = Highscore.formatSong(songLowercase, 1);
	
				trace(poop);
	
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.stop();
			}

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
			lock.visible = (lock.y > FlxG.height / 2);
		});
		grpWeekText.forEach(function(spr:MenuItem)
		{
			spr.x = -30;
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				if(curWeek == 0) {
					FlxFlicker.flicker(mainWeek, 1, 0.06, false, false);
					FlxTween.tween(altWeek, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
					FlxTween.tween(bonusWeek, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				}
				else if(curWeek == 1) {
					FlxFlicker.flicker(altWeek, 1, 0.06, false, false);
					FlxTween.tween(mainWeek, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
					FlxTween.tween(bonusWeek, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				}
				else if(curWeek == 2) {
					FlxFlicker.flicker(bonusWeek, 1, 0.06, false, false);
					FlxTween.tween(mainWeek, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
					FlxTween.tween(altWeek, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				}
				FlxTween.tween(leftArrow, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				FlxTween.tween(rightArrow, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				new FlxTimer().start(0.55, function(tmr:FlxTimer)
				{
					FlxTween.tween(bgSprite, {y: 720}, 0.35, {ease: FlxEase.expoInOut});
					FlxTween.tween(blackBarThingie, {y: 720}, 0.35, {ease: FlxEase.expoInOut});
					FlxTween.tween(mainTracks, {y: 720}, 0.35, {ease: FlxEase.expoInOut});
					FlxTween.tween(altTracks, {y: 720}, 0.35, {ease: FlxEase.expoInOut});
					FlxTween.tween(bonusTracks, {y: 720}, 0.35, {ease: FlxEase.expoInOut});
					FlxTween.tween(scoreText, {y: 720}, 0.35, {ease: FlxEase.expoInOut});
					FlxTween.tween(txtWeekTitle, {y: 720}, 0.35, {ease: FlxEase.expoInOut});
				});
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();

				for (char in grpWeekCharacters.members)
				{
					if (char.character != '' && char.hasConfirmAnimation)
					{
						char.animation.play('confirm');
					}
				}
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = CoolUtil.difficulties[curDifficulty];
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 15;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
		{
			curWeek = 0;
		    bgSprite.x = -60;
		}
		if (curWeek < 0)
		{
			curWeek = loadedWeeks.length - 1;
			bgSprite.x = 60;
		}

		bgSprite.alpha = 0.4;

		if(curWeek == 0) {
			bonusWeek.alpha = 0.5;
			altWeek.alpha = 0.5;
			mainWeek.alpha = 1;
            mainTracks.visible = true;
            altTracks.visible = false;
            bonusTracks.visible = false;
			FlxTween.tween(bgSprite, {x: 0}, 0.35, {ease: FlxEase.quadInOut});
			FlxTween.tween(bgSprite, {alpha: 1}, 0.4, {ease: FlxEase.linear});
		}
		if(curWeek == 1) {
			mainWeek.alpha = 0.5;
			bonusWeek.alpha = 0.5;
			altWeek.alpha = 1;
            mainTracks.visible = false;
            altTracks.visible = true;
            bonusTracks.visible = false;
			FlxTween.tween(bgSprite, {x: 0}, 0.35, {ease: FlxEase.quadInOut});
			FlxTween.tween(bgSprite, {alpha: 1}, 0.4, {ease: FlxEase.linear});
		}
		if(curWeek == 2) {
			altWeek.alpha = 0.5;
			mainWeek.alpha = 0.5;
			bonusWeek.alpha = 1;
            mainTracks.visible = false;
            altTracks.visible = false;
            bonusTracks.visible = true;
			FlxTween.tween(bgSprite, {x: 0}, 0.35, {ease: FlxEase.quadInOut});
			FlxTween.tween(bgSprite, {alpha: 1}, 0.4, {ease: FlxEase.linear});
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && unlocked)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5
		difficultySelectors.visible = unlocked;

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
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
