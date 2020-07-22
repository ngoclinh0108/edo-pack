-- The Forbidden Pharaoh's True Name
local s, id = GetID()

s.listed_names = {410000009}

function s.initial_effect(c)
    -- check deck
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- return
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.echlimit(e, ep, tp) return tp == ep end

function s.e1bool1(c)
    return c:IsLocation(LOCATION_DECK + LOCATION_GRAVE) and c:IsAbleToHand()
end

function s.e1bool2(c, e, tp)
    return c:IsLocation(LOCATION_HAND + LOCATION_DECK) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e1filter(c, e, tp)
    return c:IsOriginalAttribute(ATTRIBUTE_DIVINE) and
               (s.e1bool1(c) or s.e1bool2(c, e, tp))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
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

    Duel.SetChainLimit(s.echlimit)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.ConfirmDecktop(tp, 1)
    local tc = Duel.GetDecktopGroup(tp, 1):GetFirst()
    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)

    if not tc:IsCode(ac) or not tc:IsAbleToHand() then
        Duel.DisableShuffleCheck()
        Duel.SendtoGrave(tc, REASON_EFFECT + REASON_REVEAL)
        return
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND +
                                        LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                    e, tp)
    if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.BreakEffect()

        Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 1))
        local sc = g:Select(tp, 1, 1, nil):GetFirst()
        local b1 = s.e1bool1(sc)
        local b2 = s.e1bool2(sc, e, tp)

        local op = 0
        if b1 and b2 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
        elseif b1 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 1))
        else
            op = Duel.SelectOption(tp, aux.Stringid(id, 2)) + 1
        end

        if op == 0 then
            Duel.SendtoHand(sc, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sc)
        else
            Duel.SpecialSummon(sc, 0, tp, tp, false, false, POS_FACEUP)
        end
    else
        Duel.DisableShuffleCheck()
    end

    Duel.ShuffleHand(tp)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0 and Duel.IsEnvironment(410000009, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
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

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
    Duel.SetChainLimit(s.echlimit)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    _replace_count = _replace_count + 1
    if _replace_count <= _replace_max and c:IsRelateToEffect(e) then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end
end
