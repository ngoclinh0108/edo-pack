--Divine Wrath Of Giant Tormentor
local root,id=GetID()

root.listed_names={10000000}

function root.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(root.e1tg)
	e1:SetOperation(root.e1op)
	c:RegisterEffect(e1)

	--gain atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetTarget(root.e2tg)
	e2:SetOperation(root.e2op)
	c:RegisterEffect(e2)
end

function root.e1filter(c)
	return c:IsCode(10000000) and c:IsAbleToHand()
end

function root.e1tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e1filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function root.e1op(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.SelectMatchingCard(tp,root.e1filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

function root.e2filter(c,tp)
	local code1,code2=c:GetOriginalCodeRule()
	return c:IsFaceup() and (code1==10000000 or code2==10000000)
		and Duel.CheckReleaseGroupCost(tp,nil,2,false,nil,c)
end

function root.e2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e2filter,tp,LOCATION_MZONE,0,1,nil,tp) end
end

function root.e2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,root.e2filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	if not sc then return end

	local g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,nil,sc)
	if Duel.Release(g,REASON_COST)==0 then return end

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
	ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
	ec1:SetRange(LOCATION_MZONE)
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	ec1:SetValue(1000000)
	sc:RegisterEffect(ec1)
end
