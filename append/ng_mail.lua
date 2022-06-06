
biomes ={
	[2] = 1,
	[5] = 2,
	[9] = 3,
	[12] = 4,
	[16] = 5,
	[20] = 5,
    [25] = 5 
}

local function reload_abilities(tier)
    abilities[tier]={}
    for _, value in pairs(ABILITIES) do
        table.insert(abilities[tier], {
            probability = value.weigths[tier],
            id = value.id,
            name = value.name
        })
    end
end

local _spawn_spell_eater = spawn_spell_eater
function spawn_spell_eater(x,y)
    local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
    if ngcount ~= "0" then
        -- when ng+
        reload_abilities(6)
        _spawn_spell_eater(x+25,y)
        _spawn_spell_eater(x+1,y)
    else
        _spawn_spell_eater(x,y)
    end
end

local _spawn_spell_spitter = spawn_spell_spitter
function spawn_spell_spitter(x,y)
    local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
    if ngcount ~= "0" then
        -- when ng+
        reload_abilities(6)
        _spawn_spell_spitter(x-25,y)
        _spawn_spell_spitter(x-1,y)
    else
        _spawn_spell_spitter(x,y)
    end
end


local _SpawnNemesisAbility = SpawnNemesisAbility
function SpawnNemesisAbility(x,y, rnd)
    local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
    if (ngcount == "0") then
        _SpawnNemesisAbility(x,y, rnd)
    else
        -- when ng+
        if (not GameHasFlagRun("nemesis_abilities")) then return end
        local level = 25 + math.floor(y/512)
        local tier = 6
        local ability = pick_random_from_table_weighted(rnd, abilities[tier])
        if (ability==nil) then
            return
        end

        for i, v in ipairs(abilities[tier]) do
            if (v.id == ability.id) then
                table.remove(abilities[tier], i)
            end
        end
        local price = 10*math.floor(math.pow(level, 1.5)) + 15
        local ability_eid = EntityLoad("mods/noita-nemesis/files/entities/ability/entity.xml", x, y)
        EntityAddComponent2(ability_eid, "VariableStorageComponent", {
            name="nemesis_ability",
            value_string=ability.id
        })
        EntityAddComponent2(ability_eid, "VariableStorageComponent", {
            name="ability_price",
            value_int= price
        })
    
        local interact = EntityGetFirstComponent(ability_eid, "InteractableComponent")
        ComponentSetValue2(interact, "ui_text", "Press $0 to buy "..ability.name.." ("..price..")")
        local uiinfo = EntityGetFirstComponent(ability_eid, "UIInfoComponent")
        ComponentSetValue2(uiinfo, "name", ability.name)
    
        local badge = EntityGetFirstComponent( ability_eid, "SpriteComponent", "badge" )
        ComponentSetValue2(badge, "image_file", "mods/noita-nemesis/files/badges/" .. ability.id .. ".png")
    end
end