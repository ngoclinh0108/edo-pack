-- Black Luster Soldier - Palladium Soldier
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {910000101}
s.listed_series = {0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, 1)
    e2:SetValue(1)
    e2:SetCondition(function(e)
        local c = e:GetHandler()
        return Duel.GetAttacker() == c or Duel.GetAttackTarget() == c
    end)
    c:RegisterEffect(e2)

    -- battle destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCondition(aux.bdocon)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local b1 = true
    local b2 = Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0,
                                           LOCATION_ONFIELD, 1, nil)
    local b3 = Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0,
                                           LOCATION_HAND, 1, nil)
    local b4 = true
    if chk == 0 then return b1 or b2 or b3 or b4 end

    local opt = {}
    local sel = {}
    if b1 then
        table.insert(opt, aux.Stringid(id, 1))
        table.insert(sel, 1)
    end
    if b2 then
        table.insert(opt, aux.Stringid(id, 2))
        table.insert(sel, 2)
    end
    if b3 then
        table.insert(opt, aux.Stringid(id, 3))
        table.insert(sel, 3)
    end
    if b4 then
        table.insert(opt, aux.Stringid(id, 4))
        table.insert(sel, 4)
    end
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]

    e:SetCategory(0)
    if op == 2 then
        e:SetCategory(CATEGORY_REMOVE)
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0,
                                        LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, tp, 0)
    elseif op == 3 then
        e:SetCategory(CATEGORY_REMOVE)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 1 - tp, LOCATION_HAND)
    end
    e:SetLabel(op)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = e:GetLabel()
    if op == 1 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1500)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
    elseif op == 2 then
        local g = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp,
                                             Card.IsAbleToRemove, tp, 0,
                                             LOCATION_ONFIELD, 1, 1, nil)
        if #g > 0 then Duel.Remove(g, POS_FACEUP, REASON_EFFECT) end
    elseif op == 3 then
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0,
                                        LOCATION_HAND, nil, tp, POS_FACEDOWN)
        if #g > 0 then
            g = g:RandomSelect(tp, 1)
            Duel.Remove(g, POS_FACEDOWN, REASON_EFFECT)
        end
    elseif op == 4 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3201)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_EXTRA_ATTACK)
        ec1:SetLabel(Duel.GetTurnCount())
        ec1:SetCondition(function(e)
            return Duel.GetTurnCount() > e:GetLabel()
        end)
        ec1:SetValue(1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END +
                         RESET_SELF_TURN, 2)
        c:RegisterEffect(ec1)
    end
end
