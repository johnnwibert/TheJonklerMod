SMODS.Atlas {
    key = "jonkler_seals",
    path = "jonkler_seals.png",
    px = 71,
    py = 95
}

-- Navy Seal
-- Gives a Spectral Card when destroyed.
SMODS.Seal {
    key = 'navy',
    atlas = "jonkler_seals",
    pos = { x = 0, y = 0 },
    badge_colour = HEX("00007a"),
    loc_txt = {
        label = "Navy Seal",
        name = "Navy Seal",
        text = {
            "Gives a {C:spectral}Spectral{} card",
            "when {C:attention}destroyed{}",
            "{C:inactive}(Must have room)"
        }
    },
    calculate = function(self, card, context)
        if context.remove_playing_cards then
            for k, v in ipairs(context.removed) do
                if v == card then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = (function()
                            SMODS.add_card {
                                set = 'Spectral',
                                key_append = 'navsl'    -- Vanilla naming convention (blusl)
                            }
                            G.GAME.consumeable_buffer = 0
                            return true
                        end)
                    }))
                    return {
                        message = "+1 Spectral", colour = HEX("00007a")
                    }
                    end
                end
            end
        end
    end
}