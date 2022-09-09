-- Mach Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- hand synchro
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_HAND_SYNCHRO)
    e1:SetLabel(id)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
end

function s.e1val(e, tc, sc)
    local c = e:GetHandler()
    if tc:IsLocation(LOCATION_HAND) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)
        ec1:SetLabel(id)
        ec1:SetTarget(s.e1synctg)
        tc:RegisterEffect(ec1)
        return true
    else
        return false
    end
end

function s.e1syncheck1(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then
        return false
    end

    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() ~= id then
            return false
        end
    end

    return true
end

function s.e1syncheck2(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then
        return false
    end

    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() == id then
            return true
        end
    end

    return false
end

function s.e1synctg(e, c, sg, tg, ntg, tsg, ntsg)
    if c then
        local res = true
        if sg:IsExists(s.e1syncheck1, 1, c) or
            (not tg:IsExists(s.e1syncheck2, 1, c) and not ntg:IsExists(s.e1syncheck2, 1, c) and
                not sg:IsExists(s.e1syncheck2, 1, c)) then
            return false
        end

        local trg = tg:Filter(s.e1syncheck1, nil)
        local ntrg = ntg:Filter(s.e1syncheck1, nil)
        return res, trg, ntrg
    else
        return true
    end
end
