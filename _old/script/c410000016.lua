-- Palladium Oracle Faris
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(6368038)
    c:RegisterEffect(code)

    -- race
    local race = Effect.CreateEffect(c)
    race:SetType(EFFECT_TYPE_SINGLE)
    race:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    race:SetCode(EFFECT_ADD_RACE)
    race:SetValue(RACE_SPELLCASTER)
    c:RegisterEffect(race)

    -- summon with no tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetCode(EFFECT_SUMMON_COST)
    e1b:SetOperation(s.e1atkop)
    c:RegisterEffect(e1b)

    -- ritual material
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e2:SetCondition(function(e)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), 69832741)
    end)
    e2:SetValue(function(e, c) return c:IsSetCard(0x13a) end)
    c:RegisterEffect(e2)

    -- search tuner
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SEARCH + CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetCountLimit(1, id + 1000000)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3b)
    local e3c = e3:Clone()
    e3c:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3c)

    -- search spell/trap
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SEARCH + CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCountLimit(1, id + 2000000)
    e4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return
            (r & REASON_RITUAL + REASON_FUSION + REASON_SYNCHRO + REASON_LINK) ~=
                0
    end)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EVENT_TO_GRAVE)
    e4b:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:IsPreviousLocation(LOCATION_OVERLAY) and
                   c:IsReason(REASON_COST) and re:IsActivated() and
                   re:IsActiveType(TYPE_XYZ)

    end)
    c:RegisterEffect(e4b)
    local e4c = e4b:Clone()
    e4c:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e4c)
end

function s.e1con(e, c, minc)
    if c == nil then return true end
    return minc == 0 and c:GetLevel() > 4 and
               Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0
end

function s.e1atkcon(e) return e:GetHandler():GetMaterialCount() == 0 end

function s.e1atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCondition(s.e1atkcon)
    ec1:SetValue(1900)
    ec1:SetReset(RESET_EVENT + 0xff0000)
    c:RegisterEffect(ec1)
end

function s.e3filter(c, e, tp)
    return c:IsLevelBelow(4) and c:IsSetCard(0x13a) and c:IsType(TYPE_TUNER) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e3filter, tp, LOCATION_HAND +
                                          LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                      1, nil, e, tp)

    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end

function s.e4filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSetCard(0x13a) and
               c:IsAbleToHand()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e4filter, tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
