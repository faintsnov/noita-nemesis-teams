dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "noita-nemesis-teams"
mod_settings_version = 1
mod_settings = 
{
	{
		id = "NOITA_NEMESIS_TEAMS_MORE_TEAM_FEATURE",
		ui_name = "More Team Feature",
		value_default = false,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NOITA_NEMESIS_TEAMS_AUTOMATIC_TEAM_DIVISION",
		ui_name = "Automatic Team Division",
		value_default = false,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NOITA_NEMESIS_TEAMS_EXPERIMENTAL_PLAYER_LIST",
		ui_name = "Experimental Player List",
		value_default = true,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NOITA_NEMESIS_TEAMS_ALLOW_PLAYER_DISPLAY_NAME",
		ui_name = "Use display player names set by others",
		value_default = false,
        scope=MOD_SETTING_SCOPE_RUNTIME
	},
	{
		id = "NOITA_NEMESIS_TEAMS_PLAYER_DISPLAY_NAME",
		ui_name = "Your display name.",
		ui_description = "Textbox.",
		value_default = "",
		text_max_length = 20,
		allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789",
		scope = MOD_SETTING_SCOPE_RUNTIME,
	}
--	{
--		id = "NOITA_NEMESIS_TEAMS_ABILITY_REBALANCE_OVERHALL",
--		ui_name = "Nemesis Ability Rebalance Overhall",
--		value_default = false,
--        scope=MOD_SETTING_SCOPE_RUNTIME
--	},
}

function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id )
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end
