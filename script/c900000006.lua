-- The Wicked Deity Dreadroot
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 1, false)

    -- half atk/def
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetTarget(function(e, tc)
        return tc ~= e:GetHandler()
    end)
    e1:SetValue(function(e, c)
        return math.ceil(c:GetAttack() / 2)
    end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e1b:SetValue(function(e, c)
        return math.ceil(c:GetDefense() / 2)
    end)
    c:RegisterEffect(e1b)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e2b)
end

function s.e2con(e)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c and c:GetBattleTarget() and
               (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL)
end

function s.e2tg(e, c)
    return c == e:GetHandler():GetBattleTarget()
end
