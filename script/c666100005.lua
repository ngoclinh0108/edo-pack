--Phantom Slime
local root,id=GetID()

function root.initial_effect(c)
	--summon with 3 tribute
	local sum1=aux.AddNormalSummonProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	local sum2=Effect.CreateEffect(c)
	sum2:SetDescription(aux.Stringid(id,1))
	sum2:SetType(EFFECT_TYPE_SINGLE)
	sum2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	sum2:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	sum2:SetTargetRange(POS_FACEUP_ATTACK,1)
	sum2:SetCondition(root.sum2con)
	sum2:SetTarget(root.sum2tg)
	sum2:SetOperation(root.sum2op)
	sum2:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(sum2)
	local noset=aux.AddNormalSetProcedure(c)

	--control return
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(root.e1reg)
	c:RegisterEffect(e1)

	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

	--no damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	--battle indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetCountLimit(2)
	e4:SetValue(function(e,re,r,rp) return (r&REASON_BATTLE)~=0 end)
	c:RegisterEffect(e4)
	
	--special summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetCost(root.e5cost)
	e5:SetTarget(root.e5tg)
	e5:SetOperation(root.e5op)
	c:RegisterEffect(e5)
end

function root.sum2con(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	if exeff then
		local ret={exeff:GetValue()(exeff,c)}
		if #ret>1 then zone=(ret[2]>>16)&0x7f end
	end

	local tp=c:GetControler()
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)

	return minc<=3 and Duel.CheckTribute(c,3,3,mg,1-tp,zone)
end

function root.sum2tg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	if exeff then
		local ret={exeff:GetValue()(exeff,c)}
		if #ret>1 then zone=(ret[2]>>16)&0x7f end
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

function root.e1reg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,2)

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ec1:SetCode(EVENT_PHASE+PHASE_END)
	ec1:SetLabel(Duel.GetTurnCount()+1)
	ec1:SetCountLimit(1)
	ec1:SetCondition(root.e1con)
	ec1:SetOperation(root.e1op)
	ec1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(ec1,tp)
end

function root.e1con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==e:GetLabel() and e:GetOwner():GetFlagEffect(id)~=0
end

function root.e1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	c:ResetEffect(EFFECT_SET_CONTROL,RESET_CODE)

	local ec1=Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_SET_CONTROL)
	ec1:SetValue(c:GetOwner())
	ec1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
	c:RegisterEffect(ec1)
end

function root.e2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackPos() end

	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end

function root.e2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or c:IsDefensePos() or not c:IsRelateToEffect(e) then return end

	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
end

function root.e5filter(c,e,tp)
	return c:IsRace(RACE_DIVINE) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function root.e5cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end

	Duel.Release(c,REASON_COST)
end

function root.e5tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end

	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(root.e5filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function root.e5op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,root.e5filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end