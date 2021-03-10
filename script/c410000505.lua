-- Shooting Majestic Quasar Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {21159309, 35952884}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_EXTRA)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

    -- summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(spsafe)

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

    -- immunity
    local immunity = Effect.CreateEffect(c)
    immunity:SetType(EFFECT_TYPE_SINGLE)
    immunity:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    immunity:SetCode(EFFECT_IMMUNE_EFFECT)
    immunity:SetRange(LOCATION_MZONE)
    immunity:SetValue(function(e, te)
        return te:GetHandler() ~= e:GetHandler()
    end)
    c:RegisterEffect(immunity)

    -- banish return
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_REMOVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- attack all monsters
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ATTACK_ALL)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- disable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0, LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e3b)

    -- negate activation
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_NEGATE + CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- special summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.sprfilter(c) return c:IsFaceup() and c:IsAbleToGraveAsCost() end

function s.sprfilter1(c, sc, tp)
    if not c:IsCode(21159309) then return false end
    return Duel.IsExistingMatchingCard(s.sprfilter2, tp, LOCATION_MZONE, 0, 1,
                                       c, sc, tp)
end

function s.sprfilter2(c, sc, tp)
    local sg = Group.FromCards(c, sc)
    return Duel.GetLocationCountFromEx(tp, tp, sg, sc) > 0 and
               c:IsCode(35952884) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.sprcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
    return g:IsExists(s.sprfilter1, 1, nil, c, tp)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)

    local mg = aux.SelectUnselectGroup(g:Filter(s.sprfilter1, nil, c, tp), e,
                                       tp, 1, 1, nil, 1, tp, HINTMSG_TOGRAVE,
                                       nil, nil, true)
    if #mg > 0 then
        local mc = mg:GetFirst()
        mg:Merge(aux.SelectUnselectGroup(g:Filter(s.sprfilter2, mc, mc, tp), e,
                                         tp, 1, 1, nil, 1, tp, HINTMSG_TOGRAVE,
                                         nil, nil, true))
    end

    if #mg ~= 2 then return false end
    mg:KeepAlive()
    e:SetLabelObject(mg)
    return true
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local mg = e:GetLabelObject()
    if not mg then return end

    Duel.SendtoGrave(mg, REASON_COST)
end

function s.e1filter(c, tp)
    return c:IsControler(tp) and c:IsType(TYPE_MONSTER) and
               c:IsPreviousLocation(LOCATION_GRAVE)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return eg and eg:IsExists(s.e1filter, 1, nil, tp)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.e1filter, nil, tp)
    if #g == 0 then return end

    Duel.SendtoGrave(g, REASON_EFFECT)
end

function s.e3con(e)
    local c = e:GetHandler()
    return (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() ==
               PHASE_DAMAGE_CAL) and Duel.GetAttacker() == c and
               c:GetBattleTarget()
end

function s.e3tg(e, c) return c == e:GetHandler():GetBattleTarget() end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and
               Duel.IsChainNegatable(ev)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if rc:IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, eg, 1, 0, rc:GetLocation())
    else
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, eg, 1, 0,
                              rc:GetPreviousLocation())
    end

    Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Remove(eg, POS_FACEUP, REASON_EFFECT)
    end
end

function s.e5filter(c, e, tp)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e5filter, tp,
                                               LOCATION_EXTRA + LOCATION_GRAVE,
                                               0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0,
                          LOCATION_EXTRA + LOCATION_GRAVE)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e5filter, tp,
                                      LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, 1,
                                      nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, SUMMON_TYPE_SYNCHRO, tp, tp, false, false,
                           POS_FACEUP)
    end
end
