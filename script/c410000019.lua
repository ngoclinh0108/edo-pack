--Emissary of the Egyptian Gods
local root,id=GetID()

function root.initial_effect(c)
	Pendulum.AddProcedure(c)

	--special summon condition
	local spc=Effect.CreateEffect(c)
	spc:SetType(EFFECT_TYPE_SINGLE)
	spc:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	spc:SetCode(EFFECT_SPSUMMON_CONDITION)
	spc:SetValue(aux.penlimit)
	c:RegisterEffect(spc)

	--immune
	local pe1=Effect.CreateEffect(c)
	pe1:SetType(EFFECT_TYPE_SINGLE)
	pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	pe1:SetCode(EFFECT_IMMUNE_EFFECT)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsExistingMatchingCard(function(tc)
			return tc:GetAttribute()==ATTRIBUTE_DIVINE
		end,tp,LOCATION_PZONE,0,1,e:GetHandler())
	end)
	pe1:SetValue(function(e,te) return te:GetHandlerPlayer()~=e:GetHandlerPlayer() end)
	c:RegisterEffect(pe1)

	--scale
	local pe2=Effect.CreateEffect(c)
	pe2:SetType(EFFECT_TYPE_SINGLE)
	pe2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	pe2:SetCode(EFFECT_CHANGE_LSCALE)
	pe2:SetRange(LOCATION_PZONE)
	pe2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.IsExistingMatchingCard(function(tc)
			return tc:GetAttribute()==ATTRIBUTE_DIVINE
		end,tp,LOCATION_PZONE,0,1,e:GetHandler())
	end)
	pe2:SetValue(4)
	c:RegisterEffect(pe2)
	local pe2b=pe2:Clone()
	pe2b:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(pe2b)

	--no damage
	local pe3=Effect.CreateEffect(c)
	pe3:SetType(EFFECT_TYPE_FIELD)
	pe3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	pe3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	pe3:SetRange(LOCATION_PZONE)
	pe3:SetTargetRange(1,0)
	pe3:SetCondition(root.pe3con)
	pe3:SetValue(1)
	c:RegisterEffect(pe3)

	--special summon
	local pe4=Effect.CreateEffect(c)
	pe4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	pe4:SetType(EFFECT_TYPE_IGNITION)
	pe4:SetRange(LOCATION_PZONE)
	pe4:SetCost(root.pe4cost)
	pe4:SetTarget(root.pe4tg)
	pe4:SetOperation(root.pe4op)
	c:RegisterEffect(pe4)

	--cannot be tribute
	local me1=Effect.CreateEffect(c)
	me1:SetType(EFFECT_TYPE_SINGLE)
	me1:SetCode(EFFECT_UNRELEASABLE_SUM)
	me1:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_DIVINE))
	c:RegisterEffect(me1)

	--triple tribute
	local me2=Effect.CreateEffect(c)
	me2:SetType(EFFECT_TYPE_SINGLE)
	me2:SetCode(EFFECT_TRIPLE_TRIBUTE)
	me2:SetValue(1)
	c:RegisterEffect(me2)

	--search
	local me3=Effect.CreateEffect(c)
	me3:SetDescription(aux.Stringid(id,0))
	me3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	me3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	me3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	me3:SetCode(EVENT_RELEASE)
	me3:SetCountLimit(1,id+1000000)
	me3:SetCondition(root.me3con)
	me3:SetTarget(root.me3tg)
	me3:SetOperation(root.me3op)
	c:RegisterEffect(me3)

	--token
	local me4=Effect.CreateEffect(c)
	me4:SetDescription(aux.Stringid(id,1))
	me4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	me4:SetType(EFFECT_TYPE_QUICK_O)
	me4:SetCode(EVENT_FREE_CHAIN)
	me4:SetRange(LOCATION_MZONE)
	me4:SetCost(root.me4cost)
	me4:SetTarget(root.me4tg)
	me4:SetOperation(root.me4op)
	c:RegisterEffect(me4)
end

function root.pe3con(e)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DIVINE)
	end,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function root.pe4cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,2,false,nil,c) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,nil,c)
	Duel.Release(g,REASON_COST)
end

function root.pe4tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function root.pe4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

function root.me3filter(c)
	return aux.IsCodeListed(c,10000000,10000010,10000020) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function root.me3con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end

function root.me3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(root.me3filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function root.me3op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,root.me3filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function root.me4filter(c,e,tp)
	return c:IsSetCard(0x5a) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function root.me4cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function root.me4tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) end

	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft~=1 then
		local ct = {}
		for i=1,math.min(ft,3) do
			ct[#ct+1]=i
		end
		ft=Duel.AnnounceNumber(tp,table.unpack(ct))
	end
	
	Duel.SetTargetParam(ft)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
end

function root.me4op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>ct then ft=ct end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end

	for i=1,ft do
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end