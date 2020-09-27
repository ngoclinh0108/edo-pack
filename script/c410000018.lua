-- Palladium Chaos Draco-Knight
local s, id = GetID()

s.listed_names = {5405694, 21082832}

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

    -- search dragon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot be target & indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(aux.tgoval)
    e2:SetCondition(s.e2con)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2b:SetValue(function(e, re, rp) return rp == 1 - e:GetHandlerPlayer() end)
    c:RegisterEffect(e2b)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCondition(aux.bdocon)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return c:IsAbleToHand() and c:IsLevelAbove(7) and
               c:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK) and
               c:IsRace(RACE_DRAGON)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        g = g:Select(tp, 1, 1, nil)
    end

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e2filter(c) return c:IsFaceup() and c:IsRace(RACE_DRAGON) end

function s.e2con(e, tp)
    local c = e:GetHandler()
    return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_MZONE, 0, 1, c)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
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

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
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
