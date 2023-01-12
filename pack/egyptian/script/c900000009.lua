-- Zorc Necrophades, the Great Wicked God
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
local s, id = GetID()

s.divine_hierarchy = 3

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 1, id)

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_EXTRA)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(spsafe)

    -- cannot be release, or be material
    local matlimit = Effect.CreateEffect(c)
    matlimit:SetType(EFFECT_TYPE_SINGLE)
    matlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    matlimit:SetCode(EFFECT_UNRELEASABLE_SUM)
    matlimit:SetValue(1)
    c:RegisterEffect(matlimit)
    local matlimit2 = matlimit:Clone()
    matlimit2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(matlimit2)
    local matlimit3 = matlimit:Clone()
    matlimit3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    c:RegisterEffect(matlimit3)

    -- immune
    local immune = Effect.CreateEffect(c)
    immune:SetType(EFFECT_TYPE_SINGLE)
    immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    immune:SetCode(EFFECT_IMMUNE_EFFECT)
    immune:SetRange(LOCATION_MZONE)
    immune:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        return te:GetOwner() ~= e:GetOwner() and Divine.GetDivineHierarchy(c) >= Divine.GetDivineHierarchy(tc)
    end)
    c:RegisterEffect(immune)

    -- battle indes & avoid damage
    local indes = Effect.CreateEffect(c)
    indes:SetType(EFFECT_TYPE_SINGLE)
    indes:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    indes:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    indes:SetValue(function(e, tc)
        return tc and Divine.GetDivineHierarchy(tc) > 0 and Divine.GetDivineHierarchy(tc) <
                   Divine.GetDivineHierarchy(e:GetHandler())
    end)
    c:RegisterEffect(indes)
    local indes2 = indes:Clone()
    indes2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(indes2)

    -- attach
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- gain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.sprfilter(c)
    return c:IsOriginalAttribute(ATTRIBUTE_DARK) and c:IsOriginalRace(RACE_DIVINE) and
               c:IsSummonType(SUMMON_TYPE_NORMAL)
end

function s.sprescon(sg, e, tp, mg)
    return aux.ChkfMMZ(1)(sg, e, tp, mg) and sg:GetClassCount(Card.GetCode) == #sg,
        sg:GetClassCount(Card.GetCode) ~= #sg
end

function s.sprcon(e, c)
    if c == nil then
        return true
    end
    local tp = c:GetControler()

    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
    return aux.SelectUnselectGroup(g, e, tp, 3, 3, s.sprescon, 0)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
    local sg = aux.SelectUnselectGroup(g, e, tp, 3, 3, s.sprescon, 1, tp, HINTMSG_XMATERIAL, nil, nil, true)
    if #sg > 0 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then
        return
    end

    Duel.Overlay(c, g)
    g:DeleteGroup()
end

function s.e1filter(c, tp)
    return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and (c:IsControler(tp) or c:IsAbleToChangeControler())
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsType(TYPE_XYZ) and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_ONFIELD + LOCATION_GRAVE,
                LOCATION_ONFIELD + LOCATION_GRAVE, 1, c, tp)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    local tc = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e1filter, tp, LOCATION_ONFIELD + LOCATION_GRAVE,
        LOCATION_ONFIELD + LOCATION_GRAVE, 1, 1, c, tp):GetFirst()
    if not tc then
        return
    end

    Duel.HintSelection(tc)
    local og = tc:GetOverlayGroup()
    if #og > 0 then
        Duel.Overlay(c, og)
    end
    Duel.Overlay(c, tc)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(function(tc)
        return not tc:IsCode(id) and tc:IsMonster()
    end, nil)
    if #og <= 0 then
        return
    end

    for tc in aux.Next(og) do
        local code = tc:GetOriginalCode()
        local isExisted = og:IsExists(function(tc, code)
            return tc:IsOriginalCode(code) and tc:GetFlagEffect(id) > 0
        end, 1, nil, code)

        if not isExisted then
            tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe2000, 0, 0)
            local cid = c:CopyEffect(code, RESET_EVENT + 0x1fe2000)

            local reset = Effect.CreateEffect(c)
            reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            reset:SetCode(EVENT_ADJUST)
            reset:SetRange(LOCATION_MZONE)
            reset:SetLabel(cid)
            reset:SetLabelObject(tc)
            reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                local cid = e:GetLabel()
                local c = e:GetHandler()
                local tc = e:GetLabelObject()
                local g = c:GetOverlayGroup():Filter(function(c)
                    return c:GetFlagEffect(id) > 0
                end, nil)
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset:SetReset(RESET_EVENT + 0x1fe2000)
            c:RegisterEffect(reset, true)
        end
    end
end
