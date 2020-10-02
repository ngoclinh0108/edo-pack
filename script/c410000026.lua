-- Palladium Reborn
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- code
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(83764718)
    c:RegisterEffect(e1)

    -- activate
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c, e, tp)
    return (c:IsType(TYPE_MONSTER) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)) or
               (c:IsOriginalCode(CARD_RA) and
                   c:IsCanBeSpecialSummoned(e, 0, tp, true, false))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
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

    if Duel.SpecialSummon(tc, 0, tp, tp,
                          tc:IsOriginalCode(CARD_RA) and true or false, false,
                          POS_FACEUP) == 0 then return end

    if not tc:IsSetCard(0x13a) then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0,
                              aux.Stringid(id, 0))

        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(666000)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetCountLimit(1)
        ec1:SetOperation(s.e2gyop)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e2gyop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(function(c)
        return c:GetFlagEffect(id) ~= 0
    end, tp, LOCATION_MZONE, 0, nil)
    if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
end
