-- Millennium Hieroglyph
local s, id = GetID()

function s.initial_effect(c)
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    startup:SetCode(EVENT_STARTUP)
    startup:SetRange(LOCATION_ALL)
    startup:SetOperation(s.startup)
    c:RegisterEffect(startup)
end

function s.startup(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    -- outside duel
    Duel.DisableShuffleCheck(true)
    Duel.SendtoDeck(c, tp, -2, REASON_RULE)
    if c:IsPreviousLocation(LOCATION_HAND) then Duel.Draw(p, 1, REASON_RULE) end
    e:Reset()

    -- complete summoned when summon
    local sum = Effect.CreateEffect(c)
    sum:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    sum:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    sum:SetCode(EVENT_SPSUMMON_SUCCESS)
    sum:SetCondition(s.sumcon)
    sum:SetOperation(s.sumop)
    Duel.RegisterEffect(sum, tp)

    -- normal summon in defense
    local sumdef = Effect.CreateEffect(c)
    sumdef:SetType(EFFECT_TYPE_FIELD)
    sumdef:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    sumdef:SetCode(EFFECT_LIGHT_OF_INTERVENTION)
    sumdef:SetTargetRange(1, 0)
    Duel.RegisterEffect(sumdef, tp)

    -- set dice & coin result
    local dice = Effect.CreateEffect(c)
    dice:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    dice:SetCode(EVENT_TOSS_DICE_NEGATE)
    dice:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return rp == tp end)
    dice:SetOperation(s.diceop)
    Duel.RegisterEffect(dice, tp)
    local coin = dice:Clone()
    coin:SetCode(EVENT_TOSS_COIN_NEGATE)
    coin:SetOperation(s.coinop)
    Duel.RegisterEffect(coin, tp)

    -- activate skill
    local skill = Effect.CreateEffect(c)
    skill:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    skill:SetCode(EVENT_FREE_CHAIN)
    skill:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return aux.CanActivateSkill(tp)
    end)
    skill:SetOperation(s.skillop)
    Duel.RegisterEffect(skill, tp)
end

function s.sumfilter(c, tp) return c:GetSummonPlayer() == tp end

function s.sumcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.sumfilter, 1, nil, tp)
end

function s.sumop(e, tp, eg, ep, ev, re, r, rp)
    local tg = eg:Filter(s.sumfilter, nil, tp)
    if #tg == 0 then return end

    for tc in aux.Next(tg) do tc:CompleteProcedure() end
end

function s.diceop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local cc = Duel.GetCurrentChain()
    local cid = Duel.GetChainInfo(cc, CHAININFO_CHAIN_ID)
    if root[0] == cid or not Duel.SelectYesNo(tp, 553) then return end
    Duel.Hint(HINT_CARD, tp, id)

    local t = {}
    for i = 1, 7 do t[i] = i end

    local res = {Duel.GetDiceResult()}
    local ct = bit.band(ev, 0xff) + bit.rshift(ev, 16)
    for i = 1, ct do res[i] = Duel.AnnounceNumber(tp, table.unpack(t)) end

    Duel.SetDiceResult(table.unpack(res))
    root[0] = cid
end

function s.coinop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local cc = Duel.GetCurrentChain()
    local cid = Duel.GetChainInfo(cc, CHAININFO_CHAIN_ID)
    if root[1] == cid or not Duel.SelectYesNo(tp, 552) then return end
    Duel.Hint(HINT_CARD, tp, id)

    local res = {Duel.GetCoinResult()}
    local ct = ev
    for i = 1, ct do
        local ac = Duel.SelectOption(tp, 60, 61)
        if ac == 0 then
            ac = 1
        else
            ac = 0
        end
        res[i] = ac
    end

    Duel.SetCoinResult(table.unpack(res))
    root[1] = cid
end

