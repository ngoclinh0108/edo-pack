--Nameless King of Divine Beasts
local root,id=GetID()

root.listed_names={10000000,10000010,10000020,410000006,410000007,410000008}

function root.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(root.e1tg)
	e1:SetOperation(root.e1op)
	c:RegisterEffect(e1)

	--salvage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(root.e2con)
	e2:SetTarget(root.e2tg)
	e2:SetOperation(root.e2op)
	c:RegisterEffect(e2)
end

function root.e1checkfilter(c,tp,mcode,scode)
	local code1,code2=c:GetOriginalCodeRule()
	return c:IsFaceup() and (code1==mcode or code2==mcode)
		and Duel.IsExistingMatchingCard(root.e1tgfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,scode)
end

function root.e1tgfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end

function root.e1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e1checkfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,10000000,410000006)
		or Duel.IsExistingMatchingCard(root.e1checkfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,10000020,410000007)
		or Duel.IsExistingMatchingCard(root.e1checkfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,10000010,410000008) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function root.e1op(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()

	if Duel.IsExistingMatchingCard(root.e1checkfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,10000000,410000006) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		g:Merge(Duel.SelectMatchingCard(tp,root.e1tgfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,410000006))
	end
	if Duel.IsExistingMatchingCard(root.e1checkfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,10000020,410000007) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		g:Merge(Duel.SelectMatchingCard(tp,root.e1tgfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,410000007))
	end
	if Duel.IsExistingMatchingCard(root.e1checkfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,10000010,410000008) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		g:Merge(Duel.SelectMatchingCard(tp,root.e1tgfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,410000008))
	end

	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function root.e2filter(c,code)
	local code1,code2=c:GetOriginalCodeRule()
	return c:IsFaceup() and (code1==code or code2==code)
end

function root.e2con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (Duel.GetTurnCount()~=c:GetTurnID() or c:IsReason(REASON_RETURN))
		and Duel.IsExistingMatchingCard(root.e2filter,tp,LOCATION_ONFIELD,0,1,nil,10000000)
		and Duel.IsExistingMatchingCard(root.e2filter,tp,LOCATION_ONFIELD,0,1,nil,10000010)
		and Duel.IsExistingMatchingCard(root.e2filter,tp,LOCATION_ONFIELD,0,1,nil,10000020)
end

function root.e2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function root.e2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	Duel.SendtoHand(c,nil,REASON_EFFECT)
end