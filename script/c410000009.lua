-- Zorc Necrophades the Creator of Shadow Realm
local s, id = GetID()

s.divine_hierarchy = 3

function s.initial_effect(c)
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
end
