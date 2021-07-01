-- Supreme King Dragon Grimwurm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x10f8, 0x20f8}

function s.initial_effect(c)
    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- add to your hand
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 1))
    me1:SetCategory(CATEGORY_TOHAND)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    me1:SetCode(EVENT_SUMMON_SUCCESS)
    me1:SetCountLimit(1, id + 1 * 1000000)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)
    local me1b = me1:Clone()
    me1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(me1b)

    -- special summon
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(2)
    me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_IGNITION)
    me2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    me2:SetRange(LOCATION_HAND + LOCATION_GRAVE + LOCATION_EXTRA)
    me2:SetCountLimit(1, id + 2 * 1000000)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
end

function s.me1filter(c)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return ((c:IsSetCard(0x10f8) and c:IsType(TYPE_PENDULUM)) or
               (c:IsSetCard(0x20f8) and c:IsType(TYPE_MONSTER))) and
               c:IsAbleToHand()
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.me1filter, tp, LOCATION_DECK +
                                               LOCATION_GRAVE + LOCATION_EXTRA,
                                           0, 1, nil)
    end
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.me1filter, tp, LOCATION_DECK +
                                          LOCATION_GRAVE + LOCATION_EXTRA, 0, 1,
                                      1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        if (not c:IsLocation(LOCATION_EXTRA) and
            Duel.GetLocationCount(tp, LOCATION_MZONE) == 0) or
            (c:IsLocation(LOCATION_EXTRA) and
                Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0) then
            return false
        end

        return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_PZONE, 0, 1,
                                     nil) and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_PZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or
        Duel.Destroy(tc, REASON_EFFECT) == 0 then return end

    if (not c:IsLocation(LOCATION_EXTRA) and
        Duel.GetLocationCount(tp, LOCATION_MZONE) == 0) or
        (c:IsLocation(LOCATION_EXTRA) and
            Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0) then
        return false
    end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end
