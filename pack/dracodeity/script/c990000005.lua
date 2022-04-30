-- Andalusite, Dracodeity of the Continent
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
	UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_EARTH)
	UtilityDracodeity.RegisterEffect(c, id)

	-- battle indes
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE, 0)
	e1:SetTarget(function(e, tc) return tc == e:GetHandler() or tc:GetMutualLinkedGroupCount() > 0 end)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- avoid battle damage
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- absorpt attack
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 0))
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE + PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, id)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tg)
	e3:SetOperation(s.e3op)
	c:RegisterEffect(e3)

	-- attack redirect
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 1))
	e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabel(0)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tg)
	e4:SetOperation(s.e4op)
	c:RegisterEffect(e4)
end

function s.e3filter(c)
	return c:IsFaceup() and c:GetAttack() > 0
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer() == tp
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, c) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tc = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e3filter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, c):GetFirst()

	if c:IsFacedown() or not tc or tc:IsFacedown() or tc:IsImmuneToEffect(e) then return end
	Duel.HintSelection(Group.FromCards(tc))
	local atk = tc:GetAttack()

	local ec1 = Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_SINGLE)
	ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
	ec1:SetValue(math.ceil(atk / 2))
	ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
	tc:RegisterEffect(ec1)

	local ec2 = Effect.CreateEffect(c)
	ec2:SetType(EFFECT_TYPE_SINGLE)
	ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	ec2:SetCode(EFFECT_UPDATE_ATTACK)
	ec2:SetValue(math.ceil(atk / 2))
	ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
	c:RegisterEffect(ec2)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer() ~= tp and Duel.GetAttackTarget() ~= e:GetHandler()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	local max = c:GetMutualLinkedGroupCount()
	local ct = c:GetFlagEffect(id) == 0 and 0 or e:GetLabel()
	if chk == 0 then return not c:IsStatus(STATUS_CHAINING) and ct < max end

	e:SetLabel(ct + 1)
	if c:GetFlagEffect(id) == 0 then c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1) end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local ac = Duel.GetAttacker()
	if ac:CanAttack() and not ac:IsImmuneToEffect(e) then
		Duel.CalculateDamage(ac, c)
	end
end
