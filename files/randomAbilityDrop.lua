
dofile_once("mods/noita-together/files/ws/events.lua")
dofile_once("data/scripts/lib/utilities.lua")

abilities = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {}
}

for _, value in pairs(ABILITIES) do
    for i, weight in ipairs(value.weigths) do
        table.insert(abilities[i], {
            probability = weight,
            id = value.id,
            name = value.name
        })
    end
end

function randomAbilitySpawnAt(x, y, rnd, tier) 
    if (not GameHasFlagRun("nemesis_abilities")) then return end
    local ability = pick_random_from_table_weighted(rnd, abilities[tier])
    
    local price = 0
    EntityLoad( "data/entities/particles/tinyspark_blue_large.xml", x, y )
    local baseEntity = "mods/noita-nemesis/files/entities/ability/entity.xml"
    -- compatibility to NAP
    if (string.sub (ability.id,1,7)=="nap-al-") then
        baseEntity = "mods/Nemesis-Ability-Plus/files/entities/ability/entity.xml"
    end

    local ability_eid = EntityLoad(baseEntity, x, y)

    local badge = EntityGetFirstComponent( ability_eid, "SpriteComponent", "badge" )
    if (ABILITIES[ability.id].sprite==nil) then
        ComponentSetValue2(badge, "image_file", "mods/noita-nemesis/files/badges/" .. ability.id .. ".png")
    else
        ComponentSetValue2(badge, "image_file", ABILITIES[ability.id].sprite)
    end

    EntityAddComponent2(ability_eid, "VariableStorageComponent", {
        name="nemesis_ability",
        value_string=ability.id
    })
    EntityAddComponent2(ability_eid, "VariableStorageComponent", {
        name="ability_price",
        value_int= price
    })

    local interact = EntityGetFirstComponent(ability_eid, "InteractableComponent")
    ComponentSetValue2(interact, "ui_text", ability.name)
    local uiinfo = EntityGetFirstComponent(ability_eid, "UIInfoComponent")
    ComponentSetValue2(uiinfo, "name", ability.name)

end
