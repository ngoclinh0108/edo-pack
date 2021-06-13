-- Dark Rebellion Magician
Duel.LoadScript("util.lua")
Duel.LoadScript("c419.lua")
local s, id = GetID()

s.listed_series = {0x13b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM), 4,
                     2)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- to extra
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetCategory(CATEGORY_TODECK)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- rank-up
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 1))
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- xyz level
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_XYZ_LEVEL)
    me1:SetValue(function(e, c) return c:GetRank() end)
    c:RegisterEffect(me1)

    -- place pendulum
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(1160)
    me2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me2:SetProperty(EFFECT_FLAG_DELAY)
    me2:SetCode(EVENT_DESTROYED)
    me2:SetCondition(s.me2con)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- destroy & summon
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(aux.Stringid(id, 2))
    me3:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    me3:SetType(EFFECT_TYPE_QUICK_O)
    me3:SetCode(EVENT_FREE_CHAIN)
    me3:SetRange(LOCATION_MZONE)
    me3:SetHintTiming(0, TIMING_MAIN_END)
    me3:SetCountLimit(1, id + 1 * 1000000)
    me3:SetCondition(function() return Duel.IsMainPhase() end)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)

    -- damage
    local me4 = Effect.CreateEffect(c)
    me4:SetCategory(CATEGORY_DAMAGE)
    me4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me4:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    me4:SetCode(511001265)
    me4:SetRange(LOCATION_MZONE)
    me4:SetCountLimit(1, id + 2 * 1000000)
    me4:SetCondition(s.me4con)
    me4:SetCost(s.me4cost)
    me4:SetTarget(s.me4tg)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.pe1filter(c)
    if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then return false end
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.pe1filter, tp,
                                     LOCATION_GRAVE + LOCATION_REMOVED, 0, 1,
                                     nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.pe1filter, tp,
                                LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    Duel.SendtoDeck(tc, nil, 0, REASON_EFFECT)
end

function s.pe2filter1(c, e, tp)
    local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(c), tp, nil, nil,
                                          REASON_XYZ)
    return #pg <= 1 and c:IsFaceup() and c:IsRace(RACE_DRAGON) and
               (c:GetRank() > 0 or c:IsStatus(STATUS_NO_LEVEL)) and
               Duel.IsExistingMatchingCard(s.pe2filter2, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp, c, pg)
end

function s.pe2filter2(c, e, tp, mc, pg)
    local rk = mc:GetRank()
    if c.rum_limit and not c.rum_limit(mc, e) or
        Duel.GetLocationCountFromEx(tp, tp, mc, c) <= 0 then return false end
    return
        c:IsType(TYPE_XYZ) and mc:IsType(TYPE_XYZ, c, SUMMON_TYPE_XYZ, tp) and
            mc:IsRace(RACE_DRAGON, c, SUMMON_TYPE_XYZ, tp) and c:IsRank(rk + 1) and
            mc:IsCanBeXyzMaterial(c, tp) and (#pg <= 0 or pg:IsContains(mc)) and
            c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, false, false)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.pe2filter1, tp, LOCATION_MZONE, 0, 1,
                                     nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.pe2filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or tc:IsFacedown() or not c:IsRelateToEffect(e) or
        not tc:IsRelateToEffect(e) or tc:IsControler(1 - tp) or
        tc:IsImmuneToEffect(e) then return end

    local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(tc), tp, nil, nil,
                                          REASON_XYZ)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.pe2filter2, tp, LOCATION_EXTRA, 0,
                                       1, 1, nil, e, tp, tc, pg):GetFirst()
    if not sc then return end

    local mg = tc:GetOverlayGroup()
    if #mg ~= 0 then Duel.Overlay(sc, mg) end
    sc:SetMaterial(Group.FromCards(tc))
    Duel.Overlay(sc, Group.FromCards(tc, c))
    Duel.SpecialSummon(sc, SUMMON_TYPE_XYZ, tp, tp, false, false, POS_FACEUP)
    sc:CompleteProcedure()
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckLocation(tp, LOCATION_PZONE, 0) or
                   Duel.CheckLocation(tp, LOCATION_PZONE, 1)
    end
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.CheckLocation(tp, LOCATION_PZONE, 0) and
        not Duel.CheckLocation(tp, LOCATION_PZONE, 1) then return false end
    if not c:IsRelateToEffect(e) then return end

    Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end

function s.me3filter(c, e, tp, rp)
    return c:IsFaceup() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)
end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsDestructable() and
                   Duel.IsExistingMatchingCard(s.me3filter, tp,
                                               LOCATION_GRAVE + LOCATION_REMOVED,
                                               0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.Destroy(c, REASON_EFFECT) == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.me3filter, tp,
                                      LOCATION_GRAVE + LOCATION_REMOVED, 0, 1,
                                      1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.me4filter1(c, tp)
    local preatk = 0
    if c:GetFlagEffect(284) > 0 then preatk = c:GetFlagEffectLabel(284) end
    return
        c:IsControler(tp) and c:GetAttack() ~= preatk and c:IsSetCard(0x13b) and
            c:IsRace(RACE_DRAGON)
end

function s.me4filter2(c, g)
    local preatk = 0
    if c:GetFlagEffect(284) > 0 then preatk = c:GetFlagEffectLabel(284) end

    local dif = 0
    if c:GetAttack() > preatk then
        dif = c:GetAttack() - preatk
    else
        dif = preatk - c:GetAttack()
    end
    return g:IsExists(s.me4filter3, 1, c, dif)
end

function s.me4filter3(c, dif)
    local preatk = 0
    if c:GetFlagEffect(284) > 0 then preatk = c:GetFlagEffectLabel(284) end

    local dif2 = 0
    if c:GetAttack() > preatk then
        dif2 = c:GetAttack() - preatk
    else
        dif2 = preatk - c:GetAttack()
    end

    return dif ~= dif2
end

function s.me4con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.me4filter1, 1, nil, tp)
end

function s.me4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    c:RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.me4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local sc = eg:GetFirst()
    local sg = eg:Filter(s.me4filter2, nil, eg)
    if #sg > 0 then sc = sg:Select(tp, 1, 1, nil):GetFirst() end

    local dmg = 0
    local preatk = 0
    if sc:GetFlagEffect(284) > 0 then preatk = sc:GetFlagEffectLabel(284) end
    if sc:GetAttack() > preatk then
        dmg = sc:GetAttack() - preatk
    else
        dmg = preatk - sc:GetAttack()
    end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.me4op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
