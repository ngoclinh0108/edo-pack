-- Messiah, Genesis of Dracodeity
local s, id = GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)
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

    -- move zone
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- move material
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- to deck
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.sprfilter(c)
    return c:GetMutualLinkedGroupCount() > 0
end

function s.sprcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
    return #g > 0 and Duel.GetLocationCountFromEx(tp, tp, g, c) > 0
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
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

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_SET_BASE_ATTACK)
    ec2:SetValue(g:GetClassCount(Card.GetOriginalAttribute) * 1000)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE - RESET_TOFIELD)
    c:RegisterEffect(ec2)
    for tc in aux.Next(g) do
        if tc:IsOriginalRace(RACE_DIVINE) then
            c:CopyEffect(tc:GetCode(), RESET_EVENT + RESETS_STANDARD_DISABLE - RESET_TOFIELD)
        end
    end

    Duel.Overlay(c, g)
    g:DeleteGroup()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and not Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOZONE)
    local seq = Duel.SelectDisableField(tp, 1, LOCATION_MZONE, 0, 0)
    Duel.MoveSequence(c, math.log(seq, 2))
end

function s.e3zone(e, tp, type)
    if type ~= LOCATION_MZONE and type ~= LOCATION_SZONE then return 0 end

    local c = e:GetHandler()
    local seq = c:GetSequence()
    if type == LOCATION_SZONE and seq > 4 then return 0 end

    local zones = {}
    if seq == 0 then
        zones = { 1, 2 }
        if type == LOCATION_MZONE then table.insert(zones, 32) end
    elseif seq == 1 or seq == 5 then zones = { 1, 2, 4 }
    elseif seq == 2 then
        zones = { 2, 4, 8 }
        if type == LOCATION_MZONE then
            table.insert(zones, 32)
            table.insert(zones, 64)
        end
    elseif seq == 3 or seq == 6 then zones = { 4, 8, 16 }
    elseif seq == 4 then
        zones = { 8, 16 }
        if type == LOCATION_MZONE then table.insert(zones, 64) end
    else return 0 end

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, type, 0, nil)
    local result = 0
    for _, zone in ipairs(zones) do
        if not g:IsExists(function(c) return aux.IsZone(c, zone, tp) end, 1, nil) then
            result = result + zone
        end
    end
    return result
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return (s.e3zone(e, tp, LOCATION_MZONE) > 0 or s.e3zone(e, tp, LOCATION_SZONE) > 0)
            and c:GetOverlayCount() > 0
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetOverlayGroup():Select(tp, 1, 1, nil):GetFirst()
    if not tc then return end

    local opt = {}
    local sel = {}
    if s.e3zone(e, tp, LOCATION_MZONE) > 0 then
        table.insert(opt, 2201)
        table.insert(sel, 1)
    end
    if s.e3zone(e, tp, LOCATION_SZONE) > 0 then
        table.insert(opt, 2202)
        table.insert(sel, 2)
    end
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]

    if op == 1 then
        Duel.MoveToField(tc, tp, tp, LOCATION_MZONE, POS_FACEUP, true, s.e3zone(e, tp, LOCATION_MZONE))
    elseif op == 2 then
        Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true, s.e3zone(e, tp, LOCATION_SZONE))
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_TYPE)
        ec1:SetValue(TYPE_SPELL + TYPE_LINK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
    end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetDescription(3206)
    ec2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_CANNOT_ATTACK)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec2)
    local ec2b = ec2:Clone()
    ec2b:SetDescription(3302)
    ec2b:SetCode(EFFECT_CANNOT_TRIGGER)
    tc:RegisterEffect(ec2b)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetMutualLinkedGroupCount() >= 7 end

    local loc = LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, loc, loc, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, tp, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, loc, loc, nil)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
end
