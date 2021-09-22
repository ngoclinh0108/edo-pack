-- Wicked God Avatar
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, true, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetValue(ATTRIBUTE_DARK)
    Divine.RegisterEffect(c, e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_ADD_RACE)
    e1b:SetValue(RACE_FIEND)
    Divine.RegisterEffect(c, e1b)

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetOperation(s.e2op)
    Divine.RegisterEffect(c, e2)

    -- atk/def
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_REPEAT +
                       EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_SET_ATTACK_FINAL)
    e3:SetValue(s.e3val)
    Divine.RegisterEffect(c, e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    Divine.RegisterEffect(c, e3b)
    local e3c = Effect.CreateEffect(c)
    e3c:SetType(EFFECT_TYPE_SINGLE)
    e3c:SetCode(21208154)
    Divine.RegisterEffect(c, e3c)

    -- indes & no damage
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetValue(function(e, tc)
        return Divine.GetDivineHierarchy(e:GetHandler()) >
                   Divine.GetDivineHierarchy(tc)
    end)
    Divine.RegisterEffect(c, e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    Divine.RegisterEffect(c, e4b)

    -- no effect damage
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_CHANGE_DAMAGE)
    e5:SetTargetRange(1, 0)
    e5:SetValue(function(e, re, val, r, rp, rc)
        if (r & REASON_EFFECT) ~= 0 then return 0 end
        return val
    end)
    c:RegisterEffect(e5)
    local e5b = e5:Clone()
    e5b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e5b)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec1:SetTargetRange(0, 1)
    ec1:SetValue(function(e, re) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
    ec1:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_PHASE + PHASE_END)
    ec2:SetCountLimit(1)
    ec2:SetLabel(0)
    ec2:SetLabelObject(ec1)
    ec2:SetCondition(function(e, tp) return Duel.GetTurnPlayer() ~= tp end)
    ec2:SetOperation(s.e2turnop)
    ec2:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    Duel.RegisterEffect(ec2, tp)

    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_SINGLE)
    ec3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                        EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SET_AVAILABLE)
    ec3:SetCode(1082946)
    ec3:SetLabelObject(ec2)
    ec3:SetOwnerPlayer(tp)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        s.e2turnop(e:GetLabelObject(), tp, eg, ep, ev, e, r, rp)
    end)
    ec3:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    c:RegisterEffect(ec3)
end

function s.e2turnop(e, tp, eg, ep, ev, re, r, rp)
    local ct = e:GetLabel() + 1
    e:GetHandler():SetTurnCounter(ct)
    e:SetLabel(ct)

    if ct == 2 then
        e:GetLabelObject():Reset()
        if re then re:Reset() end
    end
end

function s.e3filter(c) return c:IsFaceup() and not c:IsHasEffect(21208154) end

function s.e3val(e)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e3filter, 0, LOCATION_MZONE,
                                    LOCATION_MZONE, nil)
    if #g == 0 then
        return 100
    else
        local tg, val = g:GetMaxGroup(Card.GetAttack)
        if not tg:IsExists(aux.TRUE, 1, c) then
            g:RemoveCard(c)
            tg, val = g:GetMaxGroup(Card.GetAttack)
        end

        return val + 100
    end
end
