-- Hyper Polymerization
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local e1 = Fusion.CreateSummonEff(c, nil, nil, s.e1matfilter, s.e1op)
    local e1tg = e1:GetTarget()
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return e1tg(e, tp, eg, ep, ev, re, r, rp, chk) end
        e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
        if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
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

function s.e1matfilter(e, tp, mg)
    if not Duel.IsPlayerAffectedByEffect(tp, 69832741) then
        local eg = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp,
                                         LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
        if #eg > 0 then return eg end
    end
    return nil
end

function s.e1op(e, tc, tp, sg)
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
    if chk == 0 then return e:GetOwner():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetOwner(), 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    if not c:IsRelateToEffect(e) then return end

    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end
