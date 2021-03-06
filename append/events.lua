
customEvents["NemesisEnemy"] = function(data)
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    local team = data.team
    PlayerList[tostring(userId)].team = team
    local nemesisPoint = data.nemesisPoint
    PlayerList[tostring(userId)].nemesisPoint = nemesisPoint
    local cx, cy = GameGetCameraPos()
    local target_x = cx - 100
    local target_y = cy - 120
    
    if (team ~= nil) then 
        GamePrint("(" .. team .. ") " .. playername .. " sends an enemy")
        --stats
        local team_stats = json.decode(NEMESIS.team_stats or "[]")
        team_stats = team_stats or {}
        team_stats[team] = team_stats[team] or {}
        team_stats[team].enemies_sent = (team_stats[team].enemies_sent or 0) + 1
        NEMESIS.team_stats = json.encode(team_stats)
    else
        GamePrint(playername .. " sends an enemy")
    end
    
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
end

customEvents["NemesisAbility"] = function(data)
    if(ABILITIES[data.ability]==nil) then
        print("unknown ability")
        return
    end
    local used = GlobalsGetValue("NEMESIS_USED_ABILITY_"..tostring(data.x).."_"..tostring(data.y), "0")
    if (used == "1") then return end
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    local team = data.team
    PlayerList[tostring(userId)].team = team
    local nemesisPoint = data.nemesisPoint
    PlayerList[tostring(userId)].nemesisPoint = nemesisPoint
    if (team ~= nil) then 
        GamePrint("(" .. team .. ") " .. playername .. " used " .. data.ability)
        --stats
        local team_stats = json.decode(NEMESIS.team_stats or "[]")
        team_stats = team_stats or {}
        team_stats[team] = team_stats[team] or {}
        team_stats[team].abilities_gained = (team_stats[team].abilities_gained or 0) + 1
        NEMESIS.team_stats = json.encode(team_stats)
    else
        GamePrint(playername .. " used " .. data.ability)
    end
    GlobalsSetValue("NEMESIS_USED_ABILITY_"..tostring(data.x).."_"..tostring(data.y), "1")

    PlayerList[tostring(userId)].emote = data.ability
    PlayerList[tostring(userId)].emoteIsNemesisAblility = true
    PlayerList[tostring(userId)].emoteStartFrame = GameGetFrameNum()
    PlayerList[tostring(userId)].emoteSprite = ABILITIES[data.ability].sprite
    if (NEMESIS.nt_nemesis_team ~= nil and team == NEMESIS.nt_nemesis_team) then 
        --GamePrint("avoid ability, we are same team!")
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

    if (team=="leave") then
        PlayerList[tostring(userId)].team = nil
        GamePrint(playername .. " left the team")
    else
        PlayerList[tostring(userId)].team = team
        GamePrint(playername .. " joins " .. team .. " team")
    end
end

customEvents["NemesisTeamSendEmote"] = function(data)
    local userId = data.userId
    local team = data.team
    if (NEMESIS.nt_nemesis_team ~= nil and team == NEMESIS.nt_nemesis_team) then 
        PlayerList[tostring(userId)].team = team
        PlayerList[tostring(userId)].emote = data.emote
        PlayerList[tostring(userId)].emoteIsNemesisAblility = false
        PlayerList[tostring(userId)].emoteStartFrame = GameGetFrameNum()
    end
end

customEvents["WhoAmI"] = function(data)
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    local whoamiToken = data.whoamiToken
    if (whoamiToken == nil) then
        return
    end
    --print(" --------------  WhoAmI recieved. token:"..whoamiToken)
    local queue = json.decode(NT.wsQueue)
    table.insert(queue, {event="CustomModEvent", payload={name="WhoYouAre", whoamiUserId=userId, whoamiToken=whoamiToken, whoamiName=playername}})
    NT.wsQueue = json.encode(queue)
end

customEvents["WhoYouAre"] = function(data)
    if (NEMESIS.whoamiToken ~= nil) then
        local whoamiToken = data.whoamiToken
        local whoamiUserId = data.whoamiUserId
        local whoamiName = data.whoamiName
        local playerlist = json.decode(NEMESIS.PlayerList)
        for k, _ in pairs(PlayerList) do
            if (k == whoamiUserId) then
                return --if whoamiUserId found in PlayerList.
            end
        end
        if (NEMESIS.whoamiToken == whoamiToken) then
            --print(" -------------- debug whoAmI recieved. token:"..NEMESIS.whoamiToken)
            NEMESIS.whoamiUserId = whoamiUserId
            NEMESIS.whoamiName = whoamiName
        end
    end
