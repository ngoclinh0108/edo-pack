-- init
if not aux.DimensionProcedure then
    aux.DimensionProcedure = {}
    aux.DimensionProcedure._zones = {}
end
if not Dimension then Dimension = aux.DimensionProcedure end

-- constant
Dimension.TYPE = 0x20000000

-- function
function Dimension.AddProcedure(c, matfilter)
    -- startup 
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    startup:SetCode(EVENT_STARTUP)
    startup:SetRange(LOCATION_ALL)
    startup:SetOperation(function(e)
        local c = e:GetHandler()
        local tp = c:GetOwner()

        Duel.DisableShuffleCheck()
        Duel.SendtoDeck(c, nil, -2, REASON_RULE)
        Dimension.Zones(tp):AddCard(c)

        if matfilter then
            local change = Effect.CreateEffect(c)
            change:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            change:SetCode(EVENT_FREE_CHAIN)
            change:SetCountLimit(1)
            change:SetCondition(Dimension.Condition(matfilter))
            change:SetOperation(Dimension.Operation(matfilter))
            Duel.RegisterEffect(change, tp)
        end
    end)
    c:RegisterEffect(startup)

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
        Dimension.Zones(c:GetOwner()):AddCard(c)

        if loc == LOCATION_DECK then
            Duel.SendtoDeck(mc, mtp, sequence, reason)
        elseif loc == LOCATION_HAND then
            Duel.SendtoHand(mc, mtp, reason)
        elseif loc == LOCATION_GRAVE then
            Duel.SendtoGrave(mc, reason)
        elseif loc == LOCATION_REMOVED then
            Duel.Remove(mc, pos, reason)
        end
        Dimension.Zones(mc:GetOwner()):RemoveCard(mc)
    end)
    c:RegisterEffect(turnback)
end

function Dimension.Zones(tp)
    local g = Dimension._zones[tp]
    if not g then
        g = Group.CreateGroup()
        g:KeepAlive()
        Dimension._zones[tp] = g
    end

    return g
end

function Dimension.RegisterEffect(c, op)
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    startup:SetCode(EVENT_STARTUP)
    startup:SetRange(LOCATION_ALL)
    startup:SetOperation(op)
    c:RegisterEffect(startup)
end

function Dimension.Change(c, mc, change_player, target_player, pos, mg)
    if not pos then pos = POS_FACEUP end

    local zone = 0xff
    if change_player == target_player then
        zone = mc:GetSequence()
        zone = 2 ^ zone
    end

    Duel.SendtoDeck(mc, nil, -2, REASON_MATERIAL + REASON_RULE)
    Dimension.Zones(mc:GetOwner()):AddCard(mc)

    Duel.MoveToField(c, change_player, target_player, LOCATION_MZONE, pos, true,
                     zone)
    Dimension.Zones(c:GetOwner()):RemoveCard(c)

    if mg then
        c:SetMaterial(mg)
    else
        c:SetMaterial(Group.FromCards(mc))
    end
    Debug.PreSummon(c, mc:GetSummonType(), mc:GetSummonLocation())

    -- not allow change posiiton
    local nochangepos = Effect.CreateEffect(c)
    nochangepos:SetType(EFFECT_TYPE_SINGLE)
    nochangepos:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    nochangepos:SetReset(RESET_PHASE + PHASE_END)
    c:RegisterEffect(nochangepos)
end

function Dimension.Dechange(c, change_player, target_player, pos)
    if not c:IsType(Dimension.TYPE) then return end

    local mc = c:GetMaterial():GetFirst()
    if not pos then pos = POS_FACEUP end

    local zone = 0xff
    if change_player == target_player then
        zone = c:GetSequence()
        zone = 2 ^ zone
    end

    Duel.SendtoDeck(c, target_player, -2, REASON_RULE)
    Dimension.Zones(c:GetOwner()):AddCard(c)

    Duel.MoveToField(mc, change_player, target_player, LOCATION_MZONE, pos,
                     true, zone)
    Dimension.Zones(mc:GetOwner()):RemoveCard(mc)
    Debug.PreSummon(mc, c:GetSummonType(), c:GetSummonLocation())
    
    -- not allow change posiiton
    local nochangepos = Effect.CreateEffect(mc)
    nochangepos:SetType(EFFECT_TYPE_SINGLE)
    nochangepos:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    nochangepos:SetReset(RESET_PHASE + PHASE_END)
    mc:RegisterEffect(nochangepos)

    return mc
end

function Dimension.Condition(matfilter)
    return function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()

        return c:GetLocation() == 0 and Duel.GetCurrentChain() == 0 and
                   Duel.GetTurnPlayer() == tp and
                   (Duel.GetCurrentPhase() == PHASE_MAIN1 or
                       Duel.GetCurrentPhase() == PHASE_MAIN2) and
                   Duel.IsExistingMatchingCard(matfilter, tp, LOCATION_MZONE, 0,
                                               1, nil, tp, c)
    end
end

function Dimension.Operation(matfilter)
    return function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()

        Duel.Hint(HINT_SELECTMSG, tp, 666100)
        local mc = Duel.SelectMatchingCard(tp, matfilter, tp, LOCATION_MZONE, 0,
                                           1, 1, nil, tp, c):GetFirst()
        if not mc then return end
        Duel.BreakEffect()

        Dimension.Change(c, mc, tp, tp, POS_FACEUP)
    end
end
