-- Avatar the Wicked God
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.SetHierarchy(s, 2)
    Divine.DivineImmunity(c, "wicked")
    Divine.ToGraveLimit(c)

    -- attribute & race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_ADD_RACE)
    e1b:SetValue(RACE_FIEND)
    c:RegisterEffect(e1b)

    -- atk & def
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(id)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_SINGLE)
    e2b:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_REPEAT +
                        EFFECT_FLAG_DELAY)
    e2b:SetCode(EFFECT_SET_BASE_ATTACK)
    e2b:SetRange(LOCATION_MZONE)
    e2b:SetValue(s.e2val)
    c:RegisterEffect(e2b)
    local e2c = e2b:Clone()
    e2c:SetCode(EFFECT_SET_ATTACK_FINAL)
    c:RegisterEffect(e2c)
    local e2d = e2b:Clone()
    e2d:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e2d)
    local e2e = e2b:Clone()
    e2e:SetCode(EFFECT_SET_DEFENSE_FINAL)
    c:RegisterEffect(e2e)

    -- act limit
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0, 1)
    e3:SetCondition(s.e3con)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
end

function s.e2filter(c, divine_hierarchy)
    return c:IsFaceup() and not c:IsHasEffect(id) and
               (not c.divine_hierarchy or c.divine_hierarchy <= divine_hierarchy)
end

function s.e2val(e, tc)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter, 0, LOCATION_MZONE,
                                    LOCATION_MZONE, nil, c.divine_hierarchy)

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

function s.e3con(e)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c or Duel.GetAttackTarget() == c
end

function s.e3val(e, re, tp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    return not rc.divine_hierarchy or rc.divine_hierarchy <= c.divine_hierarchy
end
