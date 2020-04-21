--Millennium War
local root,id=GetID()

function root.RegisterGlobalEffect(c,eff,filter,param1,param2,param3,param4,param5)
	local g=Duel.GetMatchingGroup(filter,c:GetControler(),LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD,0,nil,param1,param2,param3,param4,param5)

	for tc in aux.Next(g) do
		tc:RegisterEffect(eff:Clone())
	end
end

function root.initial_effect(c)
	--activate
	local act=Effect.CreateEffect(c)
	act:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	act:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	act:SetCode(EVENT_PREDRAW)
	act:SetRange(0x5f)
	act:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	act:SetOperation(root.actop)
	c:RegisterEffect(act)

	--immune
	local immune=Effect.CreateEffect(c)
	immune:SetType(EFFECT_TYPE_SINGLE)
	immune:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	immune:SetCode(EFFECT_IMMUNE_EFFECT)
	immune:SetValue(1)
	c:RegisterEffect(immune)
	local immuneb=immune:Clone()
	immuneb:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(immuneb)
	local immunec=immune:Clone()
	immunec:SetCode(EFFECT_CANNOT_TO_DECK)
	c:RegisterEffect(immunec)
	local immuned=immune:Clone()
	immuned:SetCode(EFFECT_CANNOT_TO_GRAVE)
	c:RegisterEffect(immuned)
	local immunee=immune:Clone()
	immunee:SetCode(EFFECT_CANNOT_REMOVE)
	c:RegisterEffect(immunee)

	--to bottom deck
	local tobot=Effect.CreateEffect(c)
	tobot:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	tobot:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	tobot:SetCode(EVENT_ADJUST)
	tobot:SetRange(0x5f)
	tobot:SetTarget(root.tobottg)
	tobot:SetOperation(root.tobotop)
	c:RegisterEffect(tobot)

	--properly summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(0x5f)
	e1:SetCondition(root.e1con)
	e1:SetOperation(root.e1op)
	c:RegisterEffect(e1)

	--summon as face-up defense position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_DEVINE_LIGHT)
	e2:SetRange(0x5f)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)

	--set dice result
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TOSS_DICE_NEGATE)
	e3:SetRange(0x5f)
	e3:SetCondition(root.e3con)
	e3:SetOperation(root.e3op)
	c:RegisterEffect(e3)

	--set coin result
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TOSS_COIN_NEGATE)
	e4:SetRange(0x5f)
	e4:SetCondition(root.e4con)
	e4:SetOperation(root.e4op)
	c:RegisterEffect(e4)

	--time skip
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(0x5f)
	e5:SetCondition(root.e5con)
	e5:SetTarget(root.e5tg)
	e5:SetOperation(root.e5op)
	c:RegisterEffect(e5)

	--create card
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(0x5f)
	e6:SetCondition(root.e6con)
	e6:SetTarget(root.e6tg)
	e6:SetOperation(root.e6op)
	c:RegisterEffect(e6)

	--protect card
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(0x5f)
	e7:SetCondition(root.e7con)
	e7:SetTarget(root.e7tg)
	e7:SetOperation(root.e7op)
	c:RegisterEffect(e7)

	--reset game
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,4))
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(0x5f)
	e8:SetCondition(root.e8con)
	e8:SetTarget(root.e8tg)
	e8:SetOperation(root.e8op)
	c:RegisterEffect(e8)

	--add card to your hand
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(506)
	e9:SetType(EFFECT_TYPE_QUICK_O)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetRange(0x5f)
	e9:SetCondition(root.e9con)
	e9:SetTarget(root.e9tg)
	e9:SetOperation(root.e9op)
	c:RegisterEffect(e9)

	--add card to your graveyard
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(504)
	e10:SetType(EFFECT_TYPE_QUICK_O)
	e10:SetCode(EVENT_FREE_CHAIN)
	e10:SetRange(0x5f)
	e10:SetCondition(root.e10con)
	e10:SetTarget(root.e10tg)
	e10:SetOperation(root.e10op)
	c:RegisterEffect(e10)
