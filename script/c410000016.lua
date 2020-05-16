--The Sun Divine Sphere of Ra
local root,id=GetID()

root.divine_hierarchy=2
root.listed_names={10000010}

function root.initial_effect(c)
	Pendulum.AddProcedure(c)
	
	--summon with 3 tribute
	aux.AddNormalSummonProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	local sum2=Effect.CreateEffect(c)
	sum2:SetDescription(aux.Stringid(id,1))
	sum2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	sum2:SetType(EFFECT_TYPE_SINGLE)
	sum2:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	sum2:SetTargetRange(POS_FACEUP_ATTACK,1)
	sum2:SetCondition(root.sum2con)
	sum2:SetTarget(root.sum2tg)
	sum2:SetOperation(root.sum2op)
	sum2:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(sum2)
	aux.AddNormalSetProcedure(c)

	--control return
	local control=Effect.CreateEffect(c)
	control:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	control:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	control:SetCode(EVENT_SUMMON_SUCCESS)
	control:SetOperation(root.controlreg)
	c:RegisterEffect(control)

	--special summon condition
	local spc=Effect.CreateEffect(c)
	spc:SetType(EFFECT_TYPE_SINGLE)
	spc:SetCode(EFFECT_SPSUMMON_CONDITION)
	spc:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
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
	norelease:SetTargetRange(1,1)
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
	local noleave=noflip:Clone()
	noleave:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	noleave:SetCode(EFFECT_SEND_REPLACE)
	noleave:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsReason(REASON_EFFECT) and r&REASON_EFFECT~=0 and re and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) end
		return true
	end)
	noleave:SetValue(function(e) return false end)
	c:RegisterEffect(noleave)
	local untarget=noflip:Clone()
	untarget:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	untarget:SetValue(function(e,re,rp)
		local c=e:GetOwner()
		local tc=te:GetOwner()
		if tc==c or (tc.divine_hierarchy and tc.divine_hierarchy>=c.divine_hierarchy) then return false end
		return rp~=e:GetHandlerPlayer()
	end)
	c:RegisterEffect(untarget)
	local unbattle=noflip:Clone()
	unbattle:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	unbattle:SetValue(function(e,tc)
		local c=e:GetOwner()
		return not tc:IsImmuneToEffect(e) and tc:GetControler()~=e:GetHandlerPlayer()
			and (not tc.divine_hierarchy or tc.divine_hierarchy<c.divine_hierarchy)
	end)
	c:RegisterEffect(unbattle)
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
			owner=(eff:GetOwner()~=c and not eff:GetOwner():IsCode(0,10000080)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)))
				and (eff:GetOwner()~=c and not eff:GetOwner():IsCode(0,10000080)
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
			if eff:GetOwner()~=c and not eff:GetOwner():IsCode(0,10000080)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)) then
				eff:Reset()
			end
		end
	end)
	c:RegisterEffect(reset)

	--immune
	local pe1=Effect.CreateEffect(c)
	pe1:SetType(EFFECT_TYPE_SINGLE)
	pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	pe1:SetCode(EFFECT_IMMUNE_EFFECT)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetValue(function(e,te) return te:GetHandlerPlayer()~=e:GetHandlerPlayer() end)
	c:RegisterEffect(pe1)

	--no damage
	local pe2=Effect.CreateEffect(c)
	pe2:SetType(EFFECT_TYPE_FIELD)
	pe2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	pe2:SetCode(EFFECT_CHANGE_DAMAGE)
	pe2:SetRange(LOCATION_PZONE)
	pe2:SetTargetRange(1,0)
	pe2:SetCondition(root.pe2con)
	pe2:SetValue(root.pe2val)
	c:RegisterEffect(pe2)
	local pe2b=pe2:Clone()
	pe2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(pe2b)

	--special summon
	local pe3=Effect.CreateEffect(c)
	pe3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	pe3:SetType(EFFECT_TYPE_IGNITION)
	pe3:SetRange(LOCATION_PZONE)
	pe3:SetCost(root.pe3cost)
	pe3:SetTarget(root.pe3tg)
	pe3:SetOperation(root.pe3op)
	c:RegisterEffect(pe3)

	--atk/def
	local me1=Effect.CreateEffect(c)
	me1:SetType(EFFECT_TYPE_SINGLE)
	me1:SetCode(EFFECT_MATERIAL_CHECK)
	me1:SetValue(root.me1val)
	c:RegisterEffect(me1)
	local me1sum=Effect.CreateEffect(c)
	me1sum:SetType(EFFECT_TYPE_SINGLE)
	me1sum:SetCode(EFFECT_SUMMON_COST)
	me1sum:SetLabelObject(me1)
	me1sum:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) e:GetLabelObject():SetLabel(1) end)
	c:RegisterEffect(me1sum)

	--attack limit
	local me2=Effect.CreateEffect(c)
	me2:SetType(EFFECT_TYPE_SINGLE)
	me2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(me2)
	
	--summon ra
	local me4=Effect.CreateEffect(c)
	me4:SetDescription(aux.Stringid(id,2))
	me4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	me4:SetType(EFFECT_TYPE_QUICK_O)
	me4:SetCode(EVENT_FREE_CHAIN)
	me4:SetRange(LOCATION_MZONE)
	me4:SetCountLimit(1)
	me4:SetTarget(root.me4tg)
	me4:SetOperation(root.me4op)
	c:RegisterEffect(me4)
