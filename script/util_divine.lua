-- init
if not aux.DivineProcedure then aux.DivineProcedure = {} end
if not Divine then Divine = aux.DivineProcedure end

-- function
function Divine.AddProcedure(c, summon_mode, summon_extra, limit)
    -- summon mode
    if summon_mode == "nomi" then
        summonNomi(c, summon_extra)
    elseif summon_mode == "egyptian" then
        summonEgyptian(c, summon_extra)
    elseif summon_mode == "wicked" then
        summonWicked(c, summon_extra)
    end

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

        if (tc == c) or
            (tc.divine_hierarchy and tc.divine_hierarchy >= c.divine_hierarchy) then
            return false
        end

        return (te:GetOwnerPlayer() ~= e:GetOwnerPlayer() and
                   te:IsActiveType(TYPE_MONSTER)) or
                   te:IsHasCategory(CATEGORY_DESTROY + CATEGORY_REMOVE +
                                        CATEGORY_TOGRAVE + CATEGORY_TOHAND +
                                        CATEGORY_TODECK + CATEGORY_RELEASE +
                                        CATEGORY_FUSION_SUMMON)
    end)
    c:RegisterEffect(immunity)

    -- battle indes & no damage
    local battle = Effect.CreateEffect(c)
    battle:SetType(EFFECT_TYPE_SINGLE)
    battle:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    battle:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    battle:SetRange(LOCATION_MZONE)
    battle:SetValue(function(e, tc)
        return tc and tc.divine_hierarchy and tc.divine_hierarchy <
                   e:GetOwner().divine_hierarchy
    end)
    c:RegisterEffect(battle)
    local nodmg = battle:Clone()
    nodmg:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(nodmg)

    -- reset effect
    local reset = Effect.CreateEffect(c)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    reset:SetCode(EVENT_ADJUST)
    reset:SetRange(LOCATION_MZONE)
    reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        if Duel.GetCurrentPhase() ~= PHASE_END then return false end

        local c = e:GetOwner()
        local check = false
        local effs = {c:GetCardEffect()}
        for _, eff in ipairs(effs) do
            check = (eff:GetOwner() ~= c and
                        not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and
                        eff:GetCode() ~= EFFECT_SPSUMMON_PROC and
                        (eff:GetTarget() == aux.PersistentTargetFilter or
                            not eff:IsHasType(EFFECT_TYPE_GRANT)))
            if check == true then break end
        end
        return check
    end)
    reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetOwner()
        local effs = {c:GetCardEffect()}
        for _, eff in ipairs(effs) do
            local ec = eff:GetOwner()
            local check = ec ~= c and
                              not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and
                              eff:GetCode() ~= EFFECT_SPSUMMON_PROC and
                              (eff:GetTarget() == aux.PersistentTargetFilter or
                                  not eff:IsHasType(EFFECT_TYPE_GRANT))

            if check then
                if not eff:IsHasType(EFFECT_TYPE_FIELD) then
                    eff:Reset()
                end

                if (not ec.divine_hierarchy) then
                    local immunity = Effect.CreateEffect(c)
                    immunity:SetType(EFFECT_TYPE_SINGLE)
                    immunity:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
                    immunity:SetCode(EFFECT_IMMUNE_EFFECT)
                    immunity:SetRange(LOCATION_MZONE)
                    immunity:SetLabelObject(ec)
                    immunity:SetValue(function(e, te)
                        return te:GetOwner() == e:GetLabelObject()
                    end)
                    immunity:SetReset(RESET_EVENT + RESETS_STANDARD)
                    c:RegisterEffect(immunity)
                end
            end
        end
    end)
    c:RegisterEffect(reset)
end

function Divine.ToGraveLimit(c)
    local togy = Effect.CreateEffect(c)
    togy:SetCategory(CATEGORY_TOGRAVE)
    togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    togy:SetCode(EVENT_ADJUST)
    togy:SetRange(LOCATION_MZONE)
    togy:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetOwner()
        return Duel.GetCurrentPhase() == PHASE_END and
                   c:IsSummonType(SUMMON_TYPE_SPECIAL) and
                   c:IsPreviousLocation(LOCATION_GRAVE) and c:IsAbleToGrave()
    end)
    togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.SendtoGrave(e:GetOwner(), REASON_EFFECT)
    end)
    c:RegisterEffect(togy)
end

function summonNomi(c, summon_extra)
    c:EnableReviveLimit()

    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)
end

function summonEgyptian(c, summon_extra)
    aux.AddNormalSummonProcedure(c, true, false, 3, 3)
    aux.AddNormalSetProcedure(c)

    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(sumsafe)
end

function summonWicked(c, summon_extra)
    aux.AddNormalSummonProcedure(c, true, false, 3, 3)
    aux.AddNormalSetProcedure(c)

    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(sumsafe)
end
