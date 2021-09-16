-- Blue-Eyes Holy Shining Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_BLUEEYES_W_DRAGON}
s.listed_series = {0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(Card.IsSetCard, 0xdd),
                         1, 1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, c)
        local tp = c:GetControler()
        return Duel.GetMatchingGroupCount(Card.IsRace, tp, LOCATION_GRAVE, 0,
                                          nil, RACE_DRAGON) * 300
    end)
    c:RegisterEffect(e2)

    -- disable
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(1117)
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_SINGLE)
    e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                        EFFECT_FLAG_SINGLE_RANGE)
    e3b:SetRange(LOCATION_MZONE)
    e3b:SetCode(3682106)
    c:RegisterEffect(e3b)

    -- destroy
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return not e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) or
                   not e:GetHandler():GetMaterial()
                       :IsExists(Card.IsCode, 1, nil, CARD_BLUEEYES_W_DRAGON)
    end)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetType(EFFECT_TYPE_QUICK_O)
    e4b:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e4b:SetCode(EVENT_FREE_CHAIN)
    e4b:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and
                   e:GetHandler():GetMaterial():IsExists(Card.IsCode, 1, nil,
                                                         CARD_BLUEEYES_W_DRAGON)
    end)
    c:RegisterEffect(e4b)
end

function s.e3filter(c, tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and
               c:IsSetCard(0xdd)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    if rp == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end

    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return tg and tg:IsExists(s.e3filter, 1, nil, tp) and
               Duel.IsChainDisablable(ev)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp, chk) Duel.NegateEffect(ev) end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(), REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD,
                                     LOCATION_ONFIELD, 1, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, Card.IsDestructable, tp, LOCATION_ONFIELD,
                                LOCATION_ONFIELD, 1, 99, c)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g == 0 then return end

    Duel.Destroy(g, REASON_EFFECT)
end
