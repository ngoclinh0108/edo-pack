--Egyptian God Slime III
local root,id=GetID()

function root.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),root.fusfilter)

	--special summon rule
	local spr=Effect.CreateEffect(c)
	spr:SetType(EFFECT_TYPE_FIELD)
	spr:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	spr:SetCode(EFFECT_SPSUMMON_PROC)
	spr:SetRange(LOCATION_EXTRA)
	spr:SetCondition(root.sprcon)
	spr:SetOperation(root.sprop)
	c:RegisterEffect(spr)

	--triple tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRIPLE_TRIBUTE)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	--battle target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(function(e,c) return c~=e:GetHandler() end)
	c:RegisterEffect(e3)
end

function root.fusfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,fc,sumtype,tp) and c:GetLevel()==10
end

function root.sprfilter(c,tp,sc)
	return c:IsRace(RACE_AQUA) and c:GetLevel()==10 and c:GetAttack()==0 and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end

function root.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,root.sprfilter,1,nil,tp,c)
end

function root.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,root.sprfilter,1,1,nil,tp,c)
	Duel.Release(g,g,REASON_COST+REASON_MATERIAL)
end
