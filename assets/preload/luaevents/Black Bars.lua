
function onCreatePost()
	makeLuaSprite('UpperBar', 'empty', -110, -350)
	makeGraphic('UpperBar', 1500, 350, '000000')
	setObjectCamera('UpperBar', 'HUD')
	addLuaSprite('UpperBar', false)

	makeLuaSprite('LowerBar', 'empty', -110, 720)
	makeGraphic('LowerBar', 1500, 350, '000000')
	setObjectCamera('LowerBar', 'HUD')
	addLuaSprite('LowerBar', false)

	UpperBar = getProperty('UpperBar.y')
	LowerBar = getProperty('LowerBar.y')
end


function onEvent(name, value1, value2)
	if name == 'Black Bars' then
	
	Speed = tonumber(value1)
	Distance = tonumber(value2)
           if value2 == '50' or value2 == '60' or value2 == '70' or value2 == '80' or value2 == '90' or value2 == '100' or value2 == '110' or value2 == '120' then
              doTweenAlpha('cam1', 'healthBarBG', 0, 1)
              doTweenAlpha('cam2', 'healthBarBG2', 0, 1)
              doTweenAlpha('cam3', 'healthBar', 0, 1)
              doTweenAlpha('cam4', 'scoreTxt', 0, 1)
              doTweenAlpha('cam5', 'iconP1', 0, 1)
              doTweenAlpha('cam6', 'iconP2', 0, 1)
              doTweenAlpha('cam7', 'timeBar', 0, 1)
              doTweenAlpha('cam8', 'timeBarBG', 0, 1)
              doTweenAlpha('cam9', 'timeTxt', 0, 1)
           end	
           if value2 == '0' or value2 == '10' or value2 == '20' or value2 == '30' or value2 == '40' then
              doTweenAlpha('cam1', 'healthBarBG', 1, 1)
              doTweenAlpha('cam2', 'healthBarBG2', 1, 1)
              doTweenAlpha('cam3', 'healthBar', 1, 1)
              doTweenAlpha('cam4', 'scoreTxt', 1, 1)
              doTweenAlpha('cam5', 'iconP1', 1, 1)
              doTweenAlpha('cam6', 'iconP2', 1, 1)
              doTweenAlpha('cam7', 'timeBar', 1, 1)
              doTweenAlpha('cam8', 'timeBarBG', 1, 1)
              doTweenAlpha('cam9', 'timeTxt', 1, 1)
           end
	end
	if Speed and Distance > 0 then	
	doTweenY('Cinematics1', 'UpperBar', UpperBar + Distance, Speed, 'QuadOut')
	doTweenY('Cinematics2', 'LowerBar', LowerBar - Distance, Speed, 'QuadOut')
	end
	if downscroll and Speed and Distance > 0 then	
	doTweenY('Cinematics1', 'UpperBar', UpperBar + Distance, Speed, 'QuadOut')
	doTweenY('Cinematics2', 'LowerBar', LowerBar - Distance, Speed, 'QuadOut')
	end
	if Distance <= 0 then		
	doTweenY('Cinematics1', 'UpperBar', UpperBar, Speed, 'QuadIn')
	doTweenY('Cinematics2', 'LowerBar', LowerBar, Speed, 'QuadIn')		
	end	
end

