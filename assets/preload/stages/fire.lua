function onCreatePost()
        setProperty('timeTxt.visible', false)
        setProperty('timeBar.visible', false)
        setProperty('timeBarBG.visible', false)
end

function onCreate()
	precacheImage('bomb')
	precacheImage('burn')

	makeLuaSprite('theblack', 'blackstuff', 0, 0);
	setObjectCamera('theblack', 'hud');
	
	addLuaSprite('theblack', true);
	
	setProperty('theblack.alpha', 0);
	setObjectOrder('theblack',1);
end 

function onEvent(name)
	if name == 'Black Stuff' then
		setProperty('theblack.alpha', 80);
		cameraFlash('hud','000000',1,true);
		setProperty("defaultCamZoom",1)
	elseif name == 'Remove Black' then
		setProperty('theblack.alpha', 0);
		cameraFlash('hud','000000',1,true);
		setProperty("defaultCamZoom",0.6)
	end
end