
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-together/files/scripts/utils.lua")

function sendEmote( emote )    
    if (NEMESIS==nil) then return end
    local team = NEMESIS.nt_nemesis_team
    if (team==nil) then return end

    local currentFrameNum = GameGetFrameNum()
    local lastFrameNum = tonumber(GlobalsGetValue("NOITA_NEMESIS_LAST_SEND_EMOTE_FRAME_NUM")) or 0
    local interval = 60*2  --2 secound
    if (currentFrameNum - lastFrameNum < interval) then
        GamePrint("Wait a moment.")
        return
    end

    local queue = json.decode(NT.wsQueue)
    table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamSendEmote", team=team, emote=emote}})
    NT.wsQueue = json.encode(queue)

    GlobalsSetValue("NOITA_NEMESIS_LAST_SEND_EMOTE_FRAME_NUM", GameGetFrameNum())
    GamePrint("Send a emote.")
end
