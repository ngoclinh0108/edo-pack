-- Avatar the Wicked God
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 2

function s.initial_effect(c)
    Divine.AddProcedure(c, "wicked")
    Divine.ToGraveLimit(c)

    -- atk & def
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(id)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_REPEAT +
                        EFFECT_FLAG_DELAY)
    e1b:SetCode(EFFECT_SET_BASE_ATTACK)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetValue(s.e1val)
    c:RegisterEffect(e1b)
    local e1c = e1b:Clone()
    e1c:SetCode(EFFECT_SET_ATTACK_FINAL)
    c:RegisterEffect(e1c)
    local e1d = e1b:Clone()
    e1d:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e1d)
    local e1e = e1b:Clone()
    e1e:SetCode(EFFECT_SET_DEFENSE_FINAL)
    c:RegisterEffect(e1e)
end

function s.e1filter(c) return c:IsFaceup() and not c:IsHasEffect(id) end

function s.e1val(e, tc)
    local c = e:GetOwner()
    local g = Duel.GetMatchingGroup(s.e1filter, 0, LOCATION_MZONE,
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
