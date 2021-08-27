-- Millennium Hieroglyph
Duel.LoadScript("util.lua")
local s, id = GetID()

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
    if c:IsPreviousLocation(LOCATION_HAND) then Duel.Draw(p, 1, REASON_RULE) end
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

    -- normal summon in defense
    local sumdef = Effect.CreateEffect(c)
    sumdef:SetType(EFFECT_TYPE_FIELD)
    sumdef:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    sumdef:SetCode(EFFECT_LIGHT_OF_INTERVENTION)
    sumdef:SetTargetRange(1, 0)
    Duel.RegisterEffect(sumdef, tp)

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

    -- activate skill
    local skill = Effect.CreateEffect(c)
    skill:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    skill:SetCode(EVENT_FREE_CHAIN)
    skill:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return aux.CanActivateSkill(tp)
    end)
    skill:SetOperation(s.skillop)
    Duel.RegisterEffect(skill, tp)

    -- activate field
    local field = Effect.CreateEffect(c)
    field:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    field:SetCode(EVENT_ADJUST)
    field:SetCountLimit(1)
    field:SetCondition(function(e, tp)
        return Duel.GetCurrentPhase() == PHASE_DRAW
    end)
    field:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local g = Duel.GetMatchingGroup(function(c)
            return c:IsType(TYPE_FIELD) and
                       Utility.CheckActivateEffect(c, e, tp, false, true, false)
        end, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE +
                                            LOCATION_REMOVED, 0, nil)
        if #g == 0 then return end
        if #g >= 2 and Duel.GetTurnCount() >= 2 and
            not Duel.SelectYesNo(tp, 2204) then return end

        local sc =
            Utility.GroupSelect(g, tp, 1, nil, HINTMSG_TOFIELD):GetFirst()

        aux.PlayFieldSpell(sc, e, tp, eg, ep, ev, re, r, rp)
        if Duel.GetTurnCount() == 1 then
            Utility.ApplyActivateEffect(sc, e, tp, false, true, false)
        end

        if sc:IsPreviousLocation(LOCATION_HAND) and Duel.GetTurnCount() == 1 and
            Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 then
            Duel.Draw(tp, 1, REASON_RULE)
        end
    end)
    Duel.RegisterEffect(field, tp)

    -- mulligan
    local mulligan = Effect.CreateEffect(c)
    mulligan:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    mulligan:SetCode(EVENT_ADJUST)
    mulligan:SetCountLimit(1)
    mulligan:SetCondition(function(e, tp)
        return
            Duel.GetCurrentPhase() == PHASE_DRAW and Duel.GetTurnCount() == 1 and
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

function s.skillop(e, tp, eg, ep, ev, re, r, rp)
    Utility.HintCard(id)
    local all = {
        {desc = aux.Stringid(id, 0), check = true, op = nil},
        {desc = aux.Stringid(id, 1), check = true, op = s.e1op}, {
            desc = aux.Stringid(id, 2),
            check = s.e2con(e, tp, eg, ep, ev, re, r, rp),
            op = s.e2op
        }, {
            desc = aux.Stringid(id, 3),
            check = s.e3con(e, tp, eg, ep, ev, re, r, rp),
            op = s.e3op
        }, {
            desc = aux.Stringid(id, 4),
            check = s.e4con(e, tp, eg, ep, ev, re, r, rp),
            op = s.e4op
        }, {
            desc = aux.Stringid(id, 5),
            check = s.e5con(e, tp, eg, ep, ev, re, r, rp),
            op = s.e5op
        }
    }

    local t = {}
    local desc = {}
    for i, item in ipairs(all) do
        if (item.check) then
            table.insert(t, {index = i, desc = item.desc})
            table.insert(desc, item.desc)
        end
    end

    local index = Duel.SelectOption(tp, table.unpack(desc)) + 1
    index = t[index].index
    if all[index].op then all[index].op(e, tp, eg, ep, ev, re, r, rp) end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ph = Duel.GetCurrentPhase()

    if ph <= PHASE_DRAW then
        Duel.SkipPhase(tp, PHASE_DRAW, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_STANDBY then
        Duel.SkipPhase(tp, PHASE_STANDBY, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_MAIN1 then
        Duel.SkipPhase(tp, PHASE_MAIN1, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_BATTLE then
        Duel.SkipPhase(tp, PHASE_BATTLE, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_MAIN2 then
        Duel.SkipPhase(tp, PHASE_MAIN2, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_END then
        Duel.SkipPhase(tp, PHASE_END, RESET_PHASE + PHASE_END, 1)
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_SKIP_TURN)
    ec1:SetTargetRange(0, 1)
    ec1:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_EP)
    ec2:SetTargetRange(1, 0)
    ec2:SetReset(RESET_PHASE + PHASE_DRAW + RESET_SELF_TURN)
    Duel.RegisterEffect(ec2, tp)

    Duel.SkipPhase(tp, PHASE_DRAW, RESET_PHASE + PHASE_END, 2)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1,
                                       nil) and
               Duel.GetLocationCount(tp, LOCATION_MZONE, tp,
                                     LOCATION_REASON_CONTROL) > 0
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local tc = Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0,
                                       1, 1, nil):GetFirst()
    if not tc or Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOZONE)
    local zone = math.log(Duel.SelectDisableField(tp, 1, LOCATION_MZONE, 0, 0),
                          2)
    Duel.MoveSequence(tc, zone)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return
        Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_REMOVED, 0, 1, nil)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(nil, tp, LOCATION_REMOVED, 0, nil)
    g = Utility.GroupSelect(g, tp, 1, 99, HINTMSG_TOGRAVE)
    if #g == 0 then return end
    Duel.SendtoGrave(g, REASON_RULE)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_GRAVE + LOCATION_REMOVED
    return Duel.IsExistingMatchingCard(aux.TRUE, tp, loc, 0, 1, nil)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_GRAVE + LOCATION_REMOVED

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, loc, 0, 1, 99, nil)
    if #g == 0 then return end

    Duel.SendtoDeck(g, nil, 2, REASON_RULE)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED
    return Duel.IsExistingMatchingCard(nil, tp, loc, loc, 1, nil)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED +
                    LOCATION_EXTRA
    local tpdraw = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)
    local opdraw = Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND)

    local g = Duel.GetMatchingGroup(nil, tp, loc, loc, nil)
    if #g > 0 then Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) end

    Duel.ShuffleDeck(tp)
    Duel.ShuffleDeck(1 - tp)
    if Duel.GetLP(tp) < 8000 then Duel.SetLP(tp, 8000) end
    if Duel.GetLP(1 - tp) < 8000 then Duel.SetLP(1 - tp, 8000) end
    if Duel.GetFieldGroupCount(tp, LOCATION_ONFIELD, 0) > 0 then
        Duel.Draw(tp, tpdraw, REASON_EFFECT)
    else
        Duel.Draw(tp, 5, REASON_EFFECT)
    end
    if Duel.GetFieldGroupCount(1 - tp, LOCATION_ONFIELD, 0) > 0 then
        Duel.Draw(1 - tp, opdraw, REASON_EFFECT)
    else
        Duel.Draw(1 - tp, 5, REASON_EFFECT)
    end
end
