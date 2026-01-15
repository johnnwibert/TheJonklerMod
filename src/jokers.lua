-- Atlas is 6 jokers wide (index 0-5)
SMODS.Atlas {
    key = "thejonklermod",
    path = "thejonklermod.png",
    px = 71,
    py = 95
}

-- Evil Joker
-- Useless joker. I'll give him something to do one day, but he
-- was initially created as a joke/test. The first joker I made.
SMODS.Joker {
    key = "evil_joker",
    rarity = 1,
    atlas = 'thejonklermod',
    pos = { x = 0, y = 0 },
    blueprint_compat = true,
    cost = 1,
    discovered = true,
    config = {extra = { mult = -20}, },
    loc_txt = {
        name = "Evil Joker",
        text = {
            "Does some",
            "{C:mult,s:1.2}Evil{} stuff",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                message = 'Evil!'
            }
        end
    end
}

-- Illusion Joker
-- Loosely inspired by Gob from Arrested Development. Turns one
-- scoring card into a lucky card, then destroys a random card held in hand.
SMODS.Joker {
    key = "illusion_joker",
    rarity = 2,
    atlas = 'thejonklermod',
    pos = { x = 1, y = 0 },
    blueprint_compat = false,
    cost = 7,
    discovered = true,
    loc_txt = {
        name = "Master of Illusions",
        text = {
            "On {C:attention}first hand of round{}, turns a random",
            "{C:attention}scoring card{} into a {C:attention}Lucky Card{}, then",
            "destroys a random card held in hand",
        },
    },
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.before and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            local scored_card = pseudorandom_element(context.scoring_hand, 'Gobker')
            if scored_card then
                scored_card:set_ability('m_lucky', nil, true)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        scored_card:juice_up()
                        return true
                    end
                }))
                return {
                    message = 'Magic!'
                }
            end
        end
        if context.joker_main and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            local card_to_destroy = pseudorandom_element(G.hand.cards, 'random_destroy')
            SMODS.destroy_cards(card_to_destroy)
            return {
                message = 'Disappear!'
            }
        end
    end
}

-- Is This Your Card?
-- Mimics Idol's card selecting and scoring behavior. 
-- Each score of the selected card gives money equal to card.ability.extra.dollars.
-- Currently only works for the first hand of each round. Subject to change.
SMODS.Joker {
    key = "your_card",
    rarity = 1,
    atlas = 'thejonklermod',
    pos = { x = 2, y = 0 },
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    loc_txt = {
        name = "Is This Your Card?",
        text = {
            "On {C:attention}first hand of round{},",
            "each played {C:attention}#2#{} of {V:1}#3#{} ",
            "gives {C:money}$#1#{} when scored",
            "{s:0.8}Card changes every round"
            },
    },
    config = { extra = { dollars = 5 } },
    loc_vars = function(self, info_queue, card)
        local money_card = G.GAME.current_round.money_card or { rank = 'Ace', suit = 'Spades' }
        return {
            vars = { card.ability.extra.dollars, localize(money_card.rank, 'ranks'), localize(money_card.suit, 'suits_plural'), colours = { G.C.SUITS[money_card.suit] } }
        }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.individual and context.cardarea == G.play and 
            context.other_card:get_id() == G.GAME.current_round.money_card.id and
            context.other_card:is_suit(G.GAME.current_round.money_card.suit) and
            G.GAME.current_round.hands_played == 0 then
                return {
                    dollars = card.ability.extra.dollars
                }
            end
        end
}

