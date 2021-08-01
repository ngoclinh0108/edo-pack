-- War for the Nordic Artifacts
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x5042}

function s.initial_effect(c)
    -- act in hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0, TIMING_END_PHASE)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsSetCard(0x4b)
    end, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.e2filter(c)
    return c:IsSetCard(0x5042) and c:IsType(TYPE_SPELL + TYPE_TRAP) and
               (c:IsAbleToHand() and c:IsSSetable(false))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_DECK, 0, 1,
                                       1, nil):GetFirst()
    if not tc then return end

    aux.ToHandOrElse(tc, tp, function(tc)
        return tc:IsSSetable(false) and
                   Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
    end, function(tc)
        Duel.SSet(tp, tc)

        local effect_code
        if tc:IsType(TYPE_TRAP) then
            effect_code = EFFECT_TRAP_ACT_IN_SET_TURN
        elseif tc:IsType(TYPE_QUICKPLAY) then
            effect_code = EFFECT_QP_ACT_IN_SET_TURN
        else
            return
        end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        ec1:SetCode(effect_code)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end, 1159)
end
