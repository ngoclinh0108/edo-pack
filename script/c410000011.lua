-- Divine Reborn
local s, id = GetID()

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
end

function s.echlimit(e, ep, tp) return tp == ep end

function s.e1filter(c, e, tp)
    return c:IsType(TYPE_MONSTER) and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
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
    Duel.SetChainLimit(s.echlimit)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    local togy = not tc:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)

    if togy then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, 0, 1)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetCategory(CATEGORY_TOGRAVE)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EVENT_ADJUST)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetLabelObject(tc)
        ec1:SetCondition(s.e1togycon)
        ec1:SetOperation(s.e1togyop)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e1togycon(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    return Duel.GetCurrentPhase() == PHASE_END and tc:GetFlagEffect(id) ~= 0
end

function s.e1togyop(e, tp, eg, ep, ev, re, r, rp)
    Duel.SendtoGrave(e:GetLabelObject(), REASON_EFFECT)
end
