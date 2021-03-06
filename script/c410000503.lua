-- Majestic Fairy Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {21159309, 25862681}
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddMajesticProcedure(c,
                                 aux.FilterBoolFunction(Card.IsCode, 21159309),
                                 true,
                                 aux.FilterBoolFunction(Card.IsCode, 25862681),
                                 true, Synchro.NonTuner(nil), false)

    -- double tuner check
    local doubletuner = Effect.CreateEffect(c)
    doubletuner:SetType(EFFECT_TYPE_SINGLE)
    doubletuner:SetCode(EFFECT_MATERIAL_CHECK)
    doubletuner:SetValue(function(e, c)
        local g = c:GetMaterial()
        if not g:IsExists(Card.IsType, 2, nil, TYPE_TUNER) then return end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
        ec1:SetCode(21142671)
        ec1:SetReset(
            RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD + RESET_PHASE +
                PHASE_END)
        c:RegisterEffect(ec1)
    end)
    c:RegisterEffect(doubletuner)

    -- to extra & special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_PHASE + PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e4filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsCode(25862681)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return true end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e4filter, tp, LOCATION_GRAVE, 0, 1, 1,
                                nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()

    if c:IsRelateToEffect(e) and c:IsAbleToExtra() and
        Duel.SendtoDeck(c, nil, 0, REASON_EFFECT) ~= 0 and
        c:IsLocation(LOCATION_EXTRA) and tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end
