-- Divine Reborn
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- add setcode
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_ADD_SETCODE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetValue(0x13a)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp)
    return (c:IsType(TYPE_MONSTER) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)) or
               (c:IsCode(CARD_RA) and
                   c:IsCanBeSpecialSummoned(e, 0, tp, true, false))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e1filter, tp, LOCATION_GRAVE,
                                         LOCATION_GRAVE, 1, nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_GRAVE,
                                LOCATION_GRAVE, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
    Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(tc, 0, tp, tp, tc:IsCode(CARD_RA) and true or false,
                       false, POS_FACEUP)
end
