--Osiris, The Celestial Divine Dragon
local root,id=GetID()

root.divine_hierarchy=2
root.listed_names={410000012,10000020}
root.divine_evolution=10000020

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
	e1:SetValue(RACE_DRAGON+RACE_THUNDER)
	c:RegisterEffect(e1)

	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,c)
		local atk=Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
		if atk<5000 then atk=5000 end
		return atk
	end)
	c:RegisterEffect(e2)

	--infinite hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_HAND_LIMIT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(999)
	c:RegisterEffect(e3)

	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(root.e4cost)
	e4:SetTarget(root.e4tg)
	e4:SetOperation(root.e4op)
	c:RegisterEffect(e4)

	--lightning force
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(root.e5cost)
	e5:SetTarget(root.e5tg)
	e5:SetOperation(root.e5op)
	c:RegisterEffect(e5)
end

function root.e4cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end

function root.e4tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	if chk==0 then return #g>0 end

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function root.e4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function root.e5filter(c)
	return c:GetFlagEffect(id)==0
end

function root.e5cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end

function root.e5tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(root.e5filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetChainLimit(root.e5actlimit(g))
end

function root.e5actlimit(g)
	return function(e,lp,tp)
		return not g:IsContains(e:GetHandler())
	end
end

function root.e5op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(root.e5filter,tp,0,LOCATION_MZONE,nil)
	local dg=Group.CreateGroup()
	
	for tc in aux.Next(g) do
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			local preatk=tc:GetAttack()
			local ec1=Effect.CreateEffect(c)
			ec1:SetType(EFFECT_TYPE_SINGLE)
			ec1:SetCode(EFFECT_UPDATE_ATTACK)
			ec1:SetValue(-3000)
			ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(ec1)
			if preatk>0 and tc:GetAttack()==0 then dg:AddCard(tc) end
		elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
			local predef=tc:GetDefense()
			local ec2=Effect.CreateEffect(c)
			ec2:SetType(EFFECT_TYPE_SINGLE)
			ec2:SetCode(EFFECT_UPDATE_DEFENSE)
			ec2:SetValue(-3000)
			ec2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(ec2)
			if predef>0 and tc:GetDefense()==0 then dg:AddCard(tc) end
		end
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
	Duel.Destroy(dg,REASON_EFFECT)
end
