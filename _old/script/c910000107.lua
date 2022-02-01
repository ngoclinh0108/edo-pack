-- Palladium's Sanctuary
Duel.LoadScript("util.lua")
local s, id = GetID()

local PALLADIUM_TOKEN = 910000099
s.listed_names = {PALLADIUM_TOKEN}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- multiply
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_RELEASE + CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
               Duel.IsTurnPlayer(1 - tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp, PALLADIUM_TOKEN,
                                                        0x13a, TYPES_TOKEN, 0,
                                                        0, 1, RACE_FAIRY,
                                                        ATTRIBUTE_LIGHT)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 or
        not Duel.IsPlayerCanSpecialSummonMonster(tp, PALLADIUM_TOKEN, 0x13a,
                                                 TYPES_TOKEN, 0, 0, 1,
                                                 RACE_FAIRY, ATTRIBUTE_LIGHT) then
        return
    end

    local token = Duel.CreateToken(tp, PALLADIUM_TOKEN)
    if Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP) == 0 then
        return
    end

    -- cannot attack
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    token:RegisterEffect(ec1, true)

    -- reflect battle damage
    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(3212)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
    ec2:SetValue(1)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    token:RegisterEffect(ec2, true)

    -- maintain
    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec3:SetCode(EVENT_PHASE + PHASE_STANDBY)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCountLimit(1)
    ec3:SetCondition(function(e, tp) return Duel.IsTurnPlayer(1 - tp) end)
    ec3:SetOperation(function(e, tp)
        if Duel.CheckLPCost(tp, 1000) and
            Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.PayLPCost(tp, 1000)
        else
            Duel.Destroy(e:GetHandler(), REASON_COST)
        end
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    token:RegisterEffect(ec3, true)

    local ac = Duel.GetAttacker()
    if Duel.IsBattlePhase() and ac and ac:IsControler(1 - tp) then
        local ec4 = Effect.CreateEffect(c)
        ec4:SetType(EFFECT_TYPE_FIELD)
        ec4:SetCode(EFFECT_MUST_ATTACK)
        ec4:SetRange(LOCATION_MZONE)
        ec4:SetTargetRange(0, LOCATION_MZONE)
        ec4:SetTarget(function(e, c) return c == ac end)
        ec4:SetCondition(function(e)
            return Duel.GetTurnPlayer() == 1 - e:GetHandlerPlayer() and
                       Duel.IsBattlePhase()
        end)
        token:RegisterEffect(ec4)
        local ec4b = ec4:Clone()
        ec4b:SetCode(EFFECT_MUST_ATTACK_MONSTER)
        ec4b:SetValue(function(e, c) return c == e:GetHandler() end)
        c:RegisterEffect(ec4b)
    end
end

function s.e2filter(c)
    return c:IsFaceup() and c:IsAttackBelow(500) and c:IsDefenseBelow(500) and
               c:IsReleasableByEffect()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_MZONE, 0, 1,
                                           nil) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > -1 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp, PALLADIUM_TOKEN,
                                                        0x13a, TYPES_TOKEN, -2,
                                                        -2, 1, RACE_FAIRY,
                                                        ATTRIBUTE_LIGHT)
    end

    Duel.SetOperationInfo(0, CATEGORY_RELEASE, nil, 1, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 1, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_RELEASE, tp, s.e2filter, tp,
                                          LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if not tc then return end
    local atk = tc:GetAttack()
    local def = tc:GetDefense()
    if not tc or Duel.Release(tc, REASON_EFFECT) == 0 then return end

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if ft <= 0 then return end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp, PALLADIUM_TOKEN, 0x13a,
                                                TYPES_TOKEN, atk, def, 1,
                                                RACE_FAIRY, ATTRIBUTE_LIGHT) then
        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 1))
    local ac = ft == 1 and ft or Duel.AnnounceNumberRange(tp, 1, ft)

    for i = 1, ac, 1 do
        local token = Duel.CreateToken(tp, PALLADIUM_TOKEN)
        Duel.SpecialSummonStep(token, 0, tp, tp, false, false,
                               POS_FACEUP_DEFENSE)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        token:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_SET_DEFENSE)
        ec1b:SetValue(def)
        token:RegisterEffect(ec1b)
    end
    Duel.SpecialSummonComplete()
end
