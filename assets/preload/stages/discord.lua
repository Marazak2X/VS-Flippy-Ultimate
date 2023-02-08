function onCreate()
        makeLuaSprite('junee', 'junee', 800, -150)
        scaleObject('junee', 2.5, 2.5)
        addLuaSprite('junee', false)

        makeLuaSprite('zayders', 'zayders', 760,500)
        scaleObject('zayders', 2.5, 2.5)
        addLuaSprite('zayders', false)

        makeLuaSprite('mayc', 'mayc', 1300,-150)
        scaleObject('mayc', 2.5, 2.5)
        addLuaSprite('mayc', false)

	makeAnimatedLuaSprite('vc', 'discord', -575, -350);
	luaSpriteAddAnimationByPrefix('vc', 'both', 'discord both', 24, false);
	luaSpriteAddAnimationByPrefix('vc', 'zayders', 'discord zayders', 24, false);
	luaSpriteAddAnimationByPrefix('vc', 'junee', 'discord junee', 24, false);
	luaSpriteAddAnimationByPrefix('vc', 'nobody', 'discord nobody', 24, false);
	setScrollFactor('vc', 1.0, 1.0);
	addLuaSprite('vc', true);

	makeAnimatedLuaSprite('vc-2', 'discord_2', -575, -350);
	luaSpriteAddAnimationByPrefix('vc-2', 'jm', 'discord_2 jm', 24, false);
	luaSpriteAddAnimationByPrefix('vc-2', 'j', 'discord_2 j', 24, false);
	luaSpriteAddAnimationByPrefix('vc-2', 'm', 'discord_2 m', 24, false);
	luaSpriteAddAnimationByPrefix('vc-2', 'zm', 'discord_2 zm', 24, false);
	luaSpriteAddAnimationByPrefix('vc-2', 'z', 'discord_2 z', 24, false);
	luaSpriteAddAnimationByPrefix('vc-2', 'zj', 'discord_2 zj', 24, false);
	luaSpriteAddAnimationByPrefix('vc-2', 'nobody', 'discord_2 noone', 24, false);
	luaSpriteAddAnimationByPrefix('vc-2', 'everyone', 'discord_2 everyone', 24, false);
	setScrollFactor('vc-2', 1.0, 1.0);
	addLuaSprite('vc-2', true);
	setProperty('vc-2.visible', false);

	objectPlayAnimation('vc', 'nobody')
	objectPlayAnimation('vc-2', 'z')

        setProperty('dadGroup.visible', false)
        setProperty('boyfriendGroup.visible', false)
	setProperty('gfGroup.visible', false);
end

function onCreatePost()
	setProperty('scoreTxt.visible', false)
	setProperty("timeTxt.visible", false)
	setProperty("timeBarBG.visible", false)
	setProperty("timeBar.visible", false)
	setProperty("updateTime", false)
	setProperty("healthBar.visible", false)
	setProperty('healthBarBG.visible', false);
	setProperty('iconP1.visible', false);
	setProperty('iconP2.visible', false);
end

local lockcam = true;

function onUpdate(elapsed)

    xx2 = 750;
    yy2 = 340;

    if lockcam == true then
        if mustHitSection == false then
            triggerEvent('Camera Follow Pos',xx2,yy2)
        else
            triggerEvent('Camera Follow Pos',xx2,yy2)
        end
    end
    
end

function onStepHit()
	if curStep == 47 then
		objectPlayAnimation('vc', 'junee')
	end

	if curStep == 113 then
		objectPlayAnimation('vc', 'both')
	end

	if curStep == 129 then
		objectPlayAnimation('vc', 'zayders')
	end

	if curStep == 133 then
		objectPlayAnimation('vc', 'nobody')
	end

	if curStep == 179 then
		objectPlayAnimation('vc', 'junee')
	end

	if curStep == 181 then
		objectPlayAnimation('vc', 'both')
	end

	if curStep == 191 then
		objectPlayAnimation('vc', 'junee')
	end

	if curStep == 197 then
		objectPlayAnimation('vc', 'nobody')
	end

	if curStep == 201 then
		objectPlayAnimation('vc', 'zayders')
	end

	if curStep == 225 then
		objectPlayAnimation('vc', 'both')
	end

	if curStep == 256 then
		objectPlayAnimation('vc', 'nobody')
	end

	if curStep == 907 then
         setProperty('junee.x', 250)
		MayPopIns()
		noteTweenX(defaultPlayerStrumX0, 4, defaultPlayerStrumX0 + 120, 0.25, 'expoOut')
        noteTweenX(defaultPlayerStrumX1, 5, defaultPlayerStrumX1 + 110, 0.25, 'expoOut')
        noteTweenX(defaultPlayerStrumX2, 6, defaultPlayerStrumX2 + 100, 0.25, 'expoOut')
        noteTweenX(defaultPlayerStrumX3, 7, defaultPlayerStrumX3 + 90, 0.25, 'expoOut')
        noteTweenX(defaultOpponentStrumX0, 0, defaultOpponentStrumX0 - 90, 0.25, 'expoOut')
        noteTweenX(defaultOpponentStrumX1, 1, defaultOpponentStrumX1 - 100, 0.25, 'expoOut')
        noteTweenX(defaultOpponentStrumX2, 2, defaultOpponentStrumX2 - 110, 0.25, 'expoOut')
        noteTweenX(defaultOpponentStrumX3, 3, defaultOpponentStrumX3 - 120, 0.25, 'expoOut')
		triggerEvent('3rdstrum',true,'')
	end

	if curStep == 951 then
		objectPlayAnimation('vc-2', 'zj')
	end

	if curStep == 992 then
		objectPlayAnimation('vc-2', 'z')
	end

	if curStep == 1012 then
		objectPlayAnimation('vc-2', 'nobody')
	end

	if curStep == 1020 then
		objectPlayAnimation('vc-2', 'z')
	end

	if curStep == 1031 then
		objectPlayAnimation('vc-2', 'm')
	end

	if curStep == 1088 then
		objectPlayAnimation('vc-2', 'nobody')
	end

	if curStep == 1881 then
		objectPlayAnimation('vc-2', 'm')
	end
	
	if curStep == 1900 then
		objectPlayAnimation('vc-2', 'nobody')
	end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    objectPlayAnimation('vc', 'junee')
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    objectPlayAnimation('vc', 'zayders')
end

function MayPopIns()
	setProperty('vc.visible', false);
	setProperty('vc-2.visible', true);
	--setProperty('gfGroup.visible', true);
	doTweenX('zip', 'dad', 100, 0.25, 'linear');
end