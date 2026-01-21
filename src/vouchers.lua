SMODS.Atlas {
    key = "jonkler_vouchers",
    path = "jonkler_vouchers.png",
    px = 71,
    py = 95
}

-- Amplify Voucher
-- Makes Enhancements stronger (Do Purify next)
SMODS.Voucher {
    key = "amplify",
    pos = { x = 0, y = 0 },
}

SMODS.Enhancement:take_ownership('stone', {
    config = { bonus = 50, h_Xchips = 1.5 },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.bonus, self.config.h_Xchips } }
    end,
    loc_txt = {
        name = "Stone Card",
        text = {
            "{C:blue}+#1#{} chips",
            "no rank or suit",
            "gives {C:white,X:blue}X#2# chips",
            "while held in hand"
            }
        },
    }
)