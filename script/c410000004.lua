--Ra the Sun Divine Sphere
Duel.LoadScript("triplesix_util.lua")
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
	etrans:SetCode(EVENT_SUMMON_SUCCESS)
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

	--attack limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)

	--battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(root.e3val)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE) 
	c:RegisterEffect(e3b)

	--reborn ra
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(root.e4con)
	e4:SetOperation(root.e4op)
	Duel.RegisterEffect(e4,0)

	--standard mode
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(root.e5tg)
	e5:SetOperation(root.e5op)
	c:RegisterEffect(e5)
end

function root.etransfilter(c)
	return c:IsCode(10000010)
end

function root.etranscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLocation()==0 and eg:IsExists(root.etransfilter,1,nil)
end

function root.etransop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:Filter(root.etransfilter,nil):GetFirst()
	if not tc then return end
	Duel.BreakEffect()

	Duel.Hint(HINT_CARD,tp,id)
	local pos=tc:GetPosition()
	local zone=tc:GetSequence()
	if zone>=0 and zone<=4 then zone=2^zone
	else zone=0xff end
	Duel.SendtoDeck(tc,nil,-2,REASON_RULE)
	Duel.MoveToField(c,tc:GetControler(),tc:GetControler(),LOCATION_MZONE,pos,true,zone)
	c.base_transform:AddCard(tc)
	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	ec1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(ec1)
end

function root.e3val(e,tc)
	return not tc.divine_hierarchy
end

function root.e4filter(c,e,tp)
	return c:IsCode(10000010) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
end

function root.e4con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLocation()==0 and eg:IsExists(root.e4filter,1,nil,e,tp)
end

function root.e4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:Filter(root.e4filter,nil,e,tp):GetFirst()
	if not tc then return end
	Duel.BreakEffect()

	Duel.Hint(HINT_CARD,tp,id)
	if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP_DEFENSE) then
		local zone=tc:GetSequence()
		if zone>=0 and zone<=4 then zone=2^zone
		else zone=0xff end
		Duel.SendtoDeck(tc,nil,-2,REASON_RULE)
		Duel.MoveToField(c,tc:GetControler(),tc:GetControler(),LOCATION_MZONE,POS_FACEUP_DEFENSE,true,zone)
		c.base_transform:AddCard(tc)
		local ec1=Effect.CreateEffect(c)
		ec1:SetType(EFFECT_TYPE_SINGLE)
		ec1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		ec1:SetReset(RESET_PHASE+PHASE_END)
		c:RegisterEffect(ec1)

		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	end
	Duel.SpecialSummonComplete()
end

function root.e5tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c.base_transform:GetFirst()
	if chk==0 then return c:GetFlagEffect(id)==0 and tp==tc:GetOwner()
		and (c:IsControler(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
	end
end

function root.e5op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsControler(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=c.base_transform:GetFirst()
	c.base_transform:RemoveCard(tc)
	
	local zone=c:GetSequence()
	if c:IsControler(tc:GetOwner()) and zone>=0 and zone<=4 then zone=2^zone
	else zone=0xff end
	Duel.SendtoDeck(c,tp,-2,REASON_RULE)
	Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP,true,zone)
	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	ec1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(ec1)

	local atk=0
	local def=0
	if tc:IsSummonType(SUMMON_TYPE_TRIBUTE) then
		local mg=tc:GetMaterial()
		for mc in aux.Next(mg) do
			atk=atk+mc:GetBaseAttack()
			def=def+mc:GetBaseDefense()
		end
	end
	local ec2=Effect.CreateEffect(c)
	ec2:SetType(EFFECT_TYPE_SINGLE)
	ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	ec2:SetCode(EFFECT_SET_BASE_ATTACK)
	ec2:SetRange(LOCATION_MZONE)
	ec2:SetValue(atk<4000 and 4000 or atk)
	ec2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
	tc:RegisterEffect(ec2)
	local ec3=ec2:Clone()
	ec3:SetCode(EFFECT_SET_BASE_DEFENSE)
	ec3:SetValue(def<4000 and 4000 or def)
	tc:RegisterEffect(ec3)
end