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
	inact:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	inact:SetCode(EFFECT_CANNOT_INACTIVATE)
	inact:SetValue(function(e,ct)
		local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		return tp==e:GetOwnerPlayer() and te:GetHandler()==e:GetHandler()
	end)
	c:RegisterEffect(inact)
	local nodis=Effect.CreateEffect(c)
	nodis:SetType(EFFECT_TYPE_SINGLE)
	nodis:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	nodis:SetCode(EFFECT_CANNOT_DISEFFECT)
	c:RegisterEffect(nodis)
	local nodisb=nodis:Clone()
	nodisb:SetCode(EFFECT_CANNOT_DISABLE)
	c:RegisterEffect(nodisb)
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
			owner=(eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
				and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)))
				and (eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
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
			if eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
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
	e1:SetValue(RACE_WINDBEAST+RACE_PYRO)
	c:RegisterEffect(e1)
end
