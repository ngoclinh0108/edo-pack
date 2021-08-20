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

function Dimension.ZonesAddCard(c) Dimension.Zones(c:GetOwner()):AddCard(c) end

function Dimension.ZonesRemoveCard(c) Dimension.Zones(c:GetOwner()):RemoveCard(c) end

function Dimension.AddProcedure(c)
    -- startup
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    startup:SetCode(EVENT_STARTUP)
    startup:SetRange(LOCATION_ALL)
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
    turnback:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
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

function Dimension.RegisterChange(c, op)
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    startup:SetCode(EVENT_STARTUP)
    startup:SetRange(LOCATION_ALL)
    startup:SetOperation(op)
    c:RegisterEffect(startup)
end

function Dimension.SendToDimension(tc, reason)
    Duel.SendtoDeck(tc, nil, -2, reason)
    Dimension.ZonesAddCard(tc)
end

function Dimension.IsAbleToDimension(c) return c:GetLocation() ~= 0 end

function Dimension.CanBeDimensionMaterial(c) return c:GetLocation() ~= 0 end

function Dimension.CanBeDimensionChanged(c) return c:GetLocation() == 0 end

function Dimension.CanBeDimensionSummoned(c, e, sumplayer, nocheck, nolimit,
                                          sumpos)
    return c:GetLocation() == 0 and
               c:IsCanBeSpecialSummoned(e, 0, sumplayer, nocheck, nolimit,
                                        sumpos)
end

function Dimension.Change(c, mc, sumplayer, target_player, pos, mg)
    if not pos then pos = POS_FACEUP end
    local sumtype = mc:GetSummonType()
    local sumloc = mc:GetSummonLocation()

    local zone = 0xff
    if sumplayer == target_player then
        zone = mc:GetSequence()
        zone = 2 ^ zone
    end

    if mg then
        c:SetMaterial(mg)
    else
        c:SetMaterial(Group.FromCards(mc))
    end

    Dimension.SendToDimension(mc, REASON_RULE)
    Duel.MoveToField(c, sumplayer, target_player, LOCATION_MZONE, pos, true,
                     zone)
    Dimension.ZonesRemoveCard(c)
    Debug.PreSummon(c, sumtype, sumloc)
    Duel.BreakEffect()

    -- not allow change posiiton
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    nopos:SetReset(RESET_PHASE + PHASE_END)
    c:RegisterEffect(nopos)
end

function Dimension.Condition(condition)
    return function(e, tp, eg, ep, ev, re, r, rp)
        return Dimension.CanBeDimensionChanged(e:GetHandler()) and
                   condition(e, tp, eg, ep, ev, re, r, rp)
    end
end
