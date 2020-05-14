--Sun Divine Phoenix of Ra
local root,id=GetID()

root.divine_hierarchy=2

function root.initial_effect(c)
	--summon with 3 tribute
	aux.AddNormalSummonProcedure(c,true,false,3,3)
	aux.AddNormalSetProcedure(c)

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
	local noflip=Effect.CreateEffect(c)
	noflip:SetType(EFFECT_TYPE_SINGLE)
	noflip:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	noflip:SetCode(EFFECT_CANNOT_TURN_SET)
	noflip:SetRange(LOCATION_MZONE)
	c:RegisterEffect(noflip)
	local noswitch=noflip:Clone()
	noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(noswitch)
	local noleave=noflip:Clone()
	noleave:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	noleave:SetCode(EFFECT_SEND_REPLACE)
	noleave:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsReason(REASON_EFFECT) and r&REASON_EFFECT~=0 and re and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) end
		return true
	end)
	noleave:SetValue(function(e) return false end)
	c:RegisterEffect(noleave)
	local immunity=noflip:Clone()
	immunity:SetCode(EFFECT_IMMUNE_EFFECT)
	immunity:SetValue(function(e,te)
		local c=e:GetOwner()
		local tc=te:GetOwner()
		return tc~=c and te:IsActiveType(TYPE_MONSTER)
			and (not tc.divine_hierarchy or tc.divine_hierarchy<c.divine_hierarchy)
	end)
	c:RegisterEffect(immunity)
	local reset=noflip:Clone()
	reset:SetDescription(1162)
	reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	reset:SetCode(EVENT_PHASE+PHASE_END)
	reset:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local owner=false
		local effs={c:GetCardEffect()}
		for _,eff in ipairs(effs) do
			owner=(eff:GetOwner()~=c and not eff:GetOwner():IsCode(0,10000080,10000090)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)))
				and (eff:GetOwner()~=c and not eff:GetOwner():IsCode(0,10000080,10000090)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)))
				or owner
		end
		return owner or c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_GRAVE)
	end)
	reset:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local effs={c:GetCardEffect()}
		for _,eff in ipairs(effs) do
			if eff:GetOwner()~=c and not eff:GetOwner():IsCode(0,10000080,10000090)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)) then
				eff:Reset()
			end
		end
		if c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_GRAVE) then Duel.SendtoGrave(c,REASON_EFFECT) end
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

	--atk/def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(root.e2val)
	c:RegisterEffect(e2)
	local e2sum=Effect.CreateEffect(c)
	e2sum:SetType(EFFECT_TYPE_SINGLE)
	e2sum:SetCode(EFFECT_SUMMON_COST)
	e2sum:SetLabelObject(e2)
	e2sum:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) e:GetLabelObject():SetLabel(1) end)
	c:RegisterEffect(e2sum)

	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(root.e3cost)
	e3:SetTarget(root.e3tg)
	e3:SetOperation(root.e3op)
	c:RegisterEffect(e3)

	--summon from grave
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE) end)
	e4:SetOperation(root.e4op)
	c:RegisterEffect(e4)

	--indes, no battle damage, unstoppable attack, attack all
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetFlagEffect(id)>0 end)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e5b=e5:Clone()
	e5b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5b:SetValue(1)
	c:RegisterEffect(e5b)
	local e5c=e5:Clone()
	e5c:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
	c:RegisterEffect(e5c)
	local e5d=e5:Clone()
	e5d:SetCode(EFFECT_ATTACK_ALL)
	c:RegisterEffect(e5d)

	--pay lp for atk/def
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetFlagEffect(id)>0 end)
	e6:SetCost(root.e6cost)
	e6:SetTarget(root.e6tg)
	e6:SetOperation(root.e6op)
	c:RegisterEffect(e6)

	--tribute for atk/def
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetLabelObject(Effect.CreateEffect(c))
	e7:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetFlagEffect(id)>0 end)
	e7:SetCost(root.e7cost)
	e7:SetOperation(root.e7op)
	c:RegisterEffect(e7)
end

function root.e2val(e,c)
	local atk=0
	local def=0
	local mg=c:GetMaterial()
	for tc in aux.Next(mg) do
		local catk=tc:GetAttack()
		local cdef=tc:GetDefense()
		atk=atk+(catk>=0 and catk or 0)
		def=def+(cdef>=0 and cdef or 0)
	end

	if e:GetLabel()==1 then
		e:SetLabel(0)
		local ec1=Effect.CreateEffect(c)
		ec1:SetType(EFFECT_TYPE_SINGLE)
		ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		ec1:SetCode(EFFECT_SET_BASE_ATTACK)
		ec1:SetRange(LOCATION_MZONE)
		ec1:SetValue(atk)
		ec1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(ec1)
		local ec2=ec1:Clone()
		ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
		ec2:SetValue(def)
		c:RegisterEffect(ec2)
	end
end

function root.e3cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end

function root.e3tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end

	Duel.Destroy(tc,REASON_EFFECT)
end

function root.e4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() then return end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end

function root.e6cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)>100 end

	local lp=Duel.GetLP(tp)
	e:SetLabel(lp-100)
	Duel.PayLPCost(tp,lp-100)
end

function root.e6tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(aux.FALSE)
end

function root.e6op(e,tp,eg,ep,ev,re,r,rp)
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
	ec3:SetOperation(root.e6recoverop)
	ec3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(ec3)
end

function root.e6recoverop(e,tp,eg,ep,ev,re,r,rp)
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

function root.e7cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsFaceup,1,false,nil,c) end

	local atk=0
	local def=0
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsFaceup,1,99,false,nil,c)
	for tc in aux.Next(g) do
		local catk=tc:GetAttack()
		local cdef=tc:GetDefense()
		atk=atk+(catk>=0 and catk or 0)
		def=def+(cdef>=0 and cdef or 0)
	end
	
	e:SetLabel(atk)
	e:GetLabelObject():SetLabel(def)
	Duel.Release(g,REASON_COST)
end

function root.e7op(e,tp,eg,ep,ev,re,r,rp)
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
	ec2:SetValue(c:GetBaseDefense()+e:GetLabelObject():GetLabel())
	c:RegisterEffect(ec2)
end
