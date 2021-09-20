-- init
if not aux.DimensionProcedure then
    aux.DimensionProcedure = {}
    aux.DimensionProcedure._zones = {}
end
if not Dimension then Dimension = aux.DimensionProcedure end

-- constant
Dimension.TYPE = 0x20000000

-- function
function Dimension.Zones(tp)
    local g = Dimension._zones[tp]
    if not g then
        g = Group.CreateGroup()
        g:KeepAlive()
        Dimension._zones[tp] = g
    end

    return g
end

function Dimension.ZonesAddCard(c)
    return Dimension.Zones(c:GetOwner()):AddCard(c)
end

function Dimension.ZonesRemoveCard(c)
    return Dimension.Zones(c:GetOwner()):RemoveCard(c)
end

function Dimension.AddProcedure(c)
    -- startup
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    startup:SetCode(EVENT_STARTUP)
    startup:SetRange(LOCATION_ALL - LOCATION_ONFIELD)
    startup:SetOperation(function(e)
        local c = e:GetHandler()
        Duel.DisableShuffleCheck()
        Duel.SendtoDeck(c, nil, -2, REASON_RULE)
        Dimension.ZonesAddCard(c)
    end)
    c:RegisterEffect(startup)

    -- turn back when leave field
    local turnback = Effect.CreateEffect(c)
    turnback:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    turnback:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    turnback:SetCode(EVENT_ADJUST)
    turnback:SetRange(LOCATION_ALL - LOCATION_ONFIELD)
    turnback:SetCondition(function(e)
        return e:GetHandler():GetLocation() ~= 0
    end)
    turnback:SetOperation(function(e)
        local c = e:GetHandler()
        local tp = c:GetControler()
        local mc = c:GetMaterial():GetFirst()
        local loc = c:GetLocation()
        local r = c:GetReason()
        local rp = c:GetReasonPlayer()
        local re = c:GetReasonEffect()
        local rc = c:GetReasonCard()

        if loc == LOCATION_EXTRA and c:IsFaceup() then
            Duel.SendtoExtraP(mc, tp, r)
        elseif loc == LOCATION_DECK or loc == LOCATION_EXTRA then
            Duel.SendtoDeck(mc, tp, SEQ_DECKSHUFFLE, r)
        elseif loc == LOCATION_HAND then
            Duel.SendtoHand(mc, tp, r)
        elseif loc == LOCATION_GRAVE then
            Duel.SendtoGrave(mc, r)
        elseif loc == LOCATION_REMOVED then
            Duel.Remove(mc, c:GetPosition(), r, rp)
        end
        if re then mc:SetReasonEffect(re) end
        if rc then mc:SetReasonCard(rc) end
        if rp then mc:SetReasonPlayer(rp) end

        Dimension.ZonesRemoveCard(mc)
        Dimension.SendToDimension(c, c:GetReason())
    end)
    c:RegisterEffect(turnback)
end

function Dimension.SendToDimension(tc, reason)
    Duel.SendtoDeck(tc, nil, -2, reason)
    return Dimension.ZonesAddCard(tc)
end

function Dimension.IsInDimensionZone(c) return c:GetLocation() == 0 end

function Dimension.IsAbleToDimension(c)
    return c:GetLocation() ~= 0 and c:IsFaceup()
end

function Dimension.CanBeDimensionMaterial(c)
    return c:GetLocation() ~= 0 and c:IsFaceup()
end

function Dimension.CanBeDimensionChanged(c) return c:GetLocation() == 0 end

function Dimension.CanBeDimensionSummoned(c, e, sumplayer)
    if c:GetLocation() ~= 0 then return false end
    if c:IsSummonType(SUMMON_TYPE_NORMAL) then return c:IsSummonable(true, e) end
    return
        c:IsCanBeSpecialSummoned(e, c:GetSummonType(), sumplayer, true, false)
end

function Dimension.Change(mc, sc, mg)
    local tp = mc:GetControler()
    local sumtype = mc:GetSummonType()
    local sumloc = mc:GetSummonLocation()
    local seq = mc:GetSequence()
    local pos = mc:IsAttackPos() and POS_FACEUP_ATTACK or POS_FACEUP_DEFENSE

    if mg then
        sc:SetMaterial(mg)
    else
        sc:SetMaterial(Group.FromCards(mc))
    end

    Dimension.SendToDimension(mc, REASON_RULE)
    Duel.MoveToField(sc, tp, tp, LOCATION_MZONE, pos, true, 1 << seq)
    sc:SetStatus(STATUS_FORM_CHANGED, true)
    Debug.PreSummon(sc, sumtype, sumloc)
    Dimension.ZonesRemoveCard(sc)

    local ec1 = Effect.CreateEffect(sc)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_CONTROL)
    ec1:SetValue(tp)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD -
                     (RESET_TOFIELD + RESET_TEMP_REMOVE + RESET_TURN_SET))
    sc:RegisterEffect(ec1)

    return true
end

function Dimension.Summon(c, sumplayer, target_player, pos, seq)
    if not pos then pos = POS_FACEUP end

    if not Duel.MoveToField(c, sumplayer, target_player, LOCATION_MZONE, pos,
                            true, seq and 1 << seq or nil) then
        if not c:IsType(Dimension.TYPE) then
            Duel.SendtoGrave(c, REASON_RULE)
        end
        return false
    end

    c:SetStatus(STATUS_FORM_CHANGED, true)
    Dimension.ZonesRemoveCard(c)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_CONTROL)
    ec1:SetValue(target_player)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD -
                     (RESET_TOFIELD + RESET_TEMP_REMOVE + RESET_TURN_SET))
    c:RegisterEffect(ec1)

    Duel.BreakEffect()
    return true
end

Dimension.RegisterChange = aux.FunctionWithNamedArgs(
                               function(c, event_code, filter, custom_reg,
                                        custom_op, flag_id)
        if flag_id == nil then flag_id = c:GetOriginalCode() end

        -- register
        if custom_reg then
            custom_reg(c, flag_id)
        else
            local reg = Effect.CreateEffect(c)
            reg:SetType(EFFECT_TYPE_CONTINUOUS)
            reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
            reg:SetCode(event_code)
            reg:SetCondition(function(e)
                return Dimension.CanBeDimensionChanged(e:GetHandler())
            end)
            reg:SetOperation(function(e, _, eg)
                local g = eg:Filter(aux.FilterFaceupFunction(filter, e), nil)
                for tc in aux.Next(g) do
                    tc:RegisterFlagEffect(flag_id, 0, 0, 1)
                end
            end)
            Duel.RegisterEffect(reg, 0)
        end

        -- change
        local change = Effect.CreateEffect(c)
        change:SetType(EFFECT_TYPE_CONTINUOUS)
        change:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
        change:SetCode(EVENT_ADJUST)
        change:SetCondition(function(e)
            return Dimension.CanBeDimensionChanged(e:GetHandler()) and
                       Duel.IsExistingMatchingCard(function(c)
                    return c:GetFlagEffect(flag_id) > 0
                end, 0, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
        end)
        change:SetOperation(function(e)
            local mc = Duel.GetFirstMatchingCard(function(c)
                return c:GetFlagEffect(flag_id) > 0
            end, 0, LOCATION_MZONE, LOCATION_MZONE, nil)
            if not mc then return end
            mc:ResetFlagEffect(flag_id)
            if custom_op then
                custom_op(e, c, mc)
            else
                Dimension.Change(mc, c)
            end
        end)
        Duel.RegisterEffect(change, 0)
    end, "handler", "event_code", "filter", "custom_reg", "custom_op", "flag_id")
