local shaderName = "invert"
function onBeatHit()
    if curBeat == 16 then
        shaderCoordFix()

        makeLuaSprite("invert")
        makeGraphic("shaderImage", screenWidth, screenHeight)

        setSpriteShader("shaderImage", "invert")


        runHaxeCode([[
             var shaderName = "]] .. shaderName .. [[";
        
             game.initLuaShader(shaderName);
        
             var shader0 = game.createRuntimeShader(shaderName);
             game.camGame.setFilters([new ShaderFilter(shader0)]);
             game.getLuaObject("invert").shader = shader0;
             //game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("invert").shader)]);
             return;
        ]])
    end
end

function shaderCoordFix()
    runHaxeCode([[
        resetCamCache = function(?spr) {
            if (spr == null || spr.filters == null) return;
            spr.__cacheBitmap = null;
            spr.__cacheBitmapData = null;
        }
        
        fixShaderCoordFix = function(?_) {
            resetCamCache(game.camGame.flashSprite);
            //resetCamCache(game.camHUD.flashSprite);
            resetCamCache(game.camOther.flashSprite);
        }
    
        FlxG.signals.gameResized.add(fixShaderCoordFix);
        fixShaderCoordFix();
        return;
    ]])
    
    local temp = onDestroy
    function onDestroy()
        runHaxeCode([[
            FlxG.signals.gameResized.remove(fixShaderCoordFix);
            return;
        ]])
        if (temp) then temp() end
    end
end