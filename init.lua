
-- append TEAM flag to NemesisAbility event.
ModLuaFileAppend("mods/noita-nemesis/files/scripts/buy_ability.lua", "mods/noita-nemesis-teams/append/buy_ability.lua")

-- avoid NemesisEnemy if same team
-- avoid NemesisAbility if same team
-- add respawned flag to player list
-- add NemesisTeamJoin event
-- add WhoAmI and WhoYouAre protocol to get client userId itself
-- add NemesisTeamRequest event to divide team 
-- change PlayerDeath to win when team survive 
ModLuaFileAppend("mods/noita-nemesis/files/events.lua", "mods/noita-nemesis-teams/append/events.lua")

-- append TEAM flag to NemesisEnemy event.
ModTextFileSetContent("mods/noita-nemesis/files/death.lua", "-- noop\n")
ModTextFileSetContent("mods/nemesis-fix/files/death.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-nemesis/files/death.lua", "mods/noita-nemesis-teams/append/death.lua")

-- add UI components for teams.
ModTextFileSetContent("mods/noita-nemesis/files/append/ui.lua", "-- noop\n")
ModLuaFileAppend("mods/noita-together/files/scripts/ui.lua", "mods/noita-nemesis-teams/append/ui.lua")

-- add NG+ Nemesis Abilities
ModLuaFileAppend("mods/noita-nemesis/files/append/disable_mail.lua", "mods/noita-nemesis-teams/append/ng_mail.lua")


--function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
--end

--try to get client userId
--TOBE
function OnWorldPreUpdate()
    dofile("mods/noita-nemesis-teams/files/whoAmI.lua")
end
