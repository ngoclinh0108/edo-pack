-- Tablet of Lost Memories
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {
    410000000, CARD_DARK_MAGICIAN, CARD_BLUEEYES_W_DRAGON, CARD_REDEYES_B_DRAGON
}

function s.initial_effect(c)
    -- add to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(573)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_DECK + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(function(e, tp) return Duel.IsEnvironment(410000000, tp) end)
    e1:SetCost(s.e1cost)
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return e:GetHandler():IsAbleToHand() end
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsRelateToEffect(e) then return end
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCondition(function(e) return Duel.IsMainPhase() end)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- destroy spell/trap
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- destroy monsters
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_ACTIVATE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- damage
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetCategory(CATEGORY_DAMAGE)
    e5:SetType(EFFECT_TYPE_ACTIVATE)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetCondition(s.e5con)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e1filter(c)
    return not c:IsPublic() and
               c:IsCode(CARD_DARK_MAGICIAN, CARD_BLUEEYES_W_DRAGON,
                        CARD_REDEYES_B_DRAGON)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetTurnPlayer() == tp and Duel.IsMainPhase() and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND, 0,
                                               1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_HAND, 0, 1,
                                      1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
end

function s.e2check1(c)
    return not c:IsLocation(LOCATION_HAND) and c:IsAbleToHand()
end

function s.e2check2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

function s.e2filter(c, e, tp)
    return (s.e2check1(c) or s.e2check2(c, e, tp)) and
               c:IsCode(CARD_DARK_MAGICIAN, CARD_BLUEEYES_W_DRAGON,
                        CARD_REDEYES_B_DRAGON)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND +
                                               LOCATION_DECK + LOCATION_GRAVE,
                                           0, 1, nil, e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e2filter), tp,
                                    LOCATION_HAND + LOCATION_DECK +
                                        LOCATION_GRAVE, 0, nil, e, tp)
    if #g == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local sc = g:Select(tp, 1, 1, nil):GetFirst()

    local b1 = s.e2check1(sc)
    local b2 = s.e2check2(sc, e, tp)
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, 573, 5)
    elseif b1 then
        op = Duel.SelectOption(tp, 573)
    else
        op = Duel.SelectOption(tp, 5) + 1
    end

    if op == 0 then
        Duel.SendtoHand(sc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sc)
    else
        Duel.SpecialSummon(sc, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.e3filter(c) return c:IsType(TYPE_SPELL + TYPE_TRAP) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase() and
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsCode, CARD_DARK_MAGICIAN),
                   tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e3filter, tp, 0, LOCATION_ONFIELD, c)

    if chk == 0 then return #g > 0 end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e3filter, tp, 0, LOCATION_ONFIELD, c)
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase() and
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsCode, CARD_BLUEEYES_W_DRAGON),
                   tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)

    if chk == 0 then return #g > 0 end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e5filter(c) return c:IsFaceup() and c:IsAttackAbove(0) end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase() and
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsCode, CARD_REDEYES_B_DRAGON),
                   tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_MZONE, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc = Duel.SelectMatchingCard(tp, s.e5filter, tp, LOCATION_MZONE, 0, 1,
                                       1, nil):GetFirst()
    if not tc then return end

    Duel.Damage(1 - tp, tc:GetBaseAttack(), REASON_EFFECT)
end
