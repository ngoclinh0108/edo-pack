-- Palladium Guardian Suijin
local s, id = GetID()

s.listed_names = {98434877}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(98434877)
    c:RegisterEffect(code)

    -- special summon from hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c) return c:IsReleasableByEffect() and
                                  c:IsType(TYPE_MONSTER) end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                       LOCATION_HAND + LOCATION_ONFIELD,
                                       LOCATION_ONFIELD, 1, c)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local g = Duel.SelectMatchingCard(tp, s.e1filter, tp,
                                      LOCATION_HAND + LOCATION_ONFIELD,
                                      LOCATION_ONFIELD, 1, 1, c)

    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Release(g, REASON_COST)
    g:DeleteGroup()
end
