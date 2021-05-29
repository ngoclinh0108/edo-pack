-- Supreme King Dragon Oddwurm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {82768499}
s.listed_series = {0x99, 0x20f8}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id + 1 * 1000000)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- add extra deck & search
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCountLimit(1, id + 2 * 1000000)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    -- special summon other
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1, id + 3 * 1000000)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    if not Duel.GetFieldCard(tp, LOCATION_PZONE, 0) or
        not Duel.GetFieldCard(tp, LOCATION_PZONE, 1) then return false end

    local lsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 0):GetLeftScale()
    local rsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 1):GetRightScale()
    if lsc > rsc then lsc, rsc = rsc, lsc end
    local lv = c:GetLevel()
    return lsc < lv and lv < rsc
end

function s.e2filter1(c)
    return c:IsSetCard(0x99) and c:IsRace(RACE_DRAGON) and
               c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.e2filter2(c) return c:IsCode(82768499) and c:IsAbleToHand() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter1, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
    local g1 = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e2filter1),
                                       tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                       1, nil)
    local g2 = Duel.GetMatchingGroup(s.e2filter2, tp,
                                     LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g1 > 0 and Duel.SendtoExtraP(g1, tp, REASON_EFFECT) > 0 and #g2 > 0 and
        Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.BreakEffect()

        local sg = g2
        if #sg > 1 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            sg = g2:Select(tp, 1, 1, nil)
        end

        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end
end

function s.e3filter(c, e, tp)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    if c:IsLocation(LOCATION_EXTRA) and
        Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0 then return false end
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsSetCard(0x20f8) and not c:IsCode(id)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT + REASON_BATTLE) ~= 0
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_EXTRA
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        loc = loc + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    end
    if chk == 0 then
        return loc ~= 0 and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil,
                                               e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_EXTRA
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        loc = loc + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    end
    if loc == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e3filter), tp,
                                      loc, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
