--Ra the Sun Divine Immortal Phoenix
local root,id=GetID()

root.divine_hierarchy=2
root.listed_names={10000010}
root.base_transform=Group.CreateGroup()

function root.initial_effect(c)
	c:EnableReviveLimit()

	--outside
	local outside=Effect.CreateEffect(c)
	outside:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	outside:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	outside:SetCode(EVENT_STARTUP)
	outside:SetRange(0x5f)
	outside:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.SendtoDeck(e:GetHandler(),tp,-2,REASON_RULE)
		if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then Duel.Draw(tp,1,REASON_RULE) end
	end)
	c:RegisterEffect(outside)

	--turn back base form
	local turnback=Effect.CreateEffect(c)
	turnback:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	turnback:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	turnback:SetCode(EVENT_LEAVE_FIELD)
	turnback:SetRange(LOCATION_MZONE)
	turnback:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetLocation()~=0 end)
	turnback:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tc=c.base_transform:GetFirst()
		c.base_transform:RemoveCard(tc)
		
		local loc=c:GetLocation()
		if loc==LOCATION_DECK then Duel.SendtoDeck(tc,c:GetControler(),c:GetSequence(),c:GetReason())
		elseif loc==LOCATION_HAND then Duel.SendtoHand(tc,c:GetControler(),c:GetReason())
		elseif loc==LOCATION_GRAVE then Duel.SendtoGrave(tc,c:GetReason())
		elseif loc==LOCATION_REMOVED then Duel.Remove(tc,c:GetPosition(),c:GetReason())
		end
		Duel.SendtoDeck(c,tp,-2,REASON_RULE)
	end)
	c:RegisterEffect(turnback)

	--transform
	local etrans=Effect.CreateEffect(c)
	etrans:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	etrans:SetCode(EVENT_SPSUMMON_SUCCESS)
	etrans:SetCondition(root.etranscon)
	etrans:SetOperation(root.etransop)
	Duel.RegisterEffect(etrans,0)

	--special summon limit
	local splimit=Effect.CreateEffect(c)
	splimit:SetType(EFFECT_TYPE_SINGLE)
	splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
	splimit:SetValue(aux.FALSE)
	c:RegisterEffect(splimit)

	--divine hierarchy
	local inact=Effect.CreateEffect(c)
	inact:SetType(EFFECT_TYPE_FIELD)
	inact:SetCode(EFFECT_CANNOT_INACTIVATE)
	inact:SetRange(0x5f)
	inact:SetLabelObject(c)
	inact:SetValue(function(e,ct)
		local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
		return te:GetHandler()==e:GetLabelObject()
	end)
	c:RegisterEffect(inact)
	local inactb=inact:Clone()
	inactb:SetCode(EFFECT_CANNOT_DISEFFECT)
	c:RegisterEffect(inactb)
	local nodis=Effect.CreateEffect(c)
	nodis:SetType(EFFECT_TYPE_SINGLE)
	nodis:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	nodis:SetCode(EFFECT_CANNOT_DISABLE)
	c:RegisterEffect(nodis)
	local norelease=Effect.CreateEffect(c)
	norelease:SetType(EFFECT_TYPE_FIELD)
	norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	norelease:SetCode(EFFECT_CANNOT_RELEASE)
	norelease:SetRange(LOCATION_MZONE)
	norelease:SetTargetRange(0,1)
	norelease:SetTarget(function(e,tc,tp,sumtp) return tc==e:GetHandler() end)
	c:RegisterEffect(norelease)
	local nofus=Effect.CreateEffect(c)
	nofus:SetType(EFFECT_TYPE_SINGLE)
	nofus:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	nofus:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	nofus:SetValue(function(e,tc)
		if not tc then return false end
		return tc:GetControler()~=e:GetOwnerPlayer()
	end)
	c:RegisterEffect(nofus)
	local nosync=nofus:Clone()
	nosync:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(nosync)
	local noxyz=nofus:Clone()
	noxyz:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(noxyz)
	local nolnk=nofus:Clone()
	nolnk:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(nolnk)
	local noswitch=Effect.CreateEffect(c)
	noswitch:SetType(EFFECT_TYPE_SINGLE)
	noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	noswitch:SetRange(LOCATION_MZONE)
	c:RegisterEffect(noswitch)
	local noflip=noswitch:Clone()
	noflip:SetCode(EFFECT_CANNOT_TURN_SET)
	c:RegisterEffect(noflip)
	local immunity=noswitch:Clone()
	immunity:SetCode(EFFECT_IMMUNE_EFFECT)
	immunity:SetValue(function(e,te)
		local c=e:GetOwner()
		local tc=te:GetOwner()   
		return (te:IsActiveType(TYPE_MONSTER) and c~=tc and (not tc.divine_hierarchy or tc.divine_hierarchy<c.divine_hierarchy))
			or (te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
				and te:IsHasCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_RELEASE+CATEGORY_TOGRAVE+CATEGORY_FUSION_SUMMON))
	end)
	c:RegisterEffect(immunity)
	local reset=noswitch:Clone()
	reset:SetDescription(1162)
	reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	reset:SetCode(EVENT_PHASE+PHASE_END)
	reset:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local owner=false
		local effs={c:GetCardEffect()}
		for _,eff in ipairs(effs) do
			local check=(eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and eff:GetCode()~=EFFECT_SPSUMMON_PROC
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)))
			owner=check or owner
		end
		return owner
	end)
	reset:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local effs={c:GetCardEffect()}
		for _,eff in ipairs(effs) do
			if eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and eff:GetCode()~=EFFECT_SPSUMMON_PROC
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)) then
				eff:Reset()
			end
		end
	end)
	c:RegisterEffect(reset)

	--add race
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(RACE_WINGEDBEAST+RACE_PYRO)
	c:RegisterEffect(e1)

	--indes & battle damage avoid
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e2b)
	
	--immune & unstoppable attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(function(e,te) return e:GetOwnerPlayer()~=te:GetOwnerPlayer() and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) end)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
	e3b:SetValue(1)
	c:RegisterEffect(e3b)

	--life point transfer
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(root.e4cost)
	e4:SetTarget(root.e4tg)
	e4:SetOperation(root.e4op)
	c:RegisterEffect(e4)

	--tribute for atk/def
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(root.e5cost)
	e5:SetOperation(root.e5op)
	c:RegisterEffect(e5)

	--destroy
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCost(root.e6cost)
	e6:SetTarget(root.e6tg)
	e6:SetOperation(root.e6op)
	c:RegisterEffect(e6)

	--send monsters to GY
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,4))
	e7:SetCategory(CATEGORY_TOGRAVE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_BATTLED)
	e7:SetCondition(root.e7con)
	e7:SetTarget(root.e7tg)
	e7:SetOperation(root.e7op)
	c:RegisterEffect(e7)

	--sphere mode
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,5))
	e8:SetCategory(CATEGORY_TOGRAVE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(root.e8tg)
	e8:SetOperation(root.e8op)
	c:RegisterEffect(e8)
end

function root.etransfilter(c,tp)
	return c:IsCode(10000010) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end

function root.etranscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLocation()==0 and eg:IsExists(root.etransfilter,1,nil,tp)
end

function root.etransop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:Filter(root.etransfilter,nil,tp):GetFirst()
	if not tc or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.BreakEffect()

	Duel.Hint(HINT_CARD,tp,id)
	local zone=tc:GetSequence()
	if zone>=0 and zone<=4 then zone=2^zone
	else zone=0xff end
	Duel.SendtoDeck(tc,nil,-2,REASON_RULE)
	Duel.MoveToField(c,tc:GetControler(),tc:GetControler(),LOCATION_MZONE,POS_FACEUP_ATTACK,true,zone)
	c.base_transform:AddCard(tc)
	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	ec1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(ec1)
end

function root.e4cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)>100 end

	local lp=Duel.GetLP(tp)
	e:SetLabel(lp-100)
	Duel.PayLPCost(tp,lp-100)
