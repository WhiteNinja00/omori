package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	public static var initialized:Bool = false;

	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	
	var optionShit:Array<String> = [
		'new game',
		'continue',
		'options'
	];
	
	var debugKeys:Array<FlxKey>;
	var hand:FlxSprite;
	var floatstuff = 0.0;
	var optiontime = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();
		super.create();

		FlxG.save.bind('omori', 'thewhiteninja');

		ClientPrefs.loadPrefs();

		if(!initialized) {
			if(FlxG.save.data != null && FlxG.save.data.fullscreen) {
				FlxG.fullscreen = FlxG.save.data.fullscreen;
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		FlxG.mouse.visible = false;
		if(FlxG.save.data.alreadydone == null) {
			FlxG.save.data.alreadydone = false;
		}
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			if(!FlxG.save.data.alreadydone) {
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new FlashingState());
			}
		} else {
			#if desktop
			if (!DiscordClient.isInitialized) {
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end
		}

		if(!initialized && FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		}
	
		Conductor.changeBPM(102);
		persistentUpdate = true;

		if(!initialized) initialized = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		if(FlxG.save.data.progression == null) {
			FlxG.save.data.progression = -1;
			FlxG.save.flush();
		}

		var background:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		background.scrollFactor.set(0, 0);
		add(background);

		var logo:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omori menu/logo'));
		logo.scrollFactor.set(0, 0);
		logo.screenCenter(X);
		add(logo);

		var omori:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omori menu/omori'), true, 607, 672);
		omori.animation.add("idle", [0, 1], 4);
		omori.scrollFactor.set(0, 0);
		omori.scale.x = 0.8;
		omori.scale.y = 0.8;
		omori.screenCenter(X);
		omori.y = FlxG.height - (omori.height * 0.88);
		add(omori);
		omori.animation.play('idle');

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		hand = new FlxSprite(0, 664).loadGraphic(Paths.image('omori menu/hand'));
		hand.scrollFactor.set(0, 0);
		add(hand);

		var vertext:FlxText = new FlxText(2.5, 2.5, 0, 'vDEV BUILD', 32);
		vertext.scrollFactor.set(0, 0);
		vertext.setFormat(Paths.font("mainmenu.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		vertext.borderSize = 2;
		add(vertext);

		for (i in 0...optionShit.length) {
			var button:FlxSprite = new FlxSprite(0, 652).loadGraphic(Paths.image('omori menu/square'));
			button.scrollFactor.set(0, 0);
			button.screenCenter(X);
			button.ID = i;
			menuItems.add(button);

			var xthing = 0.0;
			if(i == 0) {
				xthing -= 72 + button.width;
			} else if(i == 2) {
				xthing += 72 + button.width;
			}

			button.x += xthing;

			var color = 0xFFFFFFFF;
			if(FlxG.save.data.progression == -1 && i == 1) {
				color = 0xFF878787;
			}

			var text:FlxText = new FlxText(button.x + (button.width / 2), 0, 0, optionShit[i].toUpperCase(), 44);
			text.scrollFactor.set(0, 0);
			text.setFormat(Paths.font("mainmenu.ttf"), 44, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.x -= text.width / 2;
			text.y = button.y - 7;
			add(text);
		}

		firstchangeitem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float) {
		floatstuff += 0.05;
		hand.x += Math.sin(floatstuff) / 2;

		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if(optiontime) {
			if (controls.BACK) {
				optiontime = false;
				selectedSomethin = false;
			}
		} else {
			if (!selectedSomethin) {
				if (controls.UI_LEFT_P) {
					changeItem(-1);
				}
	
				if (controls.UI_RIGHT_P) {
					changeItem(1);
				}
	
				if (controls.ACCEPT) {
					if(FlxG.save.data.progression == -1 && curSelected == 1) {
						FlxG.sound.play(Paths.sound('cant'));
					} else {
						FlxG.sound.play(Paths.sound('confirmMenu'));
						selectedSomethin = true;
	
						menuItems.forEach(function(spr:FlxSprite) {
							if (curSelected == spr.ID) {
								switch (optionShit[curSelected])
								{
									case 'new game':
										FlxG.save.data.progression = 0;
										FlxG.save.data.gamestuff = [96, 224, 'down', 0];
										FlxG.save.data.songsdone = [];
										FlxG.save.data.cat = false;
										FlxG.save.data.pc = false;
										FlxG.save.data.diary = false;
										FlxG.save.data.tissue = false;
										FlxG.save.data.door = false;
										FlxG.save.data.omori = false;
										FlxG.save.data.mic = false;
										FlxG.save.data.micfell = false;
										FlxG.save.flush();
										MusicBeatState.switchState(new Omori('intro'));
									case 'continue':
										MusicBeatState.switchState(new Omori());
									case 'options':
										optiontime = true;
								}
							}
						});
					}
				}
				#if desktop
				else if (FlxG.keys.anyJustPressed(debugKeys)) {
					selectedSomethin = true;
					MusicBeatState.switchState(new MasterEditorMenu());
				}
				#end
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0) {
		var oldcurselected = 0;
		oldcurselected = curSelected;
		curSelected += huh;

		if (curSelected >= menuItems.length) curSelected = menuItems.length - 1;
		if (curSelected < 0) curSelected = 0;

		if(oldcurselected != curSelected) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		menuItems.forEach(function(spr:FlxSprite) {
			if(spr.ID == curSelected && oldcurselected != curSelected) {
				floatstuff = 0;
				hand.x = spr.x - hand.width - 22.5;
			}
		});
	}

	function firstchangeitem() {
		menuItems.forEach(function(spr:FlxSprite) {
			if(spr.ID == curSelected) {
				floatstuff = 0;
				hand.x = spr.x - hand.width - 22.5;
			}
		});
	}
}
