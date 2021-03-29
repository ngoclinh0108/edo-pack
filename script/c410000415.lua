-- Evil HERO Supreme Neos
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0x8, 0x46}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(CARD_NEOS)
    c:RegisterEffect(code)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id + 1 * 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- fusion substitute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
    e2:SetRange(LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE)
    e2:SetValue(function(e, c) return c:IsSetCard(0x8) end)
    c:RegisterEffect(e2)

    -- dark fusion ignore
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(72043279)
    e3:SetRange(LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED)
    e3:SetTargetRange(1, 0)
    c:RegisterEffect(e3)

    -- atk up
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- search
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_BATTLE_DESTROYING)
    e5:SetCountLimit(1, id + 2 * 1000000)
    e5:SetCondition(aux.bdocon)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e1filter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:IsDiscardable()
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND, 0, c)
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and #g > 0 and
               aux.SelectUnselectGroup(g, e, tp, 1, 1, nil, 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND, 0, c)
    g = aux.SelectUnselectGroup(g, e, tp, 1, 1, nil, 1, tp, HINTMSG_TOGRAVE,
                                nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.SendtoGrave(g, REASON_COST)
    g:DeleteGroup()
end

function s.e4filter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:HasLevel() and
               c:IsAbleToGraveAsCost()
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttacker()
    local bc = Duel.GetAttackTarget()
    if not bc then return false end

    if bc:IsControler(1 - tp) then bc = tc end
    e:SetLabelObject(bc)
    return bc:IsFaceup() and bc:IsRace(RACE_FIEND)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_HAND +
                                               LOCATION_DECK + LOCATION_REMOVED,
                                           0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local tc = Duel.SelectMatchingCard(tp, s.e4filter, tp, LOCATION_HAND +
                                           LOCATION_DECK + LOCATION_REMOVED, 0,
                                       1, 1, nil):GetFirst()

    Duel.SendtoGrave(tc, REASON_COST)
    e:SetLabel(tc:GetLevel())
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(e:GetLabel() * 200)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
end

function s.e5filter(c)
    return c:IsAbleToHand() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x46)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e5filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e5filter, tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
