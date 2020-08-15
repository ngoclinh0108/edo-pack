-- Divine Reborn
local s, id = GetID()

s.listed_names = {410000011, CARD_RA}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c, e, tp)
    return (c:IsType(TYPE_MONSTER) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)) or
               (c:IsOriginalCode(CARD_RA) and
                   c:IsCanBeSpecialSummoned(e, 0, tp, true, false))
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsEnvironment(410000011, tp)
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

    if Duel.SpecialSummon(tc, 0, tp, tp,
                          tc:IsOriginalCode(CARD_RA) and true or false, false,
                          POS_FACEUP) == 0 then return end

    if tc:IsOriginalCode(CARD_RA) then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0,
                              aux.Stringid(id, 0))

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_ADJUST)
        ec1:SetCountLimit(1)
        ec1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            return Duel.GetCurrentPhase() == PHASE_END
        end)
        ec1:SetOperation(s.e1gyop)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e1gyfilter(c)
    return c:IsOriginalCode(CARD_RA) and c:GetFlagEffect(id) ~= 0
end

function s.e1gyop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.e1gyfilter, tp, LOCATION_MZONE, 0, nil)
    if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
end
