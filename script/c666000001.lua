--Hyper Polymerization
local root,id=GetID()

function root.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(root.e1tg)
	e1:SetOperation(root.e1op)
	c:RegisterEffect(e1)

	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(root.e2cost)
	e2:SetTarget(root.e2tg)
	e2:SetOperation(root.e2op)
	c:RegisterEffect(e2)
end

function root.e1filter1(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,chkf)
end

function root.e1filter2(c,e)
	if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then
		return false
	end

	return not e or not c:IsImmuneToEffect(e)
end

function root.e1filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end

function root.e1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(root.e1filter2,nil)
		mg1:Merge(Duel.GetMatchingGroup(root.e1filter3,tp,LOCATION_GRAVE,0,nil))
		local res=Duel.IsExistingMatchingCard(root.e1filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)

		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(root.e1filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end

		return res
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)

	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(root.e1chainlimit)
	end
end

function root.e1chainlimit(e,ep,tp)
	return tp==ep
end

function root.e1op(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(root.e1filter2,nil,e)
	mg1:Merge(Duel.GetMatchingGroup(root.e1filter3,tp,LOCATION_GRAVE,0,nil))
	local sg1=Duel.GetMatchingGroup(root.e1filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)

	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(root.e1filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end

	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)

			tc:SetMaterial(mat1)
			for mc in aux.Next(mat1) do
				if mc:IsLocation(LOCATION_GRAVE) then
					Duel.Remove(mc,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				else
					Duel.SendtoGrave(mc,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				end
			end
			Duel.BreakEffect()

			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end

		tc:CompleteProcedure()
	end
end

function root.e2filter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end

function root.e2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.e2filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,root.e2filter,1,1,REASON_COST+REASON_DISCARD)
end

function root.e2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function root.e2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	Duel.SendtoHand(c,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,c)
end