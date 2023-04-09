-- The Wicked Deity Avatar
Duel.LoadScript("c419.lua")
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2)

    -- cannot special summon
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- atk/def value
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_DELAY + EFFECT_FLAG_REPEAT + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    c:RegisterEffect(e1b)
    local e1check = Effect.CreateEffect(c)
    e1check:SetType(EFFECT_TYPE_SINGLE)
    e1check:SetCode(21208154)
    c:RegisterEffect(e1check)

    -- battle destruction
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(511010508)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetTarget(function(e, tc)
        local c = e:GetHandler()
        local bc = e:GetHandler():GetBattleTarget()
        return bc and bc == tc and Divine.GetDivineHierarchy(tc) <= Divine.GetDivineHierarchy(c)
    end)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- prevent activations
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1val(e)
    local c = e:GetHandler()

    local atk = 0
    local g = Duel.GetMatchingGroup(function(tc) return tc:IsFaceup() and not tc:IsHasEffect(21208154) end, 0, LOCATION_MZONE,
        LOCATION_MZONE, nil)
    if #g > 0 then
        local tg, val = g:GetMaxGroup(Card.GetAttack)
        if not tg:IsExists(aux.TRUE, 1, c) then
            g:RemoveCard(c)
            tg, val = g:GetMaxGroup(Card.GetAttack)
        end

        atk = val
    end

    if atk >= c:GetBaseAttack() then
        return atk + 100
    else
        return c:GetBaseAttack()
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Utility.HintCard(c)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec1:SetTargetRange(0, 1)
    ec1:SetValue(function(e, re, tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
    ec1:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_PHASE + PHASE_END)
    ec2:SetCountLimit(1)
    ec2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() ~= tp end)
    ec2:SetOperation(s.e3turnop)
    ec2:SetLabelObject(ec1)
    ec2:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    Duel.RegisterEffect(ec2, tp)

    local descnum = tp == c:GetOwner() and 0 or 1
    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_SINGLE)
    ec3:SetDescription(aux.Stringid(id, descnum))
    ec3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SET_AVAILABLE)
    ec3:SetCode(1082946)
    ec3:SetLabelObject(ec2)
    ec3:SetOwnerPlayer(tp)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) s.e3turnop(e:GetLabelObject(), tp, eg, ep, ev, e, r, rp) end)
    ec3:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    c:RegisterEffect(ec3)
end

function s.e3turnop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = e:GetLabel() + 1
    c:SetTurnCounter(ct)

    if ct == 2 then
        c:SetTurnCounter(0)
        e:GetLabelObject():Reset()
        if re then re:Reset() end
    else
        e:SetLabel(ct)
    end
end
