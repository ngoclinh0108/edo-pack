-- Palladium Knight of King
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(64788463)
    c:RegisterEffect(code)

    -- special summon (self)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- special summon (other)
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and not c:IsCode(id)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1,
                                           nil)
end

function s.e2filter1(c)
    return c:IsFaceup() and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and
               c:IsRace(RACE_WARRIOR)
end

function s.e2filter2(c, e, tp)
    return c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_LIGHT) and
               c:IsRace(RACE_WARRIOR) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1,
                                       e:GetHandler())
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_HAND +
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                       1, nil, e, tp):GetFirst()
    if not tc then return end

    Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    ec1:SetValue(function(e, tc)
        if not tc then return false end
        return not (tc:IsAttribute(ATTRIBUTE_LIGHT) and tc:IsRace(RACE_WARRIOR))
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
end
