-- Palladium Apostle of Obelisk
local s, id = GetID()

function s.initial_effect(c)
    -- 3 tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e1:SetValue(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e1)

    -- token
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_RELEASE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- extra material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    e3:SetTargetRange(0, LOCATION_MZONE)
    e3:SetValue(POS_FACEUP)
    local e3reg = Effect.CreateEffect(c)
    e3reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e3reg:SetRange(LOCATION_GRAVE)
    e3reg:SetTargetRange(LOCATION_HAND, 0)
    e3reg:SetTarget(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    e3reg:SetLabelObject(e3)
    c:RegisterEffect(e3reg)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_SUMMON) and
               re:GetHandler():IsAttribute(ATTRIBUTE_DIVINE)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp, 410000000, 0x13a,
                                                        TYPES_TOKEN, 0, 0, 1,
                                                        RACE_SPELLCASTER,
                                                        ATTRIBUTE_LIGHT)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 2, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 or
        not Duel.IsPlayerCanSpecialSummonMonster(tp, 410000000, 0x13a,
                                                 TYPES_TOKEN, 0, 0, 1,
                                                 RACE_SPELLCASTER,
                                                 ATTRIBUTE_LIGHT) then return end

    for i = 1, 2 do
        local token = Duel.CreateToken(tp, 410000000)
        Duel.SpecialSummonStep(token, 0, tp, tp, false, false,
                               POS_FACEUP_DEFENSE)
    end
    Duel.SpecialSummonComplete()
end
