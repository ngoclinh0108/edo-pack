-- init
if not aux.DivineProcedure then
    aux.DivineProcedure = {}
end
if not Divine then
    Divine = aux.DivineProcedure
end

-- constant: flag
Divine.FLAG_DIVINE_EVOLUTION = 513000065

-- function
function Divine.DivineHierarchy(s, c, divine_hierarchy, cannot_be_negated)
    if divine_hierarchy then
        s.divine_hierarchy = divine_hierarchy
    end

    -- cannot special summon
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return sp == e:GetOwnerPlayer()
    end)
    c:RegisterEffect(splimit)

    -- 3 tribute
    aux.AddNormalSummonProcedure(c, true, false, 3, 3)
    aux.AddNormalSetProcedure(c)

    -- summon cannot be negate
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(sumsafe)

    -- no change control and battle position
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)
    local nopos = noswitch:Clone()
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    c:RegisterEffect(nopos)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc)
        return tc == e:GetHandler()
    end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nomaterial)

    -- no leave
    local noleave_destroy = Effect.CreateEffect(c)
    noleave_destroy:SetType(EFFECT_TYPE_SINGLE)
    noleave_destroy:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    noleave_destroy:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    noleave_destroy:SetRange(LOCATION_MZONE)
    noleave_destroy:SetValue(function(e, re)
        local rc = re:GetHandler()
        return rc ~= e:GetHandler() and
                   (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
    end)
    c:RegisterEffect(noleave_destroy)
    local noleave_release = noleave_destroy:Clone()
    noleave_release:SetCode(EFFECT_UNRELEASABLE_EFFECT)
    c:RegisterEffect(noleave_release)
    local noleave_immune = Effect.CreateEffect(c)
    noleave_immune:SetType(EFFECT_TYPE_SINGLE)
    noleave_immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    noleave_immune:SetCode(EFFECT_IMMUNE_EFFECT)
    noleave_immune:SetRange(LOCATION_MZONE)
    noleave_immune:SetValue(function(e, re)
        if not re then
            return false
        end

        local rc = re:GetHandler()
        return rc ~= e:GetHandler() and re:IsHasCategory(CATEGORY_TOHAND + CATEGORY_TODECK + CATEGORY_TOGRAVE + CATEGORY_REMOVE) and
                   (not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <= Divine.GetDivineHierarchy(c))
    end)
    c:RegisterEffect(noleave_immune)

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

    -- reset effect
    local reset = Effect.CreateEffect(c)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    reset:SetRange(LOCATION_MZONE)
    reset:SetCode(EVENT_ADJUST)
    reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetCurrentPhase() == PHASE_END and Utility.GetListEffect(e:GetHandler(), ResetEffectFilter)
    end)
    reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Utility.ResetListEffect(e:GetHandler(), ResetEffectFilter)
    end)
    c:RegisterEffect(reset)

    -- cannot attack when special summoned
    local atklimit = Effect.CreateEffect(c)
    atklimit:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    atklimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_DISABLE)
    atklimit:SetCode(EVENT_SPSUMMON_SUCCESS)
    atklimit:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local rc = re:GetHandler()
        return not rc or not rc:ListsCode(c:GetCode())
    end)
    atklimit:SetOperation(function(e)
        local c = e:GetHandler()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3206)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end)
    c:RegisterEffect(atklimit)

    -- to grave
    local togy = Effect.CreateEffect(c)
    togy:SetDescription(666002)
    togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    togy:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    togy:SetRange(LOCATION_MZONE)
    togy:SetCode(EVENT_PHASE + PHASE_END)
    togy:SetCountLimit(1)
    togy:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsAbleToGrave()
    end)
    togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
    end)
    c:RegisterEffect(togy)

    -- effect cannot be negated
    if cannot_be_negated then
        local nodis1 = Effect.CreateEffect(c)
        nodis1:SetType(EFFECT_TYPE_SINGLE)
        nodis1:SetCode(EFFECT_CANNOT_DISABLE)
        c:RegisterEffect(nodis1)
        local nodis2 = Effect.CreateEffect(c)
        nodis2:SetType(EFFECT_TYPE_FIELD)
        nodis2:SetCode(EFFECT_CANNOT_DISEFFECT)
        nodis2:SetRange(LOCATION_MZONE)
        nodis2:SetValue(function(e, ct)
            local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
            return te:GetHandler() == e:GetHandler()
        end)
        c:RegisterEffect(nodis2)
    end
end

function Divine.GetDivineHierarchy(c, get_base)
    if not c then
        return 0
    end
    local divine_hierarchy = c.divine_hierarchy
    if not divine_hierarchy then
        divine_hierarchy = 0
    end
    if get_base then
        return divine_hierarchy
    end

    if c:GetFlagEffect(Divine.FLAG_DIVINE_EVOLUTION) > 0 then
        divine_hierarchy = divine_hierarchy + 1
    end

    return divine_hierarchy
end

function Divine.DivineEvolution(c)
    c:RegisterFlagEffect(Divine.FLAG_DIVINE_EVOLUTION, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0,
        666000)
end

function Divine.IsDivineEvolution(c)
    return c:GetFlagEffect(Divine.FLAG_DIVINE_EVOLUTION) > 0
end

function ResetEffectFilter(e, c)
    if e:GetOwner() == c or e:GetOwner():IsCode(10000080) then
        return false
    end

    return not e:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and e:GetCode() ~= EFFECT_SPSUMMON_PROC and
               (e:GetTarget() == aux.PersistentTargetFilter or not e:IsHasType(EFFECT_TYPE_GRANT)) and
               not e:IsHasProperty(EFFECT_FLAG_FIELD_ONLY)
end
