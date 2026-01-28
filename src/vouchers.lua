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
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.h_x_chips } }
    end,
}

SMODS.Voucher {
    key = "mutate",
    pos = { x = 1, y = 0 },
    discovered = true,
    requires = { 'v_jonkler_amplify' },
    config = { h_x_chips = 1.5 },
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and SMODS.has_enhancement(context.other_card, 'm_stone') then
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
        if G.GAME.used_vouchers['v_jonkler_mutate'] then
            key = 'm_jonkler_stone_upgrade'
        end
        return { key = key, vars = { card.ability.bonus, card.ability.extra.h_Xchips } }
    end,
})

SMODS.Enhancement:take_ownership('mult', {
    config = { mult = 4 },
    loc_vars = function(self, info_queue, card)
        if G.GAME.used_vouchers['v_jonkler_amplify'] then
            card.ability.mult = 8
        end
        return { vars = { card.ability.mult } }
    end,
})

SMODS.Enhancement:take_ownership('glass', {
    config = { Xmult = 2, extra = { odds = 4, money = 5 } },
    loc_vars = function(self, info_queue, card)
        local key = 'm_glass'
        if G.GAME.used_vouchers['v_jonkler_mutate'] then
            key = 'm_jonkler_glass_upgrade'
        end
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'jonkler_glass')
        return { key = key, vars = { card.ability.Xmult, numerator, denominator, card.ability.extra.money } }
    end,
    calculate = function(self, card, context)
        if G.GAME.used_vouchers['v_jonkler_mutate'] and context.destroy_card and context.cardarea == G.play and context.destroy_card == card and
            SMODS.pseudorandom_probability(card, 'jonkler_glass', 1, card.ability.extra.odds) then
            card.glass_trigger = true
            return { remove = true, vars = { card.ability.extra.money } }
        end
        if context.destroy_card and context.cardarea == G.play and context.destroy_card == card and SMODS.pseudorandom_probability(card, 'jonkler_glass', 1, card.ability.extra.odds) then
            card.glass_trigger = true
            return { remove = true }
        end
    end,
})

SMODS.Enhancement:take_ownership('steel', {
    config = { h_x_mult = 1.5, extra = { Xmult = 1.25 } },
    loc_vars = function(self, info_queue, card)
        local key = 'm_steel'
        if G.GAME.used_vouchers['v_jonkler_mutate'] then
            key = 'm_jonkler_steel_upgrade'
        end
        return { key = key, vars = { card.ability.h_x_mult, card.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if G.GAME.used_vouchers['v_jonkler_mutate'] and context.individual and context.cardarea == G.play then
            return {
                Xmult = card.ability.extra.Xmult,
                message_card = card
            }
        end
    end,
})

SMODS.Enhancement:take_ownership('gold', {
    config = { h_dollars = 3, extra = { dollars = 1 } },
    loc_vars = function(self, info_queue, card)
        local key = 'm_gold'
        if G.GAME.used_vouchers['v_jonkler_mutate'] then
            key = 'm_jonkler_gold_upgrade'
        end
        return { key = key, vars = { card.ability.h_dollars, card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if G.GAME.used_vouchers['v_jonkler_mutate'] and context.individual and context.cardarea == G.hand and not context.end_of_round then
            if SMODS.has_enhancement(context.other_card, 'm_gold') then
                if context.other_card.debuff then
                    return {
                        message = "Debuffed!", colour = G.C.RED
                    }
                else
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                    return {
                        dollars = card.ability.extra.dollars,
                        message_card = context.other_card,
                        func = function()
                            G.E_MANAGER:add_event(Event({
                                    func = function()
                                        G.GAME.dollar_buffer = 0
                                        return true
                                end
                            }))
                        end
                    }
                end
            end
        end
    end
})