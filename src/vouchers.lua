SMODS.Atlas {
    key = "jonkler_enhancements",
    path = "jonkler_enhancements.png",
    px = 71,
    py = 95
}

-- Amplify Voucher
-- Makes Enhancements stronger (Do Purify next)
SMODS.Voucher {
    key = "amplify",
    pos = { x = 0, y = 0 },
    discovered = true,
    loc_txt = {
        name = "Amplify",
        text = {
            "Just affects stones rn lmao"
        }
    },
}

SMODS.Enhancement:take_ownership('stone', {
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    config = { bonus = 50, h_Xchips = 1.5 },
    loc_vars = function(self, info_queue, card)
        local key = 'm_stone'
        if G.GAME.used_vouchers['v_jonkler_amplify'] then
            key = 'm_jonkler_stone_upgrade'
        end
        return { key = key, vars = { self.config.bonus, self.config.h_Xchips } }
    end,
}
)