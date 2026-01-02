SMODS.Atlas {
    key = "jonkler_spectrals",
    path = "jonkler_spectrals.png",
    px = 71,
    py = 95
}

loc_colour()
G.ARGS.LOC_COLOURS.jonkler_navy = HEX("00007a")

SMODS.Spectral {
    key = 'offering',
    discovered = true,
    pos = { x = 0, y = 0 },
    atlas = "jonkler_spectrals",
    loc_txt = {
        label = "Offering",
        name = "Offering",
        text = {
            "Adds a {C:jonkler_navy}Navy Seal{}",
            "to up to {C:attention}#1#{} selected",
            "cards in your hand"
        }
    },
    config = { extra = { seal = 'jonkler_navy' }, max_highlighted = 2 },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        return { vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        for i = 1, #G.hand.highlighted do
            local conv_card = G.hand.highlighted[i]
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    conv_card:set_seal(card.ability.extra.seal, nil, true)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    G.hand:unhighlight_all()
                    return true
                end
            }))
        end
    end,
}
