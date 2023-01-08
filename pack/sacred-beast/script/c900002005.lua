-- Successor of Phantasmal Lord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {6007213, 32491822, 69890967}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, {6007213, 32491822, 69890967}, aux.FilterBoolFunctionEx(Card.IsType, TYPE_EFFECT))
    Fusion.AddContactProc(c, s.fusfilter, s.fusop, s.splimit)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- effect gains
    local effreg = Effect.CreateEffect(c)
    effreg:SetType(EFFECT_TYPE_SINGLE)
    effreg:SetCode(EFFECT_MATERIAL_CHECK)
    effreg:SetValue(s.effval)
    c:RegisterEffect(effreg)

    -- uria
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function(e)
        return s.effcon(e, 6007213) and Duel.GetTurnPlayer() == e:GetHandlerPlayer()
    end)
    e2:SetValue(function(e, c)
        local ct = Duel.GetMatchingGroupCount(function(c)
            return c:GetType() == TYPE_TRAP + TYPE_CONTINUOUS
        end, c:GetControler(), LOCATION_GRAVE, 0, nil)
        return ct * 1000
    end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_IMMUNE_EFFECT)
    e2b:SetCondition(function(e)
        return s.effcon(e, 6007213)
    end)
    e2b:SetValue(function(e, te)
        return te:IsActiveType(TYPE_TRAP) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e2b)

    -- hamon
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(function(e)
        return s.effcon(e, 32491822) and Duel.GetTurnPlayer() == e:GetHandlerPlayer()
    end)
    e3:SetValue(4000)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_IMMUNE_EFFECT)
    e3b:SetCondition(function(e)
        return s.effcon(e, 32491822)
    end)
    e3b:SetValue(function(e, te)
        return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e3b)

    -- raviel
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(function(e)
        return s.effcon(e, 69890967) and Duel.GetTurnPlayer() == e:GetHandlerPlayer()
    end)
    e4:SetValue(4000)
    c:RegisterEffect(e4)
    local e4b = Effect.CreateEffect(c)
    e4b:SetType(EFFECT_TYPE_SINGLE)
    e4b:SetCode(EFFECT_PIERCE)
    e4b:SetCondition(function(e)
        return s.effcon(e, 69890967)
    end)
    c:RegisterEffect(e4b)
end

function s.splimit(e, se, sp, st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.fusfilter(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil)
end

function s.fusop(g, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.Remove(g, POS_FACEUP, REASON_COST + REASON_MATERIAL)
end

function s.effval(e, c)
    local g = c:GetMaterial()
    if g:IsExists(Card.IsCode, 1, nil, 6007213, 32491822, 69890967) then
        c:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD & ~(RESET_TOFIELD | RESET_LEAVE | RESET_TEMP_REMOVE), 0,
            1)
    end
end

function s.effcon(e, code)
    return e:GetHandler():GetMaterial():IsExists(Card.IsCode, 1, nil, code)
end
