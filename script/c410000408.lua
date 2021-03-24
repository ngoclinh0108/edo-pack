-- Elemental HERO Shining Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS, 17732278, 42015635}
s.material_setcode = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        17732278, function(tc)
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_LIGHT) and
                       tc:IsRace(RACE_PLANT)
        end
    }, nil, true, true)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- destroy and apply effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(function()
        return not Duel.IsEnvironment(42015635) and Duel.IsMainPhase()
    end)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetType(EFFECT_TYPE_QUICK_O)
    e2b:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e2b:SetCode(EVENT_FREE_CHAIN)
    e2b:SetCondition(function()
        return Duel.IsEnvironment(42015635) and Duel.IsMainPhase()
    end)
    c:RegisterEffect(e2b)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1,
                                         nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g =
        Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_END, 0, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()

    if not tc or not tc:IsRelateToEffect(e) then return end
    Duel.Destroy(tc, REASON_EFFECT)

    if tc:IsType(TYPE_MONSTER) then
        if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetValue(500)
        c:RegisterEffect(ec1)
    elseif tc:IsType(TYPE_SPELL) then
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0,
                                        LOCATION_EXTRA, nil)
        if #g == 0 then return end
        if #g > 0 then g = g:RandomSelect(tp, 1) end
        Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
    else
        local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0,
                                        LOCATION_GRAVE, nil)
        if #g == 0 then return end
        if #g > 0 then g = g:Select(tp, 1, 1, nil) end
        Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
    end
end
