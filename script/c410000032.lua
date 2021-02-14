-- Palladium Draco-Knight Critias
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableUnsummonable()

    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(85800949)
    c:RegisterEffect(code)

    -- race
    local race = Effect.CreateEffect(c)
    race:SetType(EFFECT_TYPE_SINGLE)
    race:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    race:SetCode(EFFECT_ADD_RACE)
    race:SetValue(RACE_DRAGON)
    c:RegisterEffect(race)

    -- change name
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE +
                        EFFECT_FLAG_CANNOT_NEGATE)
    pe1:SetCode(EFFECT_CHANGE_CODE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetValue(11082056)
    c:RegisterEffect(pe1)

    -- fusion summon
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- banish
    local me1 = Effect.CreateEffect(c)
    me1:SetCategory(CATEGORY_REMOVE)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- set trap
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 1))
    me2:SetType(EFFECT_TYPE_QUICK_O)
    me2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    me2:SetCode(EVENT_FREE_CHAIN)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, id)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
end

function s.pe2tgfilter(c, e, tp, rp)
    return c:IsType(TYPE_TRAP) and
               Duel.IsExistingMatchingCard(s.pe2spfilter, tp,
                                           LOCATION_EXTRA + LOCATION_GRAVE, 0,
                                           1, nil, e, tp, c:GetCode(), rp)
end

function s.pe2spfilter(c, e, tp, code, rp)
    return c:IsType(TYPE_FUSION) and c.material_trap and
               Duel.GetLocationCountFromEx(tp, rp, nil, c) > 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and code ==
               c.material_trap
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.pe2tgfilter, tp,
                                           LOCATION_HAND + LOCATION_SZONE, 0, 1,
                                           nil, e, tp, rp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_EXTRA + LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FMATERIAL)
    local tc = Duel.SelectMatchingCard(tp, s.pe2tgfilter, tp,
                                       LOCATION_HAND + LOCATION_SZONE, 0, 1, 1,
                                       nil, e, tp, rp):GetFirst()
    if not tc or tc:IsImmuneToEffect(e) then return end

    if tc:IsOnField() and tc:IsFacedown() then Duel.ConfirmCards(1 - tp, tc) end
    Duel.SendtoGrave(tc, REASON_EFFECT)
    if not tc:IsLocation(LOCATION_GRAVE) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc
    if tc:IsPreviousLocation(LOCATION_SZONE) and
        tc:IsPreviousPosition(POS_FACEUP) then
        sc = Duel.SelectMatchingCard(tp, s.pe2spfilter, tp,
                                     LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, 1,
                                     nil, e, tp, tc:GetPreviousCodeOnField()):GetFirst()
    else
        sc = Duel.SelectMatchingCard(tp, s.pe2spfilter, tp,
                                     LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, 1,
                                     nil, e, tp, tc:GetCode()):GetFirst()
    end
    if not sc then return end

    Duel.BreakEffect()
    Duel.SpecialSummon(sc, 0, tp, tp, true, false, POS_FACEUP)
    sc:CompleteProcedure()

    Duel.BreakEffect()
    Duel.Destroy(c, REASON_EFFECT)
end

function s.me1filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToRemove() and
               c:IsFaceup()
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.me1filter, tp, LOCATION_ONFIELD,
                                           LOCATION_ONFIELD, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, 0)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local tc = Duel.SelectMatchingCard(tp, s.me1filter, tp, LOCATION_ONFIELD,
                                       LOCATION_ONFIELD, 1, 1, nil):GetFirst()
    if not tc then return end

    Duel.Remove(tc, POS_FACEDOWN, REASON_EFFECT)
end

function s.me2filter(c) return c:IsType(TYPE_TRAP) and c:IsSSetable() end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and
                   Duel.IsExistingTarget(s.me2filter, tp, LOCATION_GRAVE,
                                         LOCATION_GRAVE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
    local g = Duel.SelectTarget(tp, s.me2filter, tp, LOCATION_GRAVE,
                                LOCATION_GRAVE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp, LOCATION_SZONE) == 0 or
        not tc:IsRelateToEffect(e) then return end

    Duel.SSet(tp, tc)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
end
