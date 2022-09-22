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
function Divine.DivineHierarchy(s, c, divine_hierarchy)
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

    -- effect cannot be negated
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

    -- no switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetRange(LOCATION_MZONE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(noswitch)

    -- no change position and switch control
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nopos:SetRange(LOCATION_MZONE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetValue(1)
    c:RegisterEffect(nopos)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc)
        return tc == e:GetHandler()
    end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nomaterial)

    -- no leave
    local noleave_release = Effect.CreateEffect(c)
    noleave_release:SetType(EFFECT_TYPE_SINGLE)
    noleave_release:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noleave_release:SetCode(EFFECT_UNRELEASABLE_EFFECT)
    noleave_release:SetRange(LOCATION_MZONE)
    noleave_release:SetValue(function(e, te)
        local tc = te:GetHandler()
        if tc == e:GetHandler() or not te:IsActivated() then
            return false
        end

        return not tc:IsMonster() or Divine.GetDivineHierarchy(tc) <= Divine.GetDivineHierarchy(c)
    end)
    c:RegisterEffect(noleave_release)
    local noleave_destroy = noleave_release:Clone()
    noleave_destroy:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(noleave_destroy)
    local noleave_solving = Effect.CreateEffect(c)
    noleave_solving:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    noleave_solving:SetRange(LOCATION_MZONE)
    noleave_solving:SetCode(EVENT_CHAIN_SOLVING)
    noleave_solving:SetLabelObject({})
    noleave_solving:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local effs = e:GetLabelObject()
        while #effs > 0 do
            local eff = table.remove(effs)
            if not eff then
                eff:Reset()
            end
        end

        local c = e:GetHandler()
        local rc = re:GetHandler()
        if c == rc or (rc:IsMonster() and Divine.GetDivineHierarchy(rc) > Divine.GetDivineHierarchy(c)) then
            return
        end

        local eff_codes = {EFFECT_CANNOT_TO_HAND, EFFECT_CANNOT_TO_DECK, EFFECT_CANNOT_TO_GRAVE, EFFECT_CANNOT_REMOVE}
        for _, eff_code in ipairs(eff_codes) do
            local eff = Effect.CreateEffect(c)
            eff:SetType(EFFECT_TYPE_SINGLE)
            eff:SetCode(eff_code)
            eff:SetRange(LOCATION_MZONE)
            eff:SetValue(1)
            eff:SetReset(RESET_CHAIN)
            c:RegisterEffect(eff)
            table.insert(e:GetLabelObject(), eff)
        end
    end)
    c:RegisterEffect(noleave_solving)

    -- immune
    local immune = Effect.CreateEffect(c)
    immune:SetType(EFFECT_TYPE_SINGLE)
    immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    immune:SetRange(LOCATION_MZONE)
    immune:SetCode(EFFECT_IMMUNE_EFFECT)
    immune:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        return tc:IsControler(1 - e:GetHandlerPlayer()) and tc:IsMonster() and Divine.GetDivineHierarchy(tc) <
                   Divine.GetDivineHierarchy(c)
    end)
    c:RegisterEffect(immune)

    -- reset effect
    local reset = Effect.CreateEffect(c)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
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
    atklimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    atklimit:SetCode(EVENT_SPSUMMON_SUCCESS)
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
               (e:GetTarget() == aux.PersistentTargetFilter or not e:IsHasType(EFFECT_TYPE_GRANT + EFFECT_TYPE_FIELD))
end
