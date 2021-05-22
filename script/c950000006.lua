-- Supreme Soul
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {13331639}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetCondition(s.actcon)
    c:RegisterEffect(act)

    -- cannot disable pendulum summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(1, 0)
    e1:SetTarget(function(e, c)
        return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsType(TYPE_PENDULUM)
    end)
    c:RegisterEffect(e1)

    -- add to extra deck
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e2b)

    -- special summon from pendulum zone
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetHintTiming(0, TIMING_END_PHASE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- place in pendulum zone
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetHintTiming(0, TIMING_END_PHASE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- summon Z-Arc
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCountLimit(1, id)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.actcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFieldCard(tp, LOCATION_PZONE, 0) and
               Duel.GetFieldCard(tp, LOCATION_PZONE, 1)
end

function s.e2filter(c, tp) return c:IsControler(tp) and c:IsType(TYPE_PENDULUM) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return eg and (re == nil or e:GetHandler() ~= re:GetHandler()) and
               eg:IsExists(s.e2filter, 1, nil, tp, re)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.e2filter, nil, tp)
    if #g == 0 then return end
    Duel.SendtoExtraP(g, tp, REASON_EFFECT)
end

function s.e3filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e3filter, tp, LOCATION_PZONE, 0, 1,
                                         nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_PZONE, 0, 1, 1,
                                nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) then return end
    if not tc:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
end

function s.e4filter(c) return c:IsFaceup() and c:IsType(TYPE_PENDULUM) end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or
                   Duel.CheckLocation(tp, LOCATION_PZONE, 1)) and
                   Duel.IsExistingTarget(s.e4filter, tp, LOCATION_MZONE, 0, 1,
                                         nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 2))
    Duel.SelectTarget(tp, s.e4filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or
        not (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or
            Duel.CheckLocation(tp, LOCATION_PZONE, 1)) then return end

    local tc = Duel.GetFirstTarget()
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end

function s.e5filter1(c, e, tp, sg)
    return c:IsCode(13331639) and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
               Duel.GetLocationCountFromEx(tp, tp, sg or nil, c) > 0
end

function s.e5filter2(c)
    return (c:IsSetCard(0x10f2) or c:IsSetCard(0x2073) or c:IsSetCard(0x2017) or
               c:IsSetCard(0x1046)) and c:IsType(TYPE_MONSTER) and
               c:IsAbleToRemoveAsCost() and
               (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and
               (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true, true))
end

function s.e5rescon(checkfunc)
    return function(sg, e, tp, mg)
        if not sg:CheckDifferentProperty(checkfunc) then
            return false, true
        end

        return Duel.IsExistingMatchingCard(s.e5filter1, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp, sg)
    end
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mg = Duel.GetMatchingGroup(s.e5filter2, tp, LOCATION_HAND +
                                         LOCATION_MZONE + LOCATION_GRAVE, 0, c)
    local checkfunc = aux.PropertyTableFilter(Card.GetSetCard, 0x10f2, 0x2073,
                                              0x2017, 0x1046)

    if chk == 0 then
        return
            aux.SelectUnselectGroup(mg, e, tp, 4, 4, s.e5rescon(checkfunc), 0)
    end

    local sg = aux.SelectUnselectGroup(mg, e, tp, 4, 4, s.e5rescon(checkfunc),
                                       1, tp, HINTMSG_REMOVE,
                                       s.e5rescon(checkfunc))
    Duel.Remove(sg, POS_FACEUP, REASON_COST)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e5filter1, tp, LOCATION_EXTRA, 0,
                                       1, 1, nil, e, tp):GetFirst()
    if not tc then return end

    if Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP) > 0 then
        tc:CompleteProcedure()
    end
end
