SMODS.Back {
    key = 'mutated',
    pos = { x = 5, y = 2 },
    unlocked = true,
    config = { vouchers = { 'v_jonkler_amplify', 'v_jonkler_mutate' } },
    loc_txt = {
        name = "Mutated Deck",
        text = {
            "Start run with",
            "{C:attention,T:v_jonkler_amplify}#1#{} and {C:attention,T:v_jonkler_mutate}#2#{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = { localize { type = 'name_text', key = self.config.vouchers[1], set = 'Voucher' },
                localize { type = 'name_text', key = self.config.vouchers[2], set = 'Voucher' }
            }
        }
    end,
}