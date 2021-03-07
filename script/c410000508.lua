-- Majestic Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0xc2, 0x3f}

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
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c)
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and
               ((c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON)) or
                   c:IsSetCard(0xc2))
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return
        Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_MZONE, 0, 1, nil)
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

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c)
        return not (c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x3f)) and
                   c:IsLocation(LOCATION_EXTRA)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 0), nil)

    if not c:IsRelateToEffect(e) then return end
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end
