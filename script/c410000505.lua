-- Signer Overdrive
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {410000500}

function s.initial_effect(c)
    -- add to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(573)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE + PHASE_DRAW)
    e1:SetRange(LOCATION_DECK + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(function(e, tp) return Duel.IsEnvironment(410000500, tp) end)
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return e:GetHandler():IsAbleToHand() end
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsRelateToEffect(e) then return end
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end)
    c:RegisterEffect(e1)
end
