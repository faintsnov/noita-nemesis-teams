
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-nemesis/files/scripts/utils.lua")

local function get_entity_name_from_entity_file(entity_file)
    if ( string.len( entity_file ) > 0 ) then
        local entity_name = ""
        for j=1,string.len(entity_file) do
            local letter = string.sub( entity_file, string.len( entity_file ) - ( j - 1 ), string.len( entity_file ) - ( j - 1 ) )
            if ( letter ~= "/" ) then
                entity_name = letter .. entity_name
            else
                break
            end
        end
        entity_name = string.sub( entity_name, 1, string.len( entity_name ) - 4 )
        return entity_name
    end
end

function death( dmg_type, dmg_msg, entity_thats_responsible, drop_items )
    local player = get_player()
    if (entity_thats_responsible ~= player and EntityGetParent(entity_thats_responsible) ~= player) then
        return
    end
    GlobalsSetValue("NOITA_NEMESIS_LAST_KILL_FRAME_NUM", GameGetFrameNum())
    local entity_id = GetUpdatedEntityID()
	local x, y = EntityGetTransform( entity_id )
    local px, py = get_player_pos()
    local entity_file = EntityGetFilename( entity_id )
    local entity_name = EntityGetName(entity_id)
    local damagecomp = EntityGetFirstComponentIncludingDisabled(entity_id, "DamageModelComponent")
    local max_hp = 0
    local points = 0
    if (damagecomp ~= nil) then
        max_hp = ComponentGetValue2(damagecomp, "max_hp")
        points = math.floor(max_hp*10) --Y scaling TODO ???
    end 
    NEMESIS.points = NEMESIS.points + points

    if (EntityHasTag(entity_id, "NEMESIS_ENEMY")) then
        -- kills more nemsis enemy will give you nemesis ability
        NEMESIS.team_points = (NEMESIS.team_points or 0) + points
        SetRandomSeed(GameGetFrameNum()+x,GameGetFrameNum()+y)
        local rnd = random_create(x, y)
        local gacha = random_next( rnd, 0.0, 10.0 )
        local prob = 1
        if (gacha < prob) then
            local counter_ability_count = tonumber(GlobalsGetValue("NEMESIS_TEAMS_COUNTER_ABILITY_COUNT", "0"))
            local ability_recieved_count = tonumber(GlobalsGetValue("NEMESIS_TEAMS_ABILITY_RECIEVED_COUNT", "0"))
            local team_point_check = (NEMESIS.team_points - (36*math.pow(counter_ability_count+1, 2.4)) > 0)
            if (ability_recieved_count - counter_ability_count*4 > 0 and team_point_check) then
                print("DEBUG:Spawn Ability")
                local tier = math.max(1, math.min(6, math.floor(ability_recieved_count / 5)))
                dofile_once("mods/noita-nemesis-teams/files/randomAbilityDrop.lua")
                randomAbilitySpawnAt(x, y-12, rnd, tier)
                GlobalsSetValue("NEMESIS_TEAMS_COUNTER_ABILITY_COUNT", tostring(counter_ability_count + 1))
            end
        end
        return
    end
    local playerlist = json.decode(NEMESIS.PlayerList)
    local count = #playerlist
    if (count < 5) then count = 5 end
    if (count > 30) then count = 30 end
    local spawn_chance = 1 - 0.03 * count
	SetRandomSeed( GameGetFrameNum(), entity_id )
    if Random(1, 100) >= spawn_chance * 100 then
        return
    end
    local cx, cy = GameGetCameraPos()
    local icon = string.gsub(entity_name, "$animal_", "")
    if (icon == nil or icon == "") then
        icon = get_entity_name_from_entity_file(entity_file)
    end
    icon = "data/ui_gfx/animal_icons/" .. icon .. ".png"

    -- polyorb's entity_name is $projectile_default, and dosn's got a animal icon
    if (entity_file == "data/entities/projectiles/polyorb.xml") then
        icon = "mods/nemesis-fix/files/polyorb.png"
    end

    local icon_entity = EntityLoad("mods/noita-nemesis/files/entities/kill_icon/entity.xml")
    local sprite = EntityGetFirstComponent(icon_entity, "SpriteComponent")
    ComponentSetValue2(sprite, "image_file", icon)
    EntitySetTransform(icon_entity, x, y)
    local queue = json.decode(NT.wsQueue)
    if (NEMESIS.nt_nemesis_team ~= nil) then
        local team = NEMESIS.nt_nemesis_team
        local nemesisPoint = NEMESIS.points
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisEnemy", icon=icon, file=entity_file, team=team, nemesisPoint=nemesisPoint}})
        --stats
        local team_stats = json.decode(NEMESIS.team_stats or "[]")
        team_stats = team_stats or {}
        team_stats[team] = team_stats[team] or {}
        team_stats[team].enemies_sent = (team_stats[team].enemies_sent or 0) + 1
        team_stats[team].enemies_sent_mina = (team_stats[team].enemies_sent_mina or 0) + 1
        NEMESIS.team_stats = json.encode(team_stats)
    else
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisEnemy", icon=icon, file=entity_file}})
    end
    NT.wsQueue = json.encode(queue)

end