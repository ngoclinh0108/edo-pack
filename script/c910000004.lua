-- Black Luster Soldier - Palladium Soldier
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {910000101}
s.listed_series = {0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.ritlimit)
    c:RegisterEffect(splimit)

    -- special summon procedure
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_HAND)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

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

function s.spfilter(c, attr)
    return c:IsAttribute(attr) and c:IsAbleToRemoveAsCost() and
               aux.SpElimFilter(c, true)
end

function s.sprescon(sg, e, tp, mg)
    return aux.ChkfMMZ(1)(sg, e, tp, mg) and
               sg:IsExists(s.spattrcheck, 1, nil, sg)
end

function s.spattrcheck(c, sg)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and
               sg:FilterCount(Card.IsAttribute, c, ATTRIBUTE_DARK) == 1
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g1 = Duel.GetMatchingGroup(s.spfilter, tp,
                                     LOCATION_MZONE + LOCATION_GRAVE, 0, nil,
                                     ATTRIBUTE_LIGHT)
    local g2 = Duel.GetMatchingGroup(s.spfilter, tp,
                                     LOCATION_MZONE + LOCATION_GRAVE, 0, nil,
                                     ATTRIBUTE_DARK)

    local g = g1:Clone():Merge(g2)
    return #g1 > 0 and #g2 > 0 and
               aux.SelectUnselectGroup(g, e, tp, 2, 2, s.sprescon, 0) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > -2
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local mg = Duel.GetMatchingGroup(s.spfilter, tp,
                                     LOCATION_MZONE + LOCATION_GRAVE, 0, nil,
                                     ATTRIBUTE_LIGHT + ATTRIBUTE_DARK)
    local g = aux.SelectUnselectGroup(mg, e, tp, 2, 2, s.sprescon, 1, tp,
                                      HINTMSG_REMOVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Remove(g, POS_FACEUP, REASON_COST)
    g:DeleteGroup()
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
