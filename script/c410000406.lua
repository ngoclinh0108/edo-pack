-- Elemental HERO Celestial Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS, 54959865, 42015635}
s.material_setcode = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        54959865, function(tc)
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_WIND) and
                       tc:IsRace(RACE_WINGEDBEAST)
        end
    }, nil, true, true)

    -- no effect damage
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1, 0)
    e1:SetCondition(function() return Duel.IsEnvironment(42015635) end)
    e1:SetValue(function(e, re, val, r, rp, rc)
        if (r & REASON_EFFECT) ~= 0 then return 0 end
        return val
    end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e1b)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)

    -- disable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0, LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e3b)
end

function s.e2val(e, c)
    local lps = Duel.GetLP(c:GetControler())
    local lpo = Duel.GetLP(1 - c:GetControler())
    if lps <= lpo then
        return 0
    else
        return lps - lpo
    end
end

function s.e3con(e)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c and c:GetBattleTarget() and
               (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() ==
                   PHASE_DAMAGE_CAL)
end

function s.e3tg(e, c) return c == e:GetHandler():GetBattleTarget() end
