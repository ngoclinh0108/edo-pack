-- Yubel - The Ultimate Phantasmal Nightmare
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {78371393, 43378048}
s.material_setcode = {0x145}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, 78371393, s.fusfilter)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.fuslimit)
    c:RegisterEffect(splimit)

    -- no change control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- no change battle position
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc)
        return tc == e:GetHandler()
    end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nomaterial)

    -- add name
    local addname = Effect.CreateEffect(c)
    addname:SetType(EFFECT_TYPE_SINGLE)
    addname:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    addname:SetCode(EFFECT_ADD_CODE)
    addname:SetRange(LOCATION_MZONE)
    addname:SetValue(43378048)
    c:RegisterEffect(addname)

    -- indes & avoid damage
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(e1b)
end

function s.fusfilter(c, fc, sumtype, tp)
    return c:IsType(TYPE_FUSION, fc, sumtype, tp) and c:IsSetCard(0x145, fc, sumtype, tp)
end
