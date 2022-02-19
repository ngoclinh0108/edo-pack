-- Palladium Ankuriboh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {83764718}

function s.initial_effect(c)
    -- ritual material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e1:SetCondition(function(e)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), 69832741)
    end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_HAND)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(TIMING_SPSUMMON, TIMING_BATTLE_START)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- search
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter(c, e, tp)
    return not c:IsCode(id) and c:IsCanBeSpecialSummoned(e, SUMMON_WITH_MONSTER_REBORN, tp, false, false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(1 - tp) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST + REASON_DISCARD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE,
                                         LOCATION_GRAVE, 1, nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE,
                                LOCATION_GRAVE, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    Duel.SpecialSummon(tc, SUMMON_WITH_MONSTER_REBORN, tp, tp, false, false, POS_FACEUP)
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                              PHASE_END, 0, 1)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetCountLimit(1)
    ec1:SetLabelObject(tc)
    ec1:SetCondition(function(e)
        return e:GetLabelObject():GetFlagEffect(id) ~= 0
    end)
    ec1:SetOperation(function(e)
        Duel.SendtoGrave(e:GetLabelObject(), REASON_EFFECT)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e3filter(c) return c:IsCode(83764718) and c:IsAbleToHand() end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT + REASON_BATTLE) ~= 0
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp,
                                         aux.NecroValleyFilter(s.e3filter), tp,
                                         LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                         1, nil)
    if #g > 0 then Duel.SendtoHand(g, nil, REASON_EFFECT) end
end
