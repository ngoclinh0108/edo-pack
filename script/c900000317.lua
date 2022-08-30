-- Majestic Wills Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x3f}

function s.initial_effect(c)
    -- synchro symmon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- effect gain
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, mg)
    return c:IsSetCard(0x3f) and c:IsSynchroSummonable(mg)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() ~= tp and
               (Duel.GetCurrentPhase() == PHASE_MAIN1 or Duel.GetCurrentPhase() == PHASE_MAIN2)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_EXTRA, 0, 1, nil, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsControler(1 - tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then
        return
    end

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_EXTRA, 0, nil, c)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = g:Select(tp, 1, 1, nil)
        Duel.SynchroSummon(tp, sg:GetFirst(), c)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetReasonCard()
    return r == REASON_SYNCHRO and tc:IsSetCard(0x3f)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetReasonCard()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_TO_DECK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetDescription(3031)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetValue(aux.tgoval)
    tc:RegisterEffect(ec2)
end
