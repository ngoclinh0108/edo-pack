-- Black Luster Soldier - Palladium Soldier
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {910000100}
s.listed_series = {0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, 1)
    e2:SetValue(1)
    e2:SetCondition(function(e)
        local c = e:GetHandler()
        return Duel.GetAttacker() == c or Duel.GetAttackTarget() == c
    end)
    c:RegisterEffect(e2)

    -- battle destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCondition(aux.bdocon)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return c:IsSetCard(0x13a) and c:IsType(TYPE_MONSTER) and
               not c:IsRitualMonster() and c:IsAbleToHand()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return not e:GetHandler():IsPublic() end
    Duel.ConfirmCards(1 - tp, e:GetHandler())
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_DECK, 0,
                                          1, 1, nil):GetFirst()
    if tc and Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and
        tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, tc)
        Duel.ShuffleHand(tp)
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()

        local g = Utility.SelectMatchingCard(tp, Card.IsAbleToDeck, tp,
                                             LOCATION_HAND, 0, 1, 1, nil)
        Duel.SendtoDeck(g, nil, SEQ_DECKTOP, REASON_EFFECT)
    end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local b1 = true
    local b2 = Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0,
                                           LOCATION_ONFIELD, 1, nil)
    local b3 = Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0,
                                           LOCATION_HAND, 1, nil)
    local b4 = true

    local opt = {}
    local sel = {}
    if b1 then
        table.insert(opt, aux.Stringid(id, 1))
        table.insert(sel, 1)
    end
    if b2 then
        table.insert(opt, aux.Stringid(id, 2))
        table.insert(sel, 2)
    end
    if b3 then
        table.insert(opt, aux.Stringid(id, 3))
        table.insert(sel, 3)
    end
    if b4 then
        table.insert(opt, aux.Stringid(id, 4))
        table.insert(sel, 4)
    end
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]

    e:SetCategory(0)
    if op == 2 then
        e:SetCategory(CATEGORY_REMOVE)
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0,
                                        LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, tp, 0)
    elseif op == 3 then
        e:SetCategory(CATEGORY_REMOVE)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 1 - tp, LOCATION_HAND)
    end
    e:SetLabel(op)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = e:GetLabel()
    if op == 1 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1500)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
    elseif op == 2 then
        local g = Utility.SelectMatchingCard(tp, Card.IsAbleToRemove, tp,
                                             0, LOCATION_ONFIELD, 1, 1, nil)
        if #g > 0 then Duel.Remove(g, POS_FACEUP, REASON_EFFECT) end
    elseif op == 3 then
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0,
                                        LOCATION_HAND, nil, tp, POS_FACEDOWN)
        if #g > 0 then
            g = g:RandomSelect(tp, 1)
            Duel.Remove(g, POS_FACEDOWN, REASON_EFFECT)
        end
    elseif op == 4 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3201)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_EXTRA_ATTACK)
        ec1:SetLabel(Duel.GetTurnCount())
        ec1:SetCondition(function(e)
            return Duel.GetTurnCount() > e:GetLabel()
        end)
        ec1:SetValue(1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END +
                         RESET_SELF_TURN, 2)
        c:RegisterEffect(ec1)
    end
end
