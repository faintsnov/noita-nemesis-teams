

local _StartRun = StartRun
function StartRun()
    if (NT.StartRunCountDown == nil) then
        NT.StartRunCountDown = 600
    end
    if (NT.StartRunCountDown <= 0) then
        _StartRun()
    else
        if (NT.StartRunCountDown % 120 == 0) then
            local countdown = NT.StartRunCountDown / 120
            GamePrint("*** " .. tostring(countdown) .. " ***")
        end
        NT.StartRunCountDown = NT.StartRunCountDown - 1
    end
end