end

customEvents["NemesisTeamRequest"] = function(data)
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    if (NEMESIS.whoamiUserId ~= nil) then
        local playerTeams = data.playerTeams
        if (playerTeams~=nil) then
            for _, playerTeam in pairs(playerTeams) do
                if (playerTeam~=nil and playerTeam.id~=nil) then
                    if (playerTeam.id == NEMESIS.whoamiUserId) then
                        local team = playerTeam.team
                        dofile("mods/noita-nemesis-teams/files/joinAction.lua")
                        join( team )
                        GamePrint("*** "..playername.." force you to join "..team.." team!! ***")
                    end
                end
            end
        end
    end
end

customEvents["NemesisTeamWin"] = function(data)
    if (NEMESIS.nt_nemesis_team_run_end == "1") then 
        return 
    end
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    if (data.team ~= nil) then
        msg = "Team " .. data.team .. " won."
        NEMESIS.nt_nemesis_team_run_end = "1"
        NEMESIS.winner_team = data.team
    else
        msg = PlayerList[data.userId].name .. " has won."
    end
    GamePrintImportant(msg, "")
    GlobalsSetValue("NOITA_NEMESIS_TEAMS_SHOW_GAME_STATS", "1")
end

customEvents["NemesisTeamSendGold"] = function(data)
    if (NEMESIS.whoamiUserId == nil) then return end
    local userId = data.userId
    local playerlist = json.decode(NEMESIS.PlayerList)
    local playername = playerlist[tostring(data.userId)]
    local team = data.team
    PlayerList[tostring(userId)].team = team
    local destination = data.destination
    local amount = data.amount
    
    local myUserId = NEMESIS.whoamiUserId
    local myName = NEMESIS.whoamiName
    local myTeam = NEMESIS.nt_nemesis_team

    if (team ~= nil and myTeam ~= nil and myUserId == destination and team == myTeam) then
        GamePrint("(" .. team .. ") " .. playername .. " sends " .. amount .. " gold to you")

        local wallet, gold = nil, 0
        wallet, gold = PlayerWalletInfo()
        ComponentSetValue2(wallet, "money", gold + amount)

        --stats
        local team_stats = json.decode(NEMESIS.team_stats or "[]")
        team_stats = team_stats or {}
        team_stats[team] = team_stats[team] or {}
        team_stats[team].gold_sent = (team_stats[team].gold_sent or 0) + 1
        NEMESIS.team_stats = json.encode(team_stats)
    else
        local destPlayer = playerlist[tostring(destination)]
        if (team ~= nil and destPlayer~=nil) then
            GamePrint("(" .. team .. ") " .. playername .. " sends " .. amount .. " gold to "..destPlayer)
        end
    end
    
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
                NEMESIS.winner_team = NEMESIS.nt_nemesis_team
                --send a message to host can know which team win if died
                local queue = json.decode(NT.wsQueue)
                table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamWin", team=NEMESIS.nt_nemesis_team}})
                NT.wsQueue = json.encode(queue)
            else
                msg = "You won."
                --send a message to host can know which team win if died
                local queue = json.decode(NT.wsQueue)
                table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamWin"}})
                NT.wsQueue = json.encode(queue)
            end
            GamePrintImportant(msg, "")
            GlobalsSetValue("NOITA_NEMESIS_TEAMS_SHOW_GAME_STATS", "1")
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

local _timed_ability = timed_ability
function timed_ability(name, frames, entity_file, reduction)
    local player = get_player()
    local rrate = reduction or 0.5
    if (player == nil) then return end
    local thing = EntityGetWithName("nemesis_" .. name)
    if (thing ~= 0) then
        local lifetime = EntityGetFirstComponentIncludingDisabled(thing, "LifetimeComponent")
        local creation_frame = ComponentGetValue2(lifetime, "creation_frame")
        local kill_frame = ComponentGetValue2(lifetime, "kill_frame")
        local framesleft = kill_frame-creation_frame
        ComponentSetValue2(lifetime, "kill_frame", creation_frame + math.floor(framesleft*rrate) + frames )
        return
    end
    local x, y = get_player_pos()
    local efile = entity_file or "mods/noita-nemesis/files/effects/".. name .."/effect.xml"
    local thingy = EntityLoad(efile, x, y)
    local effectcomp = EntityGetFirstComponent(thingy, "GameEffectComponent")
    if (effectcomp) then
        ComponentSetValue2(effectcomp, "frames", frames)
    end
    EntityAddComponent2(thingy, "LifetimeComponent", {
        lifetime=frames
    })
    EntityAddChild(player, thingy)
