--
local s, id = GetID()

function s.initial_effect(c)
    -- gain effect
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_ADJUST)
    e0:SetRange(LOCATION_MZONE)
    e0:SetOperation(s.e0op)
    c:RegisterEffect(e0)
end

function s.e0filter(c)
    return c:IsType(TYPE_MONSTER) and c:GetOriginalRace() ~= RACE_CREATORGOD and
               c:GetFlagEffect(id) == 0
end

function s.e0op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup():Filter(s.e0filter, nil)
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
        reset:SetOperation(s.e0resetop)
        reset:SetReset(RESET_EVENT + 0x1fe0000)
        c:RegisterEffect(reset, true)
    end
end

function s.e0resetop(e, tp, eg, ep, ev, re, r, rp)
    local cid = e:GetLabel()
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    local g = c:GetOverlayGroup():Filter(Card.IsType, nil, TYPE_MONSTER)

    if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
        c:ResetEffect(cid, RESET_COPY)
        tc:ResetFlagEffect(id)
    end
end
