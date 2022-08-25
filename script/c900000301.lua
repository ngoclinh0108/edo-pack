-- Mark Of The Dragon Star
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetCost(s.actcost)
    act:SetTarget(s.acttg)
    act:SetOperation(s.actop)
    c:RegisterEffect(act)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.actcounterfilter)
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
        return s.e1check(tp)
    end

    local opt = {}
    local sel = {}
    if s.e1check(tp) then
        table.insert(sel, 1)
        table.insert(opt, aux.Stringid(id, 1))
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EFFECT)
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    e:SetLabel(op)

    if op == 1 then
        e:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_DECKDES)
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
        Duel.SetPossibleOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
    end
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    local op = e:GetLabel()
    if op == 1 then
        s.e1op(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.e1check(tp)
    return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
end

function s.e1filter1(c)
    return c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end

function s.e1filter2(c, tc)
    return c:HasLevel() and c:GetLevel() < tc:GetLevel()
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
        nil):GetFirst()
    if not tc then
        return
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
    Duel.ShuffleDeck(tp)

    if not tc:IsLocation(LOCATION_HAND) or not tc:HasLevel() or
        Duel.GetMatchingGroupCount(s.e1filter2, tp, LOCATION_DECK, 0, nil, tc) == 0 or not Duel.SelectYesNo(tp, 504) then
        return
    end

    Duel.BreakEffect()
    local sg = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e1filter2, tp, LOCATION_DECK, 0, 1, 1, nil, tc)
    Duel.SendtoGrave(sg, REASON_EFFECT)
end
