-- Violet-Eyes Palladium Dragoon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {CARD_DARK_MAGICIAN, CARD_BLUEEYES_W_DRAGON, CARD_REDEYES_B_DRAGON}
s.listed_names = {
    CARD_DARK_MAGICIAN, CARD_BLUEEYES_W_DRAGON, CARD_REDEYES_B_DRAGON, 24094653
}
s.material_setcode = {0x3b, 0xdd, 0x10a2}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMix(c, true, true, CARD_DARK_MAGICIAN, CARD_BLUEEYES_W_DRAGON,
                      CARD_REDEYES_B_DRAGON)

    -- attribute
    local attribute = Effect.CreateEffect(c)
    attribute:SetType(EFFECT_TYPE_SINGLE)
    attribute:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return se:GetHandler():IsCode(24094653)
    end)
    c:RegisterEffect(splimit)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_UNRELEASABLE_SUM)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e1c)
    local e1d = e1:Clone()
    e1d:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    c:RegisterEffect(e1d)
    local e1e = e1:Clone()
    e1e:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    c:RegisterEffect(e1e)

    -- destroy & damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_REMOVE + CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY + CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- repeat attack
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_START)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttackAnnouncedCount() == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1,
                                      3, nil)
    if #g == 0 then return end

    if Duel.Destroy(g, REASON_EFFECT, LOCATION_REMOVED) > 0 then
        local dmg = 0
        for tc in aux.Next(g) do
            if tc:IsPreviousLocation(LOCATION_MZONE) then
                local atk = tc:GetTextAttack()
                if atk > 0 then dmg = dmg + atk; end
            end
        end

        if dmg > 0 then
            Duel.BreakEffect()
            Duel.Damage(1 - tp, dmg, REASON_EFFECT)
        end
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return rp == 1 - tp and Duel.IsChainNegatable(ev)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, eg, 1, 0, 0)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and
        Duel.Remove(eg, POS_FACEUP, REASON_EFFECT) ~= 0 and
        c:IsRelateToEffect(e) and c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
        c:RegisterEffect(ec1b)
    end
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local tc = e:GetHandler():GetBattleTarget()
    if chk == 0 then
        return tc and tc:IsControler(1 - tp) and tc:IsAbleToRemove()
    end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, tc, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetAttacker()

    if c == tc then tc = Duel.GetAttackTarget() end
    if tc and tc:IsRelateToBattle() then
        Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
    end

    if c:IsRelateToEffect(e) and c:CanChainAttack() and c == Duel.GetAttacker() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_DAMAGE_STEP_END)
        ec1:SetCountLimit(1)
        ec1:SetOperation(s.e4atkop)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_BATTLE)
        c:RegisterEffect(ec1)
    end
end

function s.e4atkop(e, tp)
    if e:GetHandler():CanChainAttack() then Duel.ChainAttack() end
end