-- Heroic Sacrifice
-- Terminator reference. When sold, it picks a random disabled and/or
-- perishable joker and re-enables it (and removes the perishable sticker if applicable).
-- One of my favorite jokers conceptually. Niche but impactful in high stake endless runs.
SMODS.Joker {
    key = "heroic_sacrifice",
    rarity = 2,
    atlas = 'thejonklermod',
    pos = { x = 3, y = 0 },
    blueprint_compat = false,
    eternal_compat = false,
    cost = 6,
    discovered = true,
    loc_txt = {
        name = "Heroic Sacrifice",
        text = {
            "When sold, re-enables a",
            "random {C:attention}disabled{} joker",
            "{s:0.8}If applicable, removes Perishable sticker"
        },
    },
    calculate = function(self, card, context)
        if context.selling_self then
            local valid_jokers = {}
            for k, v in pairs(G.jokers.cards) do
                if v ~= card and v.ability.perishable or v.debuff then
                    table.insert(valid_jokers, v)
                end
            end
            local joker_to_save = pseudorandom_element(valid_jokers, 'heroic_sacrifice')

            if joker_to_save then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        joker_to_save:juice_up(0.8, 0.8)
                        card:start_dissolve({ G.C.RED }, nil, 2.5)
                        return true
                    end
                }))
                joker_to_save.ability.perishable = nil
                joker_to_save.debuff = nil
                return {
                    message = "I'll be back!", extra = { message = "Thanks!", message_card = joker_to_save }
                }
            end
        end
    end
}

-- Transmutation Joker
-- Very odd one. Turns played gold and steel cards into "geel" cards.
-- Geel cards act as both gold and steel cards, although they currently do NOT work with
-- jokers like Golden Ticket or Steel Joker (subject to change). Fantastic in Baron/Mime runs.
SMODS.Joker {
    key = "transmutation_joker",
    rarity = 3,
    atlas = 'thejonklermod',
    pos = { x = 4, y = 0 },
    config = { max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_jonkler_geel
        return { vars = { card.ability.max_highlighted } }
    end,
    blueprint_compat = false,
    cost = 8,
    discovered = true,
    loc_txt = {
        name = "Transmutation Joker",
        text = {
            "Scored {C:attention}Steel Cards{} and",
            "{C:attention}Gold Cards{}become {C:attention}Geel Cards",
        },
    },
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local triggers = 0
            for _, scored_card in ipairs(context.scoring_hand) do
                if not scored_card.debuff and (SMODS.has_enhancement(scored_card, 'm_steel') or SMODS.has_enhancement(scored_card, 'm_gold')) then
                    triggers = triggers + 1
                    scored_card:set_ability('m_jonkler_geel', nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            return true
                        end
                    }))
                end
            end
            if triggers > 0 then
                return {
                    message = "Geeled!"
                }
            end
        end
    end
}

