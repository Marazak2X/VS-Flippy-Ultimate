

function onCreatePost() 
  if mechanics then
    key5 = getProperty('keysText')

    makeLuaSprite('warnBG', 'warningBG', 0, 0)
    screenCenter('warnBG')
    setObjectCamera('warnBG', 'camOther')
    addLuaSprite('warnBG', true)

    makeLuaText('warningText','',1000,screenWidth/2 + -500,screenHeight/2)
    setTextSize('warningText', 30)
    setTextAlignment('warningText', 'center')
    setTextColor('warningText', 'FF0000')
    setObjectCamera('warningText', 'camOther')
    setTextString('warningText', 'Whenever grenades are present, attempt to disarm then by pressing the '..key5..'')
    setTextFont('warningText', 'vcr.ttf')
    addLuaText('warningText', true)

    makeLuaText('warning2Text','',1000,screenWidth/2 + -500,screenHeight/2 + 100)
    setTextSize('warning2Text', 30)
    setTextAlignment('warning2Text', 'center')
    setTextColor('warning2Text', 'FF0000')
    setObjectCamera('warning2Text', 'camOther')
    setTextString('warning2Text', 'Types of grenades present:')
    setTextFont('warning2Text', 'vcr.ttf')
    addLuaText('warning2Text', true)

    makeAnimatedLuaSprite('grenadeWarn', 'NADENOTE_assets', 500, 520)
    addAnimationByPrefix('grenadeWarn', 'idle', 'green', 24, true)
    scaleObject('grenadeWarn', 0.65, 0.65)
    setObjectCamera('grenadeWarn', 'camOther')
    addLuaSprite('grenadeWarn', true)

    makeAnimatedLuaSprite('burnWarn', 'BURNNOTE_assets', 680, 520)
    addAnimationByPrefix('burnWarn', 'idle', 'green', 24, true)
    scaleObject('burnWarn', 0.65, 0.65)
    setObjectCamera('burnWarn', 'camOther')
    addLuaSprite('burnWarn', true)

    makeLuaText('warning3Text','',1000,screenWidth/2 + -500,screenHeight/2 + 280)
    setTextSize('warning3Text', 30)
    setTextAlignment('warning3Text', 'center')
    setTextColor('warning3Text', 'FF0000')
    setObjectCamera('warning3Text', 'camOther')
    setTextString('warning3Text', 'TIP: Not all grenades can be disarmed.')
    setTextFont('warning3Text', 'vcr.ttf')
    addLuaText('warning3Text', true)

    setProperty('warnBG.alpha', 0)
    setProperty('warningText.alpha', 0)
    setProperty('warning2Text.alpha', 0)
    setProperty('warning3Text.alpha', 0)
    setProperty('grenadeWarn.alpha', 0)
    setProperty('burnWarn.alpha', 0)

    doTweenAlpha('w1Tween', 'warnBG', 1, 1.5, 'linear')
    doTweenAlpha('w2Tween', 'warningText', 1, 1.5, 'linear')
    doTweenAlpha('w3Tween', 'warning2Text', 1, 1.5, 'linear')
    doTweenAlpha('w4Tween', 'warning3Text', 1, 1.5, 'linear')
    doTweenAlpha('w5Tween', 'grenadeWarn', 1, 1.5, 'linear')
    doTweenAlpha('w6Tween', 'burnWarn', 1, 1.5, 'linear')
 end
end

function onStepHit()
 if mechanics then
   if curStep == 112 then
    doTweenAlpha('w1Tween', 'warnBG', 0, 1, 'linear')
    doTweenAlpha('w2Tween', 'warningText', 0, 1, 'linear')
    doTweenAlpha('w3Tween', 'warning2Text', 0, 1, 'linear')
    doTweenAlpha('w4Tween', 'warning3Text', 0, 1, 'linear')
    doTweenAlpha('w5Tween', 'grenadeWarn', 0, 1, 'linear')
    doTweenAlpha('w6Tween', 'burnWarn', 0, 1, 'linear')
   end
  end
end