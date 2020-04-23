--Millennium Hieroglyph
local root,id=GetID()

function root.initial_effect(c)
	local startup=Effect.CreateEffect(c)
	startup:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	startup:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	startup:SetCode(EVENT_STARTUP)
	startup:SetRange(0x5f)
	startup:SetOperation(root.startup)
	c:RegisterEffect(startup)
end

function root.startup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	--skill zone
	Duel.DisableShuffleCheck(true)
	Duel.SendtoDeck(c,tp,-2,REASON_RULE)
	if c:IsPreviousLocation(LOCATION_HAND) then Duel.Draw(p,1,REASON_RULE) end
	e:Reset()
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	
	-- deck edit & global effect
	local g=Duel.GetMatchingGroup(function(tc) return tc.deck_edit or tc.global_effect end,tp,0x5f,0,nil)
	local deck_edit=Group.CreateGroup()
	for tc in aux.Next(g) do
		if tc.deck_edit and not deck_edit:IsExists(root.IsOriginalCode,1,nil,tc:GetOriginalCode()) then
			tc.deck_edit(root,tp)
			deck_edit:AddCard(tc)
		end
	end
	local global_effect=Group.CreateGroup()
	for tc in aux.Next(g) do
		if tc.global_effect and not global_effect:IsExists(root.IsOriginalCode,1,nil,tc:GetOriginalCode()) then
			tc.global_effect(tc,root,tp)
			global_effect:AddCard(tc)
		end
	end

	--complete summoned
	local sum=Effect.CreateEffect(c)
	sum:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	sum:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	sum:SetCode(EVENT_SPSUMMON_SUCCESS)
	sum:SetCondition(root.sumcon)
	sum:SetOperation(root.sumop)
	Duel.RegisterEffect(sum,tp)

	--set dice & coin result
	local dice=Effect.CreateEffect(c)
	dice:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dice:SetCode(EVENT_TOSS_DICE_NEGATE)
	dice:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp end)
	dice:SetOperation(root.diceop)
	Duel.RegisterEffect(dice,tp)
	local coin=dice:Clone()
	coin:SetCode(EVENT_TOSS_COIN_NEGATE)
	coin:SetOperation(root.coinop)
	Duel.RegisterEffect(coin,tp)

	--activate skill
	local skill=Effect.CreateEffect(c)
	skill:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	skill:SetCode(EVENT_FREE_CHAIN)
	skill:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return aux.CanActivateSkill(tp) end)
	skill:SetOperation(root.skillop)
	Duel.RegisterEffect(skill,tp)
end

function root.sumfilter(c,tp)
	return c:GetSummonPlayer()==tp
end

function root.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(root.sumfilter,1,nil,tp)
end

function root.sumop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(root.sumfilter,nil,tp)
	if #tg==0 then return end

	for tc in aux.Next(tg) do
		tc:CompleteProcedure()
	end
end

function root.diceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if root[0]==cid or not Duel.SelectYesNo(tp,553) then return end
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

function root.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if root[1]==cid or not Duel.SelectYesNo(tp,552) then return end
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

function root.skillop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local b3=root.e3con(e,tp,eg,ep,ev,re,r,rp)

	if b3 then
		p=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))+1
	else
		p=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1
	end

	if p==1 then root.e1op(e,tp,eg,ep,ev,re,r,rp)
	elseif p==2 then root.e2op(e,tp,eg,ep,ev,re,r,rp)
	elseif p==3 then root.e3op(e,tp,eg,ep,ev,re,r,rp)
	end
end

function root.e1op(e,tp,eg,ep,ev,re,r,rp)
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

function root.e2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	getmetatable(c).announce_filter={id,OPCODE_ISCODE,OPCODE_NOT}
	local code=Duel.AnnounceCard(tp,table.unpack(getmetatable(c).announce_filter))

	local card=Duel.CreateToken(tp,code)
	Duel.SendtoDeck(card,nil,2,REASON_RULE)
end

function root.e3filter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)==0
end

function root.e3con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(root.e3filter,tp,LOCATION_ONFIELD,0,1,nil)
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,root.e3filter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()

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

