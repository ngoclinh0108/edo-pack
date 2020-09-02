-- Millennium Ascension
local s, id = GetID()

s.listed_names = {10000040}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetCategory(CATEGORY_TOGRAVE)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
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
    e1:SetValue(function(e, te)
        return te:GetOwnerPlayer() ~= e:GetOwnerPlayer()
    end)
    c:RegisterEffect(e1)

    -- summon protect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x13a))
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e2c)

    -- spell/trap protect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_INACTIVATE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e3b)

    -- search
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PREDRAW)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- extra summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e5:SetTarget(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e5)

    -- shuffle deck
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCountLimit(1, id)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)

    -- return banish
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 2))
    e7:SetCategory(CATEGORY_TOGRAVE)
    e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_PHASE + PHASE_END)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCountLimit(1)
    e7:SetTarget(s.e7tg)
    e7:SetOperation(s.e7op)
    c:RegisterEffect(e7)
end

function s.e0op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local sc = Duel.GetFirstMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, nil,
                                         10000040)
    if not sc then return end

    Duel.Hint(HINT_CARD, tp, id)
    Duel.ConfirmCards(1 - tp, sc)

    aux.PlayFieldSpell(c, e, tp, eg, ep, ev, re, r, rp)
end

function s.e3val(e, ct)
    local p = e:GetHandler():GetControler()
    local te, tp = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT,
                                     CHAININFO_TRIGGERING_PLAYER)
    return p == tp and te:IsActiveType(TYPE_SPELL + TYPE_TRAP) and
               te:GetHandler():IsSetCard(0x13a)
end

function s.e4filter(c) return c:IsSetCard(0x13a) and c:IsAbleToHand() end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0
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
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e4filter), tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 end
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.ShuffleDeck(tp)
    Duel.SortDecktop(tp, tp, 5)
end

function s.e7tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, LOCATION_REMOVED, 0,
                                    nil)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
end

function s.e7op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(nil, tp, LOCATION_REMOVED, 0, nil)
    Duel.SendtoGrave(g, REASON_EFFECT)
end
