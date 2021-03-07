-- Ancient Stardust Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- treated as a non-tuner
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_NONTUNER)
    e1:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e1)

    -- indes
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e3:SetCondition(s.e3con)
    e3:SetCost(aux.StardustCost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3sum = Effect.CreateEffect(c)
    e3sum:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3sum:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_FIELD)
    e3sum:SetCode(EVENT_PHASE + PHASE_END)
    e3sum:SetRange(LOCATION_GRAVE)
    e3sum:SetCountLimit(1)
    e3sum:SetTarget(s.e3sumtg)
    e3sum:SetOperation(s.e3sumop)
    c:RegisterEffect(e3sum)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_ONFIELD, 0, 1,
                                     nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    ec1:SetCountLimit(1)
    ec1:SetValue(function(e, re, r, rp)
        return (r & REASON_BATTLE + REASON_EFFECT) ~= 0
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or
        not Duel.IsChainNegatable(ev) then return false end

    if re:IsHasCategory(CATEGORY_NEGATE) and
        Duel.GetChainInfo(ev - 1, CHAININFO_TRIGGERING_EFFECT):IsHasType(
            EFFECT_TYPE_ACTIVATE) then return false end

    local ex, tg, tc = Duel.GetOperationInfo(ev, CATEGORY_DESTROY)
    return ex and tg ~= nil and tc + tg:FilterCount(Card.IsOnField, nil) - #tg >
               0
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, #eg, 0, 0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end

    e:GetHandler():RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD +
                                          RESET_PHASE + PHASE_END, 0, 0)
end

function s.e3sumtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()

    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   c:GetFlagEffect(id) > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e3sumop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end
