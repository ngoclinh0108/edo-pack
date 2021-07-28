-- Mausoleum of the Signer Dragons
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {410000506, 10723472}
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

    -- Black-Winged Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   9012916, 60992105) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 410000501), tp, 2, REASON_RULE)
    end

    -- Black Rose Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   73580471, 33698022) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 410000502), tp, 2, REASON_RULE)
    end

    -- Ancient Fairy Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   25862681, 4179255) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 410000503), tp, 2, REASON_RULE)
    end

    -- Power Tool Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   2403771, 68084557) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 410000504), tp, 2, REASON_RULE)
    end

    -- Shooting Quasar Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   35952884) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 410000505), tp, 2, REASON_RULE)
        Duel.SendtoDeck(Duel.CreateToken(tp, 26268488), tp, 2, REASON_RULE)
        Duel.SendtoDeck(Duel.CreateToken(tp, 21123811), tp, 2, REASON_RULE)
    end

    -- Shooting Star Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   24696097) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 101105104), tp, 2, REASON_RULE)
        Duel.SendtoDeck(Duel.CreateToken(tp, 68431965), tp, 2, REASON_RULE)
    end

    -- Red Nova Dragon
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   97489701, 99585850) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 16172067), tp, 2, REASON_RULE)
        Duel.SendtoDeck(Duel.CreateToken(tp, 9753964), tp, 2, REASON_RULE)
        Duel.SendtoDeck(Duel.CreateToken(tp, 36857073), tp, 2, REASON_RULE)
        Duel.SendtoDeck(Duel.CreateToken(tp, 62242678), tp, 2, REASON_RULE)
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

    -- Red Nova Dragon
    local eg7 = Effect.CreateEffect(c)
    eg7:SetType(EFFECT_TYPE_SINGLE)
    eg7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    eg7:SetCode(EFFECT_ADD_SETCODE)
    eg7:SetValue(0x1045)
    Utility.RegisterGlobalEffect(c, eg7, Card.IsCode, 97489701)
    Utility.RegisterGlobalEffect(c, eg7, Card.IsCode, 99585850)
end

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

    -- indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- cannot disable summon
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(1, 0)
    e3:SetTarget(function(e, c)
        if not c:IsType(TYPE_SYNCHRO) then return false end
        return (c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON)) or
                   c:IsSetCard(0xc2)
    end)
    c:RegisterEffect(e3)

    -- cannot to extra
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_TO_DECK)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(LOCATION_MZONE, 0)
    e4:SetTarget(function(e, c)
        return c:IsType(TYPE_EXTRA) and c:IsType(TYPE_SYNCHRO) and
                   c:IsSetCard(0x3f)
    end)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    -- additional summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e5:SetTarget(function(e, c) return c:IsType(TYPE_TUNER) end)
    c:RegisterEffect(e5)

    -- draw
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(1108)
    e6:SetCategory(CATEGORY_DRAW)
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCondition(s.e6con)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)

    -- when dragon leaves
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(7)
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e7:SetProperty(EFFECT_FLAG_DELAY)
    e7:SetCode(EVENT_LEAVE_FIELD)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCondition(s.e7con)
    e7:SetTarget(s.e7tg)
    e7:SetOperation(s.e7op)
    c:RegisterEffect(e7)
end

function s.e1filter(c) return c:IsCode(410000506) and c:IsAbleToHand() end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

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

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g > 1 then g = g:Select(tp, 1, 1, nil) end
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e6filter(c)
    if not c:IsType(TYPE_SYNCHRO) then return false end
    return (c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON)) or c:IsSetCard(0xc2)
end

function s.e6con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e6filter, 1, nil)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end

function s.e7confilter(c, r, rp, tp)
    return c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_SYNCHRO) and
               ((c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON)) or
                   c:IsSetCard(0xc2)) and rp == tp and
               ((r & REASON_EFFECT) == REASON_EFFECT or (r & REASON_COST) ==
                   REASON_COST)
end

function s.e7spfilter(c, e, tp)
    return c:IsFaceup() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e7con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e7confilter, 1, nil, r, rp, tp)
end

function s.e7tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return s.e7sptg(e, tp, eg, ep, ev, re, r, rp) or
                   s.e7dmgtg(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.e7op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local options = {
        {
            desc = 509,
            check = s.e7sptg(e, tp, eg, ep, ev, re, r, rp) and
                Duel.GetLocationCount(tp, LOCATION_MZONE) > 0,
            op = s.e7spop
        }, {
            desc = aux.Stringid(id, 2),
            check = s.e7thtg(e, tp, eg, ep, ev, re, r, rp),
            op = s.e7thop
        }, {
            desc = aux.Stringid(id, 3),
            check = s.e7dmgtg(e, tp, eg, ep, ev, re, r, rp),
            op = s.e7dmgop
        }
    }

    local t = {}
    local desc = {}
    for i, item in ipairs(options) do
        if (item.check) then
            table.insert(t, {index = i, desc = item.desc})
            table.insert(desc, item.desc)
        end
    end

    local index = Duel.SelectOption(tp, table.unpack(desc)) + 1
    index = t[index].index
    if options[index].op then
        Duel.RegisterFlagEffect(tp, id + index * 1000000,
                                RESET_PHASE + PHASE_END, 0, 1)
        options[index].op(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.e7sptg(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFlagEffect(tp, id + 1000000) > 0 then return false end
    return eg:Filter(s.e7confilter, nil, r, rp, tp):IsExists(s.e7spfilter, 1,
                                                             nil, e, tp)
end

function s.e7spop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = eg:Filter(s.e7confilter, nil, r, rp, tp)
    local tc = g:FilterSelect(tp, s.e7spfilter, 1, 1, nil, e, tp)
    Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e7thfilter(c) return c:IsCode(10723472) and c:IsAbleToHand() end

function s.e7thtg(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFlagEffect(tp, id + 2000000) > 0 then return false end
    return Duel.IsExistingMatchingCard(s.e7thfilter, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
end

function s.e7thop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.e7thfilter, tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        g = g:Select(tp, 1, 1, nil)
    end

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_RULE)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e7dmgtg(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFlagEffect(tp, id + 3000000) > 0 then return false end
    return true
end

function s.e7dmgop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CHANGE_DAMAGE)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(function(e, re, ev, r, rp, rc) return math.floor(ev / 2) end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end
