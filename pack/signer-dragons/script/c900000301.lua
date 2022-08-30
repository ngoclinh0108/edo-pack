-- Mark Of The Dragon Star
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetCost(s.actcost)
    act:SetTarget(s.acttg)
    act:SetOperation(s.actop)
    c:RegisterEffect(act)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.actcounterfilter)

    -- set from GY
    local set = Effect.CreateEffect(c)
    set:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    set:SetProperty(EFFECT_FLAG_DELAY)
    set:SetCode(EVENT_SPSUMMON_SUCCESS + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                    EFFECT_FLAG_CANNOT_INACTIVATE)
    set:SetRange(LOCATION_GRAVE)
    set:SetCountLimit(1, id)
    set:SetCondition(s.setcon)
    set:SetTarget(s.settg)
    set:SetOperation(s.setop)
    c:RegisterEffect(set)
end

function s.actcounterfilter(c)
    return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO)
end

function s.actcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c, sump, sumtype, sumpos, targetp, se)
        return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    aux.addTempLizardCheck(e:GetHandler(), tp, function(e, c)
        return not c:IsOriginalType(TYPE_SYNCHRO)
    end)
end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return s.e1check(e, tp) or s.e2check(e, tp)
    end

    local opt = {}
    local sel = {}
    if s.e1check(e, tp) then
        table.insert(sel, 1)
        table.insert(opt, aux.Stringid(id, 1))
    end
    if s.e1check(e, tp) then
        table.insert(sel, 2)
        table.insert(opt, aux.Stringid(id, 2))
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EFFECT)
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    e:SetLabel(op)

    if op == 1 then
        e:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
        Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE)
        Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
    elseif op == 2 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 2, tp,
            LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED)
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
    end
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = e:GetLabel()
    if not c:IsRelateToEffect(e) or Duel.GetFlagEffect(tp, id + op * 1000) > 0 then
        return
    end

    Duel.RegisterFlagEffect(tp, id + op * 1000, RESET_PHASE + PHASE_END, 0, 1)
    if op == 1 then
        s.e1op(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 2 then
        s.e1op(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 3 then
        s.e2op(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 4 then
        s.e2op(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.e1check(e, tp)
    return Duel.GetFlagEffect(tp, id + 1 * 1000) == 0 and
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil) and
               Duel.IsPlayerCanDraw(tp, 1)
end

function s.e1filter(c)
    return c:IsType(TYPE_TUNER) and c:IsAbleToDeck()
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1,
        nil):GetFirst()

    if Duel.SendtoDeck(tc, nil, 0, REASON_EFFECT) > 0 then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end

function s.e2check(e, tp)
    local pg = aux.GetMustBeMaterialGroup(tp, Group.CreateGroup(), tp, nil, nil, REASON_SYNCHRO)
    return Duel.GetFlagEffect(tp, id + 2 * 1000) == 0 and #pg <= 0 and
               Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
end

function s.e2rescon(tuner, sc)
    return function(sg, e, tp, mg)
        sg:AddCard(tuner)
        local res = Duel.GetLocationCountFromEx(tp, tp, sg, sc) > 0 and
                        sg:CheckWithSumEqual(Card.GetLevel, sc:GetLevel(), #sg, #sg)
        sg:RemoveCard(tuner)
        return res
    end
end

function s.e2filter1(c, e, tp)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) and
               Duel.IsExistingMatchingCard(s.e2filter2, tp,
            LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e, tp, c)
end

function s.e2filter2(c, e, tp, sc)
    local rg = Duel.GetMatchingGroup(s.e2filter3, tp,
        LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED, 0, c)
    return c:IsType(TYPE_TUNER) and c:IsAbleToDeck() and
               aux.SelectUnselectGroup(rg, e, tp, nil, 2, s.e2rescon(c, sc), 0)
end

function s.e2filter3(c)
    return c:HasLevel() and not c:IsType(TYPE_TUNER) and c:IsAbleToDeck()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local pg = aux.GetMustBeMaterialGroup(tp, Group.CreateGroup(), tp, nil, nil, REASON_SYNCHRO)
    if #pg > 0 then
        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if not sc then
        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local tuner = Duel.SelectMatchingCard(tp, s.e2filter2, tp,
        LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil, e, tp, sc):GetFirst()
    local rg = Duel.GetMatchingGroup(s.e2filter3, tp,
        LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED, 0, tuner)
    local sg = aux.SelectUnselectGroup(rg, e, tp, 1, 2, s.e2rescon(tuner, sc), 1, tp, HINTMSG_TODECK,
        s.e2rescon(tuner, sc))
    sg:AddCard(tuner)
    if Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 then
        return
    end

    Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
    sc:CompleteProcedure()
end

function s.setfilter(c, tp)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp) and
               c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.setcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.setfilter, 1, nil, tp)
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsSSetable()
    end

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsSSetable() then
        return
    end

    Duel.SSet(tp, c)
end
