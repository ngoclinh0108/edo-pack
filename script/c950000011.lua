-- Odd-Eyes Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x99}

function s.initial_effect(c)
    -- pendulum
    Pendulum.AddProcedure(c)

    -- special summon odd-eyes
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    pe1:SetCode(EVENT_DESTROYED)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1, id + 1 * 1000000)
    pe1:SetCondition(s.pe1con)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- search
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 1))
    pe2:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SEARCH)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1, id + 2 * 1000000)
    pe2:SetCondition(s.pe2con)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- atk up
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 2))
    me1:SetCategory(CATEGORY_ATKCHANGE)
    me1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me1:SetCode(EVENT_ATTACK_ANNOUNCE)
    me1:SetRange(LOCATION_MZONE)
    me1:SetCountLimit(1, id + 3 * 1000000)
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)
end

function s.pe1filter1(c, tp)
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and
               c:IsPreviousSetCard(0x99) and c:IsPreviousControler(tp) and
               c:IsPreviousLocation(LOCATION_ONFIELD) and
               c:IsPreviousPosition(POS_FACEUP)
end

function s.pe1filter2(c, e, tp)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsSetCard(0x99)
end

function s.pe1con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.pe1filter1, 1, nil, tp)
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.pe1filter2, tp, loc, 0, 1, nil, e,
                                           tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local loc = 0
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        loc = loc + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    end
    if Duel.GetLocationCountFromEx(tp, rp, nil) > 0 then
        loc = loc + LOCATION_EXTRA
    end
    if loc == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.pe1filter2),
                                      tp, loc, 0, 1, 1, nil, e, tp, rp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.pe2filter(c, e, tp, rp)
    if not c:IsAbleToHand() and
        not c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) then
        return false
    end
    return c:IsType(TYPE_PENDULUM) and c:IsAttackBelow(1500)
end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_PZONE, 0, 1,
                                       e:GetHandler())
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsDestructable() and
                   Duel.IsExistingMatchingCard(s.pe2filter, tp,
                                               LOCATION_DECK + LOCATION_GRAVE,
                                               0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.Destroy(c, REASON_EFFECT) == 0 then
        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 1))
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.pe2filter),
                                      tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                      1, nil, e, tp)
    aux.ToHandOrElse(g:GetFirst(), tp, function(tc)
        return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE)
    end, function(tc)
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end, 2)
end

function s.me1con(e, tp, eg, ep, ev, re, r, rp)
    if not Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_PZONE, 0, 1,
                                       nil) then return false end

    local ac = Duel.GetAttacker()
    local bc = Duel.GetAttackTarget()
    if not bc or ac:GetControler() == bc:GetControler() then return false end
    local sc
    if ac:IsControler(tp) then
        sc = ac
    else
        sc = bc
    end

    if sc:IsFaceup() and sc:IsSetCard(0x99) and sc:IsRace(RACE_DRAGON) then
        e:GetLabelObject(sc)
        return true
    end
    return false
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local tc = e:GetLabelObject()
    if chk == 0 then return tc:IsOnField() end
    Duel.SetTargetCard(tc)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) and tc:IsFacedown() or not tc:IsControler(tp) then
        return
    end

    local atk = 0
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0, nil)
    for pc in aux.Next(g) do
        if pc:GetAttack() > 0 then atk = atk + pc:GetAttack() end
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_BATTLE)
    tc:RegisterEffect(ec1)
end
