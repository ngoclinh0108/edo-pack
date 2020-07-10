-- Dreadroot the Wicked God
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 1

function s.initial_effect(c)
    Divine.AddProcedure(c, "wicked")
    Divine.ToGraveLimit(c)

    -- half atk & def
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetTarget(s.e1tg)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e1b:SetValue(s.e1bval)
    c:RegisterEffect(e1b)

    --pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end

function s.e1tg(e, c) return c:GetControler() ~= e:GetOwner():GetControler() end

function s.e1val(e, c) return math.ceil(c:GetAttack() / 2) end

function s.e1bval(e, c) return math.ceil(c:GetDefense() / 2) end
