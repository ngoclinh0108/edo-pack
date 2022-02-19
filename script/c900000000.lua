-- Millennium Hieroglyph
Duel.LoadScript("util.lua")
local s, id = GetID()

s.mode = {destiny_draw = 0, set_field = 1}

function s.initial_effect(c)
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    startup:SetRange(LOCATION_ALL)
    startup:SetCode(EVENT_STARTUP)
    startup:SetOperation(s.startup)
    c:RegisterEffect(startup)
end

function s.startup(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    -- remove from duel
    Duel.DisableShuffleCheck(true)
    Duel.SendtoDeck(c, tp, -2, REASON_RULE)
    if c:IsPreviousLocation(LOCATION_HAND) and
        Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 then
        Duel.Draw(p, 1, REASON_RULE)
    end
    e:Reset()

    -- deck edit & global effect
    local g = Duel.GetMatchingGroup(function(c)
        return c.deck_edit or c.global_effect
    end, tp, LOCATION_ALL, 0, nil)
    local deck_edit = Group.CreateGroup()
    local global_effect = Group.CreateGroup()
    for tc in aux.Next(g) do
        if tc.deck_edit and not deck_edit:IsExists(function(c)
            return c:GetOriginalCode() == tc:GetOriginalCode()
        end, 1, nil) then
            tc.deck_edit(tp)
            deck_edit:AddCard(tc)
        end
    end
    for tc in aux.Next(g) do
        if tc.global_effect and not global_effect:IsExists(function(c)
            return c:GetOriginalCode() == tc:GetOriginalCode()
        end, 1, nil) then
            tc.global_effect(tc, tp)
            global_effect:AddCard(tc)
        end
    end

    -- set dice & coin result
    local dice = Effect.CreateEffect(c)
    dice:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    dice:SetCode(EVENT_TOSS_DICE_NEGATE)
    dice:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return rp == tp end)
    dice:SetOperation(s.diceop)
    Duel.RegisterEffect(dice, tp)
    local coin = dice:Clone()
    coin:SetCode(EVENT_TOSS_COIN_NEGATE)
    coin:SetOperation(s.coinop)
    Duel.RegisterEffect(coin, tp)

    -- mulligan
    local mulligan = Effect.CreateEffect(c)
    mulligan:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    mulligan:SetCode(EVENT_ADJUST)
    mulligan:SetCountLimit(1)
    mulligan:SetCondition(function(e, tp)
        return
            Duel.GetCurrentPhase() == PHASE_DRAW and Duel.GetTurnCount() == 1 and
                Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) > 0 and
                Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0
    end)
    mulligan:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not Duel.SelectYesNo(tp, 507) then return end
        local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_HAND, 0, 1,
                                          Duel.GetFieldGroupCount(tp,
                                                                  LOCATION_HAND,
                                                                  0), nil)
        local ct = Duel.SendtoDeck(g, nil, SEQ_DECKBOTTOM, REASON_RULE)
        Duel.Draw(tp, ct, REASON_RULE)
        Duel.ShuffleDeck(tp)
    end)
    Duel.RegisterEffect(mulligan, tp)

    -- mode toggle
    local toggle = Effect.CreateEffect(c)
    toggle:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    toggle:SetCode(EVENT_FREE_CHAIN)
    toggle:SetCondition(function()
        local ph = Duel.GetCurrentPhase()
        return not (ph >= PHASE_BATTLE_START and ph < PHASE_BATTLE)
    end)
    toggle:SetOperation(s.toggleop)
    Duel.RegisterEffect(toggle, tp)

    -- activate field
    local field = Effect.CreateEffect(c)
    field:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    field:SetCode(EVENT_ADJUST)
    field:SetCountLimit(1)
    field:SetCondition(function(e, tp)
        return s.mode["set_field"] == 1 and Duel.IsTurnPlayer(tp) and
                   Duel.GetCurrentPhase() == PHASE_DRAW
    end)
    field:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local g = Duel.GetMatchingGroup(function(c)
            return c:IsType(TYPE_FIELD) and
                       Utility.CheckActivateEffectCanApply(c, e, tp, false,
                                                           true, false)
        end, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE +
                                            LOCATION_REMOVED, 0, nil)
        if #g == 0 then return end
        if Duel.GetTurnCount() > 2 and not Duel.SelectYesNo(tp, 2204) then
            return
        end

        local sc = Utility.GroupSelect(HINTMSG_TOFIELD, g, tp):GetFirst()
        aux.PlayFieldSpell(sc, e, tp, eg, ep, ev, re, r, rp)
        Utility.ApplyActivateEffect(sc, e, tp, false, true, false)

        if sc:IsPreviousLocation(LOCATION_HAND) and Duel.GetTurnCount() <= 2 and
            Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 then
            Duel.Draw(tp, 1, REASON_RULE)
        end
    end)
    Duel.RegisterEffect(field, tp)

    -- destiny draw
    local ddraw = Effect.CreateEffect(c)
    ddraw:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ddraw:SetCode(EVENT_PREDRAW)
    ddraw:SetCountLimit(1)
    ddraw:SetCondition(function(e, tp)
        return s.mode["destiny_draw"] == 1 and Duel.IsTurnPlayer(tp) and
                   Duel.GetTurnCount() > 1 and
                   Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 1 and
                   Duel.GetDrawCount(tp) > 0
    end)
    ddraw:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then return end
        local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, aux.TRUE, tp,
                                              LOCATION_DECK, 0, 1, 1, nil):GetFirst()
        Duel.MoveSequence(tc, 0)
    end)
    Duel.RegisterEffect(ddraw, tp)
