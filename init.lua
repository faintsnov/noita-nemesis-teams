
ModLuaFileAppend("mods/noita-nemesis/files/scripts/buy_ability.lua", "mods/noita-nemesis-teams/append/buy_ability.lua")

ModLuaFileAppend("mods/noita-nemesis/files/events.lua", "mods/noita-nemesis-teams/append/events.lua")

ModTextFileSetContent("mods/noita-nemesis/files/death.lua", "-- noop\n")
ModTextFileSetContent("mods/nemesis-fix/files/death.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/death.lua", "mods/noita-nemesis-teams/append/death.lua")

ModTextFileSetContent("mods/noita-nemesis/files/append/ui.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-together/files/scripts/ui.lua", "mods/noita-nemesis-teams/append/ui.lua")

local function spawnTeamJoin( team_name, x, y )
    print("spawnTeamJoin " .. team_name)
    local join_eid = EntityLoad("mods/noita-nemesis-teams/entities/join.xml", x, y)
    EntityAddComponent2(join_eid, "VariableStorageComponent", {
        name = "nemesis_team",
        value_string = team_name
    })
    local badge = EntityGetFirstComponent( join_eid, "SpriteComponent", "badge" )
    ComponentSetValue2(badge, "image_file", "data/ui_gfx/animal_icons/" .. team_name .. ".png")
    print("spawnTeamJoin " .. team_name)
end

function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
    dofile("mods/noita-nemesis-teams/files/remove_team_flags.lua")

    spawnTeamJoin("deer" , 420, -120)
    spawnTeamJoin("duck" , 460, -120)
    spawnTeamJoin("sheep" , 500, -120)
    spawnTeamJoin("fungus" , 540, -120)
    
end

