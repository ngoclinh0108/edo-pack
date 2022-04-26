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
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE, 0)
	e1:SetTarget(function(e, tc) return tc == e:GetHandler() or tc:GetMutualLinkedGroupCount() > 0 end)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- force attack
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE + PHASE_BATTLE_START)
	e2:SetCountLimit(1, id)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tg)
	e2:SetOperation(s.e2op)
	c:RegisterEffect(e2)

	-- reset atk
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetTargetRange(0, LOCATION_MZONE)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tg)
	e3:SetValue(s.e3val)
	c:RegisterEffect(e3)

	-- damage absorpt
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetLabel(0)
	e4:SetTarget(s.e4tg)
	e4:SetOperation(s.e4op)
	c:RegisterEffect(e4)
end

function s.e2con(e)
	return Duel.GetTurnPlayer() == 1 - e:GetHandlerPlayer() and Duel.IsBattlePhase()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, nil)
			and Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0
	end
	Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tc = Duel.GetFirstTarget()
	local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
	if not tc:IsRelateToEffect(e) or #g == 0 then return end

	local fid = tc:GetRealFieldID()
	Duel.ChangePosition(g, POS_FACEUP_ATTACK)
	for sc in aux.Next(g) do
		local ec1 = Effect.CreateEffect(c)
		ec1:SetType(EFFECT_TYPE_SINGLE)
		ec1:SetCode(EFFECT_MUST_ATTACK)
		ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		sc:RegisterEffect(ec1)
		local ec1b = ec1:Clone()
		ec1b:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		ec1b:SetValue(function(e, c)
			return c:GetRealFieldID() == e:GetLabel()
		end)
		ec1b:SetLabel(fid)
		sc:RegisterEffect(ec1b)
	end
end

function s.e3con(e)
	local c = e:GetHandler()
	return (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL)
		and c:GetBattleTarget()
end

function s.e3tg(e, tc)
	local c = e:GetHandler()
	return c:GetBattleTarget() == tc
end

function s.e3val(e, tc)
	return tc:GetAttack() > tc:GetBaseAttack() and tc:GetBaseAttack() or tc:GetAttack()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	local max = c:GetMutualLinkedGroupCount()
	local ct = c:GetFlagEffect(id) == 0 and 0 or e:GetLabel()
	if chk == 0 then
		return Duel.GetBattleDamage(tp) > 0 and not c:IsStatus(STATUS_CHAINING) and ct < max
	end

	e:SetLabel(ct + 1)
	if c:GetFlagEffect(id) == 0 then c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1) end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local dmg = Duel.GetBattleDamage(tp)

	local ec1 = Effect.CreateEffect(c)
	ec1:SetType(EFFECT_TYPE_FIELD)
	ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ec1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	ec1:SetTargetRange(1, 0)
	ec1:SetValue(0)
	ec1:SetReset(RESET_PHASE + PHASE_DAMAGE)
	Duel.RegisterEffect(ec1, tp)

	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local ec2 = Effect.CreateEffect(c)
		ec2:SetType(EFFECT_TYPE_SINGLE)
		ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ec2:SetCode(EFFECT_UPDATE_ATTACK)
		ec2:SetValue(dmg)
		ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		c:RegisterEffect(ec2)
	end
end