end

function root.sum2con(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	if exeff then
		local ret=exeff:GetValue()
		if type(ret)=="function" then
			ret={ret(exeff,c)}
			if #ret>1 then
				zone=(ret[2]>>16)&0x7f
			end
		end
	end
	local tp=c:GetControler()
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
	return minc<=3 and Duel.CheckTribute(c,3,3,mg,1-tp,zone)
end

function root.sum2tg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	if exeff then
		local ret=exeff:GetValue()
		if type(ret)=="function" then
			ret={ret(exeff,c)}
			if #ret>1 then
				zone=(ret[2]>>16)&0x7f
			end
		end
	end
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
	local g=Duel.SelectTribute(tp,c,3,3,mg,1-tp,zone,true)
	if g and #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function root.sum2op(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	g:DeleteGroup()
end

function root.controlreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,2)

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ec1:SetCode(EVENT_PHASE+PHASE_END)
	ec1:SetLabel(Duel.GetTurnCount()+1)
	ec1:SetCountLimit(1)
	ec1:SetCondition(root.controlcon)
	ec1:SetOperation(root.controlop)
	ec1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(ec1,tp)
end

function root.controlcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==e:GetLabel() and e:GetOwner():GetFlagEffect(id)~=0
end

function root.controlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	c:ResetEffect(EFFECT_SET_CONTROL,RESET_CODE)

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_SET_CONTROL)
	ec1:SetValue(c:GetOwner())
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
	c:RegisterEffect(ec1)
end

function root.pe2con(e)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DIVINE)
	end,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

function root.pe2val(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 then return 0
	else return val end
end

function root.pe3cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,3,false,nil,c) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,3,3,false,nil,c)
	Duel.Release(g,REASON_COST)
end

function root.pe3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function root.pe3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end

function root.me1val(e,c)
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

function root.me4filter(c,e,tp)
	return c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function root.me4tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:GetSequence()<5 then ft=ft+1 end
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and ft>0 and Duel.IsExistingMatchingCard(root.me4filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function root.me4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	if not c:IsRelateToEffect(e) then return end

	local atk=c:GetBaseAttack()
	if atk<4000 then atk=4000 end
	local def=c:GetBaseDefense()
	if def<4000 then def=4000 end
	if not Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,root.me4filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local ec1=Effect.CreateEffect(c)
		ec1:SetType(EFFECT_TYPE_SINGLE)
		ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ec1:SetCode(EFFECT_SET_BASE_ATTACK)
		ec1:SetValue(atk)
		ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ec1)
		local ec1b=ec1:Clone()
		ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
		ec1b:SetValue(def)
		tc:RegisterEffect(ec1b)
	end
	Duel.SpecialSummonComplete()
end
