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
    pos = { x = 0, y = 0 }, -- Placeholder Art
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

SMODS.Spectral {
    key = "enchant",
    discovered = true,
    pos = { x = 1, y = 0 }, -- No Art Yet
    atlas = "jonkler_spectrals",
    loc_txt = {
        label = "Enchant",
        name = "Enchant",
        text = {
            "Enhances #1# selected card",
            "into a {C:attention}Geel Card{}"
        }
    },
    config = { max_highlighted = 1, mod_conv = 'm_jonkler_geel' },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_jonkler_geel
        return { vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability(card.ability.mod_conv)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted
    end
}