end

function root.actop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.GetMatchingGroup(function (c) return c.deck_edit or c.global_effect end,tp,0x5f,0,nil)

	local deck_edit=Group.CreateGroup()
	for tc in aux.Next(g) do
		if tc.deck_edit and not deck_edit:IsExists(root.IsOriginalCode,1,nil,tc:GetOriginalCode()) then
			tc.deck_edit(c110000000,tp)
			deck_edit:AddCard(tc)
		end
	end

	local global_effect=Group.CreateGroup()
	for tc in aux.Next(g) do
		if tc.global_effect and not global_effect:IsExists(root.IsOriginalCode,1,nil,tc:GetOriginalCode()) then
			tc.global_effect(tc,c110000000,tp)
			global_effect:AddCard(tc)
		end
	end
end

function root.tobottg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsLocation(LOCATION_DECK) or c:GetSequence()~=0 end
end

function root.tobotop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local isdraw=c:IsLocation(LOCATION_HAND) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
	
	if c:IsLocation(LOCATION_DECK) then Duel.MoveSequence(c,1)
	else Duel.SendtoDeck(c,nil,1,REASON_RULE) end
	c:ReverseInDeck()

	if isdraw then Duel.Draw(tp,1,REASON_DRAW) end
end

function root.e1filter(c,tp)
	return c:GetSummonPlayer()==tp
end

function root.e1con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(root.e1filter,1,nil,tp)
end

function root.e1op(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(root.e1filter,nil,tp)
	if tg:GetCount()==0 then return end

	for tc in aux.Next(tg) do
		tc:CompleteProcedure()
	end
end

function root.e3con(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if root[0]~=cid and Duel.SelectYesNo(tp,553) then
		Duel.Hint(HINT_CARD,0,id)

		local t={}
		for i=1,7 do t[i]=i end

		local res={Duel.GetDiceResult()}
		local ct=bit.band(ev,0xff)+bit.rshift(ev,16)
		for i=1,ct do
			res[i]=Duel.AnnounceNumber(tp,table.unpack(t))
		end

		Duel.SetDiceResult(table.unpack(res))
		root[0]=cid
	end
end

function root.e4con(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end

function root.e4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if root[1]~=cid and Duel.SelectYesNo(tp,552) then
		Duel.Hint(HINT_CARD,0,id)

		local res={Duel.GetCoinResult()}
		local ct=ev
		for i=1,ct do
			local ac=Duel.SelectOption(tp,60,61)
			if ac==0 then ac=1 else ac=0 end
			res[i]=ac
		end

		Duel.SetCoinResult(table.unpack(res))
		root[1]=cid
	end
end

function root.e5con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentChain()<=0
end

function root.e5tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(aux.FALSE)
end

function root.e5op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	
	if ph<=PHASE_DRAW then Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,1) end
	if ph<=PHASE_STANDBY then Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1) end
	if ph<=PHASE_MAIN1 then Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1) end
	if ph<=PHASE_BATTLE then Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1) end
	if ph<=PHASE_MAIN2 then Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1) end
	if ph<=PHASE_END then Duel.SkipPhase(tp,PHASE_END,RESET_PHASE+PHASE_END,1) end
	
	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_FIELD)
	ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ec1:SetCode(EFFECT_SKIP_TURN)
	ec1:SetTargetRange(0,1)
	ec1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(ec1,tp)

	local ec2=Effect.CreateEffect(c)
	ec2:SetType(EFFECT_TYPE_FIELD)
	ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ec2:SetCode(EFFECT_CANNOT_EP)
	ec2:SetTargetRange(1,0)
	ec2:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
	Duel.RegisterEffect(ec2,tp)

	Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,2)
end

function root.e6con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()<=0
end

function root.e6tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end

	getmetatable(c).announce_filter={id,OPCODE_ISCODE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(c).announce_filter))
	Duel.SetTargetParam(ac)

	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end

function root.e6op(e,tp,eg,ep,ev,re,r,rp)
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)

	local card=Duel.CreateToken(tp,code)
	Duel.SendtoDeck(card,nil,2,REASON_RULE)
