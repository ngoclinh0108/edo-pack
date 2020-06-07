--Tri-Divine Advent
Duel.LoadScript("triplesix_util.lua")
local root,id=GetID()

root.listed_names={39913299}

function root.initial_effect(c)
	--activate
	local act=Effect.CreateEffect(c)
	act:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	act:SetType(EFFECT_TYPE_ACTIVATE)
	act:SetCode(EVENT_FREE_CHAIN)
	act:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
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

	--grave protect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	e2:SetTarget(function(e,tc) return tc:IsAttribute(ATTRIBUTE_DIVINE) end)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_CANNOT_REMOVE)
	e2b:SetValue(1)
	c:RegisterEffect(e2b)

	--extra summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e3:SetTarget(function(e,tc) return tc:IsAttribute(ATTRIBUTE_DIVINE) end)
	c:RegisterEffect(e3)

	--change future
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(root.e4cost)
	e4:SetTarget(root.e4tg)
	e4:SetOperation(root.e4op)
	c:RegisterEffect(e4)

	--divine reincarnation
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,id)
	e5:SetCost(root.e5cost)
	e5:SetTarget(root.e5tg)
	e5:SetOperation(root.e5op)
	c:RegisterEffect(e5)
end

function root.actfilter(c)
	return c:IsCode(39913299) and c:IsAbleToHand()
end

function root.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(root.actfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
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

function root.e4filter(c)
	return c:IsCode(39913299) and not c:IsPublic()
end

function root.e4cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e4filter,tp,LOCATION_HAND,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,root.e4filter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end

function root.e4tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end

function root.e4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end

	Duel.SortDecktop(tp,tp,5)
end

function root.e5filter1(c)
	return c:IsCode(39913299) and c:IsDiscardable()
end

function root.e5filter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DIVINE)
		and (c:IsAbleToHand() or root.e5summoncheck(c,e,tp))
end

function root.e5summoncheck(c,e,tp)
	if c:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED) and c:IsFacedown() then return false end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if (c:IsType(TYPE_LINK) or (c:IsType(TYPE_PENDULUM) and c:IsFaceup()))
		and c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end

function root.e5cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e5filter1,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,root.e5filter1,1,1,REASON_COST+REASON_DISCARD)
end

function root.e5tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e5filter2,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,1,nil,e,tp) end
end

function root.e5op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(root.e5filter2),tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()   
	local b1=tc:IsAbleToHand()
	local b2=root.e5summoncheck(tc,e,tp)
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

function root.e5returncon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end

function root.e5returnop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetLabelObject(),nil,2,REASON_RULE)
end