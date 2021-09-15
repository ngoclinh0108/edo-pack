-- Palladium Shattering Arrow
Duel.LoadScript("util.lua")
local s, id = GetID()

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
        for i, eff in pairs(effs) do g:AddCard(eff:GetHandler()) end
        local tc =
            Utility.GroupSelect(HINTMSG_EFFECT, g, tp, 1, 1, nil):GetFirst()
        for i, eff in pairs(effs) do
            if eff:GetHandler() == tc then
                te = eff
                break
            end
        end

        Utility.HintCard(te)
        Utility.ApplyEffect(te, e, tp, c)
    end
end
