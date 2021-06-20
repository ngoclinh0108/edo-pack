-- Supreme Presence
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {13331639}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- equip
    aux.AddEquipProcedure(c, nil, function(c)
        return c:IsRace(RACE_DRAGON) and c:IsSummonLocation(LOCATION_EXTRA)
    end)

    -- indestructable & negate target
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1b:SetRange(LOCATION_SZONE)
    e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1b:SetValue(1)
    c:RegisterEffect(e1b)
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1c:SetCode(EVENT_CHAIN_SOLVING)
    e1c:SetRange(LOCATION_SZONE)
    e1c:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if rp == tp then return end
        local c = e:GetHandler()
        if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
        local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
        if g and (g:IsContains(c) or g:IsContains(c:GetEquipTarget())) then
            Utility.HintCard(id)
            Duel.NegateEffect(ev)
        end
    end)
    c:RegisterEffect(e1c)

    -- damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- destroy & damage
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- atk up
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetCondition(s.e4con)
    e4:SetValue(s.e4val)
    c:RegisterEffect(e4)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local ec = eg:GetFirst()
    local bc = ec:GetBattleTarget()
    return e:GetHandler():GetEquipTarget() == ec and ec:IsControler(tp) and
               bc:IsPreviousControler(1 - tp) and bc:IsReason(REASON_BATTLE)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ec = e:GetHandler():GetEquipTarget()
    local bc = ec:GetBattleTarget()
    if chk == 0 then return bc:GetBaseAttack() > 0 end

    local dmg = bc:GetBaseAttack()
    if dmg < 0 then dmg = 0 end
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec = c:GetPreviousEquipTarget()
    return c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_BATTLE)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ec = e:GetHandler():GetPreviousEquipTarget()
    local rc = ec:GetReasonCard()
    if chk == 0 then return rc and rc:IsDestructable() end

    Duel.SetTargetCard(rc)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, rc, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, rc:GetAttack())
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    local atk = tc:GetAttack()
    if atk < 0 or tc:IsFacedown() then atk = 0 end
    if Duel.Destroy(tc, REASON_EFFECT) ~= 0 then
        Duel.Damage(1 - tp, atk, REASON_EFFECT)
    end
end

function s.e4con(e)
    local tp = e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsCode(13331639)
    end, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.e4val(e)
    local tp = e:GetHandlerPlayer()
    local g = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_PZONE,
                                    LOCATION_PZONE, nil, TYPE_PENDULUM)
    local atk = 0
    for tc in aux.Next(g) do
        if tc:GetBaseAttack() > 0 then atk = atk + tc:GetBaseAttack() end
    end
    return atk
end
