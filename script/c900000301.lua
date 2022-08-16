-- Ultimaya Stardust Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(CARD_STARDUST_DRAGON)
    c:RegisterEffect(code)

    -- non-tuner for a synchro summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_NONTUNER)
    e1:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e1)

    -- negate activation
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetCost(aux.StardustCost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2ret = Effect.CreateEffect(c)
    e2ret:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2ret:SetCode(EVENT_PHASE + PHASE_END)
    e2ret:SetRange(LOCATION_GRAVE)
    e2ret:SetCountLimit(1)
    e2ret:SetCondition(s.e2retcon)
    e2ret:SetOperation(s.e2retop)
    c:RegisterEffect(e2ret)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then
        return false
    end

    if re:IsHasCategory(CATEGORY_NEGATE) and
        Duel.GetChainInfo(ev - 1, CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then
        return false
    end

    local ex, tg, tc = Duel.GetOperationInfo(ev, CATEGORY_DESTROY)
    return ex and tg ~= nil and tc + tg:FilterCount(Card.IsOnField, nil) - #tg > 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then
        return true
    end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, #eg, 0, 0)
    if rc:IsDestructable() and rc:IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)

    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end

function s.e2retcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:GetFlagEffect(id) > 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2retop(e, tp, eg, ep, ev, re, r, rp)
    Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
end

function s.e3filter(c, tp, mc)
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and c:IsPreviousControler(tp) and
               c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and
               c:GetMaterial():IsContains(mc) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and
               c:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e3filter, 1, nil, tp, e:GetHandler())
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = eg:Filter(s.e3filter, nil, tp, e:GetHandler())
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = eg:Filter(s.e3filter, nil, tp, e:GetHandler())
    local tc = Utility.GroupSelect(HINTMSG_TODECK, g, tp, 1, 1):GetFirst()

    if not tc or Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 or not c:IsRelateToEffect(e) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        return
    end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3008)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        ec1:SetValue(1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        c:RegisterEffect(ec1b)
    end
end
