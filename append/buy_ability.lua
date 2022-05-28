
local _send_ability = send_ability
function send_ability(ability,x,y)
    if (sendToSelf) then
    --GamePrint(ability)
    -- doesn't work with coroutines
    local fn = ABILITIES[ability].fn
    if (fn ~= nil) then fn() end
    else
      local queue = json.decode(NT.wsQueue)
      if (NEMESIS.nt_nemesis_team ~= nil) then
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisAbility", ability=ability, x=x, y=y, team=NEMESIS.nt_nemesis_team}})
      else
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisAbility", ability=ability, x=x, y=y}})
      end
      NT.wsQueue = json.encode(queue)
    end
end
