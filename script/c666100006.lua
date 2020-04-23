--Tri-Divine Advent
local root,id=GetID()

function root.initial_effect(c)
	--activate
	local act=Effect.CreateEffect(c)
	act:SetType(EFFECT_TYPE_ACTIVATE)
	act:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(act)

	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(root.e1con)
	e1:SetTarget(root.e1tg)
	e1:SetOperation(root.e1op)
	c:RegisterEffect(e1)

	--extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(function(e,tc) return tc:IsAttribute(ATTRIBUTE_DIVINE) end)
	c:RegisterEffect(e2)

	--look at deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+10000000)
	e3:SetTarget(root.e3tg)
	e3:SetOperation(root.e3op)
	c:RegisterEffect(e3)

	--copy field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id+20000000)
	e4:SetCost(root.e4cost)
	e4:SetOperation(root.e4op)
	c:RegisterEffect(e4)
end

function root.e1filter(c)
	return c:IsCode(39913299) and c:IsAbleToHand()
end

function root.e1con(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0
end

function root.e1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e1filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end

function root.e1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local dt=Duel.GetDrawCount(tp)
	if dt==0 then return end
	_replace_count=1
	_replace_max=dt

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_FIELD)
	ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ec1:SetCode(EFFECT_DRAW_COUNT)
	ec1:SetTargetRange(1,0)
	ec1:SetValue(0)
	ec1:SetReset(RESET_PHASE+PHASE_DRAW)
	Duel.RegisterEffect(ec1,tp)
	if _replace_count>_replace_max or not e:GetHandler():IsRelateToEffect(e) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(root.e1filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function root.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end

	Duel.SortDecktop(tp,tp,5)
end

function root.e4filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToRemoveAsCost()
end

function root.e4cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(root.e4filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,root.e4filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil):GetFirst()
	e:SetLabel(sc:GetOriginalCode())
	Duel.Remove(sc,POS_FACEUP,REASON_COST)
end

function root.e4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.ChangePosition(c,POS_FACEDOWN)
	Duel.ChangePosition(c,POS_FACEUP)

	local code=e:GetLabel()
	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec1:SetCode(EFFECT_CHANGE_CODE)
	ec1:SetValue(code)
	c:RegisterEffect(ec1)
	
	c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
end