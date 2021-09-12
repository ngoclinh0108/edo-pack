-- Palladium Reborn
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(83764718)
    c:RegisterEffect(code)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    if not GhostBelleTable then GhostBelleTable = {} end
    table.insert(GhostBelleTable, e1)
end

function s.e1filter(c, ft, e, tp)
    if not c:IsMonster() then return false end
    return (ft > 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP)) or
               c:IsAbleToHand()
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
               Duel.IsTurnPlayer(1 - tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_GRAVE,
                                     LOCATION_GRAVE, 1, nil, ft, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_GRAVE,
                                LOCATION_GRAVE, 1, 1, nil, ft, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    aux.ToHandOrElse(tc, tp, function(tc)
        return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end, function(tc)
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end, 2)
end
