-- Sigrun of the Nordic Ascendant
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x42}
s.listed_names = {UtilNordic.ASCENDANT_TOKEN}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_COST) and
               re:GetHandler():IsSetCard(0x42)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 2, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) == 0 then
        return
    end

    if not re:GetHandler():IsType(TYPE_MONSTER) or
        Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 or
        not Duel.IsPlayerCanSpecialSummonMonster(tp, UtilNordic.ASCENDANT_TOKEN,
                                                 0, TYPES_TOKEN, 0, 0, 4,
                                                 RACE_FAIRY, ATTRIBUTE_LIGHT) or
        not Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then return end

    local token = Duel.CreateToken(tp, UtilNordic.ASCENDANT_TOKEN)
    Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end
