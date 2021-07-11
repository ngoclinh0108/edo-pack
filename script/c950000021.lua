-- Supreme Wrath
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {950000001, 13331639}
s.listed_series = {0x2073, 0x20f8}

function s.initial_effect(c)
    -- act in hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- pendulum summon (your turn)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1, id + 2 * 1000000)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- pendulum summon (your opponent turn)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1, id + 3 * 1000000)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- summon 4 supreme king dragon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_ACTIVATE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCountLimit(1, id + 4 * 1000000)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- attach xyz materials
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1, id + 1 * 1000000)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsCode(950000001)
    end, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local eff = Effect.CreateEffect(e:GetHandler())
    eff:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    eff:SetCode(EVENT_ADJUST)
    eff:SetOperation(function(e, tp)
        local lpz = Duel.GetFieldCard(tp, LOCATION_PZONE, 0)
        if lpz == nil or lpz:GetFlagEffect(id) ~= 0 then return end
        local effpen = Effect.CreateEffect(e:GetHandler())
        effpen:SetDescription(aux.Stringid(id, 0))
        effpen:SetType(EFFECT_TYPE_FIELD)
        effpen:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
        effpen:SetCode(EFFECT_SPSUMMON_PROC_G)
        effpen:SetRange(LOCATION_PZONE)
        effpen:SetCondition(s.e2pencon)
        effpen:SetOperation(s.e2penop)
        effpen:SetValue(SUMMON_TYPE_PENDULUM)
        effpen:SetReset(RESET_PHASE + PHASE_END)
        lpz:RegisterEffect(effpen)
        lpz:RegisterFlagEffect(id, RESET_PHASE + PHASE_END, 0, 1)
    end)
    eff:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(eff, tp)
end

function s.e2pencon(e, c, og)
    if c == nil then return true end
    local tp = c:GetControler()

    local rpz = Duel.GetFieldCard(tp, LOCATION_PZONE, 1)
    if rpz == nil or c == rpz or Duel.GetFlagEffect(tp, 29432356) > 0 then
        return false
    end
    local lscale = c:GetLeftScale()
    local rscale = rpz:GetRightScale()
    if lscale > rscale then lscale, rscale = rscale, lscale end

    local loc = 0
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        loc = loc + LOCATION_HAND
    end
    if Duel.GetLocationCountFromEx(tp) > 0 then loc = loc + LOCATION_EXTRA end
    if loc == 0 then return false end

    local g = nil
    if og then
        g = og:Filter(Card.IsLocation, nil, loc)
    else
        g = Duel.GetFieldGroup(tp, loc, 0)
    end
    return g:IsExists(Pendulum.Filter, 1, nil, e, tp, lscale, rscale)
end

function s.e2penop(e, tp, eg, ep, ev, re, r, rp, c, sg, og)
    local rpz = Duel.GetFieldCard(tp, LOCATION_PZONE, 1)
    local lscale = c:GetLeftScale()
    local rscale = rpz:GetRightScale()
    if lscale > rscale then lscale, rscale = rscale, lscale end

    local ft1 = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local ft2 = Duel.GetLocationCountFromEx(tp)
    local ft = Duel.GetUsableMZoneCount(tp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        if ft1 > 0 then ft1 = 1 end
        if ft2 > 0 then ft2 = 1 end
        ft = 1
    end

    local loc = 0
    if ft1 > 0 then loc = loc + LOCATION_HAND end
    if ft2 > 0 then loc = loc + LOCATION_EXTRA end
    local tg = nil
    if og then
        tg = og:Filter(Card.IsLocation, nil, loc):Filter(Pendulum.Filter, nil,
                                                         e, tp, lscale, rscale)
    else
        tg = Duel.GetMatchingGroup(Pendulum.Filter, tp, loc, 0, nil, e, tp,
                                   lscale, rscale)
    end
    ft1 = math.min(ft1, tg:FilterCount(Card.IsLocation, nil, LOCATION_HAND))
    ft2 = math.min(ft2, tg:FilterCount(Card.IsLocation, nil, LOCATION_EXTRA))
    ft2 = math.min(ft2, aux.CheckSummonGate(tp) or ft2)

    while true do
        local ct1 = tg:FilterCount(Card.IsLocation, nil, LOCATION_HAND)
        local ct2 = tg:FilterCount(Card.IsLocation, nil, LOCATION_EXTRA)
        local ct = ft
        if ct1 > ft1 then ct = math.min(ct, ft1) end
        if ct2 > ft2 then ct = math.min(ct, ft2) end
        local loc = 0
        if ft1 > 0 then loc = loc + LOCATION_HAND end
        if ft2 > 0 then loc = loc + LOCATION_EXTRA end
        local g = tg:Filter(Card.IsLocation, sg, loc)
        if #g == 0 or ft == 0 then break end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local tc = Group.SelectUnselect(g, sg, tp, true, true)
        if not tc then break end
        if sg:IsContains(tc) then
            sg:RemoveCard(tc)
            if tc:IsLocation(LOCATION_HAND) then
                ft1 = ft1 + 1
            else
                ft2 = ft2 + 1
            end
            ft = ft + 1
        else
            sg:AddCard(tc)
            if tc:IsLocation(LOCATION_HAND) then
                ft1 = ft1 - 1
            else
                ft2 = ft2 - 1
            end
            ft = ft - 1
        end
    end

    if #sg > 0 then
        Duel.Hint(HINT_CARD, 0, id)
        Duel.RegisterFlagEffect(tp, 29432356,
                                RESET_PHASE + PHASE_END + RESET_SELF_TURN, 0, 1)
        Duel.HintSelection(Group.FromCards(c))
        Duel.HintSelection(Group.FromCards(rpz))
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == 1 - tp and Duel.IsMainPhase()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanPendulumSummon(tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_EXTRA + LOCATION_HAND)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp) Duel.PendulumSummon(tp) end

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

function s.e4rescon(ft1, ft2, ft3, ft4, ft)
    return function(sg, e, tp, mg)
        local exnpct = sg:FilterCount(function(c)
            return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and
                       c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
        end, nil, LOCATION_EXTRA)
        local expct = sg:FilterCount(function(c)
            return c:IsLocation(LOCATION_EXTRA) and
                       (c:IsType(TYPE_LINK) or
                           (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
        end, nil, LOCATION_EXTRA)
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
                                           tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Destroy(
        Duel.GetMatchingGroup(aux.NOT(s.e4filter1), tp, LOCATION_MZONE, 0, nil),
        REASON_EFFECT)

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

function s.e5filter1(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and
               Utility.IsSetCard(c, 0x2073, 0x20f8)
end

function s.e5filter2(c)
    return c:IsSetCard(0x20f8) and c:IsType(TYPE_MONSTER) and
               (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return
            Duel.IsExistingTarget(s.e5filter1, tp, LOCATION_MZONE, 0, 1, nil) and
                Duel.IsExistingMatchingCard(s.e5filter2, tp,
                                            LOCATION_GRAVE + LOCATION_EXTRA, 0,
                                            1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e5filter1, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then
        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local g = Duel.SelectMatchingCard(tp, s.e5filter2, tp,
                                      LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 2,
                                      nil)
    if #g > 0 then Duel.Overlay(tc, g) end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, 29432356) == 0
end
