-- Loki, Aesir of Mischief
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0xa042}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_LINK, true)

    -- link summon
    Link.AddProcedure(c, s.lnkfilter1, 3, 3, s.lnkcheck)

    -- take trap
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(UtilNordic.RebornCondition)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.lnkfilter1(c) return c:HasLevel() end

function s.lnkfilter2(c, lc, sumtype, tp)
    return c:IsType(TYPE_TUNER, lc, sumtype, tp) and
               (c:IsSetCard(0xa042, lc, sumtype, tp) or
                   c:IsHasEffect(EFFECT_SYNSUB_NORDIC))
end

function s.lnkcheck(g, lc, sumtype, tp)
    local mg = g:Filter(s.lnkfilter1, nil, lc, sumtype, tp)
    return mg:CheckWithSumEqual(Card.GetLevel, 10, 3, 3) and
               mg:IsExists(s.lnkfilter2, 1, nil, lc, sumtype, tp)
end

function s.e2filter(c)
    return c:IsType(TYPE_TRAP) and (c:IsAbleToHand() or c:IsSSetable(false))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_GRAVE, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, 0, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local g =
        Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g == 0 then return end

    aux.ToHandOrElse(g, tp, function(tc)
        return tc:IsSSetable(false) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end, function(g) Duel.SSet(tp, g) end, 1159)
end
