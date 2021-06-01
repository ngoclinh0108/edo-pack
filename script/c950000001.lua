-- Supreme King Z-ARC - Overlord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x20f8}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 4,
                      4, s.lnkcheck)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- overscale
    local pensp = Effect.CreateEffect(c)
    pensp:SetType(EFFECT_TYPE_SINGLE)
    pensp:SetCode(511004423)
    c:RegisterEffect(pensp)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.lnklimit)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local nospnegate = Effect.CreateEffect(c)
    nospnegate:SetType(EFFECT_TYPE_SINGLE)
    nospnegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nospnegate:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(nospnegate)

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
    nodis:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    nodis:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nodis)

    -- indestructable by card effect
    local indes = Effect.CreateEffect(c)
    indes:SetType(EFFECT_TYPE_SINGLE)
    indes:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    indes:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    indes:SetRange(LOCATION_MZONE)
    indes:SetValue(1)
    c:RegisterEffect(indes)

    -- cannot be targeted
    local untarget = Effect.CreateEffect(c)
    untarget:SetType(EFFECT_TYPE_SINGLE)
    untarget:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    untarget:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    untarget:SetRange(LOCATION_MZONE)
    untarget:SetValue(aux.tgoval)
    c:RegisterEffect(untarget)

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

    -- cannot be switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- immune
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    pe1:SetCode(EFFECT_IMMUNE_EFFECT)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetValue(function(e, te)
        return te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(pe1)

    -- scale
    local pe2 = Effect.CreateEffect(c)
    pe2:SetType(EFFECT_TYPE_FIELD)
    pe2:SetCode(EFFECT_CHANGE_LSCALE)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetTargetRange(LOCATION_PZONE, 0)
    pe2:SetTarget(function(e, c) return e:GetHandler() ~= c end)
    pe2:SetValue(0)
    c:RegisterEffect(pe2)
    local pe2b = pe2:Clone()
    pe2b:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(pe2b)

    -- act limit
    local pe3 = Effect.CreateEffect(c)
    pe3:SetType(EFFECT_TYPE_FIELD)
    pe3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    pe3:SetCode(EFFECT_CANNOT_ACTIVATE)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetTargetRange(0, 1)
    pe3:SetValue(function(e, re, rp)
        local rc = re:GetHandler()
        return rc:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ) and
                   rc:IsLocation(LOCATION_MZONE) and
                   re:IsActiveType(TYPE_MONSTER)
    end)
    c:RegisterEffect(pe3)

    -- place pendulum monster
    local pe4 = Effect.CreateEffect(c)
    pe4:SetDescription(aux.Stringid(id, 0))
    pe4:SetType(EFFECT_TYPE_IGNITION)
    pe4:SetRange(LOCATION_PZONE)
    pe4:SetCountLimit(1)
    pe4:SetTarget(s.pe4tg)
    pe4:SetOperation(s.pe4op)
    c:RegisterEffect(pe4)

    -- destroy all
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 1))
    me1:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- destroy drawn
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 2))
    me2:SetCategory(CATEGORY_DESTROY)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me2:SetCode(EVENT_TO_HAND)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1)
    me2:SetCondition(s.me2con)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- summon dragon
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(aux.Stringid(id, 3))
    me3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me3:SetType(EFFECT_TYPE_IGNITION)
    me3:SetCountLimit(1)
    me3:SetRange(LOCATION_MZONE)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)

    -- place pendulum
    local me4 = Effect.CreateEffect(c)
    me4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me4:SetProperty(EFFECT_FLAG_DELAY)
    me4:SetCode(EVENT_DESTROYED)
    me4:SetCondition(s.me4con)
    me4:SetTarget(s.me4tg)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4)
end

function s.lnkcheck(g, sc, sumtype, tp)
    local mg = g:Clone()
    if not g:IsExists(Card.IsType, 1, nil, TYPE_FUSION, sc, sumtype, tp) then
        return false
    end
    mg:Remove(Card.IsType, nil, TYPE_FUSION, sc, sumtype, tp)
    if not g:IsExists(Card.IsType, 1, nil, TYPE_SYNCHRO, sc, sumtype, tp) then
        return false
    end
    mg:Remove(Card.IsType, nil, TYPE_SYNCHRO, sc, sumtype, tp)
    if not g:IsExists(Card.IsType, 1, nil, TYPE_XYZ, sc, sumtype, tp) then
        return false
    end
    mg:Remove(Card.IsType, nil, TYPE_XYZ, sc, sumtype, tp)
    return mg:IsExists(Card.IsType, 1, nil, TYPE_PENDULUM, sc, sumtype, tp)
end

function s.pe4filter(c)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.pe4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_PZONE, 0,
                                           1, c) and
                   Duel.IsExistingMatchingCard(s.pe4filter, tp,
                                               LOCATION_HAND + LOCATION_DECK +
                                                   LOCATION_GRAVE +
                                                   LOCATION_EXTRA, 0, 1, nil)
    end
end

function s.pe4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local dc =
        Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0, c):GetFirst()
    if not dc or Duel.Destroy(dc, REASON_EFFECT) == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local tc = Duel.SelectMatchingCard(tp, s.pe4filter, tp, LOCATION_HAND +
                                           LOCATION_DECK + LOCATION_GRAVE +
                                           LOCATION_EXTRA, 0, 1, 1, dc):GetFirst()
    if not tc then return end

    Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    if #g == 0 then return end
    Duel.Destroy(g, REASON_EFFECT)
end

function s.me2filter(c, tp) return c:IsControler(1 - tp) end

function s.me2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DRAW
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = eg:Filter(s.me2filter, nil, tp)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.me2filter, nil, tp)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.me3filter(c, e, tp, rp)
    if not c:IsLocation(LOCATION_EXTRA) and
        Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    if c:IsLocation(LOCATION_EXTRA) and
        Duel.GetLocationCountFromEx(tp, rp, nil, c) <= 0 then return false end

    return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
               c:IsSetCard(0x20f8)
end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.me3filter, tp, loc, 0, 1, nil, e,
                                           tp, rp)
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_OATH +
                        EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.me3filter),
                                       tp, loc, 0, 1, 1, nil, e, tp, rp):GetFirst()
    if not tc then return end

    if Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP) > 0 then
        tc:CompleteProcedure()
    end
end

function s.me4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.me4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckLocation(tp, LOCATION_PZONE, 0) or
                   Duel.CheckLocation(tp, LOCATION_PZONE, 1)
    end
end

function s.me4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.CheckLocation(tp, LOCATION_PZONE, 0) and
        not Duel.CheckLocation(tp, LOCATION_PZONE, 1) then return false end
    if not c:IsRelateToEffect(e) then return end

    Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end
