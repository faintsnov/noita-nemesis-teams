
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-nemesis/files/scripts/utils.lua")

function join( team )
    local displayName = ModSettingGet("noita-nemesis-teams.NOITA_NEMESIS_TEAMS_PLAYER_DISPLAY_NAME")
    local len = #displayName
    if (displayName ~= nil and len == 0) then
        displayName = nil
    end

    if (team ~= nil) then
        NEMESIS.nt_nemesis_team = team
        GamePrintImportant("Joined the " .. team .. " team ", "Good luck")
        
        local queue = json.decode(NT.wsQueue)
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamJoin", team=NEMESIS.nt_nemesis_team, displayName=displayName}})
        NT.wsQueue = json.encode(queue)
    else
        GamePrint("Leave the " .. NEMESIS.nt_nemesis_team .. " team ")
        NEMESIS.nt_nemesis_team = nil
        local queue = json.decode(NT.wsQueue)
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamJoin", team="leave", displayName=displayName}})
        NT.wsQueue = json.encode(queue)
    end
end