end

function s.diceop(e, tp, eg, ep, ev, re, r, rp)
    local cc = Duel.GetCurrentChain()
    local cid = Duel.GetChainInfo(cc, CHAININFO_CHAIN_ID)
    if s[0] == cid or not Duel.SelectYesNo(tp, 553) then return end
    Utility.HintCard(id)

    local t = {}
    for i = 1, 7 do t[i] = i end

    local res = {Duel.GetDiceResult()}
    local ct = bit.band(ev, 0xff) + bit.rshift(ev, 16)
    for i = 1, ct do res[i] = Duel.AnnounceNumber(tp, table.unpack(t)) end

    Duel.SetDiceResult(table.unpack(res))
    s[0] = cid
end

function s.coinop(e, tp, eg, ep, ev, re, r, rp)
    local cc = Duel.GetCurrentChain()
    local cid = Duel.GetChainInfo(cc, CHAININFO_CHAIN_ID)
    if s[1] == cid or not Duel.SelectYesNo(tp, 552) then return end
    Utility.HintCard(id)

    local res = {Duel.GetCoinResult()}
    local ct = ev
    for i = 1, ct do
        local ac = Duel.SelectOption(tp, 60, 61)
        if ac == 0 then
            ac = 1
        else
            ac = 0
        end
        res[i] = ac
    end

    Duel.SetCoinResult(table.unpack(res))
    s[1] = cid
end

function s.toggleop(e, tp, eg, ep, ev, re, r, rp)
    local list = {
        {desc = 666000, check = true, op = nil},
        {desc = aux.Stringid(id, 1), check = s.mode["set_field"] == 1},
        {desc = aux.Stringid(id, 2), check = s.mode["set_field"] == 0},
        {desc = aux.Stringid(id, 3), check = s.mode["destiny_draw"] == 1},
        {desc = aux.Stringid(id, 4), check = s.mode["destiny_draw"] == 0}
    }

    local opt = {}
    local sel = {}
    for i, item in ipairs(list) do
        if item.check then
            table.insert(opt, item.desc)
            table.insert(sel, i)
        end
    end
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]

    if op == 1 then
        return
    elseif op == 2 then
        s.mode["set_field"] = 0
    elseif op == 3 then
        s.mode["set_field"] = 1
    elseif op == 4 then
        s.mode["destiny_draw"] = 0
    elseif op == 5 then
        s.mode["destiny_draw"] = 1
    end
end
