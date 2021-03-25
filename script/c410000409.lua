-- Elemental HERO Void Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS, 43237273, 42015635}
s.material_setcode = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        43237273, function(tc)
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_DARK) and
                       tc:IsRace(RACE_BEAST)
        end
    }, nil, true, true)

    -- negate & copy effect
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(function() return not Duel.IsEnvironment(42015635) end)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetType(EFFECT_TYPE_QUICK_O)
    e1b:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e1b:SetCode(EVENT_FREE_CHAIN)
    e1b:SetCondition(function() return Duel.IsEnvironment(42015635) end)
    c:RegisterEffect(e1b)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingTarget(s.e1filter, tp, 0, LOCATION_MZONE, 1,
                                         nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local g =
        Duel.SelectTarget(tp, s.e1filter, tp, 0, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_END, 0, 1)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()

    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or
        tc:IsDisabled() then return end

    Duel.NegateRelatedChain(tc, RESET_TURN_SET)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    ec1b:SetValue(RESET_TURN_SET)
    tc:RegisterEffect(ec1b)

    if tc:IsImmuneToEffect(ec1) or tc:IsImmuneToEffect(ec1b) or
        not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    Duel.AdjustInstantly(tc)

    local cid = c:CopyEffect(tc:GetOriginalCode(),
                             RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                 PHASE_END, 1)
    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(1162)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    ec2:SetCode(EVENT_PHASE + PHASE_END)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetLabel(cid)
    ec2:SetCountLimit(1)
    ec2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        c:ResetEffect(e:GetLabel(), RESET_COPY)
        Duel.HintSelection(Group.FromCards(c))
        Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec2)
end