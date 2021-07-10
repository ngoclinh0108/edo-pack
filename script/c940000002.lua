-- Number Z100: Genesis Numeron Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 100
s.listed_series = {0x48}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, nil, 5, nil, aux.Stringid(id, 0), nil, nil,
                     false, s.xyzcheck)

    -- summon cannot be negated
    local nospnegate = Effect.CreateEffect(c)
    nospnegate:SetType(EFFECT_TYPE_SINGLE)
    nospnegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nospnegate:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(nospnegate)

    -- activation and effects cannot be negated
    local inact = Effect.CreateEffect(c)
    inact:SetType(EFFECT_TYPE_FIELD)
    inact:SetCode(EFFECT_CANNOT_INACTIVATE)
    inact:SetRange(LOCATION_MZONE)
    inact:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(inact)
    local inact2 = inact:Clone()
    inact2:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(inact2)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    nodis:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nodis)

    -- cannot be switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- cannot be flipped
    local noflip = Effect.CreateEffect(c)
    noflip:SetType(EFFECT_TYPE_SINGLE)
    noflip:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noflip:SetCode(EFFECT_CANNOT_TURN_SET)
    noflip:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noflip)

    -- cannot be tributed or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nofus = Effect.CreateEffect(c)
    nofus:SetType(EFFECT_TYPE_SINGLE)
    nofus:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nofus:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    nofus:SetRange(LOCATION_MZONE)
    nofus:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nofus)
    local nosync = nofus:Clone()
    nosync:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(nosync)
    local noxyz = nofus:Clone()
    noxyz:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(noxyz)
    local nolnk = nofus:Clone()
    nolnk:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(nolnk)

    -- gain effect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.xyzfilter(c, xyz, sumtype, tp)
    return c:IsType(TYPE_XYZ, xyz, sumtype, tp) and
               c:IsSetCard(0x48, xyz, sumtype, tp)
end

function s.xyzcheck(g, tp, xyz)
    local mg =
        g:Filter(function(c) return not c:IsHasEffect(511001175) end, nil)
    return mg:GetClassCount(Card.GetRank) == 1
end

function s.e1filter(c)
    return
        not c:IsCode(id) and c:GetFlagEffect(id) == 0 and c:IsType(TYPE_XYZ) and
            c:IsSetCard(0x48)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup():Filter(s.e1filter, nil)
    if #g <= 0 then return end

    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe0000, 0, 0)
        local cid = c:CopyEffect(tc:GetOriginalCode(), RESET_EVENT + 0x1fe0000)

        local reset = Effect.CreateEffect(c)
        reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        reset:SetCode(EVENT_ADJUST)
        reset:SetRange(LOCATION_PZONE)
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
        reset:SetReset(RESET_EVENT + 0x1fe0000)
        c:RegisterEffect(reset, true)
    end
end