end

ABILITIES["trip"] = {
    id="trip", name="Trip", weigths={0.80, 0.80, 0.80, 0.80, 0.80, 0.80},
    fn=function ()
        local player = get_player()
        local fungi = CellFactory_GetType("fungi")
        GlobalsSetValue("fungal_shift_last_frame", "-1000000")
        EntityIngestMaterial( player, fungi, 600 )
    end
}

ABILITIES["sanic"] = {
    id="sanic", name="Sanic", weigths={0.20, 0.10, 0.50, 0.50, 0.50, 0.50},
    fn=function()
        timed_ability("sanic", 60*45)
    end
}

ABILITIES["fizzled"] = {
    id="fizzled", name="Fizzled", weigths={0.80, 0.80, 0.80, 0.80, 0.80, 0.80},
    fn=function()
        timed_ability("fizzled", 60*30)
        timed_ability("npgain", 60*30, "mods/noita-nemesis-teams/effects/npgain.xml")
    end
}

local function spawn_bit_player_perks( x, y, prob )
	local perks_to_spawn = {}
	
	for i,perk_data in ipairs(perk_list) do
		local perk_id = perk_data.id
		
		if ( perk_data.one_off_effect == nil ) or ( perk_data.one_off_effect == false ) then
			local flag_name = get_perk_picked_flag_name( perk_id )
			local pickup_count = tonumber( GlobalsGetValue( flag_name .. "_PICKUP_COUNT", "0" ) )
			
			if GameHasFlagRun( flag_name ) or ( pickup_count > 0 ) then
				table.insert( perks_to_spawn, { perk_id, pickup_count } )
			end
		end
	end
	
	local full_arc = math.pi
	local count = 8
	local row_size_inc = 4
	local currcount = 0
	
	local angle = 0
	local inc = ( full_arc ) / count
	
	local initlen = 24
	local length = initlen
	local len_inc = 16
	
    SetRandomSeed(88888+x,99999+y)
    local rnd = random_create(x, y)

    for i,v in ipairs( perks_to_spawn ) do
		local pid = v[1]
		local pcount = v[2]
		
		if ( pcount > 0 ) then
			for j=1,pcount do
				local px = x + math.cos( angle ) * length
				local py = y - math.sin( angle ) * length

                local gacha = random_next( rnd, 0.0, 10.0 )
                if (gacha > prob) then
                    perk_spawn_with_name( px, py, pid, true )
                end
				
				angle = angle + inc
				currcount = currcount + 1
				
				if ( currcount > count ) then
					currcount = 0
					angle = 0
					count = count + row_size_inc
					length = length + len_inc
					
					inc = ( full_arc ) / count
				end
			end
		end
	end
end

ABILITIES["removerandomPerk"] = {
    id="removerandomPerk", name="Remove RandomPerk", weigths={0, 0, 0, 0.0, 0.01, 0.80},
    fn=function()
        dofile( "data/scripts/perks/perk.lua" )
        local player_entity = get_player()
        local pos_x, pos_y = EntityGetTransform( player_entity )
        EntityLoad( "mods/noita-nemesis-teams/entities/remove_ground_60.xml", pos_x, pos_y )
        EntityLoad( "data/entities/particles/supernova.xml", pos_x, pos_y )

        -- return some perk your have
        local perks_to_spawn = {}
        for i,perk_data in ipairs(perk_list) do
            local perk_id = perk_data.id
            if ( perk_data.one_off_effect == nil ) or ( perk_data.one_off_effect == false ) then
                local flag_name = get_perk_picked_flag_name( perk_id )
                local pickup_count = tonumber( GlobalsGetValue( flag_name .. "_PICKUP_COUNT", "0" ) )
                if GameHasFlagRun( flag_name ) or ( pickup_count > 0 ) then
                    table.insert( perks_to_spawn, { perk_id, pickup_count } )
                end
            end
        end

        spawn_bit_player_perks(pos_x, pos_y, 3.3)
        remove_all_perks()
    end
}
