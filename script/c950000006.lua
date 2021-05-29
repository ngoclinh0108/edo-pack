-- Supreme Wrath
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {950000005, 13331639}
s.listed_series = {0x20f8}

function s.initial_effect(c)
    -- attach xyz materials
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id + 1 * 1000000)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- pendulum summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0, TIMING_MAIN_END)
    e2:SetCountLimit(1, id + 2 * 1000000)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- activate supreme soul
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1, id + 2 * 1000000)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_ACTIVATE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCountLimit(1, id + 2 * 1000000)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter1(c)
    return c:IsFaceup() and c:IsSetCard(0x20f8) and c:IsType(TYPE_XYZ)
end

function s.e1filter2(c)
    return c:IsSetCard(0x20f8) and c:IsType(TYPE_MONSTER) and
               (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return
            Duel.IsExistingTarget(s.e1filter1, tp, LOCATION_MZONE, 0, 1, nil) and
                Duel.IsExistingMatchingCard(s.e1filter2, tp,
                                            LOCATION_GRAVE + LOCATION_EXTRA, 0,
                                            1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e1filter1, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then
        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local g = Duel.SelectMatchingCard(tp, s.e1filter2, tp,
                                      LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 2,
                                      nil)
    if #g > 0 then Duel.Overlay(tc, g) end
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanPendulumSummon(tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_EXTRA + LOCATION_HAND)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp) Duel.PendulumSummon(tp) end

function s.e3filter(c, tp)
    return c:IsCode(950000005) and c:GetActivateEffect() and
               c:GetActivateEffect():IsActivatable(tp, true, true)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return
            Duel.GetFieldGroupCount(tp, LOCATION_PZONE, LOCATION_PZONE) >= 2 and
                Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND +
                                                LOCATION_DECK + LOCATION_GRAVE,
                                            0, 1, nil, tp)
    end

    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, LOCATION_PZONE)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local dg = Duel.GetFieldGroup(tp, LOCATION_PZONE, LOCATION_PZONE)
    if Duel.Destroy(dg, REASON_EFFECT) == 0 then return end

    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_HAND +
                                        LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                    tp)
    local tc
    if #g > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
        tc = g:Select(tp, 1, 1):GetFirst()
    else
        tc = g:GetFirst()
    end

    Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
end

function s.e4filter1(c) return c:IsFaceup() and c:IsCode(13331639) end

function s.e4filter2(c, e, tp)
    if not (c:IsSetCard(0x20f8) and
        c:IsCanBeSpecialSummoned(e, 0, tp, true, false)) then return false end

    local g = Duel.GetMatchingGroup(aux.NOT(s.e4filter1), tp, LOCATION_MZONE, 0,
                                    nil)
    if c:IsLocation(LOCATION_EXTRA) then
        return Duel.GetLocationCountFromEx(tp, tp, g, c) > 0
    else
        return Duel.GetMZoneCount(tp, g) > 0
    end
end

function s.e4filter3(c)
    return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and
               c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
end

function s.e4filter4(c)
    return c:IsLocation(LOCATION_EXTRA) and
               (c:IsType(TYPE_LINK) or
                   (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end

function s.e4rescon(ft1, ft2, ft3, ft4, ft)
    return function(sg, e, tp, mg)
        local exnpct = sg:FilterCount(s.e4filter3, nil, LOCATION_EXTRA)
        local expct = sg:FilterCount(s.e4filter4, nil, LOCATION_EXTRA)
        local mct =
            sg:FilterCount(aux.NOT(Card.IsLocation), nil, LOCATION_EXTRA)
        local groupcount = #sg
        local classcount = sg:GetClassCount(Card.GetCode)
        local res = ft3 >= exnpct and ft4 >= expct and ft1 >= mct and ft >=
                        groupcount and classcount == groupcount
        return res, not res
    end
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e4filter1, tp, LOCATION_ONFIELD, 0, 1,
                                       nil)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    local g = Duel.GetMatchingGroup(aux.NOT(s.e4filter1), tp, LOCATION_MZONE, 0,
                                    nil)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter2, tp, loc, 0, 1, nil, e,
                                           tp) and #g > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local dg = Duel.GetMatchingGroup(aux.NOT(s.e4filter1), tp, LOCATION_MZONE,
                                     0, nil)
    if Duel.Destroy(dg, REASON_EFFECT) == 0 then return end

    local ft1 = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local ft2 = Duel.GetLocationCountFromEx(tp)
    local ft3 = Duel.GetLocationCountFromEx(tp, tp, nil, TYPE_FUSION +
                                                TYPE_SYNCHRO + TYPE_XYZ)
    local ft4 = Duel.GetLocationCountFromEx(tp, tp, nil,
                                            TYPE_PENDULUM + TYPE_LINK)
    local ft = math.min(Duel.GetUsableMZoneCount(tp), 4)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        if ft1 > 0 then ft1 = 1 end
        if ft2 > 0 then ft2 = 1 end
        if ft3 > 0 then ft3 = 1 end
        if ft4 > 0 then ft4 = 1 end
        ft = 1
    end

    local ect = aux.CheckSummonGate(tp)
    if ect then
        ft1 = math.min(ect, ft1)
        ft2 = math.min(ect, ft2)
        ft3 = math.min(ect, ft3)
        ft4 = math.min(ect, ft4)
    end

    local loc = 0
    if ft1 > 0 then
        loc = loc + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    end
    if ft2 > 0 or ft3 > 0 or ft4 > 0 then loc = loc + LOCATION_EXTRA end
    if loc == 0 then return end
    local sg = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e4filter2), tp,
                                     loc, 0, nil, e, tp)
    if #sg == 0 then return end

    local rg = aux.SelectUnselectGroup(sg, e, tp, 1, ft,
                                       s.e4rescon(ft1, ft2, ft3, ft4, ft), 1,
                                       tp, HINTMSG_SPSUMMON)
    Duel.SpecialSummon(rg, 0, tp, tp, true, false, POS_FACEUP)
    for tc in aux.Next(rg) do tc:CompleteProcedure() end
end
