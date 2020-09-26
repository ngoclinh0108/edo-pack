-- Forbidden Polymerization
local s, id = GetID()

function s.initial_effect(c)
    -- to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCondition(aux.exccon)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- fusion
    local e2 = Fusion.CreateSummonEff({
        handler = c,
        desc = aux.Stringid(id, 0),
        extrafil = s.e2exfilter,
        extraop = s.e2exop
    })
    c:RegisterEffect(e2)
    if not GhostBelleTable then GhostBelleTable = {} end
    table.insert(GhostBelleTable, e2)

    -- ritual
    local e3 = Ritual.CreateProc({
        handler = c,
        lvtype = RITPROC_GREATER,
        desc = aux.Stringid(id, 1),
        location = LOCATION_HAND + LOCATION_GRAVE,
    })
    c:RegisterEffect(e3)
end

function s.e1filter(c) return c:IsType(TYPE_SPELL) and c:IsDiscardable() end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end
    Duel.DiscardHand(tp, s.e1filter, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end

function s.e2exfilter(e, tp, mg)
    if not Duel.IsPlayerAffectedByEffect(tp, 69832741) then
        local eg = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp,
                                         LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
        if #eg > 0 then return eg end
    end
    return nil
end

function s.e2exop(e, tc, tp, sg)
    local rg = sg:Filter(Card.IsLocation, nil, LOCATION_GRAVE)
    if #rg > 0 then
        Duel.Remove(rg, POS_FACEUP,
                    REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
        sg:Sub(rg)
    end
end
