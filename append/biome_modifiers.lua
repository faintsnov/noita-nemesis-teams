
-- let OMINOUS can spawn to everyone. 
for key,bm in pairs(biome_modifiers) do
	bm["requires_flag"] = nil
end
-- PROTECTION_FIELDS gones
for key,bm in pairs(biome_modifiers) do
	if (bm["id"] == "PROTECTION_FIELDS") then
		--table.remove(biome_modifiers, key)
		bm["requires_flag"] = "nobody_can_spawn_this"
	end
end
