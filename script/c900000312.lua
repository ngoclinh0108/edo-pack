-- Assault Shooting Star Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.listed_names = {CARD_STARDUST_DRAGON}
s.synchro_tuner_required = 1
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1,
        Synchro.NonTunerEx(function(c, val, sc, sumtype, tp)
            return c:IsRace(RACE_DRAGON, sc, sumtype, tp) and c:IsType(TYPE_SYNCHRO, sc, sumtype, tp)
        end), 1, 1)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(SignerDragon.CARD_SHOOTING_STAR_DRAGON)
    c:RegisterEffect(code)

    -- quick synchro
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(1172)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetHintTiming(0, TIMING_MAIN_END)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetValue(function(e, re, r, rp)
        if (r & REASON_EFFECT) ~= 0 then
            return 1
        else
            return 0
        end
    end)
    c:RegisterEffect(e2)

    -- multi attack
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- banish
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e4:SetCondition(s.e4con1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetType(EFFECT_TYPE_QUICK_O)
    e4b:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e4b:SetCode(EVENT_CHAINING)
    e4b:SetCondition(s.e4con2)
    c:RegisterEffect(e4b)
end

function s.e1filter(c, tp)
    return c:IsFaceup() and c:IsCode(CARD_STARDUST_DRAGON) and
               Duel.IsExistingMatchingCard(Card.IsSynchroSummonable, tp, LOCATION_EXTRA, 0, 1, nil, c)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() == PHASE_MAIN1 or Duel.GetCurrentPhase() == PHASE_MAIN2
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, LOCATION_EXTRA)
    Duel.SetChainLimit(function(e, rp, tp)
        return tp == rp
    end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    local g = Utility.SelectMatchingCard(HINTMSG_SMATERIAL, tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
    local mc = Utility.GroupSelect(HINTMSG_SMATERIAL, g, tp):GetFirst()
    if not mc then
        return
    end

    Duel.SynchroSummon(tp, c, mc)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsAbleToEnterBP() and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 5
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.ConfirmDecktop(tp, 5)
    local ct = Duel.GetDecktopGroup(tp, 5):FilterCount(Card.IsType, nil, TYPE_TUNER)
    Duel.ShuffleDeck(tp)

    if ct > 1 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_EXTRA_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        ec1:SetValue(ct)
        c:RegisterEffect(ec1)
    end
end

function s.e4con1(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():GetControler() ~= tp
end

function s.e4con2(e, tp, eg, ep, ev, re, r, rp)
    return rp == 1 - tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsAbleToRemove()
    end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, c, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.Remove(c, POS_FACEUP, REASON_COST + REASON_TEMPORARY) == 0 then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetLabelObject(c)
    ec1:SetCountLimit(1)
    ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.ReturnToField(e:GetLabelObject())
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    if Duel.GetAttacker() and Duel.GetAttacker():GetControler() ~= tp and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
        Duel.NegateAttack()
    else
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec2:SetCode(EVENT_ATTACK_ANNOUNCE)
        ec2:SetRange(LOCATION_REMOVED)
        ec2:SetLabel(0)
        ec2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            if e:GetLabel() ~= 0 or not Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                return
            end

            Utility.HintCard(e:GetHandler())
            Duel.NegateAttack()
            e:SetLabel(1)
        end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec2)
    end
end
