-- Divine Hieroglyph
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    -- tribute summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                       EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(TIMING_SPSUMMON, TIMING_BATTLE_START)
    e2:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                       EFFECT_FLAG_CANNOT_INACTIVATE)
    e3:SetCode(EVENT_PREDRAW)
    e3:SetRange(LOCATION_DECK + LOCATION_GRAVE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsMainPhase() end

function s.e1filter1(c, ec)
    if not c:IsRace(RACE_DIVINE) then return false end

    local ec1 = Effect.CreateEffect(ec)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    ec1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    ec1:SetTargetRange(0, LOCATION_MZONE)
    ec1:SetValue(POS_FACEUP)
    ec1:SetReset(RESET_CHAIN)
    c:RegisterEffect(ec1, true)

    local res = c:IsSummonable(true, nil, 1) or c:IsMSetable(true, nil, 1)
    ec1:Reset()
    return res
end

function s.e1filter2(c)
    return c:IsAbleToHand() and c:IsAttribute(ATTRIBUTE_DIVINE)
end

function s.e1check1(e, tp)
    return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_HAND, 0, 1,
                                       nil, e:GetHandler())
end

function s.e1check2(tp)
    return
        Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_DECK, 0, 1, nil) and
            Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil):GetClassCount(
                Card.GetCode) >= 3
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return s.e1check1(e, tp) or s.e1check2(tp) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local b1 = s.e1check1(e, tp)
    local b2 = s.e1check2(tp)

    if (not b1 and b2) or (b2 and Duel.SelectYesNo(tp, aux.Stringid(id, 2))) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.e1filter2, tp, LOCATION_DECK, 0,
                                          1, 1, nil, tp)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter1, tp, LOCATION_HAND, 0, 1,
                                       1, nil, c):GetFirst()
    if not tc then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    ec1:SetTargetRange(0, LOCATION_MZONE)
    ec1:SetValue(POS_FACEUP)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1, true)

    local s1 = tc:IsSummonable(true, nil, 1)
    local s2 = tc:IsMSetable(true, nil, 1)
    if (s1 and s2 and
        Duel.SelectPosition(tp, tc, POS_FACEUP_ATTACK + POS_FACEDOWN_DEFENSE) ==
        POS_FACEUP_ATTACK) or not s2 then
        Duel.Summon(tp, tc, true, nil, 1)
    else
        Duel.MSet(tp, tc, true, nil, 1)
    end
end

function s.e2filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, c:IsCode(CARD_RA), false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
               (Duel.IsTurnPlayer(1 - tp) and Duel.IsBattlePhase())
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE,
                                         LOCATION_GRAVE, 1, nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE,
                                LOCATION_GRAVE, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(tc, 0, tp, tp, tc:IsCode(CARD_RA), false, POS_FACEUP)
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                              PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0,
                          aux.Stringid(id, 3))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetLabelObject(tc)
    ec1:SetCountLimit(1)
    ec1:SetCondition(s.e2resetcon)
    ec1:SetOperation(s.e2resetop)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2resetcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetLabelObject():GetFlagEffect(id) ~= 0
end

function s.e2resetop(e, tp, eg, ep, ev, re, r, rp)
    Duel.SendtoGrave(e:GetLabelObject(), REASON_EFFECT)
end

function s.e3filter(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and not c:IsPublic()
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.e3filter, tp, LOCATION_HAND, 0, 1,
                                      1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end
    local dt = Duel.GetDrawCount(tp)
    if dt ~= 0 then
        _replace_count = 0
        _replace_max = dt
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_DRAW_COUNT)
        ec1:SetTargetRange(1, 0)
        ec1:SetValue(0)
        ec1:SetReset(RESET_PHASE + PHASE_DRAW)
        Duel.RegisterEffect(ec1, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    _replace_count = _replace_count + 1
    if _replace_count > _replace_max then return end

    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end
end
