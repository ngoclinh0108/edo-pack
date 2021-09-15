-- Forbidden Art of Palladium
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    c:AddSetcodesRule(0x13a)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    s.eff = {}
    s.eff[1] = Ritual.CreateProc({
        desc = 1171,
        handler = c,
        lvtype = RITPROC_GREATER,
        filter = aux.FilterBoolFunction(Card.IsSetCard, 0x13a),
        location = LOCATION_HAND + LOCATION_DECK
    })
    s.eff[2] = Fusion.CreateSummonEff({
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

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(aux.exccon)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
               Duel.IsTurnPlayer(1 - tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        for i = 1, #s.eff, 1 do
            if not s.eff[i]:GetTarget() or
                s.eff[i]:GetTarget()(e, tp, eg, ep, ev, re, r, rp, chk) then
                return true
            end
        end
        return false
    end

    local opt = {}
    local sel = {}
    for i = 1, #s.eff, 1 do
        if not s.eff[i]:GetTarget() or
            s.eff[i]:GetTarget()(e, tp, eg, ep, ev, re, r, rp, 0) then
            table.insert(opt, s.eff[i]:GetDescription())
            table.insert(sel, i)
        end
    end

    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    e:SetLabel(op)
    e:SetCategory(s.eff[op]:GetCategory())
    s.eff[op]:GetTarget()(e, tp, eg, ep, ev, re, r, rp, chk)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    s.eff[e:GetLabel()]:GetOperation()(e, tp, eg, ep, ev, re, r, rp)
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
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoHand(c, nil, REASON_EFFECT)
end
