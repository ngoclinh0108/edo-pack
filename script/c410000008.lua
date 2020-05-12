--Divine Flames Of Sun Phoenix
local root,id=GetID()

root.listed_names={10000010,10000080,10000090,83764718}

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

	--monster reborn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
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
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id)
	e3:SetCondition(root.e3con)
	e3:SetTarget(root.e3tg)
	e3:SetOperation(root.e3op)
	c:RegisterEffect(e3)

	--no lp cost
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id)
	e4:SetCondition(root.e4con)
	e4:SetOperation(root.e4op)
	c:RegisterEffect(e4)

	--summon ra
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,5))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1,id)
	e5:SetCost(root.e5cost)
	e5:SetTarget(root.e5tg)
	e5:SetOperation(root.e5op)
	c:RegisterEffect(e5)
end

function root.e1filter(c)
	return c:IsCode(10000010,10000080,10000090) and c:IsAbleToHand()
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

function root.e4con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c)
		if c:IsFacedown() then return false end
		local code1,code2=c:GetOriginalCodeRule()
		return (code1==CARD_RA or code2==CARD_RA)
			or (code1==10000080 or code2==10000080)
			or (code1==10000090 or code2==10000090)
	end,tp,LOCATION_MZONE,0,1,nil)
end

function root.e4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_FIELD)
	ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ec1:SetCode(EFFECT_LPCOST_CHANGE)
	ec1:SetTargetRange(1,0)
	ec1:SetValue(0)
	ec1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ec1,tp)
end

function root.e5filter1(c,ft,tp)
	local code1,code2=c:GetOriginalCodeRule()
	return (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		and (code1==10000080 or code2==10000080)
end

function root.e5filter2(c,e,tp)
	return c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function root.e5cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupCost(tp,root.e5filter1,1,false,nil,nil,ft,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,root.e5filter1,1,1,false,nil,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end

function root.e5tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:GetSequence()<5 then ft=ft+1 end

	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(root.e5filter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function root.e5op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,root.e5filter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local ec1=Effect.CreateEffect(tc)
		ec1:SetType(EFFECT_TYPE_SINGLE)
		ec1:SetCode(EFFECT_SET_BASE_ATTACK)
		ec1:SetValue(4000)
		ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ec1)
		local ec2=ec1:Clone()
		ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
		tc:RegisterEffect(ec2)
	end
	Duel.SpecialSummonComplete()
end