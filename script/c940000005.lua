-- Number C38: Hope Heralder Dragon Tyrant Galaxy
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 38
s.listed_names = {63767246}
s.listed_series = {0x95, 0x7b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se)
        local loc = e:GetHandler():GetLocation()
        if loc ~= LOCATION_EXTRA then return true end
        return se:GetHandler():IsSetCard(0x95) and
                   se:GetHandler():IsType(TYPE_SPELL)
    end)
    c:RegisterEffect(splimit)

    -- redirect target
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- negate effect & attach
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate effect target
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.effcon)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

s.rum_limit = function(c, e) return c:IsCode(63767246) end
s.rum_xyzsummon = function(c)
    local xyz = Effect.CreateEffect(c)
    xyz:SetDescription(1073)
    xyz:SetType(EFFECT_TYPE_FIELD)
    xyz:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    xyz:SetCode(EFFECT_SPSUMMON_PROC)
    xyz:SetRange(c:GetLocation())
    xyz:SetCondition(Xyz.Condition(nil, 9, 3, 3, false))
    xyz:SetTarget(Xyz.Target(nil, 9, 3, 3, false))
    xyz:SetOperation(Xyz.Operation(nil, 9, 3, 3, false))
    xyz:SetValue(SUMMON_TYPE_XYZ)
    xyz:SetReset(RESET_CHAIN)
    c:RegisterEffect(xyz)
    return xyz
end

function s.e1filter(c, ct) return Duel.CheckChainTarget(ct, c) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    if re == e or rp == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end

    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if not g or #g ~= 1 then return false end
    local tc = g:GetFirst()
    e:SetLabelObject(tc)
    return tc:IsOnField()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ct = ev
    local label = Duel.GetFlagEffectLabel(0, id)
    if label then if ev == (label >> 16) then ct = (label & 0xffff) end end

    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_ONFIELD,
                                     LOCATION_ONFIELD, 1, e:GetLabelObject(), ct)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1,
                      1, e:GetLabelObject(), ct)

    local val = ct + (ev + 1 << 16)
    if label then
        Duel.SetFlagEffectLabel(0, 21501505, val)
    else
        Duel.RegisterFlagEffect(0, 21501505, RESET_CHAIN, 0, 1, val)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.ChangeTargetCard(ev, Group.FromCards(tc))
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local loc = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and
               (loc & LOCATION_SZONE) ~= 0 and re:IsActiveType(TYPE_TRAP) and
               Duel.IsChainDisablable(ev)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsType(TYPE_XYZ) end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if Duel.NegateEffect(ev) and c:IsRelateToEffect(e) and
        rc:IsRelateToEffect(re) and c:IsType(TYPE_XYZ) then
        rc:CancelToGrave()
        Duel.Overlay(c, Group.FromCards(rc))
    end
end

function s.effcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(function(c)
        return c:IsSetCard(0x7b) and c:IsType(TYPE_XYZ)
    end, 1, nil)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if rp == tp then return end
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if g and g:IsContains(c) then
        Utility.HintCard(id)
        Duel.NegateEffect(ev)
    end
end
