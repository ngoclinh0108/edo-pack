-- Palladium Reborn
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 410000000}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(83764718)
    c:RegisterEffect(code)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- recover LP
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- add to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(573)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(function(e, tp) return Duel.IsEnvironment(410000000, tp) end)
    e3:SetCost(s.e3cost)
    e3:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return e:GetHandler():IsAbleToHand() end
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
    end)
    e3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsRelateToEffect(e) then return end
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end)
    c:RegisterEffect(e3)
end

function s.e1check1(c) return c:IsAbleToHand() end

function s.e1check2(c, e, tp)
    local isRa = c:IsOriginalCode(CARD_RA) and true or false
    if not c:IsCanBeSpecialSummoned(e, 0, tp, isRa, false) or
        (c:IsLocation(LOCATION_EXTRA) and c:IsFacedown()) then return false end

    if (c:IsLocation(LOCATION_EXTRA)) then
        return Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
    else
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end
end

function s.e1filter(c, e, tp)
    return c:IsType(TYPE_MONSTER) and (s.e1check1(c) or s.e1check2(c, e, tp))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_GRAVE + LOCATION_EXTRA,
                                           LOCATION_GRAVE + LOCATION_EXTRA, 1,
                                           nil, e, tp)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e1filter), tp,
                                    LOCATION_GRAVE + LOCATION_EXTRA,
                                    LOCATION_GRAVE + LOCATION_EXTRA, nil, e, tp)
    if #g == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local sc = g:Select(tp, 1, 1, nil):GetFirst()

    local b1 = s.e1check1(sc)
    local b2 = s.e1check2(sc, e, tp)
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, 573, 5)
    elseif b1 then
        op = Duel.SelectOption(tp, 573)
    else
        op = Duel.SelectOption(tp, 5) + 1
    end

    if op == 0 then
        Duel.SendtoHand(sc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sc)
    else
        local isRa = c:IsOriginalCode(CARD_RA) and true or false
        Duel.SpecialSummon(sc, 0, tp, tp, isRa, false, POS_FACEUP)

        if not sc:IsSetCard(0x13a) then
            sc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD +
                                      RESET_PHASE + PHASE_END,
                                  EFFECT_FLAG_CLIENT_HINT, 1, 0,
                                  aux.Stringid(id, 0))

            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(666000)
            ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
            ec1:SetCode(EVENT_PHASE + PHASE_END)
            ec1:SetCountLimit(1)
            ec1:SetOperation(s.e1gyop)
            ec1:SetReset(RESET_PHASE + PHASE_END)
            Duel.RegisterEffect(ec1, tp)
        end
    end
end

function s.e1gyop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(function(c)
        return c:GetFlagEffect(id) ~= 0
    end, tp, LOCATION_MZONE, 0, nil)
    if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
end

function s.e2filter(c)
    return c:IsFaceup() and c:IsCode(CARD_RA, 10000080, 10000090) and
               c:GetAttack() > 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return
            Duel.CheckReleaseGroupCost(tp, s.e2filter, 1, false, nil, nil) and
                not e:GetHandler():IsStatus(STATUS_CHAINING)
    end

    local tc =
        Duel.SelectReleaseGroupCost(tp, s.e2filter, 1, 1, false, nil, nil):GetFirst()
    local rec = tc:GetAttack()

    Duel.Release(tc, REASON_COST)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(rec)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, rec)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Recover(p, d, REASON_EFFECT)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil, nil)
    end
    local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 1, false, nil,
                                          nil)
    Duel.Release(g, REASON_COST)
end
