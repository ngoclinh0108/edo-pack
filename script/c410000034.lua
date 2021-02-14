-- Timaeus the Palladium Destiny Draco-Knight
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xa0}
s.listed_series = {0xa0}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunction(Card.IsSetCard, 0xa0), 3, 3,
                      s.lnkcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.lnklimit)
    c:RegisterEffect(splimit)

    -- race
    local race = Effect.CreateEffect(c)
    race:SetType(EFFECT_TYPE_SINGLE)
    race:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    race:SetCode(EFFECT_ADD_RACE)
    race:SetValue(RACE_DRAGON)
    c:RegisterEffect(race)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e)
        return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
    end)
    e1:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    c:RegisterEffect(e1)

    -- indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(function(e, c)
        return c:GetAttack() == e:GetHandler():GetAttack()
    end)
    c:RegisterEffect(e2)

    -- atk 
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- summon the knights
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON + CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_BATTLE_DESTROYED)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.lnkcheck(g, lnkc) return g:GetClassCount(Card.GetCode) == #g end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c == Duel.GetAttacker() or c == Duel.GetAttackTarget()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE,
                                        LOCATION_MZONE, c)
        if #g == 0 then return false end

        local _, atk = g:GetMaxGroup(Card.GetAttack)
        return c:GetAttack() ~= atk and c:GetFlagEffect(id) == 0
    end

    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE,
                                    LOCATION_MZONE, c)
    if #g == 0 then return end

    local _, atk = g:GetMaxGroup(Card.GetAttack)
    if not c:IsRelateToEffect(e) or c:GetAttack() == atk then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
end

function s.e4filter(c, e, tp)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsSetCard(0xa0) and not c:IsCode(53315891) and c:IsAbleToHand() and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, true)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE

    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) >= 3 and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, loc, 0, 3, nil,
                                               e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 3, tp, loc)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 3, tp, loc)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 0, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 3 then return end

    local c = e:GetHandler()
    local loc = LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e4filter), tp, loc,
                                    0, nil, e, tp)
    if #g ~= 3 or Duel.SendtoHand(g, tp, REASON_EFFECT) ~= #g then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    if Duel.SpecialSummon(g, 0, tp, tp, true, true, POS_FACEUP) ~= 0 then
        Duel.SendtoDeck(c, tp, 2, REASON_EFFECT)
    end
end
