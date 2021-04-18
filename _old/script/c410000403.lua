-- Elemental HERO Space Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS}
s.listed_series = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        function(tc) return tc:IsLevelBelow(4) and tc:IsType(TYPE_EFFECT) end
    }, nil, function(g, tp, c)
        c:RegisterFlagEffect(id,
                             RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD +
                                 RESET_PHASE + PHASE_END,
                             EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
    end, true, false)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               (c:IsCode(CARD_NEOS) or c:IsSetCard(0x1f))
end

function s.e1check(g, e, tp) return g:GetClassCount(Card.GetCode) == #g end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToExtraAsCost() end
    Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_GRAVE + LOCATION_DECK
    local g = Duel.GetMatchingGroup(s.e1filter, tp, loc, 0, nil, e, tp)

    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsPlayerCanSpecialSummonCount(tp, 2) and
                   not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 1 and
                   aux.SelectUnselectGroup(g, e, tp, 2, 2, s.e1check, 0)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, loc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 then return end

    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e1filter), tp, loc,
                                    0, nil, e, tp)
    g = aux.SelectUnselectGroup(g, e, tp, 2, 2, s.e1check, 1, tp,
                                HINTMSG_SPSUMMON)
    if #g ~= 2 then return end

    for tc in aux.Next(g) do
        if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3206)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_CANNOT_ATTACK)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(ec1)
            local ec2 = ec1:Clone()
            ec2:SetDescription(3302)
            ec2:SetCode(EFFECT_CANNOT_TRIGGER)
            tc:RegisterEffect(ec2)
        end
    end
    Duel.SpecialSummonComplete()
end
