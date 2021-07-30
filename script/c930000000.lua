-- Asgard the Aesir Realm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- immune
    local e1 = Effect.CreateEffect(tc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCondition(s.e1con)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    
    -- cannot be target
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_GRAVE, 0)
    e3:SetTarget(function(e, c) return c:IsSetCard(0x4b) end)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    -- cannot banish
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_REMOVE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_ONFIELD + LOCATION_GRAVE, 0)
    e4:SetTarget(function(e, c) return c:IsSetCard(0x4b) end)
    c:RegisterEffect(e4)
end

function s.e1con(e)
    local tp = e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,
                                                                0x4b), tp,
                                       LOCATION_MZONE, 0, 1, nil)
end

function s.e1val(e, re) return e:GetOwnerPlayer() == 1 - re:GetOwnerPlayer() end

function s.e2filter2(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0 and
               not Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsSetCard, 0x4b), tp,
                   LOCATION_MZONE, 0, 1, nil)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
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
    if _replace_count > _replace_max or not c:IsRelateToEffect(e) then return end

    local g =
        Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_DECK, 0, nil):RandomSelect(
            tp, 1)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
