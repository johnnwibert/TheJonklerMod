SMODS.Atlas {
    key = "jonkler_enhancements",
    path = "jonkler_enhancements.png",
    px = 71,
    py = 95
}

-- Amplify Voucher
-- Makes Enhancements stronger (Do Purify next)
SMODS.Voucher {
    key = "amplify",        -- xchips in hand is working, but even when voucher isn't purchased (fix)
    pos = { x = 0, y = 0 },
    discovered = true,
    config = { h_x_chips = 1.5 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.h_x_chips } }
    end,
    loc_txt = {
        name = "Amplify",
        text = {
            "Just affects stones rn lmao"
        }
    },
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and SMODS.has_enhancement(context.other_card, 'm_stone') then
            print("m_stone detected")
            return {
                xchips = card.ability.h_x_chips,
                message_card = context.other_card
            }
        end
    end
}

SMODS.Enhancement:take_ownership('stone', {
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    config = { bonus = 50, extra = { h_Xchips = 1.5 } },
    loc_vars = function(self, info_queue, card)
        local key = 'm_stone'
        if G.GAME.used_vouchers['v_jonkler_amplify'] then
            key = 'm_jonkler_stone_upgrade'
        end
        return { key = key, vars = { card.ability.bonus, card.ability.extra.h_Xchips } }
    end,
}
)

-- SMODS.Enhancement:take_ownership('mult', {


-- })