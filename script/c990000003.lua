-- Amber, Dracodeity of the Inferno
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_FIRE)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot be tributed, or be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, tc)
        if tc == e:GetHandler() then return true end
        return tc:GetControler() == e:GetHandlerPlayer() and tc:GetMutualLinkedGroupCount() > 0
    end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetTargetRange(LOCATION_ONFIELD, 0)
    e1b:SetTarget(function(e, tc) return tc:GetMutualLinkedGroupCount() > 0 end)
    e1b:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- destroy & gain ATK
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- disable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0, LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e3b)

    -- inflict damage
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCountLimit(1)
    e4:SetCondition(aux.bdcon)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and Duel.IsMainPhase()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ct = c:GetMutualLinkedGroupCount()
    if chk == 0 then
        return ct > 0 and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, ct, 0, LOCATION_ONFIELD)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local max = c:GetMutualLinkedGroupCount()
    if max <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, max, c)
    local ct = Duel.Destroy(g, REASON_EFFECT)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(ct * 500)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e3con(e)
    local c = e:GetHandler()
    local ac = Duel.GetAttacker()
    return (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL)
        and ac:GetBattleTarget()
        and (ac == c or ac:GetBattleTarget() == c)
end

function s.e3tg(e, tc)
    return tc == e:GetHandler():GetBattleTarget()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if chk == 0 then return true end

    local dmg = bc:GetBaseAttack() > bc:GetBaseDefense() and bc:GetBaseAttack() or bc:GetBaseDefense()
    if dmg < 0 then dmg = 0 end
    dmg = dmg * 2

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
