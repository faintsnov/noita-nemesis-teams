
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-nemesis/files/scripts/utils.lua")
dofile_once("data/scripts/lib/utilities.lua")

function interacting( entity_who_interacted, entity_interacted, interactable_name )
    local x, y = EntityGetTransform(entity_interacted)
    local team_comp = get_variable_storage_component(entity_interacted, "nemesis_team")
    local team = ComponentGetValue2(team_comp, "value_string")

    if (team ~= nil) then
        GameAddFlagRun("nt_nemesis_team_" .. team)
        NEMESIS.nt_nemesis_team = team
        GamePrintImportant("Joined the " .. team .. " team ", "Good luck")
        
        local entities = EntityGetInRadiusWithTag(x, y, 1000, "NT_NEMESIS_TEAMS")

        for _, eid in ipairs(entities) do
            local tx, ty = EntityGetTransform(eid)
            EntityLoad("data/entities/particles/poof_pink.xml", tx, ty)
            EntityKill(eid)
        end

        local queue = json.decode(NT.wsQueue)
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamJoin", team=NEMESIS.nt_nemesis_team}})
        NT.wsQueue = json.encode(queue)

    end
end
