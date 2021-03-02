-- Mausoleum of the Signer Dragons
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0xc2, 0x3f}

function s.deck_edit(tp)
    -- Stardust Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   44508094, 83994433) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 7841112), tp, 2, REASON_RULE)
    end

    -- Red Dragon Archfiend
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   70902743, 39765958, 80666118) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 67030233), tp, 2, REASON_RULE)
    end

    -- Shooting Star Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   24696097) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 101105104), tp, 2, REASON_RULE)
    end

    -- Shooting Quasar Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   35952884) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 26268488), tp, 2, REASON_RULE)
        Duel.SendtoDeck(Duel.CreateToken(tp, 21123811), tp, 2, REASON_RULE)
    end
end

function s.global_effect(c, tp)
    -- Stardust Dragon
    local eg1 = Effect.CreateEffect(c)
    eg1:SetType(EFFECT_TYPE_SINGLE)
    eg1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    eg1:SetCode(EFFECT_ADD_CODE)
    eg1:SetValue(CARD_STARDUST_DRAGON)
    Utility.RegisterGlobalEffect(c, eg1, Card.IsCode, 83994433)

    -- Red Dragon Archfiend
    local eg2 = eg1:Clone()
    eg2:SetValue(70902743)
    Utility.RegisterGlobalEffect(c, eg2, Card.IsCode, 39765958)
    Utility.RegisterGlobalEffect(c, eg2, Card.IsCode, 80666118)

    -- Black-Winged Dragon
    local eg3 = eg1:Clone()
    eg3:SetValue(9012916)
    Utility.RegisterGlobalEffect(c, eg3, Card.IsCode, 60992105)

    -- Black Rose Dragon
    local eg4 = eg1:Clone()
    eg4:SetValue(73580471)
    Utility.RegisterGlobalEffect(c, eg4, Card.IsCode, 33698022)

    -- Ancient Fairy Dragon
    local eg5 = eg1:Clone()
    eg5:SetValue(25862681)
    Utility.RegisterGlobalEffect(c, eg5, Card.IsCode, 4179255)

    -- Power Tool Dragon
    local eg6 = eg1:Clone()
    eg6:SetValue(2403771)
    Utility.RegisterGlobalEffect(c, eg6, Card.IsCode, 68084557)
end

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- cannot disable summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(1, 0)
    e1:SetTarget(function(e, c)
        return c:IsType(TYPE_SYNCHRO) and
                   (c:IsSetCard(0xc2) or c:IsRace(RACE_DRAGON))
    end)
    c:RegisterEffect(e1)

    -- cannot to extra
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_TO_DECK)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c)
        return c:IsType(TYPE_EXTRA) and c:IsType(TYPE_SYNCHRO) and
                   c:IsSetCard(0x3f)
    end)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- place top deck
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PREDRAW)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- additional summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e4:SetTarget(function(e, c) return c:IsType(TYPE_TUNER) end)
    c:RegisterEffect(e4)

    -- draw
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(1108)
    e5:SetCategory(CATEGORY_DRAW)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCondition(s.e5con)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- when dragon leaves
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(7)
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_LEAVE_FIELD)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCondition(s.e6con)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e3filter(c)
    return c:IsLevel(1) and c:IsRace(RACE_DRAGON) and
               (c:IsLocation(LOCATION_DECK) or c:IsAbleToDeck())
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local tc = Duel.SelectMatchingCard(tp, s.e3filter, tp,
                                       LOCATION_HAND + LOCATION_DECK, 0, 1, 1,
                                       nil):GetFirst()
    if not tc then return end

    if not tc:IsLocation(LOCATION_DECK) then
        Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT)
    else
        Duel.ShuffleDeck(tp)
        Duel.MoveSequence(tc, SEQ_DECKTOP)
    end
    Duel.ConfirmDecktop(tp, 1)
end

function s.e5filter(c)
    return c:IsType(TYPE_SYNCHRO) and
               (c:IsSetCard(0xc2) or c:IsRace(RACE_DRAGON))
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e5filter, 1, nil)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end

function s.e6confilter(c, r, rp, tp)
    return c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_SYNCHRO) and
               (c:IsSetCard(0xc2) or c:IsRace(RACE_DRAGON)) and rp == tp and
               ((r & REASON_EFFECT) == REASON_EFFECT or (r & REASON_COST) ==
                   REASON_COST)
end

function s.e6spfilter(c, e, tp)
    return c:IsFaceup() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e6con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e6confilter, 1, nil, r, rp, tp)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return s.e6sptg(e, tp, eg, ep, ev, re, r, rp) or
                   s.e6dmgtg(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.e6sptg(e, tp, eg, ep, ev, re, r, rp)
    return eg:Filter(s.e6confilter, nil, r, rp, tp):IsExists(s.e6spfilter, 1,
                                                             nil, e, tp) and
               Duel.GetFlagEffect(tp, id + 1 * 1000000) == 0
end

function s.e6dmgtg(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id + 2 * 1000000) == 0
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local spcheck = s.e6sptg(e, tp, eg, ep, ev, re, r, rp) and
                        Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    local dmgcheck = s.e6dmgtg(e, tp, eg, ep, ev, re, r, rp)

    local op = 0
    if spcheck and dmgcheck then
        op = Duel.SelectOption(tp, 2, aux.Stringid(id, 1))
    elseif spcheck then
        op = Duel.SelectOption(tp, 2)
    else
        op = Duel.SelectOption(tp, aux.Stringid(id, 1)) + 1
    end

    if op == 0 then
        Duel.RegisterFlagEffect(tp, id + 1 * 1000000, RESET_PHASE + PHASE_END,
                                0, 1)

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = eg:Filter(s.e6confilter, nil, r, rp, tp)
        local tc = g:FilterSelect(tp, s.e6spfilter, 1, 1, nil, e, tp)
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    else
        Duel.RegisterFlagEffect(tp, id + 2 * 1000000, RESET_PHASE + PHASE_END,
                                0, 1)
        aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 1), nil)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_CHANGE_DAMAGE)
        ec1:SetTargetRange(1, 0)
        ec1:SetValue(s.e6dmgval)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e6dmgval(e, re, ev, r, rp, rc) return math.floor(ev / 2) end
