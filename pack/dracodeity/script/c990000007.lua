-- Messiah, Genesis of Dracodeity
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_EXTRA)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

    -- summon cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e1)

    -- immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    c:RegisterEffect(e2)

    -- attribute
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.sprfilter(c)
    return c:GetMutualLinkedGroupCount() > 0
end

function s.sprcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
    return #g > 0 and aux.SelectUnselectGroup(g, e, tp, 7, 7, aux.ChkfMMZ(1), 0)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local mg = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
    local g = aux.SelectUnselectGroup(mg, e, tp, 7, 7, aux.ChkfMMZ(1), 1, tp, HINTMSG_TOGRAVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(g:GetClassCount(Card.GetAttribute) * 1000)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE - RESET_TOFIELD)
    c:RegisterEffect(ec1)
    for tc in aux.Next(g) do
        c:CopyEffect(tc:GetCode(), RESET_EVENT + RESETS_STANDARD_DISABLE - RESET_TOFIELD)
    end

    Duel.Overlay(c, g)
    g:DeleteGroup()
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and not Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOZONE)
    local seq = Duel.SelectDisableField(tp, 1, LOCATION_MZONE, 0, 0)
    Duel.MoveSequence(c, math.log(seq, 2))
end