function s.skillop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, tp, id)
    local all = {
        {desc = aux.Stringid(id, 1), op = s.e1op, check = true},
        {desc = aux.Stringid(id, 2), op = s.e2op, check = true}, {
            desc = aux.Stringid(id, 3),
            op = s.e3op,
            check = s.e3con(e, tp, eg, ep, ev, re, r, rp)
        }, {
            desc = aux.Stringid(id, 4),
            op = s.e4op,
            check = s.e4con(e, tp, eg, ep, ev, re, r, rp)
        }, {
            desc = aux.Stringid(id, 5),
            op = s.e5op,
            check = s.e5con(e, tp, eg, ep, ev, re, r, rp)
        }, {
            desc = aux.Stringid(id, 6),
            op = s.e6op,
            check = s.e6con(e, tp, eg, ep, ev, re, r, rp)
        }, {
            desc = aux.Stringid(id, 7),
            op = s.e7op,
            check = s.e7con(e, tp, eg, ep, ev, re, r, rp)
        }, {
            desc = aux.Stringid(id, 8),
            op = s.e8op,
            check = s.e8con(e, tp, eg, ep, ev, re, r, rp)
        }, {
            desc = aux.Stringid(id, 9),
            op = s.e9op,
            check = s.e9con(e, tp, eg, ep, ev, re, r, rp)
        }
    }

    local t = {}
    local desc = {}
    for i, item in ipairs(all) do
        if (item.check) then
            table.insert(t, {index = i, desc = item.desc})
            table.insert(desc, item.desc)
        end
    end

    local index = Duel.SelectOption(tp, table.unpack(desc)) + 1
    index = t[index].index
    all[index].op(e, tp, eg, ep, ev, re, r, rp)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ph = Duel.GetCurrentPhase()

    if ph <= PHASE_DRAW then
        Duel.SkipPhase(tp, PHASE_DRAW, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_STANDBY then
        Duel.SkipPhase(tp, PHASE_STANDBY, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_MAIN1 then
        Duel.SkipPhase(tp, PHASE_MAIN1, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_BATTLE then
        Duel.SkipPhase(tp, PHASE_BATTLE, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_MAIN2 then
        Duel.SkipPhase(tp, PHASE_MAIN2, RESET_PHASE + PHASE_END, 1)
    end
    if ph <= PHASE_END then
        Duel.SkipPhase(tp, PHASE_END, RESET_PHASE + PHASE_END, 1)
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_SKIP_TURN)
    ec1:SetTargetRange(0, 1)
    ec1:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_EP)
    ec2:SetTargetRange(1, 0)
    ec2:SetReset(RESET_PHASE + PHASE_DRAW + RESET_SELF_TURN)
    Duel.RegisterEffect(ec2, tp)

    Duel.SkipPhase(tp, PHASE_DRAW, RESET_PHASE + PHASE_END, 2)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    getmetatable(c).announce_filter = {id, OPCODE_ISCODE, OPCODE_NOT}
    local code = Duel.AnnounceCard(tp, table.unpack(
                                       getmetatable(c).announce_filter))

    local card = Duel.CreateToken(tp, code)
    Duel.SendtoDeck(card, nil, 2, REASON_RULE)
end

function s.e3filter(c) return c:IsFaceup() and c:GetFlagEffect(id) == 0 end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_ONFIELD, 0, 1,
                                       nil)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc = Duel.SelectMatchingCard(tp, s.e3filter, tp, LOCATION_ONFIELD, 0,
                                       1, 1, nil):GetFirst()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_CANNOT_DISABLE +
                        EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    ec1:SetValue(aux.tgoval)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    ec2:SetValue(1)
    tc:RegisterEffect(ec2)
    local ec3 = ec1:Clone()
    ec3:SetCode(EFFECT_CANNOT_TO_HAND)
    ec3:SetValue(1)
    tc:RegisterEffect(ec2)
    local ec4 = ec1:Clone()
    ec4:SetCode(EFFECT_CANNOT_TO_DECK)
    ec4:SetValue(1)
    tc:RegisterEffect(ec4)
    local ec5 = ec1:Clone()
    ec5:SetCode(EFFECT_CANNOT_TO_GRAVE)
    ec5:SetValue(1)
    tc:RegisterEffect(ec5)
    local ec6 = ec1:Clone()
    ec6:SetCode(EFFECT_CANNOT_REMOVE)
    ec6:SetValue(1)
    tc:RegisterEffect(ec6)
    local ec7 = ec1:Clone()
    ec7:SetCode(EFFECT_CANNOT_TURN_SET)
    ec7:SetValue(1)
    tc:RegisterEffect(ec7)
    local ec8 = ec1:Clone()
    ec8:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    ec8:SetValue(1)
    tc:RegisterEffect(ec8)
    local ec9 = Effect.CreateEffect(c)
    ec9:SetType(EFFECT_TYPE_FIELD)
    ec9:SetCode(EFFECT_CANNOT_INACTIVATE)
    ec9:SetRange(LOCATION_ONFIELD)
    ec9:SetLabelObject(tc)
    ec9:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetLabelObject()
    end)
    tc:RegisterEffect(ec9)
    local ec10 = ec9:Clone()
    ec10:SetCode(EFFECT_CANNOT_DISEFFECT)
    tc:RegisterEffect(ec10)
    local ec11 = ec1:Clone()
    ec11:SetCode(EFFECT_CANNOT_DISABLE)
    ec11:SetValue(1)
    tc:RegisterEffect(ec11)
    -- local ec12 = Effect.CreateEffect(c)
    -- ec12:SetType(EFFECT_TYPE_FIELD)
    -- ec12:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    -- ec12:SetCode(EFFECT_LPCOST_CHANGE)
    -- ec12:SetRange(LOCATION_ONFIELD)
    -- ec12:SetTargetRange(1, 0)
    -- ec12:SetLabelObject(tc)
    -- ec12:SetValue(function(e, re, rp, val)
    --     if re and re:GetHandler() == e:GetLabelObject() then
    --         return 0
    --     else
    --         return val
    --     end
    -- end)
    -- ec12:SetReset(RESET_EVENT + RESETS_STANDARD)
    -- tc:RegisterEffect(ec12)

    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD,
                          EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1,
                                       nil) and
               Duel.GetLocationCount(tp, LOCATION_MZONE, tp,
                                     LOCATION_REASON_CONTROL) > 0
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0,
                                       1, 1, nil):GetFirst()
    if not tc or Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOZONE)
    local zone = math.log(Duel.SelectDisableField(tp, 1, LOCATION_MZONE, 0, 0),
                          2)
    Duel.MoveSequence(tc, zone)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED
    return Duel.IsExistingMatchingCard(nil, tp, loc, loc, 1, nil)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED
    local g = Duel.GetMatchingGroup(nil, tp, loc, loc, nil)
    if #g == 0 then return end

    local tpdraw = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)
    local opdraw = Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND)

    Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)
    Duel.ShuffleDeck(tp)
    Duel.ShuffleDeck(1 - tp)
    Duel.Draw(tp, tpdraw, REASON_EFFECT)
    Duel.Draw(1 - tp, opdraw, REASON_EFFECT)
    Duel.SetLP(tp, 8000)
    Duel.SetLP(1 - tp, 8000)
