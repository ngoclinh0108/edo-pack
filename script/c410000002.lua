-- Slifer the Sky Divine Dragon
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.SetHierarchy(s, 1)
    Divine.DivineImmunity(c, "egyptian")
    Divine.ToGraveLimit(c)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_THUNDER + RACE_DRAGON)
    c:RegisterEffect(e1)

    -- atk/def
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_SET_BASE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e2b)

    -- atk/def down
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3b)
    local e3c = e3:Clone()
    e3c:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3c)
end

function s.e2val(e, c)
    return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_HAND, 0) * 1000
end

function s.e3filter(c, e, tp)
    return c:IsControler(tp) and c:IsPosition(POS_FACEUP) and
               (not e or c:IsRelateToEffect(e))
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e3filter, 1, nil, nil, 1 - tp)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsRelateToEffect(e) end
    Duel.SetTargetCard(eg)
    Duel.SetChainLimit(s.e3actlimit(eg))
end

function s.e3actlimit(g)
    return function(e, lp, tp) return not g:IsContains(e:GetHandler()) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = eg:Filter(s.e3filter, nil, e, 1 - tp)
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
