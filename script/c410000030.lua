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

function s.e2check1(c, tp)
    if not c:IsAbleToHand() then return false end
    if c:IsControler(tp) and
        c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ + TYPE_LINK) then
        return false
    end
    return true
end

function s.e2check2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp,
                                    c:IsOriginalCode(CARD_RA) and true or false,
                                    false) and
               Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
end

function s.e2filter(c, e, tp)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsType(TYPE_MONSTER) and s.e2check1(c, tp) or s.e2check2(c, e, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp,
                                               LOCATION_GRAVE + LOCATION_EXTRA,
                                               LOCATION_GRAVE + LOCATION_EXTRA,
                                               1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter, tp,
                                       LOCATION_GRAVE + LOCATION_EXTRA,
                                       LOCATION_GRAVE + LOCATION_EXTRA, 1, 1,
                                       nil, e, tp):GetFirst()
    if not tc then return end

    local b1 = s.e2check1(tc, tp)
    local b2 = s.e2check2(tc, e, tp)

    local opt
    if b1 and b2 then
        opt = Duel.SelectOption(tp, 573, 5)
    elseif b1 then
        opt = Duel.SelectOption(tp, 573)
    else
        opt = Duel.SelectOption(tp, 5) + 1
    end

    if opt == 0 then
        Duel.SendtoHand(tc, tp, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
    elseif Duel.SpecialSummon(tc, 0, tp, tp,
                              tc:IsOriginalCode(CARD_RA) and true or false,
                              false, POS_FACEUP) > 0 then
        if not tc:IsSetCard(0x13a) then
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD +
                                      RESET_PHASE + PHASE_END,
                                  EFFECT_FLAG_CLIENT_HINT, 1, 0,
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
end

function s.e2gyop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(function(c)
        return c:GetFlagEffect(id) ~= 0
    end, tp, LOCATION_MZONE, 0, nil)
    if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
end