-- Piggy Bank
-- Genuinely more evil than the evil joker. Gains sell value every reroll,
-- with a chance to break on every roll.  Will break when you need it most.
SMODS.Joker {
    key = "piggy_bank",
    rarity = 1,
    atlas = 'thejonklermod',
    pos = { x = 5, y = 0 },
    blueprint_compat = false,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    loc_txt = {
        name = "Piggy Bank",
        text = {
            "Gains {C:money}$#1#{} of {C:attention}sell value{}",
            "per reroll in the shop. {C:green}#2# in #3#{} chance",
            "to break per reroll in the shop."
        },
    },
    config = { extra = { price = 2, odds = 20 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.price, (G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'piggy_bank', 1, card.ability.extra.odds) then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = "Whoops!",
                    play_sound('glass2')
                }
            else
                card.ability.extra_value = card.ability.extra_value + card.ability.extra.price
                card:set_cost()
                return {
                    message = "Invested!"
                }
            end
        end
        if context.selling_self or context.getting_sliced then
            return {
                message = "Smashed!",
                play_sound('glass2')
            }
        end
    end
}

-- Scrapbook Joker
-- Gains times mult per voucher redeemed. It does not consider vouchers purchased
-- before you got the joker (scales like Constellation or Hologram).
SMODS.Joker {
    key = "scrapbook",
    rarity = 2,
    atlas = "thejonklermod",
    pos = { x = 0, y = 1 },
    blueprint_compat = true,
    perishable_compat = false,
    cost = 7,
    discovered = true,
    loc_txt = {
        name = "Scrapbook Joker",
        text = {
            "Gains {C:white,X:red}X#1#{} Mult per",
            "{C:attention}Voucher{} redeemed in the shop",
            "{C:inactive}(Currently {}{C:white,X:red}X#2# {C:inactive} Mult)"
        },
    },
    config = { extra = { Xmult_mod = 0.75, Xmult = 1.0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.buying_card and context.card.ability.set == 'Voucher' and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
            return {
                message = "Upgraded!"
            }
        end
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

-- Here Comes...
-- Beatles reference. Gains times mult per Sun Tarot used.
-- Generally sucks and is way too common. Needs to be reworked, or maybe just made uncommon and stronger.
SMODS.Joker {
    key = "here_comes",
    rarity = 1,
    atlas = "thejonklermod",
    pos = { x = 1, y = 1 },
    blueprint_compat = true,
    perishable_compat = false,
    cost = 6,
    discovered = true,
    loc_txt = {
        name = "Here Comes...",
        text = {
            "Gains {C:white,X:red}X#1#{} Mult per",
            "{C:attention}Sun Tarot{} used",
            "{C:inactive}(Currently {}{C:white,X:red}X#2# {C:inactive} Mult)"
        },
    },
    config = { extra = { Xmult_mod = 0.25, Xmult = 1.0, max_highlighted = 1 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sun
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult, card.ability.max_highlighted } }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.config.center.key == "c_sun" then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
            return {
                message = "Doo-doo-doo-doo!"
            }
        end
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

-- One Man's Trash
-- Gives a spectral card if the final discard of the round contains 5 of a chosen suit.
-- Picks the suit like Ancient Joker. (Likely) Easier to use than Seance, but less farmable.
SMODS.Joker {
    key = "trash_joker",
    rarity = 2,
    atlas = "thejonklermod",
    pos = { x = 2, y = 1 },
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    loc_txt = {
        name = "One Man's Trash",
        text = {
            "Gives a {C:spectral}Spectral{} card if",
            "{C:attention}final discard{} of round contains",
            "{C:attention}#2#{} {V:1}#1#{} cards",
            "{s:0.8}Suit changes every round{}"
        },
    },
    config = { extra = { discards = 5, juice_check = false } },
    loc_vars = function(self, info_queue, card)
        local suit = G.GAME.current_round.trash_suit or 'Spades'
        return { vars = { localize(suit, 'suits_singular'), colours = { G.C.SUITS[suit] }, card.ability.extra.discards, card.ability.extra.juice_check } }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            card.ability.extra.juice_check = true
        end
        if G.GAME.blind.in_blind and G.GAME.current_round.discards_left == 1 and card.ability.extra.juice_check == true then
            local eval = function() return G.GAME.current_round.discards_left > 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            card.ability.extra.juice_check = false
        end
        if context.pre_discard and #context.full_hand == 5 and G.GAME.current_round.discards_left == 1 then
            local suit_cards = 0
            for _, discarded_card in ipairs(context.full_hand) do
                if discarded_card:is_suit(G.GAME.current_round.trash_suit) then suit_cards = suit_cards + 1 end
            end
            if suit_cards >= card.ability.extra.discards then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            SMODS.add_card {
                                set = 'Spectral'
                            }
                            G.GAME.consumeable_buffer = 0
                            return true
                    end)
                }))
                return {
                    message = "Treasure!"
                }
            end
        end
    end
end
}

-- Blind Box
-- Gives a random tag after beating a Boss Blind. Unlikely to make a major impact,
-- but (I believe) tags are never negative (wink) so it's an easy take. Originally intended
-- to help with finding voucher skips on endless runs, but its antisynergy with Diet Cola
-- makes it unreliable for that purpose. Still potentially good as an early utility joker.
SMODS.Joker {
    key = "blind_box",
    rarity = 1,
    atlas = "thejonklermod",
    pos = { x = 3, y = 1 },
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    loc_txt = {
        name = "Blind Box",
        text = {
            "Gives a random {C:attention}Tag{}",
            "after beating a {C:attention}Boss Blind{}"
        },
    },
    calculate = function(self, card, context)
        if context.ante_change and context.ante_end then
            G.E_MANAGER:add_event(Event({
                func = (function()
                local tag_pool = get_current_pool('Tag')
                local selected_tag = pseudorandom_element(tag_pool, 'jonkler_seed')
                local it = 1
                while selected_tag == 'UNAVAILABLE' or selected_tag == 'tag_orbital' do -- orbital tag crashes the game, fix later
                    it = it + 1
                    selected_tag = pseudorandom_element(tag_pool, 'jonkler_seed_resample'..it)
                end
                add_tag(Tag(selected_tag, false, 'Small'))
                play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                return true
                end)
            }))
            return {
                message = "Unboxing!"
            }
        end
    end
}

-- The Lamb
-- A sacrificial lamb. Most of the time, it's impact is very insignificant
-- considering its cost and rarity. If you're blessed, it becomes essentially the only
-- consequence-free way to make one of your jokers negative. Invaluable, if you're lucky.
SMODS.Joker {
    key = "lamb",
    rarity = 3,
    atlas = "thejonklermod",
    pos = { x = 4, y = 1 },
    blueprint_compat = false,
    eternal_compat = false,
    cost = 8,
    discovered = true,
    loc_txt = {
        name = "The Lamb",
        text = {
            "{C:red}Dies{} upon beating a {C:attention}Boss Blind{}",
            "Gives {C:money}$#3#{} upon {C:red}Death{} and has",
            "a {C:green}#1# in #2#{} chance to make a",
            "random {C:attention}Joker {}{C:spectral}Negative{}"
        }
    },
    config = { extra = { odds = 4, dollars = 20 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if context.ante_change and context.ante_end then
            SMODS.destroy_cards(card, nil, nil, true)
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            if SMODS.pseudorandom_probability(card, 'lamb', 1, card.ability.extra.odds) then
                local valid_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
                local valid_jokers_minus_lamb = {}
                for k, v in pairs(G.jokers.cards) do
                    if v ~= card then
                        table.insert(valid_jokers_minus_lamb, v)
                    end
                end
                local chosen_joker = pseudorandom_element(valid_jokers_minus_lamb, 'lamb')
                if chosen_joker then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            chosen_joker:juice_up()
                            return true
                        end
                    }))
                chosen_joker:set_edition({ negative = true })
                return {
                    remove_default_message = true,
                    dollars = card.ability.extra.dollars,
                    message = "Sacrificed!", extra = { message = "Blessed!", message_card = chosen_joker },
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                card:start_dissolve({ HEX("57ecab") }, nil, 1.6)
                                play_sound('slice1', 0.96 + math.random() * 0.08)
                                return true
                            end
                        }))
                    end
                }
                end
            else
            return {
                remove_default_message = true,
                dollars = card.ability.extra.dollars,
                message = "Sacrificed!",
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            card:start_dissolve({ HEX("57ecab") }, nil, 1.6)
                            play_sound('slice1', 0.96 + math.random() * 0.08)
                            return true
                        end
                    }))
                end
            }
            end         -- Possibly strange ordering on messages, also need to stop it from displaying $20 text if possible
        end
    end
}

