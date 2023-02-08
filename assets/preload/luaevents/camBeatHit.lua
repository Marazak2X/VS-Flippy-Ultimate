function onEvent(name, value1, value2)
    if name == 'camBeatHit' then
        function onBeatHit()
            if curBeat % value1 == 0 then
                triggerEvent('Add Camera Zoom', '0.015', '0.03')
            end
        end
    end
end