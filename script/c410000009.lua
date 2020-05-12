--Divine Lightning Of Sky Dragon
local root,id=GetID()

root.listed_names={10000020}

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

	--draw & destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetTarget(root.e2tg)
	e2:SetOperation(root.e2op)
	c:RegisterEffect(e2)
end

function root.e1filter(c)
	return c:IsCode(10000020) and c:IsAbleToHand()
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

function root.e2filter1(c)
	local code1,code2=c:GetOriginalCodeRule()
	return c:IsFaceup() and (code1==10000020 or code2==10000020)
end

function root.e2filter2(c,sc)
	return c:GetAttack()<sc:GetAttack() or c:GetDefense()<sc:GetAttack()
end

function root.e2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e2filter1,tp,LOCATION_MZONE,0,1,nil) end
	
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(5-ht)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,5-ht)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,0,0)
end

function root.e2op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,root.e2filter1,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not sc then return end

	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ht=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if ht<5 then Duel.Draw(p,5-ht,REASON_EFFECT) end

	local dg=Duel.GetMatchingGroup(root.e2filter2,tp,0,LOCATION_MZONE,nil,sc)
	Duel.Destroy(dg,REASON_EFFECT)
end