-- Ceremonial Dagger is designed in a way that negates any activity from the Joker it is deleting.
-- Therefore, we take ownership of Ceremonial Dagger to include an exception for The Lamb.
SMODS.Joker:take_ownership('ceremonial',
    {
        calculate = function(self, card, context)
            if context.setting_blind and not context.blueprint then
                local my_pos = nil
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then
                        my_pos = i
                        break
                    end
                end
                local lamb_check = G.jokers.cards[my_pos + 1]
                if lamb_check then
                end
                if lamb_check and lamb_check.config.center.key == "j_jonkler_lamb" then
                    lamb_check.sell_cost = lamb_check.sell_cost + 10
                    if not card.edition then
                        card:set_edition('e_polychrome', true)
                    end
                    G.E_MANAGER:add_event(Event({
                    func = function()
                        if G.jokers then
                            G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                        end
                        return true
                    end,
                }))
                lamb_check.getting_sliced = true
                G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.joker_buffer = 0
                        card:juice_up(0.8, 0.8)
                        lamb_check:start_dissolve({ HEX("57ecab") }, nil, 1.6)
                        play_sound('slice1', 0.96 + math.random() * 0.08)
                        return true
                    end
                }))
                return { message = "SACRIFICE!", extra = { message = "+1 Joker Slot!", message_card = lamb_check} }
                end
            end
        end
    },
    true
)

