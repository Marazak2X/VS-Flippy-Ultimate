function onEvent(name)
   if mechanics then
	if name == "Bomb" then
		--setting
		removeLuaSprite('bomb',true);
		cancelTimer('bomb');
		playSound('beep',1,'beep');
		makeAnimatedLuaSprite('bomb','bomb',getRandomInt(50,1000),getRandomInt(50,300));
		addLuaSprite('bomb',true);
		setObjectCamera('bomb','hud');
		addAnimationByPrefix('bomb','appear','bomb anim',24,false);
		objectPlayAnimation('bomb','bomb',false);
		setObjectOrder('bomb',2);

		--actually use the bomb
		runTimer('bomb',2);
			function onTimerCompleted(name)
				if name == 'bomb' then
					setProperty('health', getProperty('health') - 0.8);
					removeLuaSprite('bomb',true);
					cameraFlash('hud','FF6600',1,true);
					playSound('boom',1,'boom');
				end
			end
	elseif name == "Burn" then
		makeAnimatedLuaSprite('bomburn','burn',getRandomInt(50,1000),-415);
		setObjectCamera('bomburn','hud');
		addAnimationByPrefix('bomburn','fall','burnfall',24,false);
		setObjectOrder('bomburn',3);
		addLuaSprite('bomburn',true);
		objectPlayAnimation('bomburn','fall',false);
		scaleObject('bomburn',0.5,0.5);
		playSound('fall',1,'fall');
		runTimer('fallSpace', 1)
		runTimer('fall',1);
			function onTimerCompleted(name)
				if name == 'fall' then
					playSound('boom',1,'boom');
					cameraFlash('hud','FF0000',2,true);
					removeLuaSprite('bomburn',true);
					setProperty('healthDrain', getProperty('healthDrain') + 0.004);
				end
				if name == 'fallSpace' then
					playSound('boom',1,'boom');
					cameraFlash('hud','FF0000',2,true);
					removeLuaSprite('bomburn',true);
				end
			end
		end

	if name == "boomnodisarm" then
		--setting
		removeLuaSprite('bomb1',true);
		cancelTimer('bomb1');
		playSound('beep',1,'beep');
		makeAnimatedLuaSprite('bomb1','bomb',getRandomInt(50,1000),getRandomInt(50,300));
		addLuaSprite('bomb1',true);
		setObjectCamera('bomb1','hud');
		addAnimationByPrefix('bomb1','appear1','bomb anim',24,false);
		objectPlayAnimation('bomb1','bomb',false);
		setObjectOrder('bomb1',2);

		--actually use the bomb
		runTimer('bomb1',2);
			function onTimerCompleted(name)
				if name == 'bomb1' then
					setProperty('health', getProperty('health') - 0.2);
					removeLuaSprite('bomb1',true);
					cameraFlash('hud','FF6600',1,true);
					playSound('boom',1,'boom');
				end
			end
	elseif name == "burnnodisarm" then
		makeAnimatedLuaSprite('bomburn1','burn',getRandomInt(50,1000),-415);
		setObjectCamera('bomburn1','hud');
		addAnimationByPrefix('bomburn1','fall','burnfall',24,false);
		setObjectOrder('bomburn1',3);
		addLuaSprite('bomburn1',true);
		objectPlayAnimation('bomburn1','fall',false);
		scaleObject('bomburn1',0.5,0.5);
		playSound('fall',1,'fall');
		runTimer('fall1',1);
			function onTimerCompleted(name)
				if name == 'fall1' then
					playSound('boom',1,'boom');
					cameraFlash('hud','FF0000',2,true);
					removeLuaSprite('bomburn1',true);
					setProperty('healthDrain', getProperty('healthDrain') + 0.0011);
				end
			end
		end
	end
end

function onCreate()
       if mechanics then
           setTextString('botplayTxt', 'YOU CHEATER OR NOOB!!')
           setTextColor('botplayTxt', 'FF0000')
       end
end

function onUpdate()
    if mechanics then
	if keyJustPressed('key5') and getProperty('bomb.x') ~= 'bomb.x' then
		removeLuaSprite('bomb',true);
		cancelTimer('bomb');
		stopSound('beep');
		playSound('disarmed',1,'disarmed');
		cameraFlash('hud','FFFFFF',0.2,true);
	end

	if keyJustPressed('key5') and getProperty('bomburn.x') ~= 'bomburn.x' then
		cancelTimer('fall');
	end

	if keyJustPressed('key5') and getProperty('bomb1.x') ~= 'bomb1.x' then
                playSound('cancelMenu', 0.6)
	end

	if keyJustPressed('key5') and getProperty('bomburn1.x') ~= 'bomburn1.x' then
                playSound('cancelMenu', 0.6)
	end

        if botPlay then
          function onStepHit()
           if curStep > 1 then
             setProperty('health', getProperty('health') + 2)
        end
        end
       end
   end
end