-- Hervor of the Nordic Champions
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {UtilNordic.EINHERJAR_TOKEN}
s.listed_series = {0x42}

function s.initial_effect(c)
    -- special summon token
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon (self)
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local rc = re:GetHandler()
    return e:GetHandler():IsReason(REASON_COST) and rc:IsSetCard(0x42) and
               rc:IsType(TYPE_MONSTER)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) >= 1 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp,
                                                        UtilNordic.EINHERJAR_TOKEN,
                                                        0, TYPES_TOKEN, 1000,
                                                        1000, 4, RACE_WARRIOR,
                                                        ATTRIBUTE_EARTH)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 or
        not Duel.IsPlayerCanSpecialSummonMonster(tp, UtilNordic.EINHERJAR_TOKEN,
                                                 0, TYPES_TOKEN, 1000, 1000, 4,
                                                 RACE_WARRIOR, ATTRIBUTE_EARTH) then
        return
    end

    local token = Duel.CreateToken(tp, UtilNordic.EINHERJAR_TOKEN)
    Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e2filter(c)
    return c:IsFaceup() and c:IsSetCard(0x42) and c:IsLevelAbove(4)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return
            Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE, 0, 1, nil) and
                Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or
        tc:GetLevel() < 3 then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_LEVEL)
    ec1:SetValue(-3)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end
