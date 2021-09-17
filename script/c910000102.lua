-- Palladium Fusion Control
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:AddSetcodesRule(0x13a)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- prevent fusion negation
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter1(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end

function s.e1filter2(c, e, tp, fc, mg)
    return c:IsControler(tp) and (c:GetReason() & 0x40008) == 0x40008 and
               c:GetReasonCard() == fc and
               fc:CheckFusionMaterial(mg, c, PLAYER_NONE | FUSPROC_NOTFUSION) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsLocation(
                   LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE +
                       LOCATION_REMOVED)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter1, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e1filter1, tp, LOCATION_MZONE,
                                LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    local sumtype = tc:GetSummonType()
    local mg = tc:GetMaterial()
    if Duel.SendtoDeck(tc, nil, 0, REASON_EFFECT) == 0 then return end

    mg = mg:Filter(aux.NecroValleyFilter(s.e1filter2), nil, e, tp, tc, mg)
    if #mg == 0 then return end

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if ft == 0 then return end
    if ft > #mg then ft = #mg end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end

    if (sumtype & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION and
        Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.BreakEffect()

        local g = Utility.GroupSelect(HINTMSG_SPSUMMON, mg, tp, 1, ft, nil)
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST + REASON_DISCARD)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_INACTIVATE)
    ec1:SetValue(function(e, ct)
        local p = e:GetHandlerPlayer()
        local te, tp = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT,
                                         CHAININFO_TRIGGERING_PLAYER)
        return p == tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_SPSUMMON_SUCCESS)
    ec2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return eg:IsExists(function(c, tp)
            return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
        end, 1, nil, tp)
    end)
    ec2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if Duel.GetCurrentChain() == 0 then
            Duel.SetChainLimitTillChainEnd(function(e, rp, tp)
                return tp == rp
            end)
        elseif Duel.GetCurrentChain() == 1 then
            c:RegisterFlagEffect(id,
                                 RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                     PHASE_END, 0, 1)
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            ec1:SetCode(EVENT_CHAINING)
            ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                e:GetHandler():ResetFlagEffect(id)
                e:Reset()
            end)
            Duel.RegisterEffect(ec1, tp)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EVENT_BREAK_EFFECT)
            ec1b:SetReset(RESET_CHAIN)
            Duel.RegisterEffect(ec1b, tp)
        end
    end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)

    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec3:SetCode(EVENT_CHAIN_END)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:GetFlagEffect(id) ~= 0 then
            Duel.SetChainLimitTillChainEnd(function(e, rp, tp)
                return tp == rp
            end)
        end
        c:ResetFlagEffect(id)
    end)
    ec3:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec3, tp)
end

