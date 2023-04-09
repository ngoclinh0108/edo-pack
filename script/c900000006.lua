-- The Wicked Deity Dreadroot
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.WickedGod(s, c, 1)

    -- act limit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Duel.SetChainLimitTillChainEnd(aux.FALSE) end)
    c:RegisterEffect(e1)

    -- untargetable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- half atk/def
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EFFECT_SET_ATTACK_FINAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e3:SetTarget(function(e, tc)
        local c = e:GetHandler()
        return tc ~= e:GetHandler() and Divine.GetDivineHierarchy(tc) <= Divine.GetDivineHierarchy(c)
    end)
    e3:SetValue(function(e, c) return math.ceil(c:GetAttack() / 2) end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e3b:SetValue(function(e, c) return math.ceil(c:GetDefense() / 2) end)
    c:RegisterEffect(e3b)
end
