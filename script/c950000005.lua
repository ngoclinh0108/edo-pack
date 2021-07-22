-- Supreme King Z-ARC - Overlord
Duel.LoadScript("util.lua")
Duel.LoadScript("util_pendulum.lua")
local s, id = GetID()

s.listed_series = {0x20f8}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 4,
                      4, s.lnkcheck)

    -- pendulum
    Pendulum.AddProcedure(c, false)
    Utility.PlaceToPZoneWhenDestroyed(c,
                                      function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end
        local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0,
                                        nil)
        if #g > 0 then
            Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
        end
    end, function(e, tp, eg, ep, ev, re, r, rp)
        local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0,
                                        nil)
        if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
    end)

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
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_LINK) == SUMMON_TYPE_LINK or
                   (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
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

    -- cannot be switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

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

    -- gain effect
    local pe3 = Effect.CreateEffect(c)
    pe3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe3:SetCode(EVENT_ADJUST)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetOperation(s.pe3op)
    c:RegisterEffect(pe3)

    -- attach
    local pe4 = Effect.CreateEffect(c)
    pe4:SetDescription(aux.Stringid(id, 1))
    pe4:SetType(EFFECT_TYPE_IGNITION)
    pe4:SetRange(LOCATION_PZONE)
    pe4:SetCountLimit(1)
    pe4:SetTarget(s.pe4tg)
    pe4:SetOperation(s.pe4op)
    c:RegisterEffect(pe4)

    -- place pendulum zone
    local pe5 = Effect.CreateEffect(c)
    pe5:SetDescription(aux.Stringid(id, 2))
    pe5:SetType(EFFECT_TYPE_IGNITION)
    pe5:SetRange(LOCATION_PZONE)
    pe5:SetCountLimit(1)
    pe5:SetTarget(s.pe5tg)
    pe5:SetOperation(s.pe5op)
    c:RegisterEffect(pe5)

    -- summon dragon (pendulum)
    local pe6 = Effect.CreateEffect(c)
    pe6:SetDescription(aux.Stringid(id, 0))
    pe6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe6:SetType(EFFECT_TYPE_IGNITION)
    pe6:SetRange(LOCATION_PZONE)
    pe6:SetCountLimit(1)
    pe6:SetTarget(s.pe6tg)
    pe6:SetOperation(s.pe6op)
    c:RegisterEffect(pe6)

    -- destroy all
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 3))
    me1:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- summon dragon (monster)
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 0))
    me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_IGNITION)
    me2:SetCountLimit(1)
    me2:SetRange(LOCATION_MZONE)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
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

function s.sumtype(c)
    if c:IsType(TYPE_FUSION) then return SUMMON_TYPE_FUSION end
    if c:IsType(TYPE_SYNCHRO) then return SUMMON_TYPE_SYNCHRO end
    if c:IsType(TYPE_XYZ) then return SUMMON_TYPE_XYZ end
    return 0
end

function s.pe3filter(c)
    return not c:IsCode(id) and c:GetFlagEffect(id) == 0 and
               c:IsType(TYPE_PENDULUM)
end

function s.pe3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup():Filter(s.pe3filter, nil)
    if #g <= 0 then return end

    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe0000, 0, 0)

        local code = tc:GetOriginalCode()
        if not g:IsExists(function(c, code)
            return c:IsCode(code) and c:GetFlagEffect(id) > 0
        end, 1, tc, code) then
            local cid = c:CopyEffect(code, RESET_EVENT + 0x1fe0000)

            local reset = Effect.CreateEffect(c)
            reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            reset:SetCode(EVENT_ADJUST)
            reset:SetRange(LOCATION_PZONE)
            reset:SetLabel(cid)
            reset:SetLabelObject(tc)
            reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                local cid = e:GetLabel()
                local c = e:GetHandler()
                local tc = e:GetLabelObject()
                local g = c:GetOverlayGroup():Filter(function(c)
                    return c:GetFlagEffect(id) > 0
                end, nil)
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset:SetReset(RESET_EVENT + 0x1fe0000)
            c:RegisterEffect(reset, true)
        end
    end
end

function s.pe4filter(c) return c:IsFaceup() and c:IsType(TYPE_PENDULUM) end

function s.pe4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.pe4filter, tp, LOCATION_EXTRA, 0,
                                           1, nil)
    end
end

function s.pe4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectMatchingCard(tp, s.pe4filter, tp, LOCATION_EXTRA, 0, 1,
                                      1, nil)
    if #g > 0 then Utility.Overlay(c, g) end
end

function s.pe5filter(c)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.pe5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.pe5filter, tp, LOCATION_HAND +
                                               LOCATION_DECK + LOCATION_GRAVE +
                                               LOCATION_EXTRA, 0, 1, nil)
    end

    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0, c)
    if #g > 0 then Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0) end
end

function s.pe5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local dg = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0, c)
    if #dg > 0 then Duel.Destroy(dg, REASON_EFFECT) end
    if UtilPendulum.CountFreePendulumZones(tp) == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local tc = Duel.SelectMatchingCard(tp, s.pe5filter, tp, LOCATION_HAND +
                                           LOCATION_DECK + LOCATION_GRAVE +
                                           LOCATION_EXTRA, 0, 1, 1, dg):GetFirst()
    if not tc then return end

    Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end

function s.pe6filter(c, e, tp)
    if (c:IsLocation(LOCATION_REMOVED + LOCATION_EXTRA) and c:IsFacedown()) then
        return false
    end
    return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
               c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ) and
               c:IsRace(RACE_DRAGON)
end

function s.pe6tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local loc = LOCATION_REMOVED + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.pe6filter, tp, loc, 0, 1, nil,
                                               e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, loc)
end

function s.pe6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local loc = LOCATION_REMOVED + LOCATION_GRAVE + LOCATION_EXTRA
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.pe6filter),
                                       tp, loc, 0, 1, 1, nil, e, tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc, s.sumtype(tc), tp, tp, true, false, POS_FACEUP)
    end
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

function s.me2filter(c, e, tp, rp)
    if not c:IsLocation(LOCATION_EXTRA) and
        Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    if c:IsLocation(LOCATION_EXTRA) and
        Duel.GetLocationCountFromEx(tp, rp, nil, c) <= 0 then return false end

    return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
               c:IsSetCard(0x20f8)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.me2filter, tp, loc, 0, 1, nil, e,
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

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.me2filter),
                                       tp, loc, 0, 1, 1, nil, e, tp, rp):GetFirst()
    if not tc then return end

    if Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP) > 0 then
        tc:CompleteProcedure()
    end
end
