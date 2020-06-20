-- DIVINE ------------------------------------------------------------------------------------------
if not aux.DivineProcedure then
    aux.DivineProcedure = {}
    Divine = aux.DivineProcedure
end
if not Divine then Divine = aux.DivineProcedure end

-- function
function Divine.AddProcedure(c, race, summon_mode, to_grave_end_phase)
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
        return c ~= tc and
                   te:IsHasCategory(CATEGORY_TOHAND + CATEGORY_DESTROY +
                                        CATEGORY_REMOVE + CATEGORY_TODECK +
                                        CATEGORY_RELEASE + CATEGORY_TOGRAVE +
                                        CATEGORY_FUSION_SUMMON) and
                   (not tc.divine_hierarchy or tc.divine_hierarchy <
                       c.divine_hierarchy)
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

    -- send to grave
    if to_grave_end_phase then
        local togy = Effect.CreateEffect(c)
        togy:SetDescription(Transform.TEXT_SELF_TO_GRAVE)
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
end

-- TRANSFORM ------------------------------------------------------------------------------------------
if not aux.TransformProcedure then
    aux.TransformProcedure = {}
    Transform = aux.TransformProcedure
end
if not Transform then Transform = aux.TransformProcedure end

-- constant
Transform.TYPE = 0x20000000
Transform.TEXT_TRANSFORM_MATERIAL = aux.Stringid(400000000, 0)
Transform.TEXT_SELF_TO_GRAVE = aux.Stringid(400000000, 1)

-- function
function Transform.AddProcedure(c, matfilter)
    -- outside 
    local outside = Effect.CreateEffect(c)
    outside:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    outside:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    outside:SetCode(EVENT_STARTUP)
    outside:SetRange(0x5f)
    outside:SetOperation(function(e)
        Duel.DisableShuffleCheck()
        Duel.SendtoDeck(e:GetOwner(), nil, -2, REASON_RULE)
    end)
    c:RegisterEffect(outside)

    -- turn back when leave field
    local turnback = Effect.CreateEffect(c)
    turnback:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    turnback:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    turnback:SetCode(EVENT_LEAVE_FIELD)
    turnback:SetRange(LOCATION_MZONE)
    turnback:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return e:GetHandler():GetLocation() ~= 0
    end)
    turnback:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local mc = c:GetMaterial():GetFirst()
        local mtp = mc:GetOwner()
        local pos = c:GetPosition()
        local loc = c:GetLocation()
        local reason = c:GetReason()
        local sequence = c:GetSequence()

        if c:GetReasonEffect() then
            mc:SetReasonEffect(c:GetReasonEffect())
        end
        if c:GetReasonPlayer() then
            mc:SetReasonPlayer(c:GetReasonPlayer())
        end
        if c:GetReasonCard() then mc:SetReasonCard(c:GetReasonCard()) end

        Duel.SendtoDeck(c, tp, -2, REASON_RULE)
        if loc == LOCATION_DECK then
            Duel.SendtoDeck(mc, mtp, sequence, reason)
        elseif loc == LOCATION_HAND then
            Duel.SendtoHand(mc, mtp, reason)
        elseif loc == LOCATION_GRAVE then
            Duel.SendtoGrave(mc, reason)
        elseif loc == LOCATION_REMOVED then
            Duel.Remove(mc, pos, reason)
        end
    end)
    c:RegisterEffect(turnback)

    -- transform summon
    if matfilter then
        local trans = Effect.CreateEffect(c)
        trans:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        trans:SetCode(EVENT_FREE_CHAIN)
        trans:SetCondition(Transform.Condition(matfilter))
        trans:SetOperation(Transform.Operation(matfilter))
        Duel.RegisterEffect(trans, nil)
    end
end

function Transform.Summon(c, trans_player, target_player, mc, pos)
    if not pos then pos = POS_FACEUP end

    local zone = 0xff
    if trans_player == target_player then
        zone = mc:GetSequence()
        zone = 2 ^ zone
    end

    c:SetMaterial(Group.FromCards(mc))
    Duel.SendtoDeck(mc, nil, -2, REASON_MATERIAL)
    Duel.MoveToField(c, trans_player, target_player, LOCATION_MZONE, pos, true,
                     zone)
    Debug.PreSummon(c, mc:GetSummonType(), mc:GetSummonLocation())

    -- not allow change posiiton
    local nochangepos = Effect.CreateEffect(c)
    nochangepos:SetType(EFFECT_TYPE_SINGLE)
    nochangepos:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    nochangepos:SetReset(RESET_PHASE + PHASE_END)
    c:RegisterEffect(nochangepos)
end

function Transform.Detransform(c, trans_player, target_player, pos)
    local mc = c:GetMaterial():GetFirst()
    if not pos then pos = POS_FACEUP end

    local zone = 0xff
    if trans_player == target_player then
        zone = c:GetSequence()
        zone = 2 ^ zone
    end

    Duel.SendtoDeck(c, target_player, -2, REASON_RULE)
    Duel.MoveToField(mc, trans_player, target_player, LOCATION_MZONE, pos, true,
                     zone)

    -- not allow change posiiton
    local nochangepos = Effect.CreateEffect(mc)
    nochangepos:SetType(EFFECT_TYPE_SINGLE)
    nochangepos:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    nochangepos:SetReset(RESET_PHASE + PHASE_END)
    mc:RegisterEffect(nochangepos)

    return mc
end

function Transform.Condition(matfilter)
    return function(e, tp, eg, ep, ev, re, r, rp)
        tp = e:GetOwner():GetOwner()
        local c = e:GetHandler()
        return e:GetHandler():GetLocation() == 0 and
                   Duel.IsExistingMatchingCard(matfilter, tp, LOCATION_MZONE, 0,
                                               1, nil, tp, c)

    end
end

function Transform.Operation(matfilter)
    return function(e, tp, eg, ep, ev, re, r, rp)
        tp = e:GetOwner():GetOwner()
        local c = e:GetHandler()

        Duel.Hint(HINT_SELECTMSG, tp, Transform.TEXT_TRANSFORM_MATERIAL)
        local tc = Duel.SelectMatchingCard(tp, matfilter, tp, LOCATION_MZONE, 0,
                                           1, 1, nil, tp, c):GetFirst()
        if not tc then return end
        Duel.BreakEffect()

        Transform.Summon(c, tp, tp, tc, POS_FACEUP)
    end
end
