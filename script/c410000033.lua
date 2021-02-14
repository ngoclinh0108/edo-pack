-- Palladium Draco-Knight Hermos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {46232525}

function s.initial_effect(c)
    c:EnableUnsummonable()

    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(84565800)
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
    pe1:SetValue(46232525)
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

    -- copy effect
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
    return c:IsType(TYPE_MONSTER) and
               Duel.IsExistingMatchingCard(s.pe2spfilter, tp,
                                           LOCATION_EXTRA + LOCATION_GRAVE, 0,
                                           1, nil, e, tp, c:GetRace(), c)
end

function s.pe2spfilter(c, e, tp, race, mc)
    return c:IsType(TYPE_FUSION) and c.material_race and
               Duel.GetLocationCountFromEx(tp, tp, mc, c) > 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and race ==
               c.material_race
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.pe2tgfilter, tp,
                                           LOCATION_HAND + LOCATION_MZONE, 0, 1,
                                           nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FMATERIAL)
    local tc = Duel.SelectMatchingCard(tp, s.pe2tgfilter, tp,
                                       LOCATION_HAND + LOCATION_MZONE, 0, 1, 1,
                                       nil, e, tp):GetFirst()
    if not tc or tc:IsImmuneToEffect(e) then return end

    if tc:IsOnField() and tc:IsFacedown() then Duel.ConfirmCards(1 - tp, tc) end
    local race = tc:GetRace()
    Duel.SendtoGrave(tc, REASON_EFFECT)
    if not tc:IsLocation(LOCATION_GRAVE) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.pe2spfilter, tp,
                                       LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, 1,
                                       nil, e, tp, race):GetFirst()
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

function s.me2filter(c) return c:IsType(TYPE_EFFECT) end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.me2filter, tp, LOCATION_GRAVE,
                                     LOCATION_GRAVE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.me2filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1,
                      nil)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if c:IsFacedown() or not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then
        return
    end

    c:CopyEffect(tc:GetCode(),
                 RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 1)
end
