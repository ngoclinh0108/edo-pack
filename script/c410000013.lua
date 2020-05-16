--Obelisk, The Giant Divine Guardian
local root,id=GetID()

root.divine_hierarchy=2
root.listed_names={410000012,10000000}
root.divine_evolution=10000000

function root.initial_effect(c)
	c:EnableReviveLimit()

	--special summon condition
	local spc=Effect.CreateEffect(c)
	spc:SetType(EFFECT_TYPE_SINGLE)
	spc:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	spc:SetCode(EFFECT_SPSUMMON_CONDITION)
	spc:SetValue(function(e,se,sp,st) return se:GetHandler():IsCode(410000012) end)
	c:RegisterEffect(spc)

	--divine hierarchy
	local sumsafe=Effect.CreateEffect(c)
	sumsafe:SetType(EFFECT_TYPE_SINGLE)
	sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	c:RegisterEffect(sumsafe)
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
	local untarget=noswitch:Clone()
	untarget:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	untarget:SetValue(function(e,re,rp)
		local c=e:GetOwner()
		local tc=re:GetOwner()
		if tc==c or (tc.divine_hierarchy and tc.divine_hierarchy>=c.divine_hierarchy) then return false end
		return rp~=e:GetHandlerPlayer()
	end)
	c:RegisterEffect(untarget)
	local immunity=noswitch:Clone()
	immunity:SetCode(EFFECT_IMMUNE_EFFECT)
	immunity:SetValue(function(e,te)
		local c=e:GetOwner()
		local tc=te:GetOwner()
		return tc~=c and (not tc.divine_hierarchy or tc.divine_hierarchy<c.divine_hierarchy)
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
			owner=(eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)))
				and (eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)))
				or owner
		end
		return owner
	end)
	reset:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local effs={c:GetCardEffect()}
		for _,eff in ipairs(effs) do
			if eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
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
	e1:SetValue(RACE_WARRIOR+RACE_ROCK)
	c:RegisterEffect(e1)

	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetValue(root.e2val)
	c:RegisterEffect(e2)

	--must attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(root.e3con)
	e3:SetCost(root.e3cost)
	e3:SetTarget(root.e3tg)
	e3:SetOperation(root.e3op)
	c:RegisterEffect(e3)

	--destroy monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(root.effcost)
	e4:SetTarget(root.e4tg)
	e4:SetOperation(root.e4op)
	c:RegisterEffect(e4)

	--destroy spell/trap
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(root.effcost)
	e5:SetTarget(root.e5tg)
	e5:SetOperation(root.e5op)
	c:RegisterEffect(e5)
end

function root.e2val(e,re,r,rp)
	if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end

function root.e3con(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()~=tp and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end

function root.e3cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,2,false,nil,c) end

	local atk=0
	local g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,nil,c)
	for tc in aux.Next(g) do atk=atk+tc:GetAttack() end
	e:SetLabel(atk)
	Duel.Release(g,REASON_COST)
end

function root.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_UPDATE_ATTACK)
	ec1:SetValue(e:GetLabel())
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(ec1)

	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local fid=c:GetRealFieldID()
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
		for tc in aux.Next(g) do
			local ec1=Effect.CreateEffect(c)
			ec1:SetType(EFFECT_TYPE_SINGLE)
			ec1:SetCode(EFFECT_MUST_ATTACK)
			ec1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(ec1)
			
			local ec2=ec1:Clone()
			ec2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
			ec2:SetValue(root.e3atklimit)
			ec2:SetLabel(fid)
			tc:RegisterEffect(ec2)
		end
	end
end

function root.e3atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end

function root.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,c) end

	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,c)
	Duel.Release(g,REASON_COST)
end

function root.e4tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end

	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function root.e4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local ng=Duel.GetMatchingGroup(function(tc) return tc:IsFaceup() and not tc:IsDisabled() end,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(ng) do
		local ec1=Effect.CreateEffect(c)
		ec1:SetType(EFFECT_TYPE_SINGLE)
		ec1:SetCode(EFFECT_DISABLE)
		ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ec1)
		local ec2=Effect.CreateEffect(c)
		ec2:SetType(EFFECT_TYPE_SINGLE)
		ec2:SetCode(EFFECT_DISABLE_EFFECT)
		ec2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ec2)
	end
	Duel.BreakEffect()

	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil) 
	Duel.Destroy(dg,REASON_EFFECT)
end

function root.e5filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function root.e5tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e5filter,tp,0,LOCATION_ONFIELD,1,nil) end

	local g=Duel.GetMatchingGroup(root.e5filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function root.e5op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local ng=Duel.GetMatchingGroup(function(tc) return root.e5filter(tc) and tc:IsFaceup() and not tc:IsDisabled() end,tp,0,LOCATION_ONFIELD,nil)
	for tc in aux.Next(ng) do
		local ec1=Effect.CreateEffect(c)
		ec1:SetType(EFFECT_TYPE_SINGLE)
		ec1:SetCode(EFFECT_DISABLE)
		ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ec1)
		local ec2=Effect.CreateEffect(c)
		ec2:SetType(EFFECT_TYPE_SINGLE)
		ec2:SetCode(EFFECT_DISABLE_EFFECT)
		ec2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ec2)
	end
	Duel.BreakEffect()

	local dg=Duel.GetMatchingGroup(root.e5filter,tp,0,LOCATION_ONFIELD,nil) 
	Duel.Destroy(dg,REASON_EFFECT)
end