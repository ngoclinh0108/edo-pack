-- Palladium Apostle of Ra
local s, id = GetID()

function s.initial_effect(c)
    -- 3 tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e1:SetValue(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e1)

    -- recover
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_RELEASE)
    e2:SetCountLimit(1, id + 1000000)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- quick recover
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 2000000)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_SUMMON)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 2000)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Recover(tp, 2000, REASON_EFFECT)
end

function s.e3filter(c)
    return c:IsFaceup() and c:IsOriginalAttribute(ATTRIBUTE_DIVINE) and
               c:GetAttack() > 0
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   Duel.CheckReleaseGroupCost(tp, s.e3filter, 1, false, nil, nil)
    end

    local tc =
        Duel.SelectReleaseGroupCost(tp, s.e3filter, 1, 1, false, nil, nil):GetFirst()
    local rec = tc:GetAttack()
    Duel.Release(tc, REASON_COST)

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(rec)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, rec)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Recover(p, d, REASON_EFFECT)

    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 or
        not c:IsRelateToEffect(e) then return end
    Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP_DEFENSE)
end