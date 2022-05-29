

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

        SetRandomSeed( minute, second )
        local token = ""
        for i = 1, 32 do
            token = token .. string.char(Random(97, 122))
        end
        NEMESIS.whoamiToken = token
    end

    if (NEMESIS.whoamiToken == nil or GameGetFrameNum() % 600 == 0) then
        local queue = json.decode(NT.wsQueue)
        table.insert(queue, {event="CustomModEvent", payload={name="WhoAmI", token=NEMESIS.whoamiToken}})
        print(" -------------- debug whoAmI called. token:"..NEMESIS.whoamiToken)
        NT.wsQueue = json.encode(queue)
    end
    
end

whoAmI()
