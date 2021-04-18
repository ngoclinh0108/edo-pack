-- Elemental HERO Blazing Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS, 89621922, 42015635}
s.material_setcode = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, 89621922, nil, nil, true, true)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, 1)
    e2:SetCondition(s.e2con)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)

    -- cannot activate
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SSET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3b:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3b:SetRange(LOCATION_MZONE)
    e3b:SetTargetRange(0, 1)
    e3b:SetValue(s.e3val)
    c:RegisterEffect(e3)
end

function s.e1val(e)
    return Duel.GetMatchingGroupCount(Card.IsType, 0, LOCATION_ONFIELD,
                                      LOCATION_ONFIELD, nil,
                                      TYPE_SPELL + TYPE_TRAP) * 400
end

function s.e2con(e) return Duel.GetAttacker() == e:GetHandler() end

function s.e2val(e, re, tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    for tc in aux.Next(eg) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END + RESET_OPPO_TURN, 0, 1)
    end
end

function s.e3val(e, re, tp)
    if not Duel.IsEnvironment(42015635) then return false end
    if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL) then
        return false
    end
    local c = re:GetHandler()
    return not c:IsLocation(LOCATION_SZONE) or c:GetFlagEffect(id) > 0
end
