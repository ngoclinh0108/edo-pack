-- Blue-Eyes Divine Dragon
local s, id = GetID()

s.material = {CARD_BLUEEYES_W_DRAGON}
s.material_setcode = {0xdd}
s.listed_names = {CARD_BLUEEYES_W_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixN(c, false, false, CARD_BLUEEYES_W_DRAGON, 3)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or
                   aux.fuslimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e1b)
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_SINGLE)
    e1c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetValue(aux.tgoval)
    c:RegisterEffect(e1c)
    local e1d = e1c:Clone()
    e1d:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1d:SetValue(function(e, re, tp) return tp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1d)
end
