
ModLuaFileAppend("mods/noita-nemesis/files/scripts/buy_ability.lua", "mods/noita-nemesis-teams/append/buy_ability.lua")

ModLuaFileAppend("mods/noita-nemesis/files/events.lua", "mods/noita-nemesis-teams/append/events.lua")

--ModLuaFileAppend("mods/noita-together/files/scripts/utils.lua", "mods/noita-nemesis-teams/append/utils.lua")

ModTextFileSetContent("mods/noita-nemesis/files/death.lua", "-- noop\n")
ModTextFileSetContent("mods/nemesis-fix/files/death.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/death.lua", "mods/noita-nemesis-teams/append/death.lua")

ModTextFileSetContent("mods/noita-nemesis/files/append/ui.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-together/files/scripts/ui.lua", "mods/noita-nemesis-teams/append/ui.lua")

function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
    --dofile("mods/noita-nemesis-teams/files/remove_team_flags.lua")

    --dofile("mods/noita-nemesis-teams/files/joinSpawn.lua")
end

