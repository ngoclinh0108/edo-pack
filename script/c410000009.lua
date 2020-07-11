-- Zorc Necrophades the Creator of Shadow Realm
local s, id = GetID()

s.divine_hierarchy = 3

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 1, id)

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, nil, 3, nil, nil, 99, nil, false,
                     s.xyzcheck)

    -- special summon condition
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not se and st and SUMMON_TYPE_XYZ == SUMMON_TYPE_XYZ
    end)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(spsafe)

    -- activation and effects cannot be negated
    local inact = Effect.CreateEffect(c)
    inact:SetType(EFFECT_TYPE_FIELD)
    inact:SetCode(EFFECT_CANNOT_INACTIVATE)
    inact:SetRange(LOCATION_MZONE)
    inact:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetOwner() == e:GetOwner()
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

    -- cannot be tributed or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc, tp, sumtp) return tc == e:GetOwner() end)
    c:RegisterEffect(norelease)
    local nofus = Effect.CreateEffect(c)
    nofus:SetType(EFFECT_TYPE_SINGLE)
    nofus:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nofus:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    nofus:SetRange(LOCATION_MZONE)
    nofus:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetOwnerPlayer()
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

    -- cannot be flipped face-down
    local noflip = Effect.CreateEffect(c)
    noflip:SetType(EFFECT_TYPE_SINGLE)
    noflip:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noflip:SetCode(EFFECT_CANNOT_TURN_SET)
    noflip:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noflip)

    -- cannot be switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- immunity
    local immunity = Effect.CreateEffect(c)
    immunity:SetType(EFFECT_TYPE_SINGLE)
    immunity:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    immunity:SetCode(EFFECT_IMMUNE_EFFECT)
    immunity:SetRange(LOCATION_MZONE)
    immunity:SetValue(function(e, te)
        local c = e:GetOwner()
        local tc = te:GetOwner()
        return tc ~= c and
                   (not tc.divine_hierarchy or tc.divine_hierarchy <
                       c.divine_hierarchy)
    end)
    c:RegisterEffect(immunity)

    -- battle indes & no damage
    local battle = Effect.CreateEffect(c)
    battle:SetType(EFFECT_TYPE_SINGLE)
    battle:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    battle:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    battle:SetRange(LOCATION_MZONE)
    battle:SetValue(function(e, tc)
        return tc and
                   (not tc.divine_hierarchy or tc.divine_hierarchy <
                       e:GetOwner().divine_hierarchy)
    end)
    c:RegisterEffect(battle)
    local nodmg = battle:Clone()
    nodmg:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(nodmg)

    -- attribute & race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_ADD_RACE)
    e1b:SetValue(RACE_FIEND)
    c:RegisterEffect(e1b)

    -- gain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.xyzfilter(c, xyz, sumtype, tp)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DIVINE)
end

function s.xyzcheck(g, tp, xyz)
    return
        g:GetClassCount(Card.GetLevel) == 1 and g:GetClassCount(Card.GetCode) ==
            #g
end

function s.e2filter(c)
    return c:IsType(TYPE_MONSTER) and c:GetOriginalRace() ~= RACE_CREATORGOD and
               c:GetFlagEffect(id) == 0
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    local g = c:GetOverlayGroup():Filter(s.e2filter, nil)
    if c:IsFacedown() or #g <= 0 then return end

    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe0000, 0, 0)
        local cid = c:CopyEffect(tc:GetOriginalCode(), RESET_EVENT + 0x1fe0000)

        local reset = Effect.CreateEffect(c)
        reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        reset:SetCode(EVENT_ADJUST)
        reset:SetRange(LOCATION_MZONE)
        reset:SetLabel(cid)
        reset:SetLabelObject(tc)
        reset:SetOperation(s.e2resetop)
        reset:SetReset(RESET_EVENT + 0x1fe0000)
        c:RegisterEffect(reset, true)
    end
end

function s.e2resetop(e, tp, eg, ep, ev, re, r, rp)
    local cid = e:GetLabel()
    local c = e:GetOwner()
    local tc = e:GetLabelObject()
    local g = c:GetOverlayGroup():Filter(Card.IsType, nil, TYPE_MONSTER)

    if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
        c:ResetEffect(cid, RESET_COPY)
        tc:ResetFlagEffect(id)
    end
end