end

function s.e6filter(c) return not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup() end

function s.e6con(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED +
                    LOCATION_EXTRA + LOCATION_ONFIELD
    return Duel.IsExistingMatchingCard(s.e6filter, tp, loc, 0, 1, nil)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED +
                    LOCATION_EXTRA + LOCATION_ONFIELD

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e6filter, tp, loc, 0, 1, 10, nil)
    if #g == 0 then return end

    Duel.SendtoHand(g, nil, REASON_RULE)
    Duel.ConfirmCards(1 - tp, g)
end

function s.e7con(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_REMOVED +
                    LOCATION_EXTRA + LOCATION_ONFIELD
    return Duel.IsExistingMatchingCard(aux.TRUE, tp, loc, 0, 1, nil)
end

function s.e7op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_REMOVED +
                    LOCATION_EXTRA + LOCATION_ONFIELD

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, loc, 0, 1, 10, nil)
    if #g == 0 then return end

    Duel.SendtoGrave(g, REASON_RULE)
end

function s.e8filter(c) return not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup() end

function s.e8con(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED +
                    LOCATION_EXTRA + LOCATION_ONFIELD
    return Duel.IsExistingMatchingCard(s.e8filter, tp, loc, 0, 1, nil)
end

function s.e8op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED +
                    LOCATION_EXTRA + LOCATION_ONFIELD

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.e8filter, tp, loc, 0, 1, 10, nil)
    if #g == 0 then return end

    Duel.SendtoDeck(g, nil, 2, REASON_RULE)
end

function s.e9filter(c) return c:IsType(TYPE_PENDULUM) end

function s.e9con(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE +
                    LOCATION_REMOVED + LOCATION_ONFIELD
    return Duel.IsExistingMatchingCard(s.e9filter, tp, loc, 0, 1, nil)
end

function s.e9op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE +
                    LOCATION_REMOVED + LOCATION_ONFIELD

    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 8))
    local g = Duel.SelectMatchingCard(tp, s.e9filter, tp, loc, 0, 1, 10, nil)
    if #g == 0 then return end

    Duel.SendtoExtraP(g, tp, REASON_RULE)
end
