-- init
if not aux.DivineProcedure then aux.DivineProcedure = {} end
if not Divine then Divine = aux.DivineProcedure end

-- constant
Divine.DIVINE_EVOLUTION = 513000065

-- function
function Divine.DivineHierarchy(s, c, divine_hierarchy,
                                summon_by_three_tributes, limit)
    if divine_hierarchy then s.divine_hierarchy = divine_hierarchy end

    if summon_by_three_tributes then
        aux.AddNormalSummonProcedure(c, true, false, 3, 3)
        aux.AddNormalSetProcedure(c)

        -- summon cannot be negate
        local sumsafe = Effect.CreateEffect(c)
        sumsafe:SetType(EFFECT_TYPE_SINGLE)
        sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
        Divine.RegisterEffect(c, sumsafe)
    end

    -- activation and effects cannot be negated
    local inact = Effect.CreateEffect(c)
    inact:SetType(EFFECT_TYPE_FIELD)
    inact:SetCode(EFFECT_CANNOT_INACTIVATE)
    inact:SetRange(LOCATION_MZONE)
    inact:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    Divine.RegisterEffect(c, inact)
    local inact2 = inact:Clone()
    inact2:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(inact2)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    nodis:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(c, nodis)

    -- cannot switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(c, noswitch)

    -- cannot be tributed by your opponent
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    Divine.RegisterEffect(c, norelease)

    -- cannot be used as a material by your opponent
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    Divine.RegisterEffect(c, nomaterial)

    -- cannot change position with effect
    local posunchange = Effect.CreateEffect(c)
    posunchange:SetType(EFFECT_TYPE_SINGLE)
    posunchange:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    posunchange:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    Divine.RegisterEffect(c, posunchange)

    -- immune
    local immunity = Effect.CreateEffect(c)
    immunity:SetType(EFFECT_TYPE_SINGLE)
    immunity:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    immunity:SetCode(EFFECT_IMMUNE_EFFECT)
    immunity:SetRange(LOCATION_MZONE)
    immunity:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        if tc == c or Divine.GetDivineHierarchy(tc) >=
            Divine.GetDivineHierarchy(c) then return false end

        return te:IsActiveType(TYPE_MONSTER) or
                   te:IsHasCategory(
                       CATEGORY_TOHAND + CATEGORY_DESTROY + CATEGORY_REMOVE +
                           CATEGORY_TODECK + CATEGORY_RELEASE + CATEGORY_TOGRAVE +
                           CATEGORY_FUSION_SUMMON)
    end)
    Divine.RegisterEffect(c, immunity)
    local noleave = Effect.CreateEffect(c)
    noleave:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    noleave:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noleave:SetCode(EFFECT_SEND_REPLACE)
    noleave:SetRange(LOCATION_MZONE)
    noleave:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then
            return
                c:IsReason(REASON_EFFECT) and r & REASON_EFFECT ~= 0 and re and
                    re:IsActiveType(TYPE_SPELL + TYPE_TRAP) and
                    Divine.GetDivineHierarchy(re:GetHandler()) <
                    Divine.GetDivineHierarchy(c)
        end
        return true
    end)
    noleave:SetValue(function() return false end)
    Divine.RegisterEffect(c, noleave)

    -- reset effect
    local reset = Effect.CreateEffect(c)
    reset:SetDescription(666000)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    reset:SetCode(EVENT_ADJUST)
    reset:SetRange(LOCATION_MZONE)
    reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        if Duel.GetCurrentPhase() ~= PHASE_END then return false end
        local check = false
        local c = e:GetHandler()

        local effs = {c:GetCardEffect()}
        for _, eff in ipairs(effs) do
            if eff:GetOwner() ~= c and
                not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and
                eff:GetCode() ~= EFFECT_SPSUMMON_PROC and
                (eff:GetTarget() == aux.PersistentTargetFilter or
                    not eff:IsHasType(EFFECT_TYPE_GRANT + EFFECT_TYPE_FIELD)) then
                check = true
                break
            end
        end
        return check
    end)
    reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local effs = {c:GetCardEffect()}
        for _, eff in ipairs(effs) do
            if eff:GetOwner() ~= c and
                not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and
                eff:GetCode() ~= EFFECT_SPSUMMON_PROC and
                (eff:GetTarget() == aux.PersistentTargetFilter or
                    not eff:IsHasType(EFFECT_TYPE_GRANT + EFFECT_TYPE_FIELD)) then
                eff:Reset()
            end
        end
    end)
    Divine.RegisterEffect(c, reset)

    if limit then
        -- cannot attack when special summoned
        local spnoattack = Effect.CreateEffect(c)
        spnoattack:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        spnoattack:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        spnoattack:SetCode(EVENT_SPSUMMON_SUCCESS)
        spnoattack:SetOperation(function(e)
            local c = e:GetHandler()
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3206)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_CANNOT_ATTACK)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            c:RegisterEffect(ec1)
        end)
        Divine.RegisterEffect(c, spnoattack)

        -- return
        local returnend = Effect.CreateEffect(c)
        returnend:SetDescription(666001)
        returnend:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        returnend:SetCode(EVENT_PHASE + PHASE_END)
        returnend:SetRange(LOCATION_MZONE)
        returnend:SetCountLimit(1)
        returnend:SetCode(EVENT_PHASE + PHASE_END)
        returnend:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            return c:IsSummonType(SUMMON_TYPE_SPECIAL) and
                       c:IsPreviousLocation(LOCATION_GRAVE) and
                       c:IsAbleToGrave()
        end)
        returnend:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
        end)
        Divine.RegisterEffect(c, returnend)
    end
end

function Divine.GetDivineHierarchy(c, get_base)
    local divine_hierarchy = c.divine_hierarchy
    if not divine_hierarchy then divine_hierarchy = 0 end
    if get_base then return divine_hierarchy end

    if c:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0 then
        divine_hierarchy = divine_hierarchy + 1
    end

    return divine_hierarchy
end

function Divine.RegisterEffect(c, eff)
    local e = eff:Clone()
    e:SetProperty(e:GetProperty() + EFFECT_FLAG_UNCOPYABLE)
    c:RegisterEffect(e)
end
