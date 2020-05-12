--Sun God's Descendant
local root,id=GetID()

function root.initial_effect(c)
	--cannot be tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_DIVINE))
	c:RegisterEffect(e1)

	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(root.e2con)
	e2:SetTarget(root.e2tg)
	e2:SetOperation(root.e2op)
	c:RegisterEffect(e2)

	--recover
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCondition(root.e3con)
	e3:SetTarget(root.e3tg)
	e3:SetOperation(root.e3op)
	c:RegisterEffect(e3)
end

function root.e2con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end

function root.e2filter(c,e,tp)
	return c:IsCode(410000004,410000005,410000006) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function root.e2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(root.e2filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end

	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function root.e2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsDefensePos() then return end
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,root.e2filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_FIELD)
	ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ec1:SetCode(EFFECT_CANNOT_SUMMON)
	ec1:SetTargetRange(1,0)
	ec1:SetTarget(function(e,tc,sump,sumtype,sumpos,targetp) return not tc:IsAttribute(ATTRIBUTE_DIVINE) end)
	ec1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ec1,tp)
	local ec2=ec1:Clone()
	ec2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(ec2,tp)
end

function root.e3con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end

function root.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end