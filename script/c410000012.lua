--Divine Evolution
local root,id=GetID()

function root.initial_effect(c)
	--gain hierarchy & atk
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(root.e1tg)
	e1:SetOperation(root.e1op)
	c:RegisterEffect(e1)
end

function root.e1filter1(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DIVINE)
end

function root.e1filter2(c,sc,e,tp)
	return c.divine_evolution and c.divine_evolution==sc:GetCode() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function root.e1tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e1filter1,tp,LOCATION_MZONE,0,1,nil) end
end

function root.e1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,root.e1filter1,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc or tc:IsFacedown() then return end

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ec1:SetCode(EFFECT_SET_BASE_ATTACK)
	ec1:SetValue(tc:GetBaseAttack()+1000)
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(ec1)
	local ec2=ec1:Clone()
	ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
	ec2:SetValue(tc:GetBaseDefense()+1000)
	tc:RegisterEffect(ec2)

	local sc=Duel.SelectMatchingCard(tp,root.e1filter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tc,e,tp):GetFirst()
	if not sc then return end
	Duel.Release(tc,REASON_COST)
	Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()
end