-- Stargazing Joker
-- Makes planets that come from blue seals negative. Even if your consumeable slots are full,
-- it will create the planets. This is good for making use of large amounts of blue seals at once,
-- but the main application is its synergy with the Observatory voucher. Utilizes a hook on create_card.
SMODS.Joker {
    key = "stargazing_joker",
    rarity = 3,
    atlas = "thejonklermod",    -- No art yet
    pos = { x = 5, y = 1 },
    blueprint_compat = false,
    cost = 8,
    discovered = true,
    loc_txt = {
        name = "Stargazing Joker",
        text = {
            "Turns {C:planet}Planet{} cards created",
            "from {C:planet}Blue{} {C:attention}seals{} {C:spectral}Negative{}"
        }
    },
    config = { extra = { check = false } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.check } }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            card.ability.extra.check = false
        end
        if not context.blueprint and context.end_of_round and context.individual and context.cardarea == G.hand and not card.ability.extra.check then
            card.ability.extra.check = true
            for k, v in ipairs(G.hand.cards) do
                if v.seal == 'Blue' then    -- This allows us to TEMPORARILY bypass the consumeable limit
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                end                         -- Otherwise, you will only get as many negative planets as there are consumeable slots
            end                             -- Gets reset by the create_card hook, may be moved here later
        end
    end
}


-- Stargazing Joker hook, forces planets from blue seals to be negative
local create_card_ref = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    local card = create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if next(SMODS.find_card("j_jonkler_stargazing_joker")) and key_append == "blusl" then
        card:set_edition('e_negative', true)
        G.GAME.consumeable_buffer = 0
    end
    return card
end

-- Picks a card for "Is This Your Card?" joker at the start of each round
local function reset_money_card()
    G.GAME.current_round.money_card = { rank = 'Ace', suit = 'Spades' }
    local valid_money_cards = {}
    for _, playing_card in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(playing_card) and not SMODS.has_no_rank(playing_card) then
            valid_money_cards[#valid_money_cards + 1] = playing_card
        end
    end
    local money_card = pseudorandom_element(valid_money_cards, 'your_card' .. G.GAME.round_resets.ante)
    if money_card then
        G.GAME.current_round.money_card.rank = money_card.base.value
        G.GAME.current_round.money_card.suit = money_card.base.suit
        G.GAME.current_round.money_card.id = money_card.base.id
    end
end

-- Picks a suit for "One Man's Trash" joker at the start of each round
local function reset_trash_suit()
    G.GAME.current_round.trash_suit = G.GAME.current_round.trash_suit or 'Spades'
    local suits = {}
    for k, v in ipairs({ 'Spades', 'Hearts', 'Clubs', 'Diamonds' }) do
        if v ~= G.GAME.current_round.trash_suit then suits[#suits+1] = v end
    end
    local trash_suit = pseudorandom_element(suits, 'trash' .. G.GAME.round_resets.ante)
    G.GAME.current_round.trash_suit = trash_suit
end

-- Resets MODDED game globals for each run
function SMODS.current_mod.reset_game_globals(run_start)
    reset_money_card()
    reset_trash_suit()
end
