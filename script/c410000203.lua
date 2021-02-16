-- Blue-Eyes Savior Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xdd}
s.listed_names = {CARD_BLUEEYES_W_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, s.synfilter, 1, 1,
                         aux.FilterBoolFunction(Card.IsSetCard, 0xdd), 1, 1)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c)
        local ct = Duel.GetMatchingGroupCount(Card.IsRace, c:GetControler(),
                                              LOCATION_GRAVE, 0, nil,
                                              RACE_DRAGON)
        return ct * 800
    end)
    c:RegisterEffect(e1)

    -- negate
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.synfilter(c) return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) end

function s.e2filter(c, tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    if not (rp == 1 - tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then
        return false
    end

    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return g and g:IsExists(s.e2filter, 1, nil, tp) and
               Duel.IsChainDisablable(ev)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk) Duel.NegateEffect(ev) end

function s.e3filter(c, e, tp)
    return c:IsCode(CARD_BLUEEYES_W_DRAGON) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(), REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1,
                                           nil)
    end

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local dg = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    if Duel.Destroy(dg, REASON_EFFECT) > 0 then
        local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_HAND +
                                            LOCATION_DECK + LOCATION_GRAVE, 0,
                                        nil, e, tp)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            local sg = g:Select(tp, 1, 1, nil)
            Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end
