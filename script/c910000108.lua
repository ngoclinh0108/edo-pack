-- Ragnarok of Palladium
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMINGS_CHECK_MONSTER)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2}, EFFECT_COUNT_CODE_DUEL)
    e2:SetCondition(aux.exccon)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() < PHASE_END
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(function(c)
        return c:IsMonster() and c:IsAbleToRemoveAsCost()
    end, tp, LOCATION_MZONE + LOCATION_HAND + LOCATION_GRAVE, 0, c)
    if chk == 0 then return g:IsExists(Card.IsSetCard, 1, nil, 0x13a) end

    local sg = Utility.GroupSelect({
        hintmsg = HINTMSG_REMOVE,
        g = g,
        tp = tp,
        max = #g,
        check = function(g)
            return g:IsExists(Card.IsSetCard, 1, nil, 0x13a)
        end
    })

    local divine_hierarchy = 0
    for tc in aux.Next(sg) do
        divine_hierarchy = divine_hierarchy + Divine.GetDivineHierarchy(tc)
    end
    local ct = Duel.Remove(sg, POS_FACEUP, REASON_COST)

    e:SetLabelObject({ct, divine_hierarchy})
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE,
                                           1, nil)
    end

    local label = e:GetLabelObject()
    if label then
        Duel.SetOperationInfo(0, CATEGORY_DISABLE, nil, label[1], 0, 0)
    end
    Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local label = e:GetLabelObject()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CHANGE_DAMAGE)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetTargetRange(0, 1)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(ec1b, tp)

    if label == nil then return end
    local g = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, Card.IsFaceup, tp,
                                         0, LOCATION_MZONE, 1, label[1], nil)
    Duel.HintSelection(g)
    for tc in aux.Next(g) do
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        ec1b:SetValue(RESET_TURN_SET)
        tc:RegisterEffect(ec1b)
    end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_PHASE + PHASE_END)
    ec2:SetCountLimit(1)
    ec2:SetLabel(label[2])
    ec2:SetOperation(function(e, tp)
        Utility.HintCard(e)
        local g = Duel.GetMatchingGroup(function(c)
            return Divine.GetDivineHierarchy(c) <= e:GetLabel()
        end, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
        Duel.Remove(g, POS_FACEUP, REASON_EFFECT + REASON_REPLACE + REASON_RULE)
    end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
end

function s.e2filter(c, e, tp)
    return c:IsFaceup() and c:IsMonster() and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.e2check(g) return g:IsExists(Card.IsSetCard, 1, nil, 0x13a) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return aux.bfgcost(e, tp, eg, ep, ev, re, r, rp, chk) end
    aux.bfgcost(e, tp, eg, ep, ev, re, r, rp, chk)
    Duel.PayLPCost(tp, math.floor(Duel.GetLP(tp) / 2))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_REMOVED, 0, nil, e,
                                    tp)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and s.e2check(g)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_REMOVED)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if ft == 0 then return end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end

    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_REMOVED, 0, nil, e,
                                    tp)
    if #g < ft then ft = #g end
    g = Utility.GroupSelect({
        hintmsg = HINTMSG_SPSUMMON,
        g = g,
        tp = tp,
        max = ft,
        check = s.e2check
    })
    if #g == 0 then return end

    local fid = c:GetFieldID()
    for tc in aux.Next(g) do
        Duel.SpecialSummonStep(tc, 0, tp, tp, true, false, POS_FACEUP)
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, fid,
                              aux.Stringid(id, 1))
    end
    Duel.SpecialSummonComplete()
    g:KeepAlive()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetCountLimit(1)
    ec1:SetLabel(fid)
    ec1:SetLabelObject(g)
    ec1:SetCondition(s.e2rmcon)
    ec1:SetOperation(s.e2rmop)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2rmfilter(c, fid) return c:GetFlagEffectLabel(id) == fid end

function s.e2rmcon(e, tp, eg, ep, ev, re, r, rp)
    local g = e:GetLabelObject()
    if not g:IsExists(s.e2rmfilter, 1, nil, e:GetLabel()) then
        g:DeleteGroup()
        e:Reset()
        return false
    else
        return true
    end
end

function s.e2rmop(e, tp, eg, ep, ev, re, r, rp)
    local g = e:GetLabelObject()
    local tg = g:Filter(s.e2rmfilter, nil, e:GetLabel())
    Duel.Remove(tg, POS_FACEUP, REASON_EFFECT + REASON_REPLACE + REASON_RULE)
end
