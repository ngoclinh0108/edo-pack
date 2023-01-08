-- Phantasms Seed
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {78371393}

function s.initial_effect(c)
    -- destroy (hand)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter1(c)
    return c:IsFaceup()
end

function s.e1filter2(c, e, tp)
    return c:IsCode(78371393) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return not e:GetHandler():IsPublic()
    end
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter1, tp, LOCATION_MZONE, 0, 1, nil) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) or
                       Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil))
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.e1filter1, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_HAND + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or Duel.Destroy(tc, REASON_EFFECT) == 0 then
        return
    end

    local opt = {}
    if c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then
        table.insert(opt, aux.Stringid(id, 0))
    end
    if Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) then
        table.insert(opt, aux.Stringid(id, 1))
    end
    local op = Duel.SelectOption(tp, table.unpack(opt))

    if op == 0 then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    else
        local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil)
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end
