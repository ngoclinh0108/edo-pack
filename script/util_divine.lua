-- init
if not aux.DivineProcedure then aux.DivineProcedure = {} end
if not Divine then Divine = aux.DivineProcedure end

-- function
function Divine.DivineHierarchy(s, c, divine_hierarchy, summon_by_three_tributes)
    s.divine_hierarchy = divine_hierarchy

    if summon_by_three_tributes then
        aux.AddNormalSummonProcedure(c, true, false, 3, 3)
        aux.AddNormalSetProcedure(c)

        -- summon cannot be negate
        local sumsafe = Effect.CreateEffect(c)
        sumsafe:SetType(EFFECT_TYPE_SINGLE)
        sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
        sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
        c:RegisterEffect(sumsafe)

        -- act limit when summoning
        local sumactlimit = Effect.CreateEffect(c)
        sumactlimit:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        sumactlimit:SetCode(EVENT_SUMMON_SUCCESS)
        sumactlimit:SetOperation(function(e)
            local c = e:GetHandler()
            Duel.SetChainLimitTillChainEnd(function(e)
                return e:GetHandler() == c
            end)
        end)
        c:RegisterEffect(sumactlimit)
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
    c:RegisterEffect(inact)
    local inact2 = inact:Clone()
    inact2:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(inact2)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE +
                          EFFECT_FLAG_CANNOT_NEGATE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    nodis:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nodis)

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- cannot be face-down
    local noset = Effect.CreateEffect(c)
    noset:SetType(EFFECT_TYPE_SINGLE)
    noset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noset:SetCode(EFFECT_CANNOT_TURN_SET)
    noset:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noset)

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

    -- immunity
    local immunity = Effect.CreateEffect(c)
    immunity:SetType(EFFECT_TYPE_SINGLE)
    immunity:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    immunity:SetCode(EFFECT_IMMUNE_EFFECT)
    immunity:SetRange(LOCATION_MZONE)
    immunity:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()

        if (tc == c) or
            (tc.divine_hierarchy and tc.divine_hierarchy >= c.divine_hierarchy) then
            return false
        end

        return te:IsHasCategory(CATEGORY_TOHAND + CATEGORY_DESTROY +
                                    CATEGORY_REMOVE + CATEGORY_TODECK +
                                    CATEGORY_RELEASE + CATEGORY_TOGRAVE +
                                    CATEGORY_FUSION_SUMMON)
    end)
    c:RegisterEffect(immunity)
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
                    re:GetHandler() ~= c and
                    (not re:GetHandler().divine_hierarchy or
                        re:GetHandler().divine_hierarchy < c.divine_hierarchy)
        end
        return true
    end)
    noleave:SetValue(function() return false end)
    c:RegisterEffect(noleave)

    -- reset effect
    local reset = Effect.CreateEffect(c)
    reset:SetDescription(666000)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    reset:SetCode(EVENT_ADJUST)
    reset:SetRange(LOCATION_MZONE)
    reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        if Duel.GetCurrentPhase() ~= PHASE_END then return false end

        local c = e:GetHandler()
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
        local c = e:GetHandler()
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
                        return te:GetHandler() == e:GetLabelObject()
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
    togy:SetDescription(666001)
    togy:SetCategory(CATEGORY_TOGRAVE)
    togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    togy:SetCode(EVENT_PHASE + PHASE_END)
    togy:SetRange(LOCATION_MZONE)
    togy:SetCountLimit(1)
    togy:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:IsSummonType(SUMMON_TYPE_SPECIAL) and
                   c:IsPreviousLocation(LOCATION_GRAVE) and c:IsAbleToGrave()
    end)
    togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
    end)
    c:RegisterEffect(togy)
end
