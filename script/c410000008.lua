--Divine Flames Of Sun Phoenix
local root,id=GetID()

root.listed_names={10000010,10000080,10000090,83764718}

function root.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(root.e1tg)
	e1:SetOperation(root.e1op)
	c:RegisterEffect(e1)

	--monster reborn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCost(root.e2cost)
	e2:SetTarget(root.e2tg)
	e2:SetOperation(root.e2op)
	c:RegisterEffect(e2)

	--gain lp
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id)
	e3:SetCondition(root.e3con)
	e3:SetTarget(root.e3tg)
	e3:SetOperation(root.e3op)
	c:RegisterEffect(e3)
end

function root.e1filter(c)
	return c:IsCode(10000010,10000080,10000090) and c:IsAbleToHand()
end

function root.e1tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e1filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function root.e1op(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.SelectMatchingCard(tp,root.e1filter,tp,LOCATION_DECK,0,1,1,nil)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

function root.e2filter1(c)
	return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsDiscardable()
end

function root.e2filter2(c)
	return c:IsCode(83764718) and c:IsAbleToHand()
end

function root.e2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e2filter1,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,root.e2filter1,1,1,REASON_COST+REASON_DISCARD)
end

function root.e2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e2filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function root.e2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,root.e2filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

	--allow summon via monster reborn
	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_FIELD)
	ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ec1:SetCode(100424006)
	ec1:SetTargetRange(1,0)
	ec1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ec1,tp)

	--flag cards summoned by monster reborn
	local ec2=Effect.CreateEffect(c)
	ec2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ec2:SetCode(EVENT_SPSUMMON_SUCCESS)
	ec2:SetOperation(root.e2regop)
	ec2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ec2,tp)

	--send to grave
	local ec3=Effect.CreateEffect(c)
	ec3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ec3:SetCode(EVENT_PHASE+PHASE_END)
	ec3:SetCountLimit(1)
	ec3:SetOperation(root.e2gyop)
	ec3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ec3,tp)
end

function root.e2regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(function(c,tp,re)
		local code1,code2=c:GetOriginalCodeRule()
		return c:IsFaceup() and (code1==CARD_RA or code2==CARD_RA) and c:IsControler(tp) and re and re:GetHandler():IsCode(83764718)
	end,nil,tp,re)
	if #g==0 then return end

	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end

function root.e2gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(function(c)
		local code1,code2=c:GetOriginalCodeRule()
		return (code1==CARD_RA or code2==CARD_RA) and c:GetFlagEffect(id)~=0
	end,tp,LOCATION_MZONE,0,nil)

	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function root.e3filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DIVINE)
end

function root.e3con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DIVINE) end,tp,LOCATION_MZONE,0,1,nil)
end

function root.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,root.e3filter,1,false,nil,nil) end
	
	local g=Duel.SelectReleaseGroupCost(tp,root.e3filter,1,1,false,nil,nil)
	local hp=g:GetFirst():GetAttack()

	Duel.Release(g,REASON_COST)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(hp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,hp)
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_FIELD)
	ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ec1:SetCode(EFFECT_CHANGE_DAMAGE)
	ec1:SetTargetRange(1,0)
	ec1:SetValue(0)
	ec1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ec1,tp)
	local ec2=ec1:Clone()
	ec2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	Duel.RegisterEffect(ec2,tp)
end