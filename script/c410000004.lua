--Giant God's Descendant
local root,id=GetID()

function root.initial_effect(c)
	--cannot be tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_DIVINE))
	c:RegisterEffect(e1)

	--opponent tribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+1000000)
	e2:SetCost(root.e2cost)
	e2:SetOperation(root.e2op)
	c:RegisterEffect(e2)

	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,id+2000000)
	e3:SetCondition(root.e3con)
	e3:SetOperation(root.e3op)
	c:RegisterEffect(e3)
end

function root.e2filter(c)
	return c:IsAttribute(ATTRIBUTE_DIVINE) and not c:IsPublic()
end

function root.e2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e2filter,tp,LOCATION_HAND,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,root.e2filter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end

function root.e2op(e,tp,eg,ep,ev,re,r,rp)
	local ec1=Effect.CreateEffect(e:GetHandler())
	ec1:SetType(EFFECT_TYPE_FIELD)
	ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	ec1:SetCode(EFFECT_EXTRA_RELEASE_SUM)
	ec1:SetTargetRange(0,LOCATION_MZONE)
	ec1:SetCountLimit(1)
	ec1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ec1,tp)
end

function root.e3filter(c)
	return c:IsFaceup() and not c:IsDisabled()
end

function root.e3con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(root.e3filter,tp,0,LOCATION_ONFIELD,c)
	for tc in aux.Next(g) do
		local ec1=Effect.CreateEffect(c)
		ec1:SetType(EFFECT_TYPE_SINGLE)
		ec1:SetCode(EFFECT_DISABLE)
		ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ec1)
		local ec2=Effect.CreateEffect(c)
		ec2:SetType(EFFECT_TYPE_SINGLE)
		ec2:SetCode(EFFECT_DISABLE_EFFECT)
		ec2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ec2)
	end
end