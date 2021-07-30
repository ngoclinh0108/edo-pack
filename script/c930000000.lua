-- Asgard the Aesir Realm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot banish & negate
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE + LOCATION_GRAVE, 0)
    e2:SetTarget(s.e2tg)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2b:SetCode(EVENT_CHAIN_SOLVING)
    e2b:SetRange(LOCATION_FZONE)
    e2b:SetOperation(s.e2op)
    c:RegisterEffect(e2b)
end

function s.e1filter1(c)
    return c:IsFaceup() and c:IsSetCard(0x4b) and c:IsType(TYPE_MONSTER)
end

function s.e1filter2(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0 and
               not Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_MZONE,
                                               0, 1, nil)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local dt = Duel.GetDrawCount(tp)
    if dt == 0 then return false end
    _replace_count = 1
    _replace_max = dt
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_DRAW_COUNT)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_DRAW)
    Duel.RegisterEffect(ec1, tp)
    if _replace_count > _replace_max or not c:IsRelateToEffect(e) then return end

    local g =
        Duel.GetMatchingGroup(s.e1filter2, tp, LOCATION_DECK, 0, nil):RandomSelect(
            tp, 1)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e2tg(e, c) return c:IsSetCard(0x4b) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if not Duel.IsChainDisablable(ev) or rp == tp then return end
    local res = false
    if not res and s.e2check(ev, CATEGORY_SPECIAL_SUMMON, re) then res = true end
    if not res and s.e2check(ev, CATEGORY_REMOVE, re) then res = true end
    if not res and s.e2check(ev, CATEGORY_TOHAND, re) then res = true end
    if not res and s.e2check(ev, CATEGORY_TODECK, re) then res = true end
    if not res and s.e2check(ev, CATEGORY_TOEXTRA, re) then res = true end
    if not res and s.e2check(ev, CATEGORY_LEAVE_GRAVE, re) then res = true end
    if res then Duel.NegateEffect(ev) end
end

function s.e2check(ev, category, re)
    local ex, tg, ct, p, v = Duel.GetOperationInfo(ev, category)
    if not ex then return false end
    if (category == CATEGORY_LEAVE_GRAVE or v == LOCATION_GRAVE) and ct > 0 and
        not tg then return false end
    if tg and #tg > 0 then
        return tg:IsExists(function(c, re)
            if c:IsControler(0) then
                return c:IsRelateToEffect(re)
            else
                return c:IsRelateToEffect(re)
            end
        end, 1, nil, re)
    end
    return false
end

