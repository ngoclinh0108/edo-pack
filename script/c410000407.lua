-- Elemental HERO Colossal Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS, 80344569, 42015635}
s.material_setcode = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        80344569, function(tc)
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_EARTH) and
                       tc:IsRace(RACE_ROCK)
        end
    }, nil, true, true)

    -- to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_TOHAND)
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

function s.e1filter(c) return c:IsAbleToHand() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingTarget(s.e1filter, tp, 0, LOCATION_ONFIELD, 1,
                                         nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, s.e1filter, tp, 0, LOCATION_ONFIELD, 1, 1,
                                nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_END, 0, 1)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
