-- Starjunk Warrior
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.material = {63977008}
s.material_setcode = {0x1017}
s.listed_names = {63977008}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, stype, tp)
        return c:IsSummonCode(sc, stype, tp, 63977008) or c:IsHasEffect(20932152)
    end, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(60800381)
    c:RegisterEffect(code)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsLevelBelow(2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.e1val(e, c)
    return Duel.GetMatchingGroup(s.e1filter, c:GetControler(), LOCATION_MZONE, 0, c):GetSum(Card.GetAttack)
end
