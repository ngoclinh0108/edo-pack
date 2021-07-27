-- Hildr of the Nordic Ascendant
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x42}
s.listed_names = {UtilNordic.ASCENDANT_TOKEN}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- token
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsSetCard(0x42) and c:IsType(TYPE_TUNER)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1,
                                           nil)
end

function s.e2filter(c)
    return c:IsFaceup() and c:IsSetCard(0x42) and c:IsType(TYPE_TUNER)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    if not re then return false end
    return re:GetHandler():IsSetCard(0x42)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp,
                                                        UtilNordic.ASCENDANT_TOKEN,
                                                        0x3042, TYPES_TOKEN, 0,
                                                        0, 4, RACE_FAIRY,
                                                        ATTRIBUTE_LIGHT)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 1, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 or
        not Duel.IsPlayerCanSpecialSummonMonster(tp, UtilNordic.ASCENDANT_TOKEN,
                                                 0x3042, TYPES_TOKEN, 0, 0, 4,
                                                 RACE_FAIRY, ATTRIBUTE_LIGHT) then
        return
    end

    local token = Duel.CreateToken(tp, UtilNordic.ASCENDANT_TOKEN)
    Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end
