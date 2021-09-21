-- Palladium Shattering Arrow
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e2:SetCondition(s.e2con)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    for i = 1, ev do
        local te, tgp = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_EFFECT,
                                          CHAININFO_TRIGGERING_PLAYER)
        if tgp ~= tp and
            (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and
            Duel.IsChainNegatable(i) then return true end
    end

    return false
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local ng = Group.CreateGroup()
    local dg = Group.CreateGroup()
    for i = 1, ev do
        local te, tgp = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_EFFECT,
                                          CHAININFO_TRIGGERING_PLAYER)
        if tgp ~= tp and
            (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and
            Duel.IsChainNegatable(i) then
            local tc = te:GetHandler()
            ng:AddCard(tc)
            if tc:IsOnField() and tc:IsRelateToEffect(te) then
                dg:AddCard(tc)
            end
        end
    end

    Duel.SetTargetCard(dg)
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, ng, #ng, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, #dg, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local dg = Group.CreateGroup()
    local effs = {}

    for i = 1, ev do
        local te, tgp = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_EFFECT,
                                          CHAININFO_TRIGGERING_PLAYER)
        if tgp ~= tp and
            (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and
            Duel.NegateActivation(i) then
            local tc = te:GetHandler()
            if tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
                dg:AddCard(tc)
            end
            if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and
                Utility.CheckEffectCanApply(te, e, tp) then
                table.insert(effs, te)
            end
        end
    end

    Duel.Destroy(dg, REASON_EFFECT)
    if #effs > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        local te
        local g = Group.CreateGroup()
        for _, eff in pairs(effs) do g:AddCard(eff:GetHandler()) end
        local tc = Utility.GroupSelect(HINTMSG_EFFECT, g, tp):GetFirst()
        for _, eff in pairs(effs) do
            if eff:GetHandler() == tc then
                te = eff
                break
            end
        end

        Utility.HintCard(te)
        Utility.ApplyEffect(te, e, tp, c)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return aux.exccon(e) and
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsSetCard, 0x13a), tp,
                   LOCATION_MZONE, 0, 1, nil)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(aux.disfilter2, tp, 0, LOCATION_ONFIELD, 1,
                                     nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    Duel.SelectTarget(tp, aux.disfilter2, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc and not tc:IsRelateToEffect(e) or tc:IsFacedown() or
        tc:IsDisabled() then return end

    Duel.NegateRelatedChain(tc, RESET_TURN_SET)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_DISABLE_EFFECT)
    ec2:SetValue(RESET_TURN_SET)
    tc:RegisterEffect(ec2)
    if tc:IsType(TYPE_TRAPMONSTER) then
        local ec3 = ec1:Clone()
        ec3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
        tc:RegisterEffect(ec3)
    end
end
