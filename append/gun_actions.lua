
-- remove all spawn_requires_flag
for key,act in pairs(actions) do
	act["spawn_requires_flag"] = nil
end
