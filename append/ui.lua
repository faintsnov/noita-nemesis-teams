if initialized == nil then initialized = false; end

if not initialized then
    wand_cache = {}
    initialized = true
    dofile_once("mods/noita-together/files/scripts/item_list.lua")
    dofile_once("data/scripts/gun/procedural/wands.lua")
    dofile_once( "data/scripts/lib/utilities.lua" )
    local gui = gui or GuiCreate();
    local gui_id = 6969
    GuiStartFrame( gui );
    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    local show_teams_extension = false
    local show_game_stats = false
    local show_send_gold = false
    local show_emote_select = false
    local show_player_list = false
    local show_bank = false
    local show_message = false
    local caps_lock = false
    local radar_on = true
    local hidden_chat = false
    local show_wands = false
    local hoveredFrames = 0
    local last_player_msg = 0
    local bankfilter = ""
    local player_msg = ""
    local filteredItems = {}
    local wand_displayer = {}
    local gold_amount = "1"
    local bank_offset = 0
    local last_inven_is_open = false
    local selected_player = ""
    local spectate = 0
    local spectate_player_id = ""
    local numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}
    local alphabet = {"q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m"}
    local _wand_tooltip = {
        "$inventory_shuffle",
        "$inventory_actionspercast",
        "$inventory_castdelay",
        "$inventory_rechargetime",
        "$inventory_manamax",
        "$inventory_manachargespeed",
        "$inventory_capacity",
        "$inventory_spread"
    }
    local biome_sprites = {
        ["Mountain"] = "mountain.png",
        ["$biome_coalmine"] = "coalmine.png",
        ["$biome_coalmine_alt"] = "coalmine_alt.png",
        ["$biome_excavationsite"] = "excavationsite.png",
        ["$biome_fungicave"] = "fungicave.png",
        ["$biome_rainforest"] = "rainforest.png",
        ["$biome_snowcave"] = "snowcave.png",
        ["$biome_snowcastle"] = "snowcastle.png",
        ["$biome_vault"] = "vault.png",
        ["$biome_crypt"] = "crypt.png",
        ["$biome_holymountain"] = "holymountain.png",
        ["$biome_boss_victoryroom"] = "the_work.png",

        ["$biome_boss_arena"] = "laboratory.png",
        ["$biome_desert"] = "desert.png",
        ["$biome_dragoncave"] = "dragoncave.png",
        ["$biome_gold"] = "the_gold.png",
        ["$biome_lake"] = "lake.png",
        ["$biome_sandcave"] = "sandcave.png",
        ["$biome_tower"] = "tower.png",
        ["$biome_vault_frozen"] = "vault_frozen.png",
        ["$biome_clouds"] = "cloudscape.png",
        ["$biome_liquidcave"] = "ancient_laboratory.png",
        ["$biome_secret_lab"] = "alchemistboss.png",
        ["$biome_orbroom"] = "orbroom.png",
        ["$biome_wizardcave"] = "wizardcave.png",
        ["$biome_rainforest_dark"] = "lukki.png",
        ["$biome_mestari_secret"] = "wizardboss.png",
        ["$biome_ghost_secret"] = "snowy_boss.png",
        ["$biome_winter_caves"] = "snowy_chasm.png",
        ["$biome_the_end"] = "hell_work.png", --maybe no worky
        ["$biome_the_end_sky"] = "sky_work.png", --maybe no worky
        ["$biome_wandcave"] = "wandcave.png",
        ["$biome_winter"] = "winter.png",
        ["$biome_fun"] = "fun.png",
        ["$biome_robobase"] = "robobase.png",
    }

    local function reset_id()
        gui_id = 6969
    end
    
    local function next_id()
        local id = gui_id
        gui_id = gui_id + 1
        return id
    end

    local function previous_data( gui )
        local left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height = GuiGetPreviousWidgetInfo( gui );
        if left_click == 1 then left_click = true; elseif left_click == 0 then left_click = false; end
        if right_click == 1 then right_click = true; elseif right_click == 0 then right_click = false; end
        if hover == 1 then hover = true; elseif hover == 0 then hover = false; end
        return left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height;
    end

    local function follow_player( userId, name )
        local ghosts = EntityGetWithTag("nt_ghost") or {}
        for _, ghost in ipairs(ghosts) do
            local var_comp = get_variable_storage_component(ghost, "userId")
            local user_id = ComponentGetValue2(var_comp, "value_string")
            if (user_id == userId) then
                if (EntityHasTag(ghost, "nt_follow")) then
                    EntityRemoveTag(ghost, "nt_follow")
                    spectate = 0
                    GamePrint("No longer following " .. (name or ""))
                else
                    spectate = ghost
                    spectate_player_id = userId
                    EntityAddTag(ghost, "nt_follow")
                    GamePrint("Following " .. (name or ""))
                end
            end
        end
    end

    local function wand_tooltip(wand)
        local ret = {
            wand.shuffleDeckWhenEmpty and "Yes" or "No",
            tostring(wand.actionsPerRound),
            string.format("%.2f",wand.fireRateWait / 60),
            string.format("%.2f",wand.reloadTime / 60),
            string.format("%.0f",wand.manaMax),
            string.format("%.0f",wand.manaChargeSpeed),
            tostring(wand.deckCapacity),
            string.format("%.2f DEG",wand.spreadDegrees)
        }
        return ret
    end

    local function flask_info(flask, chest)
        local materials = ""
        local d = 10
        if (chest) then d = 15 end
        for i, inv in ipairs(flask) do
            local translated_text = ""
            translated_text = GameTextGetTranslatedOrNot(CellFactory_GetUIName(inv.id))
            materials = materials .. string.format("%s%s %s\n",
            math.ceil(inv.amount / d),
            "%",
            translated_text)
        end
        return materials
    end

    local function change_bank_offset(num, pages)
        local offset = bank_offset + num
        if (offset >= 0 and offset <= pages) then
            bank_offset = offset
        end
    end

    local function get_wand_sprite(filename)
        if (wand_cache[filename] ~= nil) then return wand_cache[filename] end
        local wand = {}
        wand.sprite = filename
        if (filename:sub(-#".xml") == ".xml") then
            wand.sprite = _ModTextFileGetContent(filename):match([[filename="([^"]+)]])
        end

        local w, h = GuiGetImageDimensions(gui, wand.sprite, 1)
        local ox = ((w - 20) / 2) * -1
        local oy = ((h - 20) / 2) * -1
        wand.ox = ox
        wand.oy = oy
        wand_cache[filename] = wand
        return wand_cache[filename]
    end

    local function render_wand(item, x, y, nx, ny, show_owner, force)
        GuiZSetForNextWidget(gui, 7)
        local wand = get_wand_sprite(item.stats.sprite)
        if (not force) then
            GuiImage(gui, next_id(), x + wand.ox, y + wand.oy, wand.sprite, 1, 1, 1)
        end
        local left, right, hover = previous_data(gui)
        if (hover or force) then

            local player = PlayerList[item.sentBy] or {name="Me"}
            local nox, nyx = 5, 0
            GuiZSetForNextWidget(gui, 6)
            GuiImageNinePiece(gui, next_id, nx, ny, 160, 160, 1)
            GuiImage(gui, next_id(), nx + 125, ny + 80, wand.sprite, 1, 2.2, 0, -1.5708)
            GuiZSetForNextWidget(gui, 5)
            if (not force) then
                GuiText(gui, nx + nox, ny + nyx, "Sent By " .. player.name)
            end
            nyx = nyx + 15
            
            for key, value in ipairs(wand_tooltip(item.stats))do
                GuiZSetForNextWidget(gui, 5)
                GuiText(gui, nx + nox, ny + nyx, _wand_tooltip[key])
                GuiZSetForNextWidget(gui, 5)
                GuiText(gui, nx + 80, ny + nyx, tostring(value))
                nyx = nyx + 10
            end
            nyx = nyx + 10
            local always_casts = item.alwaysCast or {}
            local deck = item.deck or {}
            if (#always_casts > 0) then
                GuiZSetForNextWidget(gui, 5)
                GuiText(gui, nx + 5, ny + nyx, "Always casts")
                nox = 60
                for index, value in ipairs(always_casts) do
                    if (value.gameId ~= "0") then
                        GuiZSetForNextWidget(gui, 5)
                        GuiImage(gui, next_id(), nx + nox, ny + nyx, SpellSprites[value.gameId].sprite, 1, 0.8, 0.8)
                        nox = nox + 15
                    end
                end
                nox = 5
                nyx = nyx + 15
            end
            for index, value in ipairs(deck) do
                if (value.gameId ~= "0") then
                    GuiZSetForNextWidget(gui, 5)
                    GuiImage(gui, next_id(), nx + nox, ny + nyx, SpellSprites[value.gameId].sprite, 1, 0.8, 0.8)
                    nox = nox + 15
                    if (index % 10 == 0) then
                        nyx = nyx + 20
                        nox = 5
                    end
                end
            end
        end
    end

    local function draw_item_sprite(item, x,y)
        GuiZSetForNextWidget(gui, 8)
        if (item.gameId ~= nil) then --spell
            local player = PlayerList[item.sentBy] or {name="Me"}
            local spell_description = ""
            if (player ~= nil) then
                spell_description = spell_description .. "\nSent by: " .. player.name
            end
            local spell = SpellSprites[item.gameId]
            GuiImage(gui, next_id(), x +2, y +2,  spell.sprite, 1,1,1)--SpellSprites[item.gameId], 1)
            GuiTooltip(gui, spell.name, spell_description)
        elseif (item.stats ~= nil) then --wand
            GuiZSetForNextWidget(gui, 7)
            local wand = get_wand_sprite(item.stats.sprite)
            GuiImage(gui, next_id(), x + wand.ox, y + wand.oy, wand.sprite, 1, 1, 1)--, GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndPause)
            
            local left, right, hover = previous_data(gui)
            if (hover) then
                local player = PlayerList[item.sentBy] or {name="Me"}
                local nx, ny = (screen_width / 2) - 260, (screen_height/2) - 95
                local nox, nyx = 5, 0
                GuiZSetForNextWidget(gui, 6)
                GuiImageNinePiece(gui, next_id, nx, ny, 160, 160, 1)
                GuiZSetForNextWidget(gui, 5)
                GuiText(gui, nx + nox, ny + nyx, "Sent By " .. player.name)
                nyx = nyx + 15
                
                for key, value in ipairs(wand_tooltip(item.stats))do
                    GuiZSetForNextWidget(gui, 5)
                    GuiText(gui, nx + nox, ny + nyx, _wand_tooltip[key])
                    GuiZSetForNextWidget(gui, 5)
                    GuiText(gui, nx + 80, ny + nyx, tostring(value))
                    nyx = nyx + 10
                end
                nyx = nyx + 10
                local always_casts = item.alwaysCast or {}
                local deck = item.deck or {}
                if (#always_casts > 0) then
                    GuiZSetForNextWidget(gui, 5)
                    GuiText(gui, nx + 5, ny + nyx, "Always casts")
                    nox = 60
                    for index, value in ipairs(always_casts) do
                        GuiZSetForNextWidget(gui, 5)
                        GuiImage(gui, next_id(), nx + nox, ny + nyx, SpellSprites[value.gameId].sprite, 1, 0.8, 0.8)
                        nox = nox + 15
                    end
                    nox = 5
                    nyx = nyx + 15
                end
                for index, value in ipairs(deck) do
                    GuiZSetForNextWidget(gui, 5)
                    GuiImage(gui, next_id(), nx + nox, ny + nyx, SpellSprites[value.gameId].sprite, 1, 0.8, 0.8)
                    nox = nox + 15
                    if (index % 10 == 0) then
                        nyx = nyx + 20
                        nox = 5
                    end
                end
            end
            
        elseif (item.content ~= nil) then --flask
            local player = PlayerList[item.sentBy] or {name="Me"}
            local container_name = item.isChest and "Powder Pouch" or "Flask"
            if (player ~= nil) then
                container_name = container_name .. "\nSent by: " .. player.name
            end
            GuiZSetForNextWidget(gui, 7)
            if (item.isChest) then
                GuiImage(gui, next_id(), x + 2, y + 2, "data/ui_gfx/items/material_pouch.png", 1, 1, 1)
            else
                GuiColorSetForNextWidget(gui, item.color.r, item.color.g, item.color.b, 1)
                GuiImage(gui, next_id(), x + 2, y + 2, "data/ui_gfx/items/potion.png", 1, 1, 1)
            end
            GuiTooltip(gui, container_name, flask_info(item.content, item.isChest))
        elseif (item.path ~= nil) then
            local player = PlayerList[item.sentBy] or {name="Me"}
            local item_name = nt_items[item.path] and nt_items[item.path].name or ""
            item_name = GameTextGetTranslatedOrNot(item_name)
            if (player ~= nil) then
                item_name = item_name .. "\nSent by: " .. player.name
            end
            local w, h = GuiGetImageDimensions(gui, item.sprite, 1)
            local ox = ((w - 20) / 2) * -1
            local oy = ((h - 20) / 2) * -1
            GuiZSetForNextWidget(gui, 7)
            GuiImage(gui, next_id(), x + ox, y + oy, item.sprite, 1, 1, 1)
            GuiTooltip(gui, item_name, "")
        end
    end

    local function draw_bank_item(x, y, i)
        local item_offset = i + bank_offset * 25
        local item = filteredItems[item_offset]
        if (item ~= nil) then
            draw_item_sprite(item, x, y)
        end

        GuiZSetForNextWidget(gui, 9)
        if (GuiImageButton(gui, next_id(), x, y, "", "data/ui_gfx/inventory/full_inventory_box.png")) then
            if (item ~= nil) then
                SendWsEvent({event="PlayerTake", payload={id=item.id}})
            end
        end
    end

    local function filterItems()
        local filterkey = bankfilter
        if (filterkey == "") then
            filteredItems = BankItems
            return
        end
        local ret = {}

        for _, item in ipairs(BankItems) do
            if (item.gameId ~= nil) then -- spell
                local spell = SpellSprites[item.gameId]
                if (string.find(string.lower(spell.name), string.lower(filterkey))) then
                    table.insert(ret, item)
                end
            elseif (item.stats ~= nil) then -- wand
                local found = false
                for _, action in ipairs(item.alwaysCast or {}) do
                    local spell = SpellSprites[action.gameId]
                    if (spell ~= nil) then
                        if (string.find(string.lower(spell.name), string.lower(filterkey))) then
                            found = true
                        end
                    end
                end
                for _, action in ipairs(item.deck or {}) do
                    local spell = SpellSprites[action.gameId]
                    if (spell ~= nil) then
                        if (string.find(string.lower(spell.name), string.lower(filterkey))) then
                            found = true
                        end
                    end
                end

                if (found) then
                    table.insert(ret, item)
                end
            elseif (item.content ~= nil) then -- flask
                local container = item.isChest and "Powder Stash\n" or "Flask\n"
                container = container .. flask_info(item.content, item.isChest)
                if (string.find(string.lower(container), string.lower(filterkey))) then
                    table.insert(ret, item)
                end
            elseif (item.path ~= nil) then -- entity item
                local item_name = nt_items[item.path] and nt_items[item.path].name or ""
                item_name = GameTextGetTranslatedOrNot(item_name)
                if (string.find(string.lower(item_name), string.lower(filterkey))) then
                    table.insert(ret, item)
                end
            end
        end

        filteredItems = ret
    end

    local function sortItems()
        table.sort(BankItems, function (a, b)
            if (a.gameId) then
                if (b.gameId) then return a.gameId < b.gameId end
                if (b.stats) then return false end
                if (b.content) then return true end
                if (b.path) then return true end
            elseif (a.stats) then
                if (b.gameId) then return true end
                if (b.stats) then return a.stats.sprite < b.stats.sprite end
                if (b.content) then return true end
                if (b.path) then return true end
            elseif (a.content) then
                if (b.gameId) then return false end
                if (b.stats) then return false end
                if (b.content) then return false end
                if (b.path) then return true end
            elseif (a.path) then
                return false
            end
            return false
        end)
    end

    local function draw_item_bank()
        local pos_x, pos_y = (screen_width / 2) - 90, (screen_height/2) - 90
        local offx, offy = 20, 20
        GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)
        GuiZSetForNextWidget(gui, 10)
        GuiImageNinePiece(gui, next_id(), pos_x, pos_y, 160, 170, 1, "mods/noita-together/files/ui/background.png")
        GuiZSetForNextWidget(gui, 9)
        if (GuiImageButton(gui, next_id(), pos_x + 147, pos_y, "", "mods/noita-together/files/ui/close.png")) then
            show_bank = not show_bank
        end
        GuiZSetForNextWidget(gui, 9)
        if (GuiImageButton(gui, next_id(), pos_x + 10, pos_y, "", "mods/noita-together/files/ui/sort.png")) then
            sortItems()
        end
        GuiZSetForNextWidget(gui, 9)
        bankfilter = GuiTextInput(gui, next_id(), pos_x + 30, pos_y, bankfilter, 100, 32)
        filterItems()
        local pages = math.floor(#filteredItems / 25)
        if (bank_offset > pages) then bank_offset = pages end
        for i = 1, 25 do
            draw_bank_item(pos_x + offx,pos_y + offy, i)
            
            offx = offx + 25

            if (i % 5 == 0) then
                offx = 20
                offy = offy + 25
            end
        end        
        offy = offy + 5
        if (GuiImageButton(gui, next_id(), pos_x, pos_y + offy, "", "mods/noita-together/files/ui/prev_page.png")) then
            change_bank_offset(-1, pages)
        end
        GuiText(gui, pos_x + 75, pos_y + offy + 5, tostring(bank_offset+1) .. "/" .. tostring(pages+1))
        if GuiImageButton(gui, next_id(), pos_x + 140, pos_y + offy, "", "mods/noita-together/files/ui/next_page.png")then
            change_bank_offset(1, pages)
        end
        GuiOptionsClear(gui)
    end

    local function getGameFrameBaseAnimatedOffsetY()
        local frame = GameGetFrameNum()
        local tmp = frame%60
        return math.min(0, tmp*(tmp-15)/10)
    end

    local function draw_player_info(player, userId)
        if (player.sampo) then
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
            GuiZSetForNextWidget(gui, 9)
            GuiImage(gui, next_id(), 88, 0, "mods/noita-together/files/ui/sampo.png", 0.5, 1, 1)
        end
        if (biome_sprites[player.location] ~= nil) then
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
            GuiZSetForNextWidget(gui, 9)
            GuiImage(gui, next_id(), 80, 0, "mods/noita-together/files/ui/biomes/" .. biome_sprites[player.location] , 0.8, 1, 1)
        end
        if (player.emote ~= nil and not player.emoteIsNemesisAblility and player.team ~= nil and NEMESIS.nt_nemesis_team ~= nil and player.team == NEMESIS.nt_nemesis_team) then
            --FIXME drawEmote
            --other emote only visiable for same team
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
            GuiZSetForNextWidget(gui, 9)
            GuiImage(gui, next_id(), 90, getGameFrameBaseAnimatedOffsetY(), "data/ui_gfx/gun_actions/"..player.emote..".png", 1, 1, 1)
            if (GameGetFrameNum()-player.emoteStartFrame>60*5) then
                player.emote = nil
                player.emoteIsNemesisAblility = false
                player.emoteStartFrame = nil
            end
        elseif (player.emote ~= nil and player.emoteIsNemesisAblility) then
            --Nemesis ablitiy emote visiable for all players
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
            GuiZSetForNextWidget(gui, 9)
            if (player.emoteSprite ~= nil) then
                GuiImage(gui, next_id(), 90, getGameFrameBaseAnimatedOffsetY(), player.emoteSprite, 1, 1, 1)
            else
                GuiImage(gui, next_id(), 90, getGameFrameBaseAnimatedOffsetY(), "mods/noita-nemesis/files/badges/"..player.emote..".png", 1, 1, 1)
            end
            if (GameGetFrameNum()-player.emoteStartFrame>60*5) then
                player.emote = nil
                player.emoteIsNemesisAblility = false
                player.emoteStartFrame = nil
                player.emoteSprite = nil
            end
        elseif (player.team ~= nil) then
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
            GuiZSetForNextWidget(gui, 9)
            GuiImage(gui, next_id(), 90, 0, "data/ui_gfx/animal_icons/" .. player.team .. ".png", 0.8, 0.7, 0.7)
        end
        GuiZSetForNextWidget(gui, 10)

        local player_display_name = player.name
        if (ModSettingGet("noita-nemesis-teams.NOITA_NEMESIS_TEAMS_EXPERIMENTAL_PLAYER_LIST")) then
            if (player.isCJK==nil) then
                local wordTable = {}
                for word in player_display_name:gmatch("[\33-\127\192-\255]+[\128-\191]*") do
                    wordTable[#wordTable+1] = word
                end
                player.isCJK = (#wordTable > 1)
            end
        end

        if (show_send_gold) then
            if(NEMESIS~=nil and NEMESIS.nt_nemesis_team~=nil and player.team~=nil and NEMESIS.nt_nemesis_team==player.team and player.curHp > 0) then
                GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
                GuiZSetForNextWidget(gui, 9)
                local sendGoldAmount = 100
                if (GuiImageButton(gui, next_id(), 100, 0, "", "data/ui_gfx/items/goldnugget.png")) then
                    dofile("mods/noita-nemesis-teams/files/sendGold.lua")
                    sendGold( userId, sendGoldAmount )
                end
                GuiTooltip(gui, "Send ".. player_display_name .." "..sendGoldAmount.." Gold", "")
            end
        end

        if (ModSettingGet("noita-nemesis-teams.NOITA_NEMESIS_TEAMS_EXPERIMENTAL_PLAYER_LIST")) then
            if(NEMESIS~=nil and NEMESIS.nt_nemesis_team~=nil and player.team~=nil and NEMESIS.nt_nemesis_team==player.team) then
                GuiColorSetForNextWidget( gui, 0.3, 0.9, 0.3, 1 )
            end
        end
        
        local lfck, rtck = GuiButton(gui, next_id(), 0,0, player_display_name)
        if (lfck) then
            follow_player(userId, player.name)
        end
        if (rtck) then
            show_wands = not show_wands
        end
        local _c, _cr, _hover = previous_data(gui)
        local inven = PlayerList[userId].inven
        if (player.team ~= nil and NEMESIS.nt_nemesis_team ~= nil and player.team == NEMESIS.nt_nemesis_team) then
            if (_hover and show_wands and inven ~= nil) then
                wand_displayer = inven
            end
        end
        
        local location = GameTextGetTranslatedOrNot(player.location)
        if (location == nil or location == "_EMPTY_") then location = "Mountain" end
        location = location .. "\nDepth: " .. string.format("%.0fm", player.y and player.y / 10 or 0)
        
        if (ModSettingGet("noita-nemesis-teams.NOITA_NEMESIS_TEAMS_EXPERIMENTAL_PLAYER_LIST")) then
            if (player.team ~= nil and NEMESIS.nt_nemesis_team ~= nil and player.team == NEMESIS.nt_nemesis_team and player.nemesisPoint ~= nil) then
                local nemesisPoint = player.nemesisPoint
                GuiTooltip(gui, player.name, "Hp: " .. tostring(math.floor(player.curHp)) .. " / " .. tostring(math.floor(player.maxHp)) .. "\nLocation: " .. location .. "\nNP: " .. nemesisPoint)
            else
                GuiTooltip(gui, player.name, "Hp: " .. tostring(math.floor(player.curHp)) .. " / " .. tostring(math.floor(player.maxHp)) .. "\nLocation: " .. location)
            end
        else
            GuiTooltip(gui, player.name, "Hp: " .. tostring(math.floor(player.curHp)) .. " / " .. tostring(math.floor(player.maxHp)) .. "\nLocation: " .. location)
        end
        
        local bar_w = player.curHp / player.maxHp
        if (ModSettingGet("noita-nemesis-teams.NOITA_NEMESIS_TEAMS_EXPERIMENTAL_PLAYER_LIST")) then
            if (player.respawned ~= nil and player.respawned) then
                GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
                GuiZSetForNextWidget(gui, 9)
                GuiImage(gui, next_id(), 0, 0, "mods/noita-nemesis-teams/ui/hpbar_full.png", 1, bar_w, 1)
                GuiZSetForNextWidget(gui, 10)
                GuiImage(gui, next_id(), 0, 0, "mods/noita-nemesis-teams/ui/hpbar_empty.png", 1, 1, 1)
            else
                GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
                GuiZSetForNextWidget(gui, 9)
                GuiImage(gui, next_id(), 0, 0, "mods/noita-together/files/ui/hpbar_full.png", 1, bar_w, 1)
                GuiZSetForNextWidget(gui, 10)
                GuiImage(gui, next_id(), 0, 0, "mods/noita-together/files/ui/hpbar_empty.png", 1, 1, 1)
            end
        else
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
            GuiZSetForNextWidget(gui, 9)
            GuiImage(gui, next_id(), 0, 0, "mods/noita-together/files/ui/hpbar_full.png", 1, bar_w, 1)
            GuiZSetForNextWidget(gui, 10)
            GuiImage(gui, next_id(), 0, 0, "mods/noita-together/files/ui/hpbar_empty.png", 1, 1, 1)
        end

        GuiLayoutAddVerticalSpacing(gui, 2)
    end

    local function sort_player_list_by_team(players)
        local myteam = "solo"
        if(NEMESIS~=nil and NEMESIS.nt_nemesis_team~=nil) then
            myteam = NEMESIS.nt_nemesis_team
        end
        local teams_asc = {deer=1, duck=2, sheep=3, fungus=4, solo=5}
        teams_asc[myteam]=0
        local _players = {}
        for _, v in pairs(players) do
            table.insert(_players, v)
        end
        table.sort(_players,
            function(a,b)
                local team_a=a.team or "solo"
                local team_b=b.team or "solo"
                return (teams_asc[team_a] < teams_asc[team_b])
            end
        )
        return _players
    end

    local function draw_player_list_scroll(players)
        GuiZSetForNextWidget(gui, 10)
        GuiBeginScrollContainer(gui, next_id(), 5, 50, 100, 150, false, 1, 1)
        GuiLayoutBeginVertical(gui, 0, 0)
        for _, player in pairs(sort_player_list_by_team(players)) do
            draw_player_info(player, player.userId)
        end
        GuiLayoutEnd(gui)
        GuiEndScrollContainer(gui)
    end

    local function draw_player_list_no_scroll(players)
        GuiZSetForNextWidget(gui, 10)
        GuiLayoutBeginVertical(gui, 1, 14)
        for _, player in pairs(sort_player_list_by_team(players)) do
            draw_player_info(player, player.userId)
        end
        GuiLayoutEnd(gui)
    end

    local function draw_player_list(players)  
        if (ModSettingGet("noita-nemesis-teams.NOITA_NEMESIS_TEAMS_EXPERIMENTAL_PLAYER_LIST")) then
            if(PlayerCount ~= nil and PlayerCount <= 16) then
                draw_player_list_no_scroll(players)
            else
                draw_player_list_scroll(players)
            end
        else
            draw_player_list_scroll(players)
        end
    end

    local function draw_gold_bank()
        local pos_x, pos_y = (screen_width / 2) + 85, (screen_height/2) - 90
        GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)
        GuiZSetForNextWidget(gui, 10)
        GuiImageNinePiece(gui, next_id(), pos_x, pos_y, 120, 65, 1, "mods/noita-together/files/ui/background.png")
        GuiZSetForNextWidget(gui, 9)
        GuiText(gui, pos_x, pos_y, "Gold: " .. tostring(BankGold))

        GuiZSetForNextWidget(gui, 9)
        GuiText(gui, pos_x, pos_y+15, "Amount")
        GuiZSetForNextWidget(gui, 9)
        gold_amount = GuiTextInput(gui, next_id(), pos_x, pos_y + 25, gold_amount, 120, 10, "0123456789")
        
        
        GuiZSetForNextWidget(gui, 9)
        if (GuiImageButton(gui, next_id(), pos_x, pos_y + 45, "", "mods/noita-together/files/ui/button.png")) then
            local amount = tonumber(gold_amount)
            if (amount <= BankGold) then
                SendWsEvent({event="TakeGold", payload={amount=amount}})
                gold_amount = "1"
            end
        end
        GuiZSetForNextWidget(gui, 8)
        GuiText(gui, pos_x + 8 , pos_y +50, "TAKE")

        GuiZSetForNextWidget(gui, 9)
        if (GuiImageButton(gui, next_id(), pos_x + 80, pos_y + 45, "", "mods/noita-together/files/ui/button.png")) then
            local wallet, gold = nil, 0
            local amount = tonumber(gold_amount)
            wallet, gold = PlayerWalletInfo()
            if (amount <= gold and wallet ~= nil) then
                SendWsEvent({event="SendGold", payload={amount=amount}})
                ComponentSetValue2(wallet, "money", gold - amount)
                gold_amount = "1"
            end
        end
        GuiZSetForNextWidget(gui, 8)
        GuiText(gui, pos_x + 80 , pos_y +50, "DEPOSIT")
        GuiOptionsClear(gui)
    end

    function draw_player_message()
        local pos_x, pos_y = (screen_width / 2) - 90, (screen_height/2) - 90
        local offx, offy = 1, 20
        GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)
        GuiZSetForNextWidget(gui, 9)
        GuiImageNinePiece(gui, next_id(), pos_x, pos_y, 160, 100, 1, "mods/noita-together/files/ui/background.png")
        GuiZSetForNextWidget(gui, 8)
        if (GuiImageButton(gui, next_id(), pos_x + 151, pos_y, "", "mods/noita-together/files/ui/close.png")) then
            player_msg = ""
            show_message = false
        end
        GuiZSetForNextWidget(gui, 8)
        player_msg = GuiTextInput(gui, next_id(), pos_x, pos_y, player_msg, 150, 99, "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm0123456789 ")
        for _, num in pairs(numbers) do
            if (GuiButton(gui, next_id(), pos_x + offx, pos_y + offy, "["..num.."]")) then
                player_msg = player_msg .. num
            end
            offx = offx + 16
        end
        offy = offy + 12
        offx = 1
        for idx, _letter in pairs(alphabet) do
            local letter = caps_lock and string.upper(_letter) or _letter
            if (GuiButton(gui, next_id(), pos_x + offx, pos_y + offy, "["..letter.."]")) then
                player_msg = player_msg .. letter
            end
            offx = offx + 16
            if (idx % 10 == 0 and idx % 20 == 10) then
                offx = 4
                offy = offy + 12
            elseif (idx % 19 == 0) then
                offx = 0
                offy = offy + 12
                if (GuiButton(gui, next_id(), pos_x + offx, pos_y + offy, "[CAPS]")) then
                    caps_lock = not caps_lock
                end
                offx = 35
            end
        end
        offy = offy + 12
        if (GuiButton(gui, next_id(), pos_x + 60, pos_y + offy, "[SPACE]")) then
            player_msg = player_msg .. " "
        end
        offy = offy + 15
        GuiZSetForNextWidget(gui, 8)
        if (GuiImageButton(gui, next_id(), pos_x + 60, pos_y + offy, "", "mods/noita-together/files/ui/button.png")) then
            local px, py = GetPlayerPos()
            py = py - 10
            if (#player_msg > 0 and GameGetFrameNum() >= last_player_msg and px ~= nil and py ~= nil and NT ~= nil and NT.run_started) then
                if (CanSpawnPoi(px, py)) then
                    SpawnPoi("My messsage", player_msg,  px, py)
                    SendWsEvent({event="CustomModEvent", payload={name="PlayerPOI", message=player_msg, x=px, y=py}})
                    show_message = false
                    player_msg = ""
                    GamePrint("message sent")
                    last_player_msg = GameGetFrameNum() + 60*30
                else
                    GamePrint("can't send message too close to another message")
                end
            else
                GamePrint("can't send message yet")
            end
        end
        GuiZSetForNextWidget(gui, 7)
        GuiText(gui, pos_x + 69 , pos_y + offy + 4, "SEND")
    end

    local function draw_winner(base_x, base_y, team)
        if (team~=nil) then
            local tweakPos = {
                -- scale_x, scale_y, animation_name, crown_dx, crown_dy, crown_scale_x, crown_scale_y)
                deer = {1.8, 1.8, "run", 7, -18, 0.9, 0.9},
                duck = {2, 2, "swim_idle", 0, -19, 0.8, 0.8},
                sheep = {1.8, 1.8, "walk", 8, -12, 0.8, 0.8},
                fungus = {1.8, 1.8, "stand", -5, -26, 1, 1}
            }
            local tweak = tweakPos[team]
            GuiZSetForNextWidget(gui, 8198)
            GuiImage(gui, next_id(), base_x, base_y, "data/enemies_gfx/"..team..".xml", 1, tweak[1], tweak[2], 0, GUI_RECT_ANIMATION_PLAYBACK.Loop, tweak[3] )        
            GuiZSetForNextWidget(gui, 8197)
            GuiImage(gui, next_id(), base_x + tweak[4], base_y + tweak[5], "data/entities/animals/boss_centipede/rewards/reward_crown.png", 1, tweak[6], tweak[7], 0)    
        else
            GuiZSetForNextWidget(gui, 8196)
            GuiImage(gui, next_id(), base_x-18, base_y, "data/entities/animals/boss_centipede/rewards/reward_crown.png", 1, 4, 3, 0)    
        end
    end

    local function _GuiTextCenteredNilZero(x, y, txt)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter )
        GuiText(gui, x, y, txt or "0" )
    end

    local function draw_team_stats(x, y, team_stats, team)
        local myteam = NEMESIS.nt_nemesis_team
        team_stats[team] = team_stats[team] or {}
        if (myteam ~= nil and myteam == team) then
            local abilities_gained = team_stats[team].abilities_gained or "0"
            local abilities_gained_mina = team_stats[team].abilities_gained_mina or "0"
            local enemies_sent = team_stats[team].enemies_sent or "0"
            local enemies_sent_mina = team_stats[team].enemies_sent_mina or "0"
            _GuiTextCenteredNilZero(x, y, abilities_gained.." ("..abilities_gained_mina..")")
            _GuiTextCenteredNilZero(x+90, y, enemies_sent.." ("..enemies_sent_mina..")")
        else
            _GuiTextCenteredNilZero(x, y, team_stats[team].abilities_gained)
            _GuiTextCenteredNilZero(x+90, y, team_stats[team].enemies_sent)
        end

    end

    local function draw_game_stats()
        local container_w, container_h = 320, 200
        local container_alpha = 0.9
        local center_x, center_y = screen_width/2, screen_height/2
        local pos_x, pos_y = center_x - container_w/2, center_y - container_h/2
        GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)
        GuiZSetForNextWidget(gui, 8199)
        GuiImageNinePiece(gui, next_id(), pos_x, pos_y, container_w, container_h, container_alpha, "mods/noita-together/files/ui/background.png")

        -- winner team
        draw_winner(center_x, pos_y + 45, NEMESIS.winner_team)

        GuiImage(gui, next_id(), center_x-100, pos_y+95, "data/ui_gfx/animal_icons/deer.png", 1, 1, 1, 0 )
        GuiImage(gui, next_id(), center_x-100, pos_y+115, "data/ui_gfx/animal_icons/duck.png", 1, 1, 1, 0 )
        GuiImage(gui, next_id(), center_x-100, pos_y+135, "data/ui_gfx/animal_icons/sheep.png", 1, 1, 1, 0 )
        GuiImage(gui, next_id(), center_x-100, pos_y+155, "data/ui_gfx/animal_icons/fungus.png", 1, 1, 1, 0 )
        
        local team_stats = json.decode(NEMESIS.team_stats or "[]")
        --print(json.encode({}))
        team_stats = team_stats or {}

        _GuiTextCenteredNilZero(center_x-0, pos_y+80, "Nemesis Abilities")
        _GuiTextCenteredNilZero(center_x+90, pos_y+80, "Enemies Sent")
        draw_team_stats(center_x, pos_y+100, team_stats, "deer")
        draw_team_stats(center_x, pos_y+120, team_stats, "duck")
        draw_team_stats(center_x, pos_y+140, team_stats, "sheep")
        draw_team_stats(center_x, pos_y+160, team_stats, "fungus")

        GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1 )
        GuiText(gui, pos_x+container_w-50, pos_y+container_h-10, ".ver "..GlobalsGetValue("NOITA_NEMESIS_TEAMS_VERSION"))
    end

    local emote_list = {
        charm = {id="charm"} ,
        cleaning_tool = {id="cleaning_tool"} ,
        damage_friendly = {id="damage_friendly"} ,
        decoy_trigger = {id="decoy_trigger"} ,
        friend_fly = {id="friend_fly"} ,
        inebriation = {id="inebriation"} ,
        keyshot = {id="keyshot"} ,
        propane_tank = {id="propane_tank"} ,
        baab_all = {id="baab_all"} ,
        baab_empty = {id="baab_empty"} ,
        baab_is = {id="baab_is"} ,
        baab_lava = {id="baab_lava"} ,
        baab_love = {id="baab_love"} ,
        baab_poop = {id="baab_poop"} ,
        baab_water = {id="baab_water"} ,
        bomb = {id="bomb", misobon=true, entity="mods/noita-nemesis-teams/entities/helpful_bomb.xml"} 
    }

    local function draw_emote_select() 
        GuiZSetForNextWidget(gui, 10)
        GuiBeginScrollContainer(gui, next_id(), 200, 50, 240, 60, false, 1, 1)
        GuiLayoutBeginVertical(gui, 0, 0)
        local offset_x = 0
        for _, emote in pairs(emote_list) do
            if (offset_x < 200) then
                GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
            end
            if (GuiImageButton(gui, next_id(), offset_x, 0, "", "data/ui_gfx/gun_actions/"..emote.id..".png")) then
                local target = nil
                if (emote.misobon) then
                    if (spectate > 0 and NEMESIS.alive == false) then
                        target = spectate_player_id
                    end
                    --EntityLoad(emote.entity)
                end
                dofile("mods/noita-nemesis-teams/files/sendEmote.lua")
                sendEmote( emote, target )
            end
            offset_x = (offset_x + 20) % 220
        end
        GuiLayoutEnd(gui)
        GuiEndScrollContainer(gui)
    end

    local function isGhostSameTeam(ghost)
        if (NEMESIS.nt_nemesis_team == nil) then 
            return false
        end
        local vars = EntityGetComponent(ghost, "VariableStorageComponent")
        for _, var in pairs(vars) do
            local name = ComponentGetValue2(var, "name")
            if (name == "userId") then
                local id = ComponentGetValue2(var, "value_string")
                if (PlayerList[id].team ~= nil and PlayerList[id].team == NEMESIS.nt_nemesis_team) then 
                    return true
                end
            end
        end
        return false
    end

    local function fogOfWar() 
        if (NEMESIS == nil) then return end
        if (GameGetFrameNum() % 300 == 0) then
            local ghosts = EntityGetWithTag("nt_ghost")
            for _, ghost in pairs(ghosts) do
                local fogComp = EntityGetFirstComponent( ghost, "SpriteComponent", "nt_nemesis_team_fow" )
                local isTeam = isGhostSameTeam(ghost)
                if (isTeam and fogComp == nil) then
                    EntityAddComponent( ghost, "SpriteComponent", { 
                        _tags="enabled_in_world,enabled_in_hand,nt_nemesis_team_fow",
                        alpha="0.8",
                        image_file="data/particles/torch_fog_of_war_hole.xml",
                        smooth_filtering="1",
                        fog_of_war_hole="1",
                        has_special_scale="1",
                        special_scale_x="8",
                        special_scale_y="8",
                    })
                end
    
                if ((not isTeam) and fogComp ~= nil) then
                    EntityRemoveComponent( ghost, fogComp)
                end
    
            end
        end
    end

    function draw_gui()
        --local frame = GameGetFrameNum()
        reset_id()
        GuiStartFrame(gui)
        GuiIdPushString( gui, "noita_together")

        -- controller stuff
        local player = GetPlayer()
        if (player) then
            local platform_shooter_player = EntityGetFirstComponentIncludingDisabled(player, "PlatformShooterPlayerComponent")
            if (platform_shooter_player) then
                local is_gamepad = ComponentGetValue2(platform_shooter_player, "mHasGamepadControlsPrev")
                if (is_gamepad) then
                    GuiOptionsAdd(gui, GUI_OPTION.NonInteractive)
                    GuiOptionsAdd(gui, GUI_OPTION.AlwaysClickable)
                end
            end
            --close on inventory change
            local inven_gui = EntityGetFirstComponent(player, "InventoryGuiComponent")
            if (inven_gui ~= nil) then
                local is_open = ComponentGetValue2(inven_gui, "mActive")

                if (is_open and not last_inven_is_open) then
                    show_bank = false
                end
                last_inven_is_open = is_open
            end
            --[[ ghost selection
                local controls_comp = EntityGetFirstComponent(player, "ControlsComponent")
            if (controls_comp ~= nil) then
                local x, y = ComponentGetValue2(controls_comp, "mMousePosition")
                local mouse_down = ComponentGetValue2(controls_comp, "mButtonDownLeftClick")
                local selected_ghosts = mouse_down and EntityGetInRadiusWithTag(x, y, 24, "nt_ghost") or nil
                if (selected_ghosts ~= nil) then
                    selected_ghosts = selected_ghosts[1]
                    local var_comps = EntityGetComponent(selected_ghosts, "VariableStorageComponent") or {}
                    for _, var in ipairs(var_comps) do
                        if (ComponentGetValue2(var, "name") == "userId") then
                            --selected_player = ComponentGetValue2(var, "value_string")
                        end
                    end
                end
            end
            ]]
        end
        -- close on escape (pause)
        local ghost_button = HideGhosts and "hide_player_ghosts.png" or "player_ghosts.png"
        local chat_button = HideChat and "hide_chat.png" or "chat.png"
        local ghost_tooltip = HideGhosts and "No player ghosts" or "Showing player ghosts"
        local chat_tooltip = HideChat and "Ignoring chat messages" or "Showing chat messages"
        
        if (NEMESIS ~= nil and NEMESIS.nt_nemesis_team ~= nil) then
            if (GuiImageButton(gui, next_id(), 80, 0, "", "data/ui_gfx/animal_icons/" .. NEMESIS.nt_nemesis_team .. ".png")) then
                show_emote_select = not show_emote_select
            end
            GuiTooltip(gui, "you are one of " .. NEMESIS.nt_nemesis_team .. " team", "")
        else
            if (GuiImageButton(gui, next_id(), 20, 0, "", "data/ui_gfx/animal_icons/deer.png")) then
                dofile("mods/noita-nemesis-teams/files/joinAction.lua")
                join( "deer" )
            end
            GuiTooltip(gui, "Join deer team", "")
            if (GuiImageButton(gui, next_id(), 40, 0, "", "data/ui_gfx/animal_icons/duck.png")) then
                dofile("mods/noita-nemesis-teams/files/joinAction.lua")
                join( "duck" )
            end
            GuiTooltip(gui, "Join duck team", "")
            if (GuiImageButton(gui, next_id(), 60, 0, "", "data/ui_gfx/animal_icons/sheep.png")) then
                dofile("mods/noita-nemesis-teams/files/joinAction.lua")
                join( "sheep" )
            end
            GuiTooltip(gui, "Join sheep team", "")
            if (GuiImageButton(gui, next_id(), 80, 0, "", "data/ui_gfx/animal_icons/fungus.png")) then
                dofile("mods/noita-nemesis-teams/files/joinAction.lua")
                join( "fungus" )
            end
            GuiTooltip(gui, "Join fungus team", "")
        end

        if (GuiImageButton(gui, next_id(), 100, 0, "", "mods/noita-together/files/ui/buttons/keyboard.png")) then
            show_message = not show_message
            if (not show_message) then
                player_msg = ""
            end
        end
        GuiTooltip(gui, "leave a message here", "")

        if (GuiImageButton(gui, next_id(), 120, 0, "", "mods/noita-together/files/ui/buttons/" .. ghost_button)) then
            HideGhosts = not HideGhosts
            if (HideGhosts) then
                DespawnPlayerGhosts()
            else
                SpawnPlayerGhosts(PlayerList)
            end
        end
        GuiTooltip(gui, ghost_tooltip, "")

        if (GuiImageButton(gui, next_id(), 140, 0, "", "mods/noita-together/files/ui/buttons/" .. chat_button)) then
            HideChat = not HideChat
        end
        GuiTooltip(gui, chat_tooltip, "")

        if (GuiImageButton(gui, next_id(), 160, 0, "", "mods/noita-together/files/ui/buttons/player_list.png")) then
            show_player_list = not show_player_list
        end
        GuiTooltip(gui, "Player List", "")

        if (GuiImageButton(gui, next_id(), 180, 0, "", "mods/noita-together/files/ui/buttons/bank.png")) then
            show_send_gold = not show_send_gold
        end
        GuiTooltip(gui, "Send Gold", "")

        if (GuiImageButton(gui, next_id(), 203, 4, "", "data/items_gfx/emerald_tablet.png")) then
            show_game_stats = not show_game_stats
            GlobalsSetValue("NOITA_NEMESIS_TEAMS_SHOW_GAME_STATS", "0")
        end
        GuiTooltip(gui, "Game Stats", "")
        

        if (ModSettingGet("noita-nemesis-teams.NOITA_NEMESIS_TEAMS_MORE_TEAM_FEATURE")) then
            if (GuiImageButton(gui, next_id(), 220, 2, "", "data/ui_gfx/gun_actions/scattershot.png")) then
                show_teams_extension = not show_teams_extension
            end
            GuiTooltip(gui, "More teams feature", "")
    
            if (show_teams_extension) then
                if (NEMESIS~= nil and NEMESIS.nt_nemesis_team~=nil) then
                    if (GuiImageButton(gui, next_id(), 240, 2, "", "data/ui_gfx/gun_actions/nolla.png")) then
                        dofile("mods/noita-nemesis-teams/files/joinAction.lua")
                        join() --nil team to leave
                    end
                    GuiTooltip(gui, "Leave the team.", "")
                end
    
                if (ModSettingGet("noita-nemesis-teams.NOITA_NEMESIS_TEAMS_AUTOMATIC_TEAM_DIVISION")) then
                    if (NEMESIS~= nil and NEMESIS.nt_nemesis_team==nil) then
                        if (GuiImageButton(gui, next_id(), 260, 2, "", "data/ui_gfx/gun_actions/divide_2.png")) then
                            dofile("mods/noita-nemesis-teams/files/teamDivide.lua")
                            teamDivide( 2 )
                        end
                        GuiTooltip(gui, "2 teams", "")
                        if (GuiImageButton(gui, next_id(), 280, 2, "", "data/ui_gfx/gun_actions/divide_3.png")) then
                            dofile("mods/noita-nemesis-teams/files/teamDivide.lua")
                            teamDivide( 3 )
                        end
                        GuiTooltip(gui, "3 teams", "")
                        if (GuiImageButton(gui, next_id(), 300, 2, "", "data/ui_gfx/gun_actions/divide_4.png")) then
                            dofile("mods/noita-nemesis-teams/files/teamDivide.lua")
                            teamDivide( 4 )
                        end
                        GuiTooltip(gui, "4 teams", "")
                    end
                end
            end
        end

        if (show_game_stats or GlobalsGetValue("NOITA_NEMESIS_TEAMS_SHOW_GAME_STATS")=="1") then
            if (not last_inven_is_open) then
                draw_game_stats()
            end
        end

        if (show_message) then
            draw_player_message()
        end

        if (show_player_list) then
            if (not last_inven_is_open) then
                draw_player_list(PlayerList)
            end
        end

        if (show_bank) then
            draw_item_bank()
            if(GameHasFlagRun("send_gold")) then
                draw_gold_bank()
            end
        end
        
        if (show_emote_select) then
            if (not last_inven_is_open) then
                draw_emote_select()
            end
        end

        local seed = ModSettingGet( "noita_together.seed" )
        local current_seed = tonumber(StatsGetValue("world_seed"))
        if (current_seed ~= seed and seed > 0) then
            GuiImageNinePiece(gui, next_id(), (screen_width / 2) - 90, 50, 180, 20, 0.8)
            GuiText(gui, (screen_width / 2) - 80, 55, "Host changed world seed, start a new game")
        end

        if (selected_player and PlayerList[selected_player] ~= nil) then
            GuiImageNinePiece(gui, next_id(), 5, 210, 90, 80, 0.5)
            if (GuiButton(gui, next_id(), 5, 210, "[x]")) then
                selected_player = ""
            end
            GuiText(gui, 5, 215, PlayerList[selected_player].name)
        end

        if (PlayerRadar) then
            local ghosts = EntityGetWithTag("nt_follow") or {}
            local ppos_x, ppos_y = GetPlayerOrCameraPos()
            local pos_x, pos_y = screen_width / 2, screen_height /2
            for _, ghost in ipairs(ghosts) do
                local var_comp = get_variable_storage_component(ghost, "userId")
                local user_id = ComponentGetValue2(var_comp, "value_string")
                local gx, gy = EntityGetTransform(ghost)
                local dir_x = (gx or 0) - ppos_x
                local dir_y = (gy or 0) - ppos_y
                local dist = math.sqrt(dir_x * dir_x + dir_y * dir_y)
                if (math.abs(dir_x) > 250 or math.abs(dir_y) > 150) then
                    dir_x,dir_y = vec_normalize(dir_x,dir_y)
                    local indicator_x = math.max(30, (pos_x - 30) + dir_x * 300)
                    local indicator_y = pos_y + dir_y * 170
                    GuiImage(gui, next_id(), indicator_x, indicator_y, "mods/noita-together/files/ui/player_ghost.png", 1, 1, 1)
                    GuiTooltip(gui, (PlayerList[user_id].name or ""), string.format("%.0fm", math.floor(dist/10)))
                end
            end
        end

        fogOfWar()

        if (spectate > 0 and NEMESIS.alive == false) then
            local x, y = EntityGetTransform(spectate)
            if (y ~= nil) then
                local player = GetPlayer()
                if (player ~= nil) then
                    --imagine using GameSetCameraPos
                    EntitySetTransform(player, x,y )
                end
            end
        end

        if (#wand_displayer > 0) then
            local wand_offset = 0
            local wand_offset_y = 0
            for _, item in ipairs(wand_displayer) do
                local nx, ny = (screen_width / 4) + 30 + wand_offset, (screen_height/2) - 160
                render_wand(item, x, y, nx, ny + wand_offset_y, false, true) 
                wand_offset = wand_offset + 165
                if (_ % 2 == 0) then 
                    wand_offset = 0
                    wand_offset_y = 165
                 end
            end
            wand_displayer = {}
        end

        GuiIdPop(gui)
    end
end

draw_gui()