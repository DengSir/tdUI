-- alaTradeSkill.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2026/6/7 16:57:26
--
---@type ns
local ns = select(2, ...)

ns.addon('alaTradeSkill', function()
    ns.event('MODIFIER_STATE_CHANGED', function(key, flag)
        if key == 'LALT' or key == 'RALT' then
            local enabled = flag == 1
            local set = alaTradeSkillSV and alaTradeSkillSV.set

            if set then
                set.show_tradeskill_frame_price_info = enabled
                set.show_tradeskill_frame_rank_info = enabled
                set.show_tradeskill_tip_craft_item_price = enabled
                set.show_tradeskill_tip_craft_spell_price = enabled
                set.show_tradeskill_tip_material_craft_info = enabled
                set.show_tradeskill_tip_recipe_account_learned = enabled
                set.show_tradeskill_tip_recipe_price = enabled
            end
        end
    end)
end)
