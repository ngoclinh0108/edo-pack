-- Ritual Fusion Gate
local s, id = GetID()

function s.initial_effect(c)
    -- fusion
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        desc = aux.Stringid(id, 0),
        extrafil = s.e1exfilter,
        p = s.e1exop
    })
    c:RegisterEffect(e1)
    if not GhostBelleTable then GhostBelleTable = {} end
    table.insert(GhostBelleTable, e1)

    -- ritual
    local e2 = Ritual.CreateProc({
        handler = c,
        lvtype = RITPROC_GREATER,
        desc = aux.Stringid(id, 1),
        extrafil = s.e2exfilter,
        p = s.e2exop
    })
    c:RegisterEffect(e2)

    -- to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(aux.exccon)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
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

function s.e2exfilter(e, tp, eg, ep, ev, re, r, rp, chk)
    return Duel.GetMatchingGroup(function(c)
        return c:HasLevel() and c:IsAbleToRemove()
    end, tp, LOCATION_GRAVE, 0, nil)
end

function s.e2exop(mg, e, tp, eg, ep, ev, re, r, rp)
    local mat2 = mg:Filter(Card.IsLocation, nil, LOCATION_GRAVE)
    mg:Sub(mat2)
    Duel.ReleaseRitualMaterial(mg)
    Duel.Remove(mat2, POS_FACEUP,
                REASON_EFFECT + REASON_MATERIAL + REASON_RITUAL)
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
    if chk == 0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end
