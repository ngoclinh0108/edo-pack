-- Starving Venom Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon procedure
    Fusion.AddProcMixN(c, true, true,
                       aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM), 2)

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

    -- fusion summon
    local pe2params = {
        nil, Fusion.CheckWithHandler(function(c)
            return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION) and
                       c:IsOnField() and c:IsAbleToGrave()
        end), function(e) return Group.FromCards(e:GetHandler()) end, nil,
        Fusion.ForcedHandler
    }
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(1170)
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetTarget(Fusion.SummonEffTG(table.unpack(pe2params)))
    pe2:SetOperation(Fusion.SummonEffOP(table.unpack(pe2params)))
    c:RegisterEffect(pe2)

    -- fusion substitute
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    me1:SetCondition(function(e)
        local c = e:GetHandler()
        if c:IsLocation(LOCATION_REMOVED + LOCATION_EXTRA) and c:IsFacedown() then
            return false
        end
        return c:IsLocation(
                   LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED +
                       LOCATION_EXTRA)
    end)
    c:RegisterEffect(me1)

    -- destroy & summon
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 1))
    me2:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_QUICK_O)
    me2:SetCode(EVENT_FREE_CHAIN)
    me2:SetRange(LOCATION_MZONE)
    me2:SetHintTiming(0, TIMING_MAIN_END)
    me2:SetCountLimit(1, id + 1 * 1000000)
    me2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.IsMainPhase()
    end)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- place pendulum
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(1160)
    me4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me4:SetProperty(EFFECT_FLAG_DELAY)
    me4:SetCode(EVENT_DESTROYED)
    me4:SetCondition(s.me4con)
    me4:SetTarget(s.me4tg)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4)
end

function s.pe1filter(c)
    if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then return false end
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
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

function s.me2filter(c, e, tp, rp)
    return c:IsFaceup() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsDestructable() and
                   Duel.IsExistingMatchingCard(s.me2filter, tp,
                                               LOCATION_GRAVE + LOCATION_REMOVED,
                                               0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    if Duel.Destroy(c, REASON_EFFECT) ~= 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, s.me2filter, tp,
                                          LOCATION_GRAVE + LOCATION_REMOVED, 0,
                                          1, 1, nil, e, tp)
        if #g > 0 then
            Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        end
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
