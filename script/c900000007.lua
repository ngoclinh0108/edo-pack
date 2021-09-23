-- The Wicked Eraser
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 1, true, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    Divine.RegisterEffect(c, splimit)

    -- return
    local spreturn = Effect.CreateEffect(c)
    spreturn:SetDescription(0)
    spreturn:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    spreturn:SetRange(LOCATION_MZONE)
    spreturn:SetCode(EVENT_PHASE + PHASE_END)
    spreturn:SetCountLimit(1)
    spreturn:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsSummonType(SUMMON_TYPE_SPECIAL) then return false end
        return (c:IsPreviousLocation(LOCATION_HAND) and c:IsAbleToHand()) or
                   (c:IsPreviousLocation(LOCATION_DECK + LOCATION_EXTRA) and
                       c:IsAbleToDeck()) or
                   (c:IsPreviousLocation(LOCATION_GRAVE) and c:IsAbleToGrave()) or
                   (c:IsPreviousLocation(LOCATION_REMOVED) and
                       c:IsAbleToRemove())
    end)
    spreturn:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsPreviousLocation(LOCATION_HAND) then
            Duel.SendtoHand(c, nil, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_DECK) then
            Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_GRAVE) then
            Duel.SendtoGrave(c, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_REMOVED) then
            Duel.Remove(c, c:GetPreviousPosition(), REASON_EFFECT)
        end
    end)
    Divine.RegisterEffect(c, spreturn)
    
    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetValue(ATTRIBUTE_DARK)
    Divine.RegisterEffect(c, e1)

    -- atk/def
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_SET_BASE_ATTACK)
    e2:SetValue(s.e2val)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_SET_BASE_DEFENSE)
    Divine.RegisterEffect(c, e2b)

    -- to grave
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DISABLE + CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    Divine.RegisterEffect(c, e3)
end

function s.e2val(e, c)
    local tp = c:GetControler()
    return Duel.GetFieldGroupCount(tp, 0, LOCATION_ONFIELD) * 1000 *
               Divine.GetDivineHierarchy(c)
end

function s.e3con(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ex = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, Card.IsFaceup,
                                          tp, LOCATION_MZONE, 0, 1, 1, nil)

    local ng = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_ONFIELD,
                                     LOCATION_ONFIELD, ex)
    for tc in aux.Next(ng) do
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_DISABLE_EFFECT)
        ec2:SetValue(RESET_TURN_SET)
        tc:RegisterEffect(ec2)
        if tc:IsType(TYPE_TRAPMONSTER) then
            local ec3 = ec1:Clone()
            ec3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            tc:RegisterEffect(ec3)
        end
        Duel.AdjustInstantly(tc)
    end

    local dg = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ONFIELD,
                                     LOCATION_ONFIELD, ex)
    Duel.SendtoGrave(dg, REASON_EFFECT)
end
