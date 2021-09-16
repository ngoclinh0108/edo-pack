-- Blue-Eyes Deep Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_BLUEEYES_W_DRAGON}
s.listed_series = {0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, 0xdd), 8, 2,
                     s.ovfilter, aux.Stringid(id, 0))

    -- atk
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- destroy replace
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.e3tg)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)

    -- destroy
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.ovfilter(c, tp, sc)
    return c:IsFaceup() and
               c:IsSummonCode(sc, SUMMON_TYPE_XYZ, tp, CARD_BLUEEYES_W_DRAGON)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup()
    if #og == 0 then return end

    local _, atk = og:GetMaxGroup(Card.GetAttack)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end

function s.e2filter(c, tp)
    return c:IsPreviousSetCard(0xdd) and c:IsPreviousControler(tp) and
               c:IsPreviousLocation(LOCATION_MZONE) and
               c:IsPreviousPosition(POS_FACEUP) and
               (c:IsReason(REASON_BATTLE + REASON_EFFECT) and
                   c:GetReasonPlayer() ~= tp) and not c:IsCode(id)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e2filter, 1, nil, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummonStep(c, 0, tp, tp, true, false, POS_FACEUP) then
        local g = eg:Filter(s.e2filter, nil, tp)
        local g = g:Filter(Card.IsLocation, nil, LOCATION_GRAVE)
        g = Utility.GroupSelect(HINTMSG_XMATERIAL, g, tp, 1, 1, nil)
        Duel.Overlay(c, g)
    end
    Duel.SpecialSummonComplete()
end

function s.e3filter(c, tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and
               c:IsPosition(POS_FACEUP) and c:IsReason(REASON_EFFECT) and
               not c:IsReason(REASON_REPLACE) and c:IsRace(RACE_DRAGON)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return eg:IsExists(s.e3filter, 1, nil, tp) and
                   c:CheckRemoveOverlayCard(tp, 1, REASON_EFFECT)
    end

    if Duel.SelectEffectYesNo(tp, c, 96) then
        c:RemoveOverlayCard(tp, 1, 1, REASON_EFFECT)
        return true
    else
        return false
    end
end

function s.e3val(e, c) return s.e3filter(c, e:GetHandlerPlayer()) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    local ct = g:FilterCount(Card.IsControler, nil, 1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, ct * 600)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.Destroy(g, REASON_EFFECT)
    local ct = Duel.GetOperatedGroup():FilterCount(Card.IsPreviousControler,
                                                   nil, 1 - tp)
    if ct > 0 then Duel.Damage(1 - tp, ct * 600, REASON_EFFECT) end
end