--  --reset game
--  local e7=Effect.CreateEffect(c)
--  e7:SetDescription(aux.Stringid(id,4))
--  e7:SetType(EFFECT_TYPE_QUICK_O)
--  e7:SetCode(EVENT_FREE_CHAIN)
--  e7:SetRange(0x5f)
--  e7:SetCondition(root.e7con)
--  e7:SetTarget(root.e7tg)
--  e7:SetOperation(root.e7op)
--  c:RegisterEffect(e7)

--  --add card to your hand
--  local e8=Effect.CreateEffect(c)
--  e8:SetDescription(506)
--  e8:SetType(EFFECT_TYPE_QUICK_O)
--  e8:SetCode(EVENT_FREE_CHAIN)
--  e8:SetRange(0x5f)
--  e8:SetCondition(root.e8con)
--  e8:SetTarget(root.e8tg)
--  e8:SetOperation(root.e8op)
--  c:RegisterEffect(e8)

--  --send card to your graveyard
--  local e9=Effect.CreateEffect(c)
--  e9:SetDescription(504)
--  e9:SetType(EFFECT_TYPE_QUICK_O)
--  e9:SetCode(EVENT_FREE_CHAIN)
--  e9:SetRange(0x5f)
--  e9:SetCondition(root.e9con)
--  e9:SetTarget(root.e9tg)
--  e9:SetOperation(root.e9op)
--  c:RegisterEffect(e9)

-- function root.e7con(e,tp,eg,ep,ev,re,r,rp)
--  return Duel.GetCurrentChain()<=0
-- end

-- function root.e7tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
--  local loc=LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED
--  if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,loc,loc,1,nil) end
-- end

-- function root.e7op(e,tp,eg,ep,ev,re,r,rp)
--  local loc=LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED
--  local g=Duel.GetMatchingGroup(nil,tp,loc,loc,nil)
--  if #g==0 then return end
--  local tpdraw=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
--  local opdraw=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)

--  Duel.SendtoDeck(g,nil,2,REASON_RULE)
--  Duel.ShuffleDeck(tp)
--  Duel.ShuffleDeck(1-tp)
--  Duel.Draw(tp,tpdraw,REASON_RULE)
--  Duel.Draw(1-tp,opdraw,REASON_RULE)
--  Duel.SetLP(tp,8000)
--  Duel.SetLP(1-tp,8000)
-- end

-- function root.e8filter(c)
--  if c:IsLocation(LOCATION_EXTRA) and not c:IsAbleToHand() then return false end
--  return not c:IsCode(id)
-- end

-- function root.e8con(e,tp,eg,ep,ev,re,r,rp)
--  return Duel.GetCurrentChain()<=0
-- end

-- function root.e8tg(e,tp,eg,ep,ev,re,r,rp,chk)
--  local loc=LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_ONFIELD
--  if chk==0 then return Duel.IsExistingMatchingCard(root.e8filter,tp,loc,0,1,nil) end
-- end

-- function root.e8op(e,tp,eg,ep,ev,re,r,rp)
--  local loc=LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_ONFIELD

--  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
--  local g=Duel.SelectMatchingCard(tp,root.e8filter,tp,loc,0,1,10,nil)
--  if #g==0 then return end
		
--  Duel.SendtoHand(g,nil,REASON_RULE)
--  Duel.ConfirmCards(1-tp,g)
-- end

-- function root.e9filter(c)
--  return not c:IsCode(id)
-- end

-- function root.e9con(e,tp,eg,ep,ev,re,r,rp)
--  return Duel.GetCurrentChain()<=0
-- end

-- function root.e9tg(e,tp,eg,ep,ev,re,r,rp,chk)
--  local loc=LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_ONFIELD
--  if chk==0 then return Duel.IsExistingMatchingCard(root.e9filter,tp,loc,0,1,nil) end
-- end

-- function root.e9op(e,tp,eg,ep,ev,re,r,rp)
--  local loc=LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_ONFIELD

--  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
--  local g=Duel.SelectMatchingCard(tp,root.e9filter,tp,loc,0,1,10,nil)
--  if #g==0 then return end
		
--  Duel.SendtoGrave(g,REASON_RULE)
-- end
