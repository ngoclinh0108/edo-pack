-- Mach Warrior
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1017}
s.material_setcode = {0x1017}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, stype, tp)
        return c:IsSetCard(0x1017, sc, stype, tp) or c:IsHasEffect(20932152)
    end, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- return card
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id + 1 * 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon from deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id + 2 * 1000000)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon from grave
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCost(aux.bfgcost)
    e3:SetCountLimit(1, id + 3 * 1000000)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(Card.IsAbleToHand, tp, LOCATION_GRAVE, 0,
                                     1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, Card.IsAbleToHand, tp, LOCATION_GRAVE, 0, 1,
                                1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc, nil, REASON_EFFECT) end
end

function s.e2filter(c, e, tp)
    return c:IsLevelBelow(2) and c:IsRace(RACE_WARRIOR + RACE_MACHINE) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0,
                                               1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_DECK, 0, 1,
                                      1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end

function s.e3filter(c, e, tp)
    return (c:IsOriginalSetCard(0x66) or c:IsOriginalSetCard(0xa3) or
               c:IsOriginalSetCard(0x1017)) and c:IsType(TYPE_SYNCHRO) and
               c:IsLevelBelow(8) and not c:IsCode(id) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e3filter, tp, LOCATION_GRAVE, 0, 1,
                                         nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_GRAVE, 0, 1, 1,
                                nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end
