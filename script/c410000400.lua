-- Neo-Space Multiverse
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_NEOS}
s.listed_series = {0x8, 0x1f}

function s.global_effect(c, tp)
    -- Elemental HERO Neos
    local eg1 = Effect.CreateEffect(c)
    eg1:SetType(EFFECT_TYPE_SINGLE)
    eg1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    eg1:SetCode(EFFECT_ADD_CODE)
    eg1:SetValue(CARD_NEOS)
    Utility.RegisterGlobalEffect(c, eg1, Card.IsCode, 14124483)
end

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetValue(function(e, te) return te:GetHandler() ~= e:GetHandler() end)
    c:RegisterEffect(e1)

    -- may not return
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(42015635)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    c:RegisterEffect(e2)

    -- extra summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_HAND, 0)
    e3:SetValue(0x1)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x8))
    c:RegisterEffect(e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e4filter1(c, e, tp)
    return c:IsLevel(4) and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck() and
               Duel.IsExistingMatchingCard(s.e4filter2, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0, 1,
                                           nil, e, tp, c:GetAttribute())
end

function s.e4filter2(c, e, tp, attr)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and
               c:IsSetCard(0x1f) and c:IsAttribute(attr)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e4filter1, tp, LOCATION_MZONE, 0, 1, nil,
                                     e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.e4filter1, tp, LOCATION_MZONE, 0, 1, 1,
                                nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetTargetCards(e):GetFirst()
    if not c:IsRelateToEffect(e) then return end
    if not tc or not tc:IsRelateToEffect(e) then return end

    local attr = tc:GetAttribute()
    if Duel.SendtoDeck(tc, tp, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 then
        return
    end

    local g = Duel.GetMatchingGroup(s.e4filter2, tp,
                                    LOCATION_HAND + LOCATION_DECK, 0, nil, e,
                                    tp, attr)
    if #g > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        g = g:Select(tp, 1, 1)
    end
    if #g == 0 then return end

    Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
end
