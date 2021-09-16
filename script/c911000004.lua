-- Blue-Eyes Chaos Azure Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_BLUEEYES_W_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.NOT(
                          aux.FilterBoolFunctionEx(Card.IsType, TYPE_TOKEN)), 3,
                      3)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetDescription(aux.Stringid(id, 0))
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                       EFFECT_FLAG_IGNORE_IMMUNE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    sp:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(sp)

    -- untargetable & indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1b:SetValue(function(e, re, tp) return tp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- pierce
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_PIERCE)
    e3:SetValue(DOUBLE_DAMAGE)
    c:RegisterEffect(e3)
end

function s.spfilter1(c)
    return c:IsType(TYPE_SPELL) and c:IsType(TYPE_RITUAL) and c:IsDiscardable()
end

function s.spfilter2(c, sc, tp)
    return c:IsCanBeLinkMaterial(sc, tp) and
               Duel.GetLocationCountFromEx(tp, tp, c, sc) > 0 and
               c:IsCode(CARD_BLUEEYES_W_DRAGON)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local g1 = Duel.GetMatchingGroup(s.spfilter1, tp, LOCATION_HAND, 0, c)
    local g2 = Duel.GetMatchingGroup(s.spfilter2, tp, LOCATION_MZONE, 0, nil, c,
                                     tp)
    return #g1 > 0 and #g2 > 0 and
               aux.SelectUnselectGroup(g1, e, tp, 1, 1, nil, 0) and
               aux.SelectUnselectGroup(g2, e, tp, 1, 1, nil, 0, c, tp)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local g1 = Duel.GetMatchingGroup(s.spfilter1, tp, LOCATION_HAND, 0, c)
    g1 = aux.SelectUnselectGroup(g1, e, tp, 1, 1, nil, 1, tp, HINTMSG_DISCARD,
                                 nil, nil, true)
    local g2 = Duel.GetMatchingGroup(s.spfilter2, tp, LOCATION_MZONE, 0, nil, c,
                                     tp)
    g2 = aux.SelectUnselectGroup(g2, e, tp, 1, 1, nil, 1, tp, HINTMSG_RELEASE,
                                 nil, nil, true)
    if #g1 > 0 and #g2 > 0 then
        g1:KeepAlive()
        g2:KeepAlive()
        e:SetLabelObject({g1, g2})
        return true
    end

    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g1 = e:GetLabelObject()[1]
    local g2 = e:GetLabelObject()[2]
    if not g1 or not g2 then return end

    Duel.SendtoGrave(g1, REASON_COST)
    Duel.SendtoGrave(g2, REASON_MATERIAL + REASON_LINK)

    g1:DeleteGroup()
    g2:DeleteGroup()
end
