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

	--instant
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e3:SetCountLimit(1,id+2000000)
	e3:SetCondition(root.e3con)
	e3:SetTarget(root.e3tg)
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
	return c:IsAttribute(ATTRIBUTE_DIVINE) and (c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1))
end

function root.e3con(e,tp,eg,ep,ev,re,r,rp)
	local tn=Duel.GetTurnPlayer()
	local ph=Duel.GetCurrentPhase()
	return tn~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
end

function root.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e3filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,root.e3filter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if not tc then return end

	local s1=tc:IsSummonable(true,nil,1)
	local s2=tc:IsMSetable(true,nil,1)
	if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
		Duel.Summon(tp,tc,true,nil,1)
	else
		Duel.MSet(tp,tc,true,nil,1)
	end
end