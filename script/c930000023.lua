-- Narfi of the Nordic Alfar
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- synchro substitute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(61777313)
    c:RegisterEffect(e1)

    -- material limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    e2:SetValue(function(e, c)
        if not c then return false end
        return not c:IsSetCard(0x4b)
    end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(e2b)

    -- extra material
    local e3syn = Effect.CreateEffect(c)
    e3syn:SetType(EFFECT_TYPE_SINGLE)
    e3syn:SetCode(EFFECT_HAND_SYNCHRO)
    e3syn:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e3syn:SetLabel(id)
    e3syn:SetValue(s.e3synval)
    c:RegisterEffect(e3syn)
    local e3lnk = Effect.CreateEffect(c)
    e3lnk:SetType(EFFECT_TYPE_FIELD)
    e3lnk:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3lnk:SetCode(EFFECT_EXTRA_MATERIAL)
    e3lnk:SetRange(LOCATION_HAND)
    e3lnk:SetTargetRange(1, 0)
    e3lnk:SetOperation(s.e3lnkcon)
    e3lnk:SetValue(s.e3lnkval)
    local e3lnkgrant = Effect.CreateEffect(c)
    e3lnkgrant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e3lnkgrant:SetRange(LOCATION_MZONE)
    e3lnkgrant:SetTargetRange(LOCATION_HAND, 0)
    e3lnkgrant:SetTarget(s.e3lnkgranttg)
    e3lnkgrant:SetLabelObject(e3lnk)
    c:RegisterEffect(e3lnkgrant)
    aux.GlobalCheck(s, function() s.flagmap = {} end)
end

function s.e3synval(e, tc, sc)
    local c = e:GetHandler()
    if (not tc:IsType(TYPE_TUNER) or tc:IsHasEffect(EFFECT_NONTUNER)) and
        tc:IsSetCard(0x42) and tc:IsLocation(LOCATION_HAND) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)
        ec1:SetLabel(id)
        ec1:SetTarget(s.e3syntg)
        tc:RegisterEffect(ec1)
        return true
    else
        return false
    end
end

function s.e3syntg(e, tc, sg, tg, ntg, tsg, ntsg)
    if not tc then return true end
    local res = true

    if sg:IsExists(s.e3chk2, 1, tc) or
        (not tg:IsExists(s.e3chk1, 1, tc) and not ntg:IsExists(s.e3chk1, 1, tc) and
            not sg:IsExists(s.e3chk1, 1, tc)) then return false end
    local trg = tg:Filter(s.e3chk2, nil)
    local ntrg = ntg:Filter(s.e3chk2, nil)
    return res, trg, ntrg
end

function s.e3chk1(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or
        c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then
        return false
    end

    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() == id then return true end
    end
    return false
end

function s.e3chk2(c)
    if c:IsSetCard(0x42) then return false end
    return not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or
               c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) or
               c:GetCardEffect(EFFECT_HAND_SYNCHRO):GetLabel() ~= id
end

function s.e3lnkcon(c, e, tp, sg, mg, lc, og, chk)
    local ct = sg:FilterCount(function(c) return c:GetFlagEffect(id) > 0 end,
                              nil)
    return ct == 0 or (sg + mg):Filter(function(c, tp)
        return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
    end, nil, e:GetHandlerPlayer()):IsExists(Card.IsCode, 1, og, id)
end

function s.e3lnkval(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        if summon_type ~= SUMMON_TYPE_LINK then
            return Group.CreateGroup()
        else
            s.flagmap[c] = c:RegisterFlagEffect(id, 0, 0, 1)
            return Group.FromCards(c)
        end
    elseif chk == 2 then
        if s.flagmap[c] then
            s.flagmap[c]:Reset()
            s.flagmap[c] = nil
        end
    end
end

function s.e3lnkgranttg(e, c)
    return c:IsCanBeLinkMaterial() and c:IsSetCard(0x42) and
               (not c:IsType(TYPE_TUNER) or c:IsHasEffect(EFFECT_NONTUNER))
end
