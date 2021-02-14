-- Palladium Draco-Knight Timaeus
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {1784686}

function s.initial_effect(c)
    c:EnableUnsummonable()

    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(80019195)
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
    pe1:SetValue(1784686)
    c:RegisterEffect(pe1)

    -- fusion summon
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON +
                        CATEGORY_DESTROY)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- change scale
    local pe3 = Effect.CreateEffect(c)
    pe3:SetType(EFFECT_TYPE_SINGLE)
    pe3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    pe3:SetCode(EFFECT_UPDATE_LSCALE)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetValue(-4)
    c:RegisterEffect(pe3)
    local pe3b = pe3:Clone()
    pe3b:SetCode(EFFECT_UPDATE_RSCALE)
    pe3b:SetValue(4)
    c:RegisterEffect(pe3b)

    -- banish
    local me1 = Effect.CreateEffect(c)
    me1:SetCategory(CATEGORY_REMOVE)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- set spell
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

function s.pe2tgfilter(c, e, tp)
    return c:IsFaceup() and c:IsCanBeFusionMaterial() and
               Duel.IsExistingMatchingCard(s.pe2spfilter, tp,
                                           LOCATION_EXTRA + LOCATION_GRAVE, 0,
                                           1, nil, e, tp, c)
end

function s.pe2spfilter(c, e, tp, mc)
    if Duel.GetLocationCountFromEx(tp, tp, mc, c) <= 0 then return false end

    local mustg = aux.GetMustBeMaterialGroup(tp, nil, tp, c, nil, REASON_FUSION)
    return aux.IsMaterialListCode(c, mc:GetCode()) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and
               (#mustg == 0 or (#mustg == 1 and mustg:IsContains(mc)))
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.pe2tgfilter, tp, LOCATION_MZONE, 0, 1,
                                     nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.pe2tgfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_EXTRA + LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() or
        not tc:IsCanBeFusionMaterial() or tc:IsImmuneToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.pe2spfilter, tp,
                                       LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, 1,
                                       nil, e, tp, tc):GetFirst()
    if not sc then return end

    sc:SetMaterial(Group.FromCards(tc))
    Duel.SendtoGrave(tc, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)

    Duel.BreakEffect()
    Duel.SpecialSummon(sc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
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

function s.me2filter(c) return c:IsType(TYPE_SPELL) and c:IsSSetable() end

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
    if tc:IsType(TYPE_QUICKPLAY) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
        ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end
