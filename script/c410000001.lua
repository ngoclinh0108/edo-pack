--Slifer the Sky Divine Dragon
Duel.LoadScript("triplesix_util.lua")
local root,id=GetID()

root.divine_hierarchy=1

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
		return owner or (c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_GRAVE+LOCATION_REMOVED))
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
		if c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_GRAVE+LOCATION_REMOVED) then Duel.SendtoGrave(c,REASON_EFFECT) end
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

	--atk/def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,c) return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000 end)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2b)

	--atk/def down
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(root.e3con)
	e3:SetTarget(root.e3tg)
	e3:SetOperation(root.e3op)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3b)
	local e3c=e3:Clone()
	e3c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3c)
end

function root.e3filter(c,e,tp)
	return c:IsControler(tp) and c:IsPosition(POS_FACEUP) and (not e or c:IsRelateToEffect(e))
end

function root.e3con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(root.e3filter,1,nil,nil,1-tp)
end

function root.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetTargetCard(eg)
	Duel.SetChainLimit(root.e3actlimit(eg))
end

function root.e3actlimit(g)
	return function(e,lp,tp)
		return not g:IsContains(e:GetHandler())
	end
end

function root.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(root.e3filter,nil,e,1-tp)
	local dg=Group.CreateGroup()
	
	for tc in aux.Next(g) do
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			local preatk=tc:GetAttack()
			local ec1=Effect.CreateEffect(c)
			ec1:SetType(EFFECT_TYPE_SINGLE)
			ec1:SetCode(EFFECT_UPDATE_ATTACK)
			ec1:SetValue(-2000)
			ec1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(ec1)
			if preatk>0 and tc:GetAttack()==0 then dg:AddCard(tc) end
		elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
			local predef=tc:GetDefense()
			local ec2=Effect.CreateEffect(c)
			ec2:SetType(EFFECT_TYPE_SINGLE)
			ec2:SetCode(EFFECT_UPDATE_DEFENSE)
			ec2:SetValue(-2000)
			ec2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(ec2)
			if predef>0 and tc:GetDefense()==0 then dg:AddCard(tc) end
		end
	end
	Duel.Destroy(dg,REASON_EFFECT)
end