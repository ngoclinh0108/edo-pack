-- Stardust Converging Maiden
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- special summon dragon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon tuner, then synchro summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 3))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_MAIN_END)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCondition(s.e3con)
    e3:SetCost(aux.CostWithReplace(s.e3cost, 84012625, function()
        return e3:GetLabel() == 1
    end))
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return c:IsAbleToHand() and aux.IsCodeListed(c, CARD_STARDUST_DRAGON)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e1filter), tp,
        LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e2filter(c, e, tp)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(id) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c, sump, sumtype, sumpos, targetp, se)
        return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON))
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        return
    end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e2filter), tp,
        LOCATION_GRAVE + LOCATION_HAND, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) ~= 0 and
        Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_LVRANK)
        local lv = Duel.AnnounceLevel(tp, 1, 12, tc:GetLevel())

        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec2:SetCode(EFFECT_CHANGE_LEVEL)
        ec2:SetValue(lv)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end

function s.e3filter1(c, e, tp, rc)
    return c:IsType(TYPE_TUNER) and Duel.GetLocationCountFromEx(tp, tp, rc, c) > 0 and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e3filter2(c, mg)
    return c:IsSynchroSummonable(nil, mg)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() ~= tp and
               (Duel.GetCurrentPhase() == PHASE_MAIN1 or Duel.GetCurrentPhase() == PHASE_MAIN2) and
               e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsReleasable() and Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c)
    end

    Duel.Release(c, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        if c:IsReleasable() and Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) then
            e:SetLabel(1)
        else
            e:SetLabel(0)
        end
        return true
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e3filter1, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if not tc or Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP_DEFENSE) == 0 then
        return
    end

    tc:CompleteProcedure()
    local mg = Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsCanBeSynchroMaterial), tp, LOCATION_MZONE, 0, nil)
    local eg = Duel.GetMatchingGroup(s.e3filter2, tp, LOCATION_EXTRA, 0, nil, mg)
    if #eg > 0 and Duel.IsPlayerCanSpecialSummonCount(tp, 2) and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sc = eg:Select(tp, 1, 1, nil):GetFirst()
        if not sc then
            return
        end
        Duel.SynchroSummon(tp, sc, nil, mg)
    end
end
