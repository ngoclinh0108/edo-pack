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
    }, nil, nil, true, true)
    
    -- cannot be target
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    
    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)

    
    -- no effect damage
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CHANGE_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(1, 0)
    e3:SetCondition(function() return Duel.IsEnvironment(42015635) end)
    e3:SetValue(function(e, re, val, r, rp, rc)
        if (r & REASON_EFFECT) ~= 0 then return 0 end
        return val
    end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
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
