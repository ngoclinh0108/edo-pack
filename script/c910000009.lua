-- Palladium Maiden Isis
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- disable
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(1117)
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND + LOCATION_MZONE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- look at deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- shuffle & draw
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCondition(aux.exccon)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local ch = Duel.GetCurrentChain(true) - 1
    if ch <= 0 then
        return false
    end
    local cp = Duel.GetChainInfo(ch, CHAININFO_TRIGGERING_CONTROLER)
    local ceff = Duel.GetChainInfo(ch, CHAININFO_TRIGGERING_EFFECT)
    if re:GetHandler():IsDisabled() or not Duel.IsChainDisablable(ev) then
        return false
    end

    local cec = ceff:GetHandler()
    return ep == 1 - tp and cp == tp and cec:IsSetCard(0x13a) and cec:IsMonster()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsReleasable()
    end
    Duel.Release(e:GetHandler(), REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return not re:GetHandler():IsStatus(STATUS_DISABLED)
    end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateEffect(ev)
end

function s.e2filter(c)
    return c:IsSetCard(0x13a) and c:IsSummonable(true, nil)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
    end

    Duel.ChangePosition(c, POS_FACEUP_DEFENSE)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 or Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) > 0
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    s.e2look(tp, tp)
    s.e2look(tp, 1 - tp)
end

function s.e2look(tp, p)
    local gc = math.min(5, Duel.GetFieldGroupCount(p, LOCATION_DECK, 0))
    if gc > 0 then
        local ac = gc == 1 and gc or Duel.AnnounceNumberRange(tp, 1, gc)
        Duel.ConfirmCards(tp, Duel.GetDecktopGroup(p, ac))
    end
end

function s.e3filter(c)
    if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then
        return false
    end

    return c:IsSetCard(0x13a) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToDeck()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
    if chk == 0 then
        return c:IsAbleToDeck() and #g >= 5
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local tg = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 5, 5, nil)
    tg:AddCard(c)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, tg, #tg, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    if not tg or not c:IsRelateToEffect(e) or tg:FilterCount(Card.IsRelateToEffect, nil, e) ~= tg:GetCount() then
        return
    end

    local sg = tg:Clone():AddCard(c)
    Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)

    local g = Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation, 1, nil, LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    end

    if g:FilterCount(Card.IsLocation, nil, LOCATION_DECK + LOCATION_EXTRA) == sg:GetCount() then
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end
