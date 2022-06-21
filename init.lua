
local _NOITA_NEMESIS_TEAMS_VERSION = "0.30.0"

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

-- disable player ghost
ModLuaFileAppend("data/scripts/biome_scripts.lua", "mods/noita-nemesis-teams/append/biome_scripts.lua")

-- Check if the player stays in one place for more than x minutes
local function addAkka(player)
    local hasAkka = false
    local lua_components = EntityGetComponent(player, "LuaComponent")
    print("-------- debug 1")
    if (lua_components ~= nil) then
        for _, component in ipairs(lua_components) do
            local script_source_file = ComponentGetValue2(component, "script_source_file")
            print("-------- debug 2:"..script_source_file)
            if (script_source_file ~= nil and script_source_file == "mods/noita-nemesis-teams/files/akkaWisper.lua") then
                hasAkka = true
            end
        end
    end
    print("-------- debug 3:"..tostring(hasAkka))
    if (not hasAkka) then
        GlobalsSetValue("NOITA_NEMESIS_AKKA_POINT", 0)
        GlobalsSetValue("NOITA_NEMESIS_AKKA_STAGE", 1)
        EntityAddComponent( player, "LuaComponent", {
            execute_every_n_frame = "60",
            script_source_file = "mods/noita-nemesis-teams/files/akkaWisper.lua"
        })
    end
end 

function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
    GlobalsSetValue("NOITA_NEMESIS_TEAMS_VERSION", _NOITA_NEMESIS_TEAMS_VERSION)

    addAkka(player_entity)
end

--try to get client userId
--TOBE
function OnWorldPreUpdate()
    dofile("mods/noita-nemesis-teams/files/whoAmI.lua")
end
