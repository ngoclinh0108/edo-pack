-- init
if not aux.DivineProcedure then
    aux.DivineProcedure = {}
    Divine = aux.DivineProcedure
end
if not Divine then Divine = aux.DivineProcedure end

-- function
function Divine.AddProcedure(c, summon_mode, limit, race)
    if summon_mode == '3_tribute' then
        -- summon with 3 tributes
        aux.AddNormalSummonProcedure(c, true, false, 3, 3)
        aux.AddNormalSetProcedure(c)

        -- summon cannot be negated
        local sumsafe = Effect.CreateEffect(c)
        sumsafe:SetType(EFFECT_TYPE_SINGLE)
        sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
        sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
        c:RegisterEffect(sumsafe)
    elseif summon_mode == 'self' then
        -- cannot normal summon / set
        c:EnableReviveLimit()

        -- must special summon by own effect
        local splimit = Effect.CreateEffect(c)
        splimit:SetType(EFFECT_TYPE_SINGLE)
        splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
        splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
        c:RegisterEffect(splimit)
    end

    -- activation and effects cannot be negated
    local inact = Effect.CreateEffect(c)
    inact:SetType(EFFECT_TYPE_FIELD)
    inact:SetCode(EFFECT_CANNOT_INACTIVATE)
    inact:SetRange(0x5f)
    inact:SetLabelObject(c)
    inact:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetLabelObject()
    end)
    c:RegisterEffect(inact)
    local inactb = inact:Clone()
    inactb:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(inactb)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(nodis)

    -- cannot be tributed or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc, tp, sumtp)
        return tc == e:GetHandler()
    end)
    c:RegisterEffect(norelease)
    local nofus = Effect.CreateEffect(c)
    nofus:SetType(EFFECT_TYPE_SINGLE)
    nofus:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
    nofus:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
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

        if tc == c then return false end

        if (tc.divine_hierarchy and tc.divine_hierarchy >= c.divine_hierarchy) then
            return false
        end

        if (te:GetOwnerPlayer() ~= e:GetHandlerPlayer() and
            te:IsActiveType(TYPE_MONSTER)) then return true end

        return te:IsHasCategory(CATEGORY_TOHAND + CATEGORY_DESTROY +
                                    CATEGORY_REMOVE + CATEGORY_TODECK +
                                    CATEGORY_RELEASE + CATEGORY_TOGRAVE +
                                    CATEGORY_FUSION_SUMMON)
    end)
    c:RegisterEffect(immunity)

    -- reset effect
    local reset = Effect.CreateEffect(c)
    reset:SetDescription(1162)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    reset:SetCode(EVENT_PHASE + PHASE_END)
    reset:SetRange(LOCATION_MZONE)
    reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
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

                if (not ec.divine_hierarchy or ec.divine_hierarchy <
                    c.divine_hierarchy) then
                    local imm = Effect.CreateEffect(c)
                    imm:SetType(EFFECT_TYPE_SINGLE)
                    imm:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
                    imm:SetCode(EFFECT_IMMUNE_EFFECT)
                    imm:SetRange(LOCATION_MZONE)
                    imm:SetLabelObject(ec)
                    imm:SetValue(function(e, te)
                        return te:GetOwner() == e:GetLabelObject()
                    end)
                    imm:SetReset(RESET_EVENT + RESETS_STANDARD)
                    c:RegisterEffect(imm)
                end
            end
        end
    end)
    c:RegisterEffect(reset)

    -- send to grave
    if limit then
        -- cannot activate effect or attack
        local atklimit = Effect.CreateEffect(c)
        atklimit:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        atklimit:SetCode(EVENT_SPSUMMON_SUCCESS)
        atklimit:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()

            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_CANNOT_TRIGGER)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            c:RegisterEffect(ec1)

            local ec2 = ec1:Clone()
            ec2:SetCode(EFFECT_CANNOT_ATTACK)
            c:RegisterEffect(ec2)
        end)
        c:RegisterEffect(atklimit)

        local togy = Effect.CreateEffect(c)
        togy:SetDescription(666000)
        togy:SetCategory(CATEGORY_TOGRAVE)
        togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        togy:SetCode(EVENT_PHASE + PHASE_END)
        togy:SetRange(LOCATION_MZONE)
        togy:SetCountLimit(1)
        togy:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            return c:IsSummonType(SUMMON_TYPE_SPECIAL) and
                       c:IsPreviousLocation(LOCATION_GRAVE)
        end)
        togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            if c:IsSummonType(SUMMON_TYPE_SPECIAL) and
                c:IsPreviousLocation(LOCATION_GRAVE) then
                Duel.SendtoGrave(c, REASON_EFFECT)
            end
        end)
        c:RegisterEffect(togy)
    end

    -- multi-race
    if race then
        local multirace = Effect.CreateEffect(c)
        multirace:SetType(EFFECT_TYPE_SINGLE)
        multirace:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        multirace:SetCode(EFFECT_ADD_RACE)
        multirace:SetRange(LOCATION_MZONE)
        multirace:SetValue(race)
        c:RegisterEffect(multirace)
    end
end
