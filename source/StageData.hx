package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end
import haxe.Json;
import haxe.format.JsonParser;
import Song;

using StringTools;

typedef StageFile = {
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;
	var isBloodStage:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var hide_girlfriend:Bool;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData {
	public static var forceNextDirectory:String = null;
	public static function loadDirectory(SONG:SwagSong) {
		var stage:String = '';
		if(SONG.stage != null) {
			stage = SONG.stage;
		} else if(SONG.song != null) {
			switch (SONG.song.toLowerCase().replace(' ', '-'))
			{
				case 'Triggered' | 'Funny' | 'Playdate' | 'Unseized' | 'LSD' | 'Fliphardy' | 'Real' | 'Tags':
					stage = 'camp';
				case 'Slaughter' | 'Disclosed':
					stage = 'blood';
				case 'Overkill-Old' | 'Fallout-Old':
					stage = 'bloodold';
				case 'Overkill' | 'Unhinged':
					stage = 'fire';
				case 'Fallout':
					stage = 'burnt';
				case 'Assault' | 'Compass' | 'Extinction' | 'Bombshell':
					stage = 'camp-alt';
				case 'Slasher' | 'Cleave' | 'Disturbed':
					stage = 'treehouse';
				case 'Kapow' | 'Meltdown':
					stage = 'army';
				case 'The Rumbling':
					stage = 'discord';						
				default:
					stage = 'stage';
			}
		} else {
			stage = 'stage';
		}

		var stageFile:StageFile = getStageFile(stage);
		if(stageFile == null) { //preventing crashes
			forceNextDirectory = '';
		} else {
			forceNextDirectory = stageFile.directory;
		}
	}

	public static function getStageFile(stage:String):StageFile {
		var rawJson:String = null;
		var path:String = Paths.getPreloadPath('stages/' + stage + '.json');

		#if MODS_ALLOWED
		var modPath:String = Paths.modFolders('stages/' + stage + '.json');
		if(FileSystem.exists(modPath)) {
			rawJson = File.getContent(modPath);
		} else if(FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		}
		#else
		if(Assets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		#end
		else
		{
			return null;
		}
		return cast Json.parse(rawJson);
	}
}