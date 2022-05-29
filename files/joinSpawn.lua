
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-nemesis/files/scripts/utils.lua")

local function spawnTeamJoin( team_name, x, y )
    local join_eid = EntityLoad("mods/noita-nemesis-teams/entities/join.xml", x, y)
    EntityAddComponent2(join_eid, "VariableStorageComponent", {
        name = "nemesis_team",
        value_string = team_name
    })
    local badge = EntityGetFirstComponent( join_eid, "SpriteComponent", "badge" )
    ComponentSetValue2(badge, "image_file", "data/ui_gfx/animal_icons/" .. team_name .. ".png")
end

if (NEMESIS.nt_nemesis_team == nil) then
    spawnTeamJoin("deer" , 420, -120)
    spawnTeamJoin("duck" , 460, -120)
    spawnTeamJoin("sheep" , 500, -120)
    spawnTeamJoin("fungus" , 540, -120)
end
