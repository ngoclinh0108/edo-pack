-- Slifer the Sky Divine Dragon
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 1

function s.initial_effect(c)
    Divine.AddProcedure(c, 'egyptian', nil, true)

    -- atk/def
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c)
        return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_HAND, 0) *
                   1000
    end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e1b)

    -- atk/def down
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2c)
end

function s.e2filter(c, e, tp)
    return c:IsControler(tp) and c:IsPosition(POS_FACEUP) and
               (not e or c:IsRelateToEffect(e))
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e2filter, 1, nil, nil, 1 - tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetOwner():IsRelateToEffect(e) end
    Duel.SetTargetCard(eg)
    Duel.SetChainLimit(s.e2actlimit(eg))
end

function s.e2actlimit(g)
    return function(e, lp, tp) return not g:IsContains(e:GetOwner()) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    local g = eg:Filter(s.e2filter, nil, e, 1 - tp)
    local dg = Group.CreateGroup()

    for tc in aux.Next(g) do
        if tc:IsPosition(POS_FACEUP_ATTACK) then
            local preatk = tc:GetAttack()
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_UPDATE_ATTACK)
            ec1:SetValue(-2000)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
            if preatk > 0 and tc:GetAttack() == 0 then dg:AddCard(tc) end
        elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
            local predef = tc:GetDefense()
            local ec2 = Effect.CreateEffect(c)
            ec2:SetType(EFFECT_TYPE_SINGLE)
            ec2:SetCode(EFFECT_UPDATE_DEFENSE)
            ec2:SetValue(-2000)
            ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec2)
            if predef > 0 and tc:GetDefense() == 0 then
                dg:AddCard(tc)
            end
        end
    end
    Duel.Destroy(dg, REASON_EFFECT)
end
