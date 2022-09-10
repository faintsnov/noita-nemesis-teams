local _SpawnPlayerGhost = SpawnPlayerGhost
function SpawnPlayerGhost(player, userId)
    local ghost = EntityLoad("mods/noita-together/files/entities/ntplayer.xml", 0, 0)
    local player_display_name = player.name
    if (ModSettingGet("noita-nemesis-teams.NOITA_NEMESIS_TEAMS_ALLOW_PLAYER_DISPLAY_NAME")) then
        print("-------------debug2:"..tostring(player.displayName)..":")
        if (player.displayName ~= nil) then
            player_display_name = player.displayName
        end
    end

    AppendName(ghost, player_display_name)
    local vars = EntityGetComponent(ghost, "VariableStorageComponent")
    for _, var in pairs(vars) do
        local name = ComponentGetValue2(var, "name")
        if (name == "userId") then
            ComponentSetValue2(var, "value_string", userId)
        end
        if (name == "inven") then
            ComponentSetValue2(var, "value_string", json.encode(PlayerList[userId].inven))
        end
    end
    if (player.x ~= nil and player.y ~= nil) then
        EntitySetTransform(ghost, player.x, player.y)
    end
end
