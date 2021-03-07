-- Majestic Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x3f}

function s.initial_effect(c)
    -- treated as a non-tuner
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_NONTUNER)
    e1:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, nil, 1, false,
                                          aux.ReleaseCheckMMZ, nil)
    end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 1, 1, false,
                                          aux.ReleaseCheckMMZ, nil)
    Duel.Release(g, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, c:GetLocation())
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3300)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        ec1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(ec1, true)
    end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec2:SetTargetRange(1, 0)
    ec2:SetTarget(function(e, c)
        return not (c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x3f)) and
                   c:IsLocation(LOCATION_EXTRA)
    end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
    aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 0), nil)
end
