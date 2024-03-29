dofile( "data/scripts/game_helpers.lua" )

function item_pickup( entity_item, entity_who_picked, name )
	
	local max_hp = 0
	local healing = 0
	local after_hp = 0
	
	local x, y = EntityGetTransform( entity_item )

	local damagemodels = EntityGetComponent( entity_who_picked, "DamageModelComponent" )
	if( damagemodels ~= nil ) then
		for i,damagemodel in ipairs(damagemodels) do
			max_hp = tonumber( ComponentGetValue( damagemodel, "max_hp" ) )
			local hp = tonumber( ComponentGetValue( damagemodel, "hp" ) )
			
			healing = math.min( max_hp - hp, 0.35) -- a healing bullet
			after_hp = hp + healing
			
			ComponentSetValue( damagemodel, "hp", after_hp)
		end
	end

	EntityLoad("data/entities/particles/image_emitters/heart_effect.xml", x, y-12)
	--EntityLoad("data/entities/particles/heart_out.xml", x, y-8)
	GamePrint( GameTextGet( "$logdesc_heart_fullhp", tostring(math.floor(after_hp*25)), tostring(math.floor(healing*25)) ) )

	-- remove the item from the game
	EntityKill( entity_item )
end
