-- Palladium Knight of Atlantis
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- race
    local race = Effect.CreateEffect(c)
    race:SetType(EFFECT_TYPE_SINGLE)
    race:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    race:SetCode(EFFECT_ADD_RACE)
    race:SetValue(RACE_DRAGON)
    c:RegisterEffect(race)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- send grave
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- search monster
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_END_PHASE)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- search spell/trap
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(0, TIMING_END_PHASE)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c, tp)
    if c:GetPreviousCodeOnField() == id then return false end
    return
        c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and
            c:IsPreviousPosition(POS_FACEUP) and not c:IsReason(REASON_RULE) and
            (c:GetPreviousRaceOnField() == RACE_DRAGON or
                c:GetPreviousRaceOnField() == RACE_WARRIOR)
end

function s.e1filter(c)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsRace(RACE_DRAGON + RACE_WARRIOR) and c:IsAbleToDeckAsCost()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_GRAVE + LOCATION_EXTRA, 0,
                                           1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.e1filter, tp,
                                      LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 1,
                                      nil)

    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e2filter(c) return c:IsAbleToGrave() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp,
                                      LOCATION_HAND + LOCATION_DECK, 0, 1, 1,
                                      nil)

    if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
end

function s.e3check1(c)
    return not c:IsLocation(LOCATION_HAND) and c:IsAbleToHand()
end

function s.e3check2(c, e, tp, mc)
    if not c:IsCanBeSpecialSummoned(e, 0, tp, false, false) or
        (c:IsLocation(LOCATION_EXTRA) and c:IsFacedown()) then return false end

    if (c:IsLocation(LOCATION_EXTRA)) then
        return Duel.GetLocationCountFromEx(tp, tp, mc, c) > 0
    else
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end
end

function s.e3filter(c, e, tp, mc)
    return c:IsLevel(7, 8) and c:IsRace(RACE_DRAGON + RACE_WARRIOR) and
               (s.e3check1(c) or s.e3check2(c, e, tp, mc))
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(), REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_HAND + LOCATION_PZONE +
                                               LOCATION_DECK + LOCATION_GRAVE +
                                               LOCATION_EXTRA, 0, 1, nil, e, tp,
                                           e:GetHandler())
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e3filter), tp,
                                    LOCATION_HAND + LOCATION_PZONE +
                                        LOCATION_DECK + LOCATION_GRAVE +
                                        LOCATION_EXTRA, 0, nil, e, tp, c)
    if #g == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local sc = g:Select(tp, 1, 1, nil):GetFirst()

    local b1 = s.e3check1(sc)
    local b2 = s.e3check2(sc, e, tp, c)
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, 573, 5)
    elseif b1 then
        op = Duel.SelectOption(tp, 573)
    else
        op = Duel.SelectOption(tp, 5) + 1
    end

    if op == 0 then
        Duel.SendtoHand(sc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sc)
    else
        Duel.SpecialSummon(sc, 0, tp, tp, false, false, POS_FACEUP)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_CANNOT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        sc:RegisterEffect(ec1)
    end
end

function s.e4filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(), REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_GRAVE, 0, 1,
                                           nil)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e4filter),
                                       tp, LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    if not tc then return end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)

    if tc:IsLocation(LOCATION_HAND) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_CANNOT_ACTIVATE)
        ec1:SetTargetRange(1, 0)
        ec1:SetValue(s.e4aclimit)
        ec1:SetLabelObject(tc)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e4aclimit(e, re, tp)
    local tc = e:GetLabelObject()
    return re:GetHandler():IsCode(tc:GetCode())
end
