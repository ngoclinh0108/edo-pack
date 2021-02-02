-- Millennium Ascension
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10000040}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetCategory(CATEGORY_TOGRAVE)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetCost(s.actcost)
    c:RegisterEffect(act)

    -- startup
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_STARTUP)
    e0:SetRange(LOCATION_ALL)
    e0:SetOperation(s.e0op)
    c:RegisterEffect(e0)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetValue(function(e, te) return te:GetHandler() ~= e:GetHandler() end)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- extra summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e3)

    -- draw
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- shuffle deck
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.actcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsCode, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0,
                                           nil, 10000040)
    end

    local tc
    local g = Duel.GetMatchingGroup(Card.IsCode, tp,
                                    LOCATION_HAND + LOCATION_DECK, 0, nil,
                                    10000040)
    if #g > 0 then
        tc = g:GetFirst()
    else
        tc = g:Select(tp, 1, 1)
    end

    Duel.ConfirmCards(1 - tp, tc)
end

function s.e0op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local sc = Duel.GetFirstMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, nil,
                                         10000040)
    if not sc then return end

    aux.PlayFieldSpell(c, e, tp, eg, ep, ev, re, r, rp)
end

function s.e2filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSetCard(0x13a) and
               c:IsAbleToHand()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local dt = Duel.GetDrawCount(tp)
    if dt == 0 then return false end
    _replace_count = 1
    _replace_max = dt

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_DRAW_COUNT)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_DRAW)
    Duel.RegisterEffect(ec1, tp)
    if _replace_count > _replace_max then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e2filter), tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4filter(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsType(TYPE_MONSTER) and
               not c:IsPublic()
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.e4filter, tp, LOCATION_HAND, 0, 1,
                                      1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 2) end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)

    Duel.Draw(p, d, REASON_EFFECT)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.ShuffleDeck(tp)
    Duel.SortDecktop(tp, tp, 5)
end