end

function root.e7filter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)==0
end

function root.e7con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()<=0
end

function root.e7tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(root.e7filter,tp,LOCATION_ONFIELD,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,root.e7filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end

function root.e7op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	
	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ec1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	ec1:SetValue(aux.tgoval)
	tc:RegisterEffect(ec1)
	local ec2=ec1:Clone()
	ec2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	ec2:SetValue(1)
	tc:RegisterEffect(ec2)
	local ec3=ec1:Clone()
	ec3:SetCode(EFFECT_CANNOT_TO_HAND)
	ec3:SetValue(1)
	tc:RegisterEffect(ec2)
	local ec4=ec1:Clone()
	ec4:SetCode(EFFECT_CANNOT_TO_DECK)
	ec4:SetValue(1)
	tc:RegisterEffect(ec4)
	local ec5=ec1:Clone()
	ec5:SetCode(EFFECT_CANNOT_TO_GRAVE)
	ec5:SetValue(1)
	tc:RegisterEffect(ec5)
	local ec6=ec1:Clone()
	ec6:SetCode(EFFECT_CANNOT_REMOVE)
	ec6:SetValue(1)
	tc:RegisterEffect(ec6)
	local ec7=ec1:Clone()
	ec7:SetCode(EFFECT_CANNOT_TURN_SET)
	ec7:SetValue(1)
	tc:RegisterEffect(ec7)
	local ec8=ec1:Clone()
	ec8:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	ec8:SetValue(1)
	tc:RegisterEffect(ec8)
	local ec9=ec1:Clone()
	ec9:SetCode(EFFECT_CANNOT_INACTIVATE)
	ec9:SetValue(1)
	tc:RegisterEffect(ec9)
	local ec10=ec1:Clone()
	ec10:SetCode(EFFECT_CANNOT_DISEFFECT)
	ec10:SetValue(1)
	tc:RegisterEffect(ec10)
	local ec11=ec1:Clone()
	ec11:SetCode(EFFECT_CANNOT_DISABLE)
	ec11:SetValue(1)
	tc:RegisterEffect(ec11)
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
end

function root.e8con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()<=0
end

function root.e8tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local loc=LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,loc,loc,1,nil) end
end

function root.e8op(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED
	local g=Duel.GetMatchingGroup(nil,tp,loc,loc,nil)
	if g:GetCount()==0 then return end
	local tpdraw=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	local opdraw=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)

	Duel.SendtoDeck(g,nil,2,REASON_RULE)
	Duel.ShuffleDeck(tp)
	Duel.ShuffleDeck(1-tp)
	Duel.Draw(tp,tpdraw,REASON_RULE)
	Duel.Draw(1-tp,opdraw,REASON_RULE)
	Duel.SetLP(tp,8000)
	Duel.SetLP(1-tp,8000)
end

function root.e9filter(c)
	if c:IsLocation(LOCATION_EXTRA) and not c:IsAbleToHand() then return false end
	return not c:IsCode(id)
end

function root.e9con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()<=0
end

function root.e9tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_ONFIELD
	if chk==0 then return Duel.IsExistingMatchingCard(root.e9filter,tp,loc,0,1,nil) end
end

function root.e9op(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_ONFIELD

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,root.e9filter,tp,loc,0,1,10,nil)
	if g:GetCount()==0 then return end
		
	Duel.SendtoHand(g,nil,REASON_RULE)
	Duel.ConfirmCards(1-tp,g)
end

function root.e10filter(c)
	return not c:IsCode(id)
end

function root.e10con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()<=0
end

function root.e10tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_ONFIELD
	if chk==0 then return Duel.IsExistingMatchingCard(root.e10filter,tp,loc,0,1,nil) end
end

function root.e10op(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_ONFIELD

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,root.e10filter,tp,loc,0,1,10,nil)
	if g:GetCount()==0 then return end
		
	Duel.SendtoGrave(g,REASON_RULE)
end