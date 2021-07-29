-- Moros of the Nordic Alfar
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- extra material
    local e1syn = Effect.CreateEffect(c)
    e1syn:SetType(EFFECT_TYPE_SINGLE)
    e1syn:SetCode(EFFECT_HAND_SYNCHRO)
    e1syn:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1syn:SetLabel(id)
    e1syn:SetValue(s.e1synval)
    c:RegisterEffect(e1syn)
    local e1lnk = Effect.CreateEffect(c)
    e1lnk:SetType(EFFECT_TYPE_FIELD)
    e1lnk:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1lnk:SetCode(EFFECT_EXTRA_MATERIAL)
    e1lnk:SetRange(LOCATION_HAND)
    e1lnk:SetTargetRange(1, 0)
    e1lnk:SetOperation(s.e1lnkcon)
    e1lnk:SetValue(s.e1lnkval)
    local e1lnkgrant = Effect.CreateEffect(c)
    e1lnkgrant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e1lnkgrant:SetRange(LOCATION_MZONE)
    e1lnkgrant:SetTargetRange(LOCATION_HAND, 0)
    e1lnkgrant:SetTarget(s.e1lnkgranttg)
    e1lnkgrant:SetLabelObject(e1lnk)
    c:RegisterEffect(e1lnkgrant)
    aux.GlobalCheck(s, function() s.flagmap = {} end)
end

function s.e1synval(e, tc, sc)
    local c = e:GetHandler()
    if sc:IsSetCard(0x4b) and
        (not tc:IsType(TYPE_TUNER) or tc:IsHasEffect(EFFECT_NONTUNER)) and
        tc:IsSetCard(0x42) and tc:IsLocation(LOCATION_HAND) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)
        ec1:SetLabel(id)
        ec1:SetTarget(s.e1syntg)
        tc:RegisterEffect(ec1)
        return true
    else
        return false
    end
end

function s.e1syntg(e, tc, sg, tg, ntg, tsg, ntsg)
    if not tc then return true end
    local res = true

    if sg:IsExists(s.e1chk2, 1, tc) or
        (not tg:IsExists(s.e1chk1, 1, tc) and not ntg:IsExists(s.e1chk1, 1, tc) and
            not sg:IsExists(s.e1chk1, 1, tc)) then return false end
    local trg = tg:Filter(s.e1chk2, nil)
    local ntrg = ntg:Filter(s.e1chk2, nil)
    return res, trg, ntrg
end

function s.e1chk1(c)
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

function s.e1chk2(c)
    if c:IsSetCard(0x42) then return false end
    return not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or
               c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) or
               c:GetCardEffect(EFFECT_HAND_SYNCHRO):GetLabel() ~= id
end

function s.e1lnkcon(c, e, tp, sg, mg, lc, og, chk)
    local ct = sg:FilterCount(function(c) return c:GetFlagEffect(id) > 0 end,
                              nil)
    return ct == 0 or (sg + mg):Filter(function(c, tp)
        return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
    end, nil, e:GetHandlerPlayer()):IsExists(Card.IsCode, 1, og, id)
end

function s.e1lnkval(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or not sc:IsSetCard(0x4b) then
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

function s.e1lnkgranttg(e, c)
    return c:IsCanBeLinkMaterial() and c:IsSetCard(0x42) and
               (not c:IsType(TYPE_TUNER) or c:IsHasEffect(EFFECT_NONTUNER))
end
