--Egyptian God Slime II
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

	--limit attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(root.e2tg)
	c:RegisterEffect(e2)

	--cannot activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(root.e3val)
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

function root.e2tg(e,c)
	return c:GetAttack()<e:GetHandler():GetAttack()
end

function root.e3val(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetAttack()<e:GetHandler():GetAttack()
end