end

function root.e4tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(aux.FALSE)
end

function root.e4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_SET_BASE_ATTACK)
	ec1:SetValue(c:GetBaseAttack()+e:GetLabel())
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(ec1)

	local ec2=ec1:Clone()
	ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
	ec2:SetValue(c:GetBaseDefense()+e:GetLabel())
	c:RegisterEffect(ec2)

	local ec3=Effect.CreateEffect(c)
	ec3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ec3:SetCode(EVENT_RECOVER)
	ec3:SetRange(LOCATION_MZONE)
	ec3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp end)
	ec3:SetOperation(root.e4recoverop)
	ec3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(ec3)
end

function root.e4recoverop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	if c:IsFacedown() then return end

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_SET_BASE_ATTACK)
	ec1:SetValue(c:GetBaseAttack()+ev)
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(ec1)

	local ec2=ec1:Clone()
	ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
	ec2:SetValue(c:GetBaseDefense()+ev)
	c:RegisterEffect(ec2)

	Duel.SetLP(tp,100,REASON_EFFECT)
end

function root.e5cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsFaceup,1,false,nil,c) end

	local g=Duel.SelectReleaseGroupCost(tp,Card.IsFaceup,1,99,false,nil,c)
	Duel.Release(g,REASON_COST)

	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	end
end

function root.e5op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	if not g then return end
	
	local atk=0
	local def=0
	for tc in aux.Next(g) do
		atk=atk+tc:GetBaseAttack()
		def=def+tc:GetBaseDefense()
	end

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_SET_BASE_ATTACK)
	ec1:SetValue(c:GetBaseAttack()+atk)
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(ec1)
	local ec2=ec1:Clone()
	ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
	ec2:SetValue(c:GetBaseDefense()+def)
	c:RegisterEffect(ec2)

	g:DeleteGroup()
end

function root.e6filter(tc,e)
	local c=e:GetHandler()
	return not tc.divine_hierarchy or tc.divine_hierarchy<=c.divine_hierarchy
end

function root.e6cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckLPCost(tp,1000) and c:GetFlagEffect(id)==0 end

	Duel.PayLPCost(tp,1000)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end

function root.e6tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(root.e6filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,e) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end

function root.e6op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,root.e6filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,e):GetFirst()

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ec1:SetCode(EFFECT_DISABLE)
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
	tc:RegisterEffect(ec1,true)
	local ec2=ec1:Clone()
	ec2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(ec2,true)
	local ec3=ec1:Clone()
	ec3:SetCode(EFFECT_IMMUNE_EFFECT)
	ec3:SetRange(LOCATION_MZONE)
	ec3:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
	tc:RegisterEffect(ec3,true)
	Duel.AdjustInstantly(c)

	Duel.Destroy(tc,REASON_EFFECT)
end

function root.e7con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end

function root.e7tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0,LOCATION_MZONE)
end

function root.e7op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end

function root.e8tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end

function root.e8op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SendtoGrave(c,REASON_EFFECT)
end