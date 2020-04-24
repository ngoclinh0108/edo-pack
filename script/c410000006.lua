--Divine Wrath Of Giant Tormentor
local root,id=GetID()

root.listed_names={10000000}

function root.initial_effect(c)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(root.e2cost)
	e2:SetTarget(root.e2tg)
	e2:SetOperation(root.e2op)
	c:RegisterEffect(e2)
end

function root.e2filter(c)
	return c:IsCode(10000000) and c:IsAbleToHand()
end

function root.e2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

function root.e2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e2filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function root.e2op(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstMatchingCard(root.thfilter,tp,LOCATION_DECK,0,nil)
	if tc then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end