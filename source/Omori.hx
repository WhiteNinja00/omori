package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxCollision;
import vlc.MP4Handler;
import flixel.util.FlxTimer;

class Omori extends MusicBeatState {
	var player:FlxSprite;
    var curdirection = 'down';
    var framerate = 4;
    var speed = 4;
    var fakespeed = 4;
    var section = 0;
    var dialoguebox:FlxSprite;
    var dialoguetext:FlxTypeText;
    var dialogueopen = false;
    var dialoguetyping = false;
    var stillopening = false;
    var sectionstuff:FlxTypedGroup<FlxSprite>;
    var frontsectionstuff:FlxTypedGroup<FlxSprite>;
    var hand:FlxSprite;
    var floatstuff = 0.0;
    var closingdialogue = false;
    var secondtext = false;
    var secondcache = '';
    var handdis = true;
    var songstuff = '';
    var songcache = '';
    var shouldplaysong = false;
    var kindasecond = false;
    var dialoguefound = false;
    var runstuff = '';
    var canmove = false;
    var invideo = false;
    var waitformic = false;
    var microphonetext = false;

    public function new(song:String = '') {
        super();

        songstuff = song;
    }

	override function create() {

        section = FlxG.save.data.gamestuff[3];

        sectionstuff = new FlxTypedGroup<FlxSprite>();
		add(sectionstuff);

        switch(section) {
            case 0:
                var white:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
                white.scrollFactor.set(0, 0);
                white.ID = 1;
                sectionstuff.add(white);

                var background:FlxSprite = new FlxSprite(63, 148).loadGraphic(Paths.image('whitespace/background'));
                background.ID = 1;
                sectionstuff.add(background);

                var cat:FlxSprite = new FlxSprite(64, 256);
                cat.loadGraphic(Paths.image('whitespace/cat'), true, 32, 32);
                cat.animation.add("idle", [0, 1], framerate);
                cat.ID = 0;
                sectionstuff.add(cat);
                cat.animation.play('idle');

                var tissue:FlxSprite = new FlxSprite(160, 224).loadGraphic(Paths.image('whitespace/tissue'));
                tissue.ID = 2;
                sectionstuff.add(tissue);

                var diary:FlxSprite = new FlxSprite(160, 160).loadGraphic(Paths.image('whitespace/diary'));
                diary.ID = 3;
                sectionstuff.add(diary);

                var pc:FlxSprite = new FlxSprite(96, 160);
                pc.loadGraphic(Paths.image('whitespace/pc'), true, 32, 32);
                pc.animation.add("idle", [0, 1, 2], framerate);
                pc.ID = 4;
                sectionstuff.add(pc);
                pc.animation.play('idle');

                var door:FlxSprite = new FlxSprite(64, 64).loadGraphic(Paths.image('whitespace/door'));
                door.ID = 5;
                sectionstuff.add(door);

                var omori:FlxSprite = new FlxSprite(64, 192).loadGraphic(Paths.image('whitespace/omori'));
                omori.ID = 6;
                sectionstuff.add(omori);

                var mic:FlxSprite = new FlxSprite(475, 89).loadGraphic(Paths.image('whitespace/omori'));
                if(FlxG.save.data.mic) {
                    mic.visible = false;
                } else {
                    mic.visible = FlxG.save.data.micfell;
                }
                mic.ID = 7;
                sectionstuff.add(mic);
        }

        player = new FlxSprite();
		player.loadGraphic(Paths.image('boyfriend'), true, 32, 32);
		player.animation.add("downidle", [1], framerate * 2);
		player.animation.add("downwalk", [0, 1, 2, 1], framerate * 2);
        player.animation.add("downrun", [3, 4, 5, 6, 7, 8, 5], framerate * 4);
		player.animation.add("leftidle", [10], framerate * 2);
		player.animation.add("leftwalk", [9, 10, 11, 10], framerate * 2);
        player.animation.add("leftrun", [12, 13, 14, 15, 16, 17, 14], framerate * 4);
        player.animation.add("rightidle", [19], framerate * 2);
		player.animation.add("rightwalk", [18, 19, 20, 19], framerate * 2);
        player.animation.add("rightrun", [21, 22, 23, 24, 25, 26, 23], framerate * 4);
        player.animation.add("upidle", [28], framerate * 2);
		player.animation.add("upwalk", [27, 28, 29, 28], framerate * 2);
        player.animation.add("uprun", [30, 31, 32, 33, 34, 35, 32], framerate * 4);
		add(player);
        player.animation.play('downidle');

        curdirection = FlxG.save.data.gamestuff[2];
        player.animation.play(curdirection + 'idle');
        player.x = FlxG.save.data.gamestuff[0];
        player.y = FlxG.save.data.gamestuff[1];

        frontsectionstuff = new FlxTypedGroup<FlxSprite>();
		add(frontsectionstuff);

        switch(section) {
            case 0:
                var light:FlxSprite = new FlxSprite(135, -120);
                light.loadGraphic(Paths.image('whitespace/light'), true, 17, 232);
                light.animation.add("idle", [0, 1], framerate);
                light.ID = 1;
                frontsectionstuff.add(light);
                light.animation.play('idle');
        }

        dialoguebox = new FlxSprite(0, 0).loadGraphic(Paths.image('dialoguebox'));
		dialoguebox.scrollFactor.set(0, 0);
        dialoguebox.scale.x = 0.5;
        dialoguebox.scale.y = 0.5;
        dialoguebox.y = 477.5 - (dialoguebox.height / 2);
        dialoguebox.scale.y = 0;
        dialoguebox.x = 5;
		add(dialoguebox);
        
        hand = new FlxSprite(690, 530).loadGraphic(Paths.image('omori menu/hand'));
        hand.x -= hand.width;
        hand.y -= hand.height;
		hand.scrollFactor.set(0, 0);
        hand.alpha = 0;
		add(hand);

        if(songstuff == 'intro') {
            var backgroundthing:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
            backgroundthing.scrollFactor.set(0, 0);
            add(backgroundthing);
            var filepath:String = Paths.video('intro');
            var video:MP4Handler = new MP4Handler();
            video.playVideo(filepath);
            invideo = true;
            FlxG.sound.music.pause();
            video.finishCallback = function() {
                remove(backgroundthing);
                FlxG.sound.music.play();
                FlxG.sound.playMusic(Paths.music('whitespace'), 0);
                invideo = false;
            }
        } else {
            switch(section) {
                case 0:
                    FlxG.sound.playMusic(Paths.music('whitespace'), 0);
            }
        }

        switch(songstuff) {
            case 'tutorial':
                opendialogue('epic', '', 'you are epic');
        }

        FlxG.worldBounds.width = 7000;
		FlxG.worldBounds.height = 7000;

        FlxG.camera.follow(player, LOCKON, 1);
        FlxG.camera.zoom = 1.8;

        if(FlxG.save.data.songsdone.contains('tutorial')) {
            FlxG.save.data.progression = 1;
        } else {
            FlxG.save.data.progression = 0;
        }

		super.create();
	}

