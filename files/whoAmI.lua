
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-nemesis/files/scripts/utils.lua")

local function whoAmI() 
    if (NEMESIS.whoamiUserId ~= nil) then
        return
    end

    if (NEMESIS.whoamiToken == nil) then
        local year,month,day,hour,minute,second = GameGetDateAndTimeUTC()
        local sincestarted = GameGetRealWorldTimeSinceStarted()
        SetRandomSeed( sincestarted*100000000, hour*60*60 + minute*60 + second )
        local whoamiToken = ""
        for i = 1, 32 do
            whoamiToken = whoamiToken .. string.char(Random(97, 122))
        end
        NEMESIS.whoamiToken = whoamiToken
    end

    if (GameGetFrameNum() % 600 == 0) then
        local queue = json.decode(NT.wsQueue)
        table.insert(queue, {event="CustomModEvent", payload={name="WhoAmI", whoamiToken=NEMESIS.whoamiToken}})
        -- GamePrint(" -------------- debug whoAmI called. token:"..NEMESIS.whoamiToken)
        NT.wsQueue = json.encode(queue)
    end
    
end

whoAmI()
