-- The Wicked Avatar
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
    Divine.RegisterEffect(c, splimit)

    -- return
    local spreturn = Effect.CreateEffect(c)
    spreturn:SetDescription(0)
    spreturn:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    spreturn:SetRange(LOCATION_MZONE)
    spreturn:SetCode(EVENT_PHASE + PHASE_END)
    spreturn:SetCountLimit(1)
    spreturn:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsSummonType(SUMMON_TYPE_SPECIAL) then return false end
        return (c:IsPreviousLocation(LOCATION_HAND) and c:IsAbleToHand()) or
                   (c:IsPreviousLocation(LOCATION_DECK + LOCATION_EXTRA) and
                       c:IsAbleToDeck()) or
                   (c:IsPreviousLocation(LOCATION_GRAVE) and c:IsAbleToGrave()) or
                   (c:IsPreviousLocation(LOCATION_REMOVED) and
                       c:IsAbleToRemove())
    end)
    spreturn:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsPreviousLocation(LOCATION_HAND) then
            Duel.SendtoHand(c, nil, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_DECK) then
            Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_GRAVE) then
            Duel.SendtoGrave(c, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_REMOVED) then
            Duel.Remove(c, c:GetPreviousPosition(), REASON_EFFECT)
        end
    end)
    Divine.RegisterEffect(c, spreturn)
    
    -- act limit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetOperation(s.e1op)
    Divine.RegisterEffect(c, e1)

    -- atk/def
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_REPEAT +
                       EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_SET_ATTACK_FINAL)
    e2:SetValue(s.e2val)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    Divine.RegisterEffect(c, e2b)
    local e2c = Effect.CreateEffect(c)
    e2c:SetType(EFFECT_TYPE_SINGLE)
    e2c:SetCode(21208154)
    Divine.RegisterEffect(c, e2c)

    -- indes & no damage
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetValue(function(e, tc)
        return Divine.GetDivineHierarchy(e:GetHandler()) >
                   Divine.GetDivineHierarchy(tc)
    end)
    Divine.RegisterEffect(c, e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    Divine.RegisterEffect(c, e3b)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
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
    ec2:SetOperation(s.e1turnop)
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
        s.e1turnop(e:GetLabelObject(), tp, eg, ep, ev, e, r, rp)
    end)
    ec3:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
    Divine.RegisterEffect(c, ec3)
end

function s.e1turnop(e, tp, eg, ep, ev, re, r, rp)
    local ct = e:GetLabel() + 1
    e:GetHandler():SetTurnCounter(ct)
    e:SetLabel(ct)

    if ct == 2 then
        e:GetLabelObject():Reset()
        if re then re:Reset() end
    end
end

function s.e2filter(c) return c:IsFaceup() and not c:IsHasEffect(21208154) end

function s.e2val(e)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter, 0, LOCATION_MZONE,
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
