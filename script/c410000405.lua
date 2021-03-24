-- Elemental HERO Abyssal Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {42015635}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        17955766, function(tc)
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_WATER) and
                       tc:IsRace(RACE_FISH)
        end
    }, nil, true, true)

    -- cannot remove
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_REMOVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, c, p) return c:IsLocation(LOCATION_GRAVE) end)
    c:RegisterEffect(e1)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetType(EFFECT_TYPE_QUICK_O)
    e2b:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e2b:SetCode(EVENT_FREE_CHAIN)
    e2b:SetCondition(function() return Duel.IsEnvironment(42015635) end)
    c:RegisterEffect(e2b)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND) > 0 and
                   c:GetFlagEffect(id) == 0
    end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1 - tp, LOCATION_HAND)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_END, 0, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
    if #g > 1 then g:RandomSelect(tp, 1) end
    Duel.Destroy(g, REASON_EFFECT)
end
