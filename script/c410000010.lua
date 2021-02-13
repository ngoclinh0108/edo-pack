-- The True Name of Palladium Ruler
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    -- recover LP
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- declare top deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1, id)
    e2:SetCondition(function() return Duel.IsMainPhase() end)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- summon divine beast
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 3))
    e3:SetCategory(CATEGORY_SUMMON)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1, id)
    e3:SetCondition(function() return Duel.IsMainPhase() end)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsCode(CARD_RA, 10000080, 10000090) and
               c:GetAttack() > 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, s.e1filter, 1, false, nil, nil)
    end

    local tc =
        Duel.SelectReleaseGroupCost(tp, s.e1filter, 1, 1, false, nil, nil):GetFirst()
    local rec = tc:GetAttack()

    Duel.Release(tc, REASON_COST)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(rec)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, rec)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Recover(p, d, REASON_EFFECT)
end

function s.e2filter(c, e, tp)
    if not c:IsAttribute(ATTRIBUTE_DIVINE) then return false end
    return s.e2check1(c) or s.e2check2(c, e, tp)
end

function s.e2check1(c)
    return not c:IsLocation(LOCATION_HAND) and c:IsAbleToHand()
end

function s.e2check2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, c:IsOriginalCode(CARD_RA) and true or false, false) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsPlayerCanDiscardDeck(tp, 1) and
                   Duel.IsExistingMatchingCard(Card.IsAbleToHand, tp,
                                               LOCATION_DECK, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CODE)
    s.announce_filter = {TYPE_EXTRA, OPCODE_ISTYPE, OPCODE_NOT}
    local ac = Duel.AnnounceCard(tp, table.unpack(s.announce_filter))

    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0, CATEGORY_ANNOUNCE, nil, 0, tp, ANNOUNCE_CARD_FILTER)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.ConfirmDecktop(tp, 1)
    local tc = Duel.GetDecktopGroup(tp, 1):GetFirst()
    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)

    if not tc:IsCode(ac) then
        Duel.DisableShuffleCheck()
        Duel.SendtoGrave(tc, REASON_EFFECT + REASON_REVEAL)
        return
    end

    if not tc:IsAbleToHand() then return end
    Duel.SendtoHand(tc, nil, REASON_EFFECT)

    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_HAND +
                                        LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                    e, tp)
    if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.BreakEffect()

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
        local sc = g:Select(tp, 1, 1, nil):GetFirst()

        local b1 = s.e2check1(sc)
        local b2 = s.e2check2(sc, e, tp)
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
            Duel.SpecialSummon(sc, 0, tp, tp, tc:IsOriginalCode(CARD_RA) and true or false, false, POS_FACEUP)
        end
    else
        Duel.DisableShuffleCheck()
    end
    Duel.ShuffleHand(tp)
end

function s.e3filter(c, e, ec)
    if not c:IsRace(RACE_DIVINE) then return false end

    local ec1 = Effect.CreateEffect(ec)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    ec1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    ec1:SetTargetRange(0, LOCATION_MZONE)
    ec1:SetLabelObject(e)
    ec1:SetTarget(s.e3sumtg)
    ec1:SetValue(POS_FACEUP)
    ec1:SetReset(RESET_CHAIN)
    c:RegisterEffect(ec1, true)

    local res = c:IsSummonable(true, nil, 1) or c:IsMSetable(true, nil, 1)
    ec1:Reset()
    return res
end

function s.e3sumtg(e, c) return not c:IsImmuneToEffect(e:GetLabelObject()) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND, 0, 1,
                                           nil, e, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e3filter, tp, LOCATION_HAND, 0, 1,
                                       1, nil, e, c):GetFirst()
    if not tc then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    ec1:SetTargetRange(0, LOCATION_MZONE)
    ec1:SetLabelObject(e)
    ec1:SetTarget(s.e3sumtg)
    ec1:SetValue(POS_FACEUP)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1, true)

    local b1 = tc:IsSummonable(true, nil, 1)
    local b2 = tc:IsMSetable(true, nil, 1)
    if (b1 and b2 and
        Duel.SelectPosition(tp, tc, POS_FACEUP_ATTACK + POS_FACEDOWN_DEFENSE) ==
        POS_FACEUP_ATTACK) or not b2 then
        Duel.Summon(tp, tc, true, nil, 1)
    else
        Duel.MSet(tp, tc, true, nil, 1)
    end
end
