-- Palladium Knight Faris
Duel.LoadScript("utility.lua")
local s, id = GetID()

s.listed_names = {6368038}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(6368038)
    c:RegisterEffect(code)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- special summon other
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2c)

    -- change battle position
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_POSITION)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(s.e3con)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 or
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsAttribute, ATTRIBUTE_DARK),
                   tp, 0, LOCATION_MZONE, 1, nil)
end

function s.e2filter(c, e, tp)
    return c:IsSetCard(0x13a) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               not c:IsCode(id)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp,
                                               LOCATION_HAND + LOCATION_GRAVE,
                                               0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0,
                          LOCATION_HAND + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp,
                                      LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1,
                                      nil, e, tp)
    if #g == 0 then return end

    Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e3filter(c) return c:IsCanChangePosition() end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsBattlePhase() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, 0, LOCATION_MZONE, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_POSITION, nil, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
    local tg = Duel.SelectMatchingCard(tp, s.e3filter, tp, 0, LOCATION_MZONE, 1,
                                       1, nil)
    if #tg == 0 then return end

    Duel.ChangePosition(tg, POS_FACEUP_DEFENSE, 0, POS_FACEUP_ATTACK, 0)
end
