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
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    if e == re or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then
        return false
    end

    if re:IsHasCategory(CATEGORY_NEGATE) and
        Duel.GetChainInfo(ev - 1, CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then
        return false
    end

    if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
        if tg and tg:IsExists(Card.IsOnField, 1, nil) then
            return true
        end
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
