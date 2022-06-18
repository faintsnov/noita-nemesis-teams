
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-together/files/scripts/utils.lua")

function sendEmote( emote )    
    if (NEMESIS==nil) then return end
    local team = NEMESIS.nt_nemesis_team
    if (team==nil) then return end

    local queue = json.decode(NT.wsQueue)
    table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamSendEmote", team=team, emote=emote}})
    NT.wsQueue = json.encode(queue)

    print("--debug emote:"..emote)
end
