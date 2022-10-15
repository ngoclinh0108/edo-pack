-- The Wicked God Avatar
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2)

    -- atk/def value
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_DELAY + EFFECT_FLAG_REPEAT)
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
end

function s.e1val(e)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(function(tc)
        return tc:IsFaceup() and not tc:IsHasEffect(21208154)
    end, 0, LOCATION_MZONE, LOCATION_MZONE, nil)
    if #g == 0 then
        return 100
    end

    local tg, val = g:GetMaxGroup(Card.GetAttack)
    if not tg:IsExists(aux.TRUE, 1, c) then
        g:RemoveCard(c)
        tg, val = g:GetMaxGroup(Card.GetAttack)
    end

    return val + 100
end
