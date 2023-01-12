-- Evil HERO Cosmos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0x8}

function s.initial_effect(c)
    -- special summon itself
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special Summon "evil HERO" fusion monster
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMING_MAIN_END + TIMINGS_CHECK_MONSTER)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, tp)
    return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION + TYPE_LINK) and c:IsAbleToRemoveAsCost() and
               (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 or c:GetSequence() < 5)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = e:GetHandlerPlayer()
    local eff = {c:GetCardEffect(EFFECT_NECRO_VALLEY)}
    for _, te in ipairs(eff) do
        local op = te:GetOperation()
        if not op or op(e, c) then return false end
    end

    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_MZONE, 0, nil, tp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    return ft > -1 and #rg > 0 and aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local g = nil
    local rg = Duel.GetMatchingGroup(s.s1filter, tp, LOCATION_MZONE, 0, nil, tp)
    local g = aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 1, tp, HINTMSG_REMOVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.Remove(g, POS_FACEUP, REASON_COST)
    g:DeleteGroup()
end

function s.e2filter1(c) return c:IsSetCard(0x8) end

function s.e2filter2(c, e, tp, chk)
    return c:IsType(TYPE_FUSION) and c.min_material_count == 2 and c.max_material_count == 2 and c.dark_calling and
               (not chk or Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, true, false)
end

function s.e2excheck(sg, tp, exg, ssg, c)
    return ssg:IsExists(function(c, sg, tp, oc)
        local sg = sg + oc
        return Duel.GetLocationCountFromEx(tp, tp, sg, c) > 0
    end, 1, nil, sg, tp, c)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() ~= tp end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mg = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_EXTRA, 0, nil, e, tp)
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, s.e2filter1, 1, false, s.e2excheck, c, mg, c) end

    local g = Duel.SelectReleaseGroupCost(tp, s.e2filter1, 1, 1, false, s.e2excheck, c, mg, c)
    g:AddCard(c)
    Duel.Release(g, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e2filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, true):GetFirst()
    if tc and Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, true, false, POS_FACEUP) > 0 then tc:CompleteProcedure() end
end
