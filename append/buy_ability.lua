
local _send_ability = send_ability
send_ability = function (ability,x,y)
    if (sendToSelf) then
      --GamePrint(ability)
      -- doesn't work with coroutines
      local fn = ABILITIES[ability].fn
      if (fn ~= nil) then fn() end
    else
      local queue = json.decode(NT.wsQueue)
      if (NEMESIS.nt_nemesis_team ~= nil) then
        local team = NEMESIS.nt_nemesis_team
        local nemesisPoint = NEMESIS.points
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisAbility", ability=ability, x=x, y=y, team=team, nemesisPoint=nemesisPoint}})
        --stats
        local team_stats = json.decode(NEMESIS.team_stats or "[]")
        team_stats = team_stats or {}
        team_stats[team] = team_stats[team] or {}
        team_stats[team].abilities_gained = (team_stats[team].abilities_gained or 0) + 1
        team_stats[team].abilities_gained_mina = (team_stats[team].abilities_gained_mina or 0) + 1
        NEMESIS.team_stats = json.encode(team_stats)
      else
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisAbility", ability=ability, x=x, y=y}})
      end
      NEMESIS.ability_used_count = (NEMESIS.ability_used_count or 0) + 1
      NT.wsQueue = json.encode(queue)
    end
end

interacting = function ( entity_who_interacted, entity_interacted, interactable_name )
  local x, y = EntityGetTransform(entity_interacted)
  local ability_comp = get_variable_storage_component(entity_interacted, "nemesis_ability")
  local price_comp = get_variable_storage_component(entity_interacted, "ability_price")

  local ability = ComponentGetValue2(ability_comp, "value_string")
  local price = ComponentGetValue2(price_comp, "value_int")

  local points = NEMESIS.points
  if (points >= price) then
      NEMESIS.points = NEMESIS.points - price
      send_ability(ability, math.floor(x), math.floor(y))

      if (SessionNumbersGetValue("NEW_GAME_PLUS_COUNT") ~= "0") then
        -- when ng+
        EntityKill(entity_interacted)
        local abs = EntityGetInRadiusWithTag(x, y, 60, "NEMESIS_ABILITY")
        for _, eid in ipairs(abs) do
            local tx, ty = EntityGetTransform(eid)
            EntityLoad("data/entities/particles/poof_pink.xml", tx, ty)
            EntityKill(eid)
        end
      else
        EntityKill(entity_interacted)
        local abs = EntityGetInRadiusWithTag(x, y - 25, 1000, "NEMESIS_ABILITY")
        for _, eid in ipairs(abs) do
            local tx, ty = EntityGetTransform(eid)
            EntityLoad("data/entities/particles/poof_pink.xml", tx, ty)
            EntityKill(eid)
        end
      end

  end
end
