
customEvents["NemesisEnemy"] = function(data)
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    local team = data.team
    PlayerList[tostring(userId)].team = team
    local cx, cy = GameGetCameraPos()
    local target_x = cx - 100
    local target_y = cy - 120
    
    if (NEMESIS.nt_nemesis_team ~= nil and team == NEMESIS.nt_nemesis_team) then 
        -- GamePrint("avoid enemy, we are same team!")
        return
    end
    spawn_entity_in_view_random_angle("mods/noita-nemesis/files/entities/enemy_spawner/entity.xml", 96, 269, 20, function(spawner)
        local dx, dy = EntityGetTransform(spawner)
        EntityAddComponent2(spawner, "VariableStorageComponent", {
            name="dest_x",
            value_float=dx
        })
        EntityAddComponent2(spawner, "VariableStorageComponent", {
            name="dest_y",
            value_float=dy
        })
        EntityAddComponent2(spawner, "VariableStorageComponent", {
            name="enemy_file",
            value_string=data.file or ""
        })
        EntitySetTransform(spawner, target_x, target_y)
        local sprite = EntityGetFirstComponent(spawner, "SpriteComponent")
        ComponentSetValue2(sprite, "image_file", data.icon or "")
    end)
    GamePrint("(" .. team .. ") " .. playername .. " sends and enemy")
end

customEvents["NemesisAbility"] = function(data)
    local used = GlobalsGetValue("NEMESIS_USED_ABILITY_"..tostring(data.x).."_"..tostring(data.y), "0")
    if (used == "1") then return end
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    local team = data.team
    PlayerList[tostring(userId)].team = team
    GamePrint("(" .. team .. ") " .. playername .. " used " .. data.ability)
    GlobalsSetValue("NEMESIS_USED_ABILITY_"..tostring(data.x).."_"..tostring(data.y), "1")

    if (NEMESIS.nt_nemesis_team ~= nil and team == NEMESIS.nt_nemesis_team) then 
        GamePrint("avoid ability, we are same team!")
        return
    end
    local fn = ABILITIES[data.ability].fn
    if (fn ~= nil) then fn() end
end

customEvents["NemesisRespawn"] = function(data)
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    
    PlayerList[tostring(userId)].respawned = "1"
    GamePrint(playername .. " respawned")
end

customEvents["NemesisTeamJoin"] = function(data)
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    local team = data.team

    PlayerList[tostring(userId)].team = team
    GamePrint(playername .. " joins " .. team .. " team")
end

wsEvents["PlayerDeath"] = function(data)
    if (data.isWin == true) then
        -- TODO: no winning
        PlayerList[data.userId].curHp = 0
        msg = PlayerList[data.userId].name .. " has won."
        --InGameChatAddMsg({name = "[System]", message = msg})
        GamePrintImportant(msg, "")
    else
        PlayerList[data.userId].curHp = 0

        local aliveCount = 0

        for k, v in pairs(PlayerList) do
            if (v.curHp > 0) then
                if (NEMESIS.nt_nemesis_team ~= nil and v.team == NEMESIS.nt_nemesis_team) then 
                else
                    aliveCount = aliveCount + 1
                end
            end
        end

        if (aliveCount == 0 and NEMESIS.nt_nemesis_team_run_end ~= "1") then
            if (NEMESIS.nt_nemesis_team ~= nil) then
                msg = "Team " .. NEMESIS.nt_nemesis_team .. " won."
                NEMESIS.nt_nemesis_team_run_end = "1"
            else
                msg = "You won."
            end
            GamePrintImportant(msg, "")
        else
            local team = PlayerList[data.userId].team
            if (team ~= nil) then
                msg = "(" .. team .. ")" .. PlayerList[data.userId].name .. " has died." 
            else
                msg = PlayerList[data.userId].name .. " has died." 
            end
            
            GamePrintImportant(msg, "")
        end
    end
end
