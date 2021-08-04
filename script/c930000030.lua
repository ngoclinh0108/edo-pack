-- Divine Nordic Relic Laevateinn
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {67098114}
s.listed_series = {0x4b}

function s.initial_effect(c)
    -- destroy
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMING_BATTLE_END + TIMING_END_PHASE)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    aux.GlobalCheck(s, function()
        local ge1 = Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_BATTLE_DESTROYING)
        ge1:SetOperation(s.e1regop1)
        Duel.RegisterEffect(ge1, 0)
        local ge2 = ge1:Clone()
        ge2:SetCode(EVENT_CHAINING)
        ge2:SetOperation(s.e1regop2)
        Duel.RegisterEffect(ge2, 0)
        local ge3 = ge1:Clone()
        ge3:SetCode(EVENT_CHAIN_NEGATED)
        ge3:SetOperation(s.e1regop3)
        Duel.RegisterEffect(ge3, 0)
    end)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id + 2000000)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsFaceup() and c:GetFlagEffect(id) ~= 0 end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp or
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsSetCard, 0x4b), tp,
                   LOCATION_MZONE, 0, 1, nil)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE,
                                LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    if e:IsHasType(EFFECT_TYPE_ACTIVATE) then Duel.SetChainLimit(aux.FALSE) end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
    Duel.Destroy(tc, REASON_EFFECT)
end

function s.e1regop1(e, tp, eg, ep, ev, re, r, rp)
    for tc in aux.Next(eg) do
        if tc:IsFaceup() and tc:IsRelateToBattle() then
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD +
                                      RESET_PHASE + PHASE_END, 0, 1)
        end
    end
end

function s.e1regop2(e, tp, eg, ep, ev, re, r, rp)
    re:GetHandler():RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD +
                                           RESET_PHASE + PHASE_END, 0, 1)
end

function s.e1regop3(e, tp, eg, ep, ev, re, r, rp)
    local rc = re:GetHandler()
    local ct = rc:GetFlagEffect(id)
    rc:ResetFlagEffect(id)
    for i = 1, ct - 1 do
        rc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, 0, 1)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return aux.exccon(e) and
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsCode, 67098114), tp,
                   LOCATION_MZONE, 0, 1, nil)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end
