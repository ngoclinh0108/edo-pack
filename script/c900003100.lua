-- Void-Eyes Ogre Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0xb}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_DARK), 1, 1,
        Synchro.NonTunerEx(Card.IsRace, RACE_FIEND), 1, 99)

    -- cannot be Tributed, or be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    c:RegisterEffect(e1c)

    -- cannot change control or battle position
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    e2:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    c:RegisterEffect(e2b)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3filter1(c) return c:IsSetCard(0xb) and c:IsMonster() end

function s.e3filter2(c, code) return c:IsOriginalCode(code) and c:IsSetCard(0xb) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e3filter1, tp, LOCATION_GRAVE, 0, nil)
    g:Remove(function(c, sc) return sc:GetFlagEffect(c:GetOriginalCode()) > 0 end, nil, c)
    if c:IsFacedown() or #g <= 0 then return end

    repeat
        local tc = g:GetFirst()
        local code = tc:GetOriginalCode()
        local cid = c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD, 1)
        c:RegisterFlagEffect(code, RESET_EVENT + RESETS_STANDARD, 0, 0)

        local ec0 = Effect.CreateEffect(c)
        ec0:SetCode(id)
        ec0:SetLabel(code)
        ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec0, true)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EVENT_ADJUST)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetLabel(cid)
        ec1:SetLabelObject(ec0)
        ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            local g = Duel.GetMatchingGroup(s.e3filter1, tp, LOCATION_GRAVE, 0, nil)
            if not g:IsExists(s.e3filter2, 1, nil, e:GetLabelObject():GetLabel()) or c:IsDisabled() then
                c:ResetEffect(e:GetLabel(), RESET_COPY)
                c:ResetFlagEffect(e:GetLabelObject():GetLabel())
            end
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1, true)

        g:Remove(s.e3filter2, nil, code)
    until #g <= 0
end
