-- Hervor of the Nordic Champions
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x42, 0x5042}

function s.initial_effect(c)
    -- to hand (negated)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_CHAIN_NEGATED)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand (grave)
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsSetCard(0x5042) and c:IsSSetable() end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local de, dp = Duel.GetChainInfo(ev, CHAININFO_DISABLE_REASON,
                                     CHAININFO_DISABLE_PLAYER)
    return de and dp ~= tp and rp == tp and re:GetHandler():IsSetCard(0x42)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if chk == 0 then return c:IsAbleToGrave() and rc:IsAbleToHand() end

    Duel.SetTargetCard(rc)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, rc, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if not c:IsRelateToEffect(e) or not rc:IsRelateToEffect(e) or
        Duel.SendtoGrave(c, REASON_EFFECT) == 0 or
        Duel.SendtoHand(rc, tp, REASON_EFFECT) == 0 then return end
    if not Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1, nil) or
        Duel.GetLocationCount(tp, LOCATION_SZONE) == 0 or
        not Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then return end

    local g = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_DECK, 0, 1,
                                      1, nil)
    if #g > 0 then Duel.SSet(tp, g) end
end

function s.e2filter(c) return c:IsFaceup() and c:IsSetCard(0x5042) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_ONFIELD, 0,
                                           1, nil) and c:IsAbleToHand()
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_ONFIELD, 0,
                                      1, 1, nil)
    if #g == 0 or Duel.Destroy(g, REASON_EFFECT) == 0 then return end

    if Duel.SendtoHand(c, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, c)
    end
end
