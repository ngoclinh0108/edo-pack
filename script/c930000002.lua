-- Frigga, Mother of the Aesir
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x4042, 0x42}
s.material_setcode = {0x4042}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.AesirGodEffect(c)

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x4042, sc, sumtype, tp) or
                   c:IsHasEffect(EFFECT_SYNSUB_NORDIC)
    end, 1, 1, Synchro.NonTuner(nil), 2, 99)

    -- apply negated effect
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCode(EVENT_CHAIN_NEGATED)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- return spell
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(UtilNordic.RebornCondition)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1check(c, e, tp, loc)
    return loc == LOCATION_MZONE and c:IsLocation(LOCATION_GRAVE) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local de, dp, loc = Duel.GetChainInfo(ev, CHAININFO_DISABLE_REASON,
                                          CHAININFO_DISABLE_PLAYER,
                                          CHAININFO_TRIGGERING_LOCATION)
    if de and dp ~= tp and rp == tp and re:IsActiveType(TYPE_MONSTER) then
        e:SetLabel(loc)
        return true
    end
    return false
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then return rc and Utility.CheckEffectCanApply(re, e, tp) end
    if s.e1check(rc, e, tp, e:GetLabel()) then
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, rc, 1, 0, 0)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) or not rc then return end

    Utility.HintCard(rc)
    Utility.ApplyEffect(re, e, tp)
    if s.e1check(rc, e, tp, e:GetLabel()) then
        Duel.SpecialSummon(rc, 0, tp, tp, false, false, rc:GetPreviousPosition())
    end
end

function s.e2filter(c)
    return c:IsType(TYPE_SPELL) and (c:IsAbleToHand() or c:IsSSetable(false))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_GRAVE, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, 0, LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local g =
        Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g == 0 then return end

    aux.ToHandOrElse(g, tp, function(tc)
        return tc:IsSSetable(false) and
                   Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
    end, function(g) Duel.SSet(tp, g) end, 1159)
end
