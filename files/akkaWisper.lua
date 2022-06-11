
local function AkkasWisper() 
    local player = EntityGetWithTag("player_unit")[1]
    if (player==nil) then return end
    local alive = false
	local damagemodels = EntityGetComponent( player, "DamageModelComponent" )
	if( damagemodels ~= nil ) then
		for i,damagemodel in ipairs(damagemodels) do
			local hp = tonumber(ComponentGetValue2( damagemodel, "hp" ))
			if (hp ~= nil and hp > 0) then
                alive = true
            end
		end
	end
    if (not alive) then return end

    local currentFrameNum = GameGetFrameNum()
    local tick = math.floor(currentFrameNum/60)%60+1

    local prev_x = tonumber(GlobalsGetValue("NOITA_NEMESIS_TRANSFORM_"..tick.."_X")) or 0
    local prev_y = tonumber(GlobalsGetValue("NOITA_NEMESIS_TRANSFORM_"..tick.."_Y")) or 0
    local x, y = EntityGetTransform(player)
    GlobalsSetValue("NOITA_NEMESIS_TRANSFORM_"..tick.."_X",x)
    GlobalsSetValue("NOITA_NEMESIS_TRANSFORM_"..tick.."_Y",y)
    --print("----- "..tick.." debug  prev_x:"..prev_x..",prev_y:"..prev_y)
    if (prev_x==0 and prev_y==0) then
        return
    end
     
    local lastKillFrameNum = tonumber(GlobalsGetValue("NOITA_NEMESIS_LAST_KILL_FRAME_NUM")) or 0
    --print("----- debug lastKillFrameNum:"..lastKillFrameNum)
    if (lastKillFrameNum==0) then
        return
    end

    local akka = tonumber(GlobalsGetValue("NOITA_NEMESIS_AKKA_POINT")) or 0
    local akka_stage = tonumber(GlobalsGetValue("NOITA_NEMESIS_AKKA_STAGE")) or 1
    
    local diffKillFrameNum = currentFrameNum - lastKillFrameNum
    --print("----- debug diffKillFrameNum:"..diffKillFrameNum)
    if (diffKillFrameNum < 60*60) then
        GlobalsSetValue("NOITA_NEMESIS_AKKA_POINT", math.max(0, akka - 1))
        --print("----- debug skip by killframe")
        return
    end

    local diff_x = math.abs(x-prev_x)
    local diff_y = math.abs(y-prev_y)
    --print("----- debug diff_x:"..diff_x..",diff_y:"..diff_x)
    if (diff_x > 240 or diff_y > 240) then
        GlobalsSetValue("NOITA_NEMESIS_AKKA_POINT", math.max(0, akka - 1))
        --print("----- debug skip by diff distance")
        return
    end
    
    akka = akka + 1
    print("----- debug akka:"..akka..",stage:"..akka_stage)
    if (akka_stage == 1 and akka > 30 ) then
        akka = 0
        GamePrintImportant("A terrible chill runs down your spine", "Akka is comming...")
        GlobalsSetValue("NOITA_NEMESIS_AKKA_STAGE", akka_stage + 1)
    end
    if (akka_stage == 2 and akka > 60) then
        akka = 0
        EntityLoad( "mods/noita-nemesis-teams/entities/remove_ground_240.xml", x, y )
        GlobalsSetValue("NOITA_NEMESIS_AKKA_STAGE", akka_stage + 1)
    end
    if (akka_stage >= 3 and akka > 30) then
        akka = 0
        if (akka_stage >= 6) then
            EntityLoad("data/entities/projectiles/deck/all_spells_loader.xml", x, y)
        else
            EntityLoad( "mods/noita-nemesis-teams/entities/remove_ground_240.xml", x, y )
        end
        GlobalsSetValue("NOITA_NEMESIS_AKKA_STAGE", akka_stage + 1)
    end
    GlobalsSetValue("NOITA_NEMESIS_AKKA_POINT", akka)
end

AkkasWisper() 