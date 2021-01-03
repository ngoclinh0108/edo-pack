-- Forbidden Polymerization
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- fusion
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        extrafil = s.e1exfilter,
        extraop = s.e1exop
    })
    e1:SetCost(s.e1cost)
    local e1tg = e1:GetTarget()
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return e1tg(e, tp, eg, ep, ev, re, r, rp, chk) end
        e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
        if e:IsHasType(EFFECT_TYPE_ACTIVATE) and e1:GetLabel() ~= 0 then
            Duel.SetChainLimit(aux.FALSE)
        end
    end)
    c:RegisterEffect(e1)
    if not GhostBelleTable then GhostBelleTable = {} end
    table.insert(GhostBelleTable, e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(aux.exccon)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return true end

    e:SetLabel(0)
    if Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1,
                                   c) and
        Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1,
                         REASON_COST + REASON_DISCARD)
        e:SetLabel(1)
    end
end

function s.e1exfilter(e, tp, mg)
    if not Duel.IsPlayerAffectedByEffect(tp, 69832741) then
        local eg = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp,
                                         LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
        if #eg > 0 then return eg end
    end
    return nil
end

function s.e1exop(e, tc, tp, sg)
    local rg = sg:Filter(Card.IsLocation, nil, LOCATION_GRAVE)
    if #rg > 0 then
        Duel.Remove(rg, POS_FACEUP,
                    REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
        sg:Sub(rg)
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
