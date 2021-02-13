-- Palladium Chaos Soldier - Envoy of the Nightfall
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {410000016}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(5405694)
    c:RegisterEffect(code)

    -- attribute
    local attribute = Effect.CreateEffect(c)
    attribute:SetType(EFFECT_TYPE_SINGLE)
    attribute:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- battle destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdocon)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               not c:IsType(TYPE_RITUAL) and c:IsLevelBelow(8) and
               c:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK) and
               c:IsRace(RACE_WARRIOR)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT + REASON_BATTLE) ~= 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e1filter), tp,
                                      LOCATION_HAND + LOCATION_DECK +
                                          LOCATION_GRAVE, 0, 1, 1, nil, e, tp)

    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local b1 = true
    local b2 = true
    local b3 = Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0,
                                           LOCATION_ONFIELD, 1, nil)
    local b4 = Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0,
                                           LOCATION_HAND, 1, nil, POS_FACEDOWN)

    local opt = {}
    local sel = {}
    if b1 then
        table.insert(opt, aux.Stringid(id, 0))
        table.insert(sel, 1)
    end
    if b2 then
        table.insert(opt, aux.Stringid(id, 1))
        table.insert(sel, 2)
    end
    if b3 then
        table.insert(opt, aux.Stringid(id, 2))
        table.insert(sel, 3)
    end
    if b4 then
        table.insert(opt, aux.Stringid(id, 3))
        table.insert(sel, 4)
    end

    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    e:SetCategory(0)
    if op == 3 then
        e:SetCategory(CATEGORY_REMOVE)
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0,
                                        LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, tp, 0)
    elseif op == 4 then
        e:SetCategory(CATEGORY_REMOVE)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 1 - tp, LOCATION_HAND)
    end
    e:SetLabel(op)
    Duel.Hint(HINT_OPSELECTED, 1 - tp, aux.Stringid(id, op))
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = e:GetLabel()

    if op == 1 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1500)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
    elseif op == 2 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_EXTRA_ATTACK)
        ec1:SetValue(1)
        ec1:SetLabel(Duel.GetTurnCount())
        ec1:SetCondition(function(e, tp)
            return Duel.GetTurnCount() > e:GetLabel()
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END +
                         RESET_SELF_TURN, 2)
        c:RegisterEffect(ec1)
    elseif op == 3 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local g = Duel.SelectMatchingCard(tp, Card.IsAbleToRemove, tp, 0,
                                          LOCATION_ONFIELD, 1, 1, nil)
        if #g > 0 then Duel.Remove(g, POS_FACEUP, REASON_EFFECT) end
    elseif op == 4 then
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0,
                                        LOCATION_HAND, nil, tp, POS_FACEDOWN)
        if #g > 0 then
            local rg = g:RandomSelect(tp, 1)
            Duel.Remove(rg, POS_FACEDOWN, REASON_EFFECT)
        end
    end
end
