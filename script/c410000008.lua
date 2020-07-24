-- Ra's Apostle
local s, id = GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- token
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and not c:IsPublic()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_HAND, 0, 1,
                                      1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp, 410000000, 0x54b,
                                                        TYPES_TOKEN, 1500, 1500,
                                                        4, RACE_SPELLCASTER,
                                                        ATTRIBUTE_FIRE)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 2, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 or
        not Duel.IsPlayerCanSpecialSummonMonster(tp, 410000000, 0x54b,
                                                 TYPES_TOKEN, 1500, 1500, 4,
                                                 RACE_SPELLCASTER,
                                                 ATTRIBUTE_FIRE) then return end

    for i = 1, 2 do
        local token = Duel.CreateToken(tp, 410000000)
        Duel.SpecialSummonStep(token, 0, tp, tp, false, false,
                               POS_FACEUP_DEFENSE)
    end
    Duel.SpecialSummonComplete()
end
