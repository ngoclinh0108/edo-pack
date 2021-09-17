-- Forbidden Art of Palladium
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    c:AddSetcodesRule(0x13a)

    -- activate
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
                   Duel.IsTurnPlayer(1 - tp)
    end)
    e0:SetTarget(Utility.MultiEffectTarget(s))
    e0:SetOperation(Utility.MultiEffectOperation(s))
    c:RegisterEffect(e0)

    -- ritual
    local e1 = Ritual.CreateProc({
        desc = 1171,
        handler = c,
        lvtype = RITPROC_GREATER,
        filter = aux.FilterBoolFunction(Card.IsSetCard, 0x13a),
        location = LOCATION_HAND + LOCATION_DECK
    })
    Utility.RegisterMultiEffect(s, 1, e1)

    -- ritual
    local e2 = Fusion.CreateSummonEff({
        desc = 1170,
        handler = c,
        extrafil = function(e, tp)
            local g = Duel.GetMatchingGroup(function(c)
                return c:IsAbleToGrave() and c:IsSetCard(0x13a)
            end, tp, LOCATION_DECK, 0, nil)
            local check = function(tp, sg, fc)
                return sg:IsExists(Card.IsSetCard, 1, nil, 0x13a) and
                           sg:FilterCount(Card.IsLocation, nil, LOCATION_DECK) <=
                           1
            end
            return g, check
        end
    })
    Utility.RegisterMultiEffect(s, 2, e2)

    -- to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(aux.exccon)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3filter(c) return c:IsType(TYPE_SPELL) and c:IsDiscardable() end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end

    Duel.DiscardHand(tp, s.e3filter, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoHand(c, nil, REASON_EFFECT)
end
