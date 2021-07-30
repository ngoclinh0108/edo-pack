-- Forbidden Polymerization
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- fusion
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        extratg = s.e1extg,
        stage2 = s.e1stage2
    })
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1extg(e, tp, eg, ep, ev, re, r, rp, chk)
    if e:IsHasType(EFFECT_TYPE_ACTIVATE) then Duel.SetChainLimit(aux.FALSE) end
end

function s.e1stage2(e, tc, tp, sg, chk)
    local c = e:GetHandler()
    if chk == 0 and tc:GetMaterialCount()>=3 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3001)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        ec1:SetValue(1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1, true)
    end
end

function s.e2filter(c) return c:IsType(TYPE_SPELL) and c:IsDiscardable() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end
    Duel.DiscardHand(tp, s.e2filter, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end
