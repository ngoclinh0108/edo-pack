-- Majestic Rose Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    SignerDragon.AddMajesticProcedure(c, s, CARD_BLACK_ROSE_DRAGON)
    SignerDragon.AddMajesticReturn(c, CARD_BLACK_ROSE_DRAGON)

    -- banish
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand
    local e2event = Effect.CreateEffect(c)
    e2event:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2event:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2event:SetRange(LOCATION_MZONE)
    e2event:SetCondition(s.e2evcon)
    e2event:SetOperation(s.e2evop)
    c:RegisterEffect(e2event)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_CUSTOM + id)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate & down atk
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DISABLE + CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0, LOCATION_GRAVE, 1, nil)
    end

    local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0, LOCATION_GRAVE, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0, LOCATION_GRAVE, nil)
    if #g > 0 then
        Duel.Remove(g, POS_FACEDOWN, REASON_EFFECT)
    end
end

function s.e2evfilter(c, tp)
    return c:IsFaceup() and c:IsControler(tp)
end

function s.e2evcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e2evfilter, 1, nil, 1 - tp)
end

function s.e2evop(e, tp, eg, ep, ev, re, r, rp)
    Duel.RaiseSingleEvent(e:GetHandler(), EVENT_CUSTOM + id, re, r, rp, ep, ev)
end

function s.e2filter(c)
    return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToHand()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return true
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_RTOHAND, tp, s.e2filter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SendtoHand(g, nil, REASON_EFFECT)
end

function s.e3filter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e3filter, tp, 0, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local tc = Duel.SelectTarget(tp, s.e3filter, tp, 0, LOCATION_MZONE, 1, 1, nil):GetFirst()

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, tc, 1, 0, 0)
    if tc:IsDefensePos() then
        Duel.SetOperationInfo(0, CATEGORY_POSITION, tc, 1, 0, 0)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsDisabled() then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b)

    if tc:IsImmuneToEffect(ec1) or tc:IsImmuneToEffect(ec1b) then
        return
    end
    Duel.AdjustInstantly(tc)

    local ec2 = Effect.CreateEffect(e:GetHandler())
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec2:SetValue(0)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec2)
    if tc:IsDefensePos() then
        Duel.ChangePosition(tc, POS_FACEUP_ATTACK)
    end
end
