-- Zorc Necrophades the Creator of Shadow Realm
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.SetHierarchy(s, 3)
    Divine.GodImmunity(c)

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, nil, 3, nil, nil, 99, nil, false,
                     s.xyzcheck)

    -- attribute & race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_ADD_RACE)
    e1b:SetValue(RACE_FIEND)
    c:RegisterEffect(e1b)

    -- gain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.xyzfilter(c, xyz, sumtype, tp)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DIVINE)
end

function s.xyzcheck(g, tp, xyz)
    return
        g:GetClassCount(Card.GetLevel) == 1 and g:GetClassCount(Card.GetCode) ==
            #g
end

function s.e2filter(c)
    return c:IsType(TYPE_MONSTER) and c:GetOriginalRace() ~= RACE_CREATORGOD and
               c:GetFlagEffect(id) == 0
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup():Filter(s.e2filter, nil)
    if c:IsFacedown() or #g <= 0 then return end

    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe0000, 0, 0)
        local cid = c:CopyEffect(tc:GetOriginalCode(), RESET_EVENT + 0x1fe0000)

        local reset = Effect.CreateEffect(c)
        reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        reset:SetCode(EVENT_ADJUST)
        reset:SetRange(LOCATION_MZONE)
        reset:SetLabel(cid)
        reset:SetLabelObject(tc)
        reset:SetOperation(s.e2resetop)
        reset:SetReset(RESET_EVENT + 0x1fe0000)
        c:RegisterEffect(reset, true)
    end
end

function s.e2resetop(e, tp, eg, ep, ev, re, r, rp)
    local cid = e:GetLabel()
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    local g = c:GetOverlayGroup():Filter(Card.IsType, nil, TYPE_MONSTER)

    if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
        c:ResetEffect(cid, RESET_COPY)
        tc:ResetFlagEffect(id)
    end
end