	override function update(elapsed:Float) {
        if(!invideo) {
            if (FlxG.sound.music.volume < 0.8) {
                FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
            }

            if(dialogueopen) {
                floatstuff += 0.05;
                hand.x += Math.sin(floatstuff) / 2;
                if(controls.ACCEPT) {
                    if(dialoguetyping) {
                        if(!stillopening) {
                            dialoguetext.skip();
                            dialoguedone();
                        }
                    } else {
                        if(secondtext) {
                            remove(dialoguetext);
                            opendialogue();
                        } else {
                            if(microphonetext) {
                                sectionstuff.forEach(function(spr:FlxSprite) {
                                    if(spr.ID == 7) {
                                        spr.visible = false;
                                    }
                                });
                                FlxG.save.data.mic = true;
                                microphonetext = false;
                                closedialogue();
                            } else {
                                if(shouldplaysong && kindasecond) {
                                    shouldplaysong = false;
                                    kindasecond = false;
                                    PlayState.SONG = Song.loadFromJson(songcache, songcache);
                                    PlayState.isStoryMode = false;
                                    PlayState.storyDifficulty = 1;
                                    LoadingState.loadAndSwitchState(new PlayState());
                                } else {
                                    if(FlxG.save.data.micfell) {
                                        closedialogue();
                                    } else {
                                        if(FlxG.save.data.cat && FlxG.save.data.pc && FlxG.save.data.diary && FlxG.save.data.tissue && FlxG.save.data.door && FlxG.save.data.omori && !waitformic) {
                                            waitformic = true;
                                            closedialogue();
                                            new FlxTimer().start(1, function(tmr:FlxTimer) {
                                                FlxG.sound.play(Paths.sound('micfall'));
                                                FlxG.save.data.micfell = true;
                                                sectionstuff.forEach(function(spr:FlxSprite) {
                                                    if(spr.ID == 7) {
                                                        spr.visible = true;
                                                    }
                                                });
                                                new FlxTimer().start(2, function(tmr:FlxTimer) {
                                                    opendialogue('Something fell nearby.');
                                                    waitformic = false;
                                                });
                                                savedata(); 
                                            });
                                        } else {
                                            closedialogue();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if(!waitformic) {
                    if(controls.UI_UP) {
                        curdirection = 'up';
                    }
                    if(controls.UI_DOWN) {
                        curdirection = 'down';
                    }
                    if(controls.UI_LEFT) {
                        curdirection = 'left';
                    }
                    if(controls.UI_RIGHT) {
                        curdirection = 'right';
                    }
                    if(FlxG.keys.pressed.S && FlxG.keys.pressed.P && FlxG.keys.pressed.E && FlxG.keys.pressed.D) {
                        speed = 8;
                        framerate = 8;
                    }
                    if(FlxG.keys.pressed.W && FlxG.keys.pressed.N) {
                        savedata();
                    }
                    if(FlxG.keys.pressed.SHIFT) {
                        if(runstuff != 'run') {
                            runstuff = 'run';
                        }
                        fakespeed = speed * 2;
                    } else {
                        if(runstuff != 'walk') {
                            runstuff = 'walk';
                        }
                        fakespeed = speed;
                    }
                    if(!controls.UI_UP && !controls.UI_DOWN && !controls.UI_LEFT && !controls.UI_RIGHT) {
                        player.animation.play(curdirection + 'idle');
                    } else {
                        canmove = true;
                        switch(curdirection) {
                            case 'up':
                                player.y -= fakespeed;
                                if(checkpos()) {
                                    player.y += fakespeed;
                                    canmove = false;
                                }
                            case 'down':
                                player.y += fakespeed;
                                if(checkpos()) {
                                    player.y -= fakespeed;
                                    canmove = false;
                                }
                            case 'left':
                                player.x -= fakespeed;
                                if(checkpos()) {
                                    player.x += fakespeed;
                                    canmove = false;
                                }
                            case 'right':
                                player.x += fakespeed;
                                if(checkpos()) {
                                    player.x -= fakespeed;
                                    canmove = false;
                                }
                        }
                        if(canmove) {
                            player.animation.play(curdirection + runstuff + '');
                        } else {
                            player.animation.play(curdirection + 'idle');
                        }
                    }
                    if(controls.BACK) {
                        savedata();
                        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
                        MusicBeatState.switchState(new MainMenuState());
                    }
                    if(controls.ACCEPT) {
                        if(!closingdialogue) {
                            dialoguefound = false;
                            sectionstuff.forEach(function(spr:FlxSprite) {
                                if(FlxMath.distanceBetween(player, spr) < 35 && !dialoguefound) {
                                    if(spr.ID != 1) {
                                        dialoguefound = true;
                                    }
                                    switch(section) {
                                        case 0:
                                            switch(spr.ID) {
                                                case 0:
                                                    opendialogue('Meow? (Waiting for something to happen?)', 'MEWO');
                                                    FlxG.save.data.cat = true;
                                                case 2:
                                                    opendialogue('A tissue box for wiping your sorrows away.');
                                                    FlxG.save.data.tissue = true;
                                                case 3:
                                                    opendialogue('This is Your sketchbook.');
                                                    FlxG.save.data.diary = true;
                                                case 4:
                                                    opendialogue('You tried to boot up your laptop.', '', '"Try again later".');
                                                    FlxG.save.data.pc = true;
                                                case 5:
                                                    if(FlxG.save.data.progression > 0) {
        
                                                    } else {
                                                        opendialogue('A white door casts a faint shadow.\nYou stared at the door.');
                                                    }
                                                    FlxG.save.data.door = true;
                                                case 6:
                                                    if(FlxG.save.data.mic) {
                                                        opendialogue('The blue haired singer stares at you.', '', 'He challenges you to sing.', 'tutorial');
                                                    } else {
                                                        opendialogue('The blue haired singer stares at you.');
                                                    }
                                                    FlxG.save.data.omori = true;
                                                case 7:
                                                    if(FlxG.save.data.micfell) {
                                                        opendialogue('You got a MICROPHONE.');
                                                    }
                                            }
                                    }
                                    savedata();
                                }
                            });
                        }
                    }
                    if(player.y < -500) {
                        player.y = 1200;
                    }
                    if(player.y > 1200) {
                        player.y = -500;
                    }
                    if(player.x < -1000) {
                        player.x = 1200;
                    }
                    if(player.x > 1200) {
                        player.x = -1000;
                    }
                }
            }
    
            if(handdis && hand.alpha != 0) {
                hand.alpha = 0;
            }
        }

		super.update(elapsed);
	}

    function savedata() {
        FlxG.save.data.gamestuff = [player.x, player.y, curdirection, section];
        FlxG.save.flush();
    }

    function opendialogue(text:String = '', charactername:String = '', second:String = '', thedamnsong:String = '') {
        if(text == '') {
            stillopening = false;
            dialogueopen = true;
            dialoguetyping = true;
            kindasecond = true;
            secondtext = false;
            makedialoguetext(secondcache, second);
        } else {
            if(text == 'You got a MICROPHONE.') {
                microphonetext = true;
            }
            if(thedamnsong != '') {
                songcache = thedamnsong;
                shouldplaysong = true;
            }
            player.animation.play(curdirection + 'idle');
            stillopening = true;
            dialogueopen = true;
            dialoguetyping = true;
            FlxTween.tween(dialoguebox, {"scale.y": 0.5}, 0.25, {
                onComplete: function(twn:FlxTween)
                {
                    stillopening = false;
                    makedialoguetext(text, second);
                }
            });
        }
    }

    function closedialogue() {
        dialogueopen = false;
        remove(dialoguetext);
        hand.alpha = 0;
        handdis = true;
        closingdialogue = true;
        FlxTween.tween(dialoguebox, {"scale.y": 0}, 0.25, {
            onComplete: function(twn:FlxTween)
            {
                closingdialogue = false;
            }
        });
    }

    function dialoguedone() {
        dialoguetyping = false;
        FlxTween.tween(hand, {alpha: 1}, 0.25);
        handdis = false;
    }

    function checkpos() {
        var trueorno = false;
        sectionstuff.forEach(function(spr:FlxSprite) {
            if(spr.ID != 1 && FlxG.pixelPerfectOverlap(player, spr, 1)) {
                if(section == 0) {
                    if(spr.ID == 7) {
                        if(FlxG.save.data.micfell && !FlxG.save.data.mic) {
                            trueorno = true;
                        }
                    } else {
                        trueorno = true;
                    }
                } else {
                    trueorno = true;
                }
            }
        });
        return trueorno;
    }

    function makedialoguetext(text:String, second:String) {
        dialoguetext = new FlxTypeText(dialoguebox.x + 245, dialoguebox.y + 60, 0, text, 22);
        dialoguetext.scrollFactor.set(0, 0);
        dialoguetext.setFormat(Paths.font("mainmenu.ttf"), 22, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        add(dialoguetext);
        dialoguetext.delay = 0.01;
        dialoguetext.setTypingVariation(1, true);
        dialoguetext.sounds = [FlxG.sound.play(Paths.sound('text')), FlxG.sound.play(Paths.sound('text'))];
        if(second != '') {
            secondtext = true;
            secondcache = second;
        }
        dialoguetext.completeCallback = dialoguedone;
        dialoguetext.start();
    }
}
