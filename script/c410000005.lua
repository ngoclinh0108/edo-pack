--Tri-Divine Advent
local root,id=GetID()

root.listed_names={39913299,10000090}

function root.initial_effect(c)
	--activate
	local act=Effect.CreateEffect(c)
	act:SetType(EFFECT_TYPE_ACTIVATE)
	act:SetCode(EVENT_FREE_CHAIN)
	act:SetTarget(root.acttg)
	act:SetOperation(root.actop)
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

	--no damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(root.e2con)
	e2:SetValue(root.e2val)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e2b)

	--no target, no banish
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_GRAVE,0)
	e3:SetTarget(function(e,tc) return tc:IsAttribute(ATTRIBUTE_DIVINE) end)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_CANNOT_REMOVE)
	e3b:SetValue(1)
	c:RegisterEffect(e3b)

	--ra - immortal phoenix
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_TO_DECK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_GRAVE,0)
	e4:SetTarget(function(e,tc) return tc:IsCode(10000090) end)
	c:RegisterEffect(e4)

	--extra summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e5:SetTarget(function(e,tc) return tc:IsAttribute(ATTRIBUTE_DIVINE) end)
	c:RegisterEffect(e5)

	--look at deck
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1,id+10000)
	e6:SetTarget(root.e6tg)
	e6:SetOperation(root.e6op)
	c:RegisterEffect(e6)

	--reborn
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1,id+20000)
	e7:SetCost(root.e7cost)
	e7:SetTarget(root.e7tg)
	e7:SetOperation(root.e7op)
	c:RegisterEffect(e7)
end

function root.actfilter(c)
	return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsAbleToGrave()
end

function root.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function root.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(root.actfilter),tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
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

function root.e2con(e)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DIVINE)
	end,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

function root.e2val(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 then return 0
	else return val end
end

function root.e6tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end

function root.e6op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end

	Duel.SortDecktop(tp,tp,5)
end

function root.e7filter1(c)
	return c:IsCode(39913299) and c:IsDiscardable()
end

function root.e7filter2(c,e,tp)
	if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then return false end
	return c:IsAttribute(ATTRIBUTE_DIVINE) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

function root.e7cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e7filter1,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,root.e7filter1,1,1,REASON_COST+REASON_DISCARD)
end

function root.e7tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e7filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end

function root.e7op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,root.e7filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()   
	local b1=tc:IsAbleToHand()
	local b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,1105,2)
	elseif b1 then op=Duel.SelectOption(tp,1105)
	else op=Duel.SelectOption(tp,2)+1 end
	if op==0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function root.e7returncon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end

function root.e7returnop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetLabelObject(),nil,2,REASON_RULE)
end