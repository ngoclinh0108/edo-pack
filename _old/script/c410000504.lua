-- Majestic Tool Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {21159309, 2403771}
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddMajesticProcedure(c,
                                 aux.FilterBoolFunction(Card.IsCode, 21159309),
                                 true,
                                 aux.FilterBoolFunction(Card.IsCode, 2403771),
                                 true, Synchro.NonTuner(nil), false)

    -- double tuner check
    local doubletuner = Effect.CreateEffect(c)
    doubletuner:SetType(EFFECT_TYPE_SINGLE)
    doubletuner:SetCode(EFFECT_MATERIAL_CHECK)
    doubletuner:SetValue(function(e, c)
        local g = c:GetMaterial()
        if not g:IsExists(Card.IsType, 2, nil, TYPE_TUNER) then return end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
        ec1:SetCode(21142671)
        ec1:SetReset(
            RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD + RESET_PHASE +
                PHASE_END)
        c:RegisterEffect(ec1)
    end)
    c:RegisterEffect(doubletuner)

    -- destroy replace
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- equip
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(518)
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- to extra
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(666002)
    e4:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_PHASE + PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c)
    return c:IsType(TYPE_SPELL) and c:IsLocation(LOCATION_SZONE) and
               not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = c:GetEquipGroup()

    if chk == 0 then
        return not c:IsReason(REASON_REPLACE) and g:IsExists(s.e1filter, 1, nil)
    end

    if Duel.SelectEffectYesNo(tp, c, 96) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
        local sg = g:FilterSelect(tp, s.e1filter, 1, 1, nil)

        Duel.SetTargetCard(sg)
        return true
    else
        return false
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    Duel.SendtoGrave(tg, REASON_EFFECT + REASON_REPLACE)
end

function s.e2filter(c, ec) return c:CheckEquipTarget(ec) and
                                      c:IsType(TYPE_EQUIP) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp,
                                               LOCATION_HAND + LOCATION_DECK, 0,
                                               1, nil, e:GetHandler())
    end

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, 0,
                          LOCATION_HAND + LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end

    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter, tp,
                                       LOCATION_HAND + LOCATION_DECK, 0, 1, 1,
                                       nil, c):GetFirst()
    if tc then Duel.Equip(tp, tc, c) end
end

function s.e3filter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e3filter, tp, 0, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g =
        Duel.SelectTarget(tp, s.e3filter, tp, 0, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or
        tc:IsDisabled() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_DISABLE_EFFECT)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec2)
    if tc:IsImmuneToEffect(ec1) or tc:IsImmuneToEffect(ec2) then return end
    Duel.AdjustInstantly(tc)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3105)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_IMMUNE_EFFECT)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(function(e, re)
        return e:GetOwnerPlayer() == 1 - re:GetOwnerPlayer()
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
end

function s.e4filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsCode(2403771)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return true end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e4filter, tp, LOCATION_GRAVE, 0, 1, 1,
                                nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()

    if c:IsRelateToEffect(e) and c:IsAbleToExtra() and
        Duel.SendtoDeck(c, nil, 0, REASON_EFFECT) ~= 0 and
        c:IsLocation(LOCATION_EXTRA) and tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end
