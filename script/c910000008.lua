-- Palladium Guardian Shada
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon & draw
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- battle indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetValue(function(e, re, r, rp) return (r & REASON_BATTLE) ~= 0 end)
    c:RegisterEffect(e2)

    -- send monster to the GY
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    if ph ~= PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end

    local tc = Duel.GetAttacker()
    if tc:IsControler(1 - tp) then tc = Duel.GetAttackTarget() end
    return tc and tc:IsSetCard(0x13a) and tc:IsRelateToBattle() and
               Duel.GetAttackTarget() ~= nil
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) ==
        0 then return end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end

function s.e3filter1(c, tp)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and
               Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_DECK, 0, 1,
                                           nil, c)
end

function s.e3filter2(c, sc)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x13a) and
               not c:IsRace(sc:GetRace()) and c:IsAbleToGrave()
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_HAND, 0, 1,
                                           nil, tp)
    end

    Duel.DiscardHand(tp, s.e3filter1, 1, 1, REASON_COST + REASON_DISCARD, nil,
                     tp)
    e:SetLabelObject(Duel.GetOperatedGroup():GetFirst())
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local tc = Duel.SelectMatchingCard(tp, s.e3filter2, tp, LOCATION_DECK, 0, 1,
                                       1, nil, e:GetLabelObject()):GetFirst()
    if not tc then return end

    if Duel.SendtoGrave(tc, REASON_EFFECT) ~= 0 and
        tc:IsLocation(LOCATION_GRAVE) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 1))
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        ec1:SetTargetRange(1, 0)
        ec1:SetLabel(tc:GetCode())
        ec1:SetTarget(function(e, c) return c:IsCode(e:GetLabel()) end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end
