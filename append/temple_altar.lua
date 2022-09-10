
-- everyone have 33 fishes in mountain
local _spawn_fish = spawn_fish
function spawn_fish(x, y)
	local f = 33
	
	for i=1,f do
		EntityLoad( "data/entities/animals/fish.xml", x, y )
	end
end