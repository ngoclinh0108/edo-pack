-- Lost Memories Tablet
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 83764718, 71703785}
s.listed_series = {0x13a}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetHintTiming(0, TIMING_END_PHASE)
    act:SetOperation(s.e2op)
    c:RegisterEffect(act)

    -- can be activated during the turn it was Set
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e1:SetCondition(function(e)
        return not Duel.IsExistingMatchingCard(Card.IsFacedown,
                                               e:GetHandlerPlayer(),
                                               LOCATION_ONFIELD, 0, 1,
                                               e:GetHandler())
    end)
    c:RegisterEffect(e1)

    -- allow summon ra via monster reborn
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(41044418)
    e2:SetTargetRange(1, 0)
    c:RegisterEffect(e2)
    aux.GlobalCheck(s, function()
        local e2reg = Effect.CreateEffect(c)
        e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2reg:SetCode(EVENT_SPSUMMON_SUCCESS)
        e2reg:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local g = eg:Filter(function(c, tp, re)
                return c:IsFaceup() and c:IsOriginalCode(CARD_RA) and
                           c:IsControler(tp) and re and
                           c:IsSummonType(
                               SUMMON_TYPE_SPECIAL + SUMMON_WITH_MONSTER_REBORN)
            end, nil, tp, re)
            if not g or #g == 0 then return end

            for tc in aux.Next(g) do
                tc:RegisterFlagEffect(41044418, RESET_EVENT + RESETS_STANDARD +
                                          RESET_PHASE + PHASE_END,
                                      EFFECT_FLAG_CLIENT_HINT, 1, 0,
                                      aux.Stringid(41044418, 3))
            end
        end)
        Duel.RegisterEffect(e2reg, 0)

        local e2togy = Effect.CreateEffect(c)
        e2togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2togy:SetCode(EVENT_PHASE + PHASE_END)
        e2togy:SetCountLimit(1)
        e2togy:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            return Duel.IsExistingMatchingCard(function(c)
                return
                    c:IsOriginalCode(CARD_RA) and c:GetFlagEffect(41044418) ~= 0
            end, tp, LOCATION_MZONE, 0, 1, nil)
        end)
        e2togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local g = Duel.GetMatchingGroup(function(c)
                return
                    c:IsOriginalCode(CARD_RA) and c:GetFlagEffect(41044418) ~= 0
            end, tp, LOCATION_MZONE, 0, nil)
            if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
        end)
        Duel.RegisterEffect(e2togy, 0)
    end)

    -- cannot disable summon
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(1, 0)
    e3:SetTarget(function(e, c) return c:IsSetCard(0x13a) end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    c:RegisterEffect(e3b)
    local e3c = e3:Clone()
    e3c:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e3c)

    -- destroy when leaving
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- special summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetHintTiming(0, TIMING_END_PHASE)
    e5:SetCountLimit(1, id)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- search card specifically lists
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 2))
    e6:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_SZONE)
    e6:SetHintTiming(0, TIMING_END_PHASE)
    e6:SetCountLimit(1, id)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)

    -- search divine
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 3))
    e7:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetRange(LOCATION_SZONE)
    e7:SetHintTiming(0, TIMING_END_PHASE)
    e7:SetCountLimit(1, id)
    e7:SetTarget(s.e7tg)
    e7:SetOperation(s.e7op)
    c:RegisterEffect(e7)

    -- search monster reborn
    local e8 = Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id, 4))
    e8:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e8:SetType(EFFECT_TYPE_QUICK_O)
    e8:SetCode(EVENT_FREE_CHAIN)
    e8:SetRange(LOCATION_SZONE)
    e8:SetHintTiming(0, TIMING_END_PHASE)
    e8:SetCountLimit(1, id)
    e8:SetCost(s.e8cost)
    e8:SetTarget(s.e8tg)
    e8:SetOperation(s.e8op)
    c:RegisterEffect(e8)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousPosition(POS_FACEUP) and
               not e:GetHandler():IsLocation(LOCATION_DECK)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e5filter(c, e, tp)
    return c:IsCode(71703785) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e5filter, tp,
                                           LOCATION_HAND + LOCATION_GRAVE, 0, 1,
                                           nil, e, tp) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_GRAVE)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp,
                                         aux.NecroValleyFilter(s.e5filter), tp,
                                         LOCATION_HAND + LOCATION_GRAVE, 0, 1,
                                         1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e6filter(c)
    return not c:IsCode(id) and aux.IsCodeListed(c, 71703785) and
               c:IsAbleToHand()
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e6filter, tp,
                                         LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e7filter(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsType(TYPE_MONSTER) and
               c:IsAbleToHand()
end

function s.e7tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e7filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e7op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp,
                                         aux.NecroValleyFilter(s.e7filter), tp,
                                         LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                         1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e8filter1(c) return c:IsRace(RACE_DIVINE) and c:IsAbleToGraveAsCost() end

function s.e8filter2(c) return c:IsCode(83764718) and c:IsAbleToHand() end

function s.e8cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e8filter1, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end

    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e8filter1, tp,
                                         LOCATION_HAND, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.e8tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e8filter2, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e8op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp,
                                         aux.NecroValleyFilter(s.e8filter2), tp,
                                         LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                         1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
