Duel.LoadScript("util_dimension.lua")

-- init
if not aux.UtilityProcedure then aux.UtilityProcedure = {} end
if not Utility then Utility = aux.UtilityProcedure end

-- function
function Utility.RegisterGlobalEffect(c, eff, filter, param1, param2, param3,
                                      param4, param5)
    local g = Duel.GetMatchingGroup(filter, c:GetControler(), LOCATION_ALL, 0,
                                    nil, param1, param2, param3, param4, param5)
    for tc in aux.Next(g) do tc:RegisterEffect(eff:Clone()) end
end

function Utility.DeckEditAddCardToDeck(tp, code, condition_code, condition_alias)
    if Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp, LOCATION_ALL, 0, 1,
                                   nil, code) then return end
    if condition_code ~= nil then
        if not condition_alias and
            not Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp,
                                            LOCATION_ALL, 0, 1, nil,
                                            condition_code) then return end
        if condition_alias and
            not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ALL, 0, 1,
                                            nil, condition_code) then
            return
        end
    end

    Duel.SendtoDeck(Duel.CreateToken(tp, code), tp, 2, REASON_RULE)
end

function Utility.DeckEditAddCardToExtraFaceup(tp, code, condition_code,
                                              condition_alias)
    if Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp, LOCATION_ALL, 0, 1,
                                   nil, code) then return end
    if condition_code ~= nil then
        if not condition_alias and
            not Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp,
                                            LOCATION_ALL, 0, 1, nil,
                                            condition_code) then return end
        if condition_alias and
            not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ALL, 0, 1,
                                            nil, condition_code) then
            return
        end
    end

    Duel.SendtoExtraP(Duel.CreateToken(tp, code), tp, REASON_RULE)
end

function Utility.DeckEditAddCardToDimension(tp, code, condition_code,
                                            condition_alias)
    if Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp, LOCATION_ALL, 0, 1,
                                   nil, code) then return end
    if condition_code ~= nil then
        if not condition_alias and
            not Duel.IsExistingMatchingCard(Card.IsOriginalCode, tp,
                                            LOCATION_ALL, 0, 1, nil,
                                            condition_code) then return end
        if condition_alias and
            not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ALL, 0, 1,
                                            nil, condition_code) then
            return
        end
    end

    local c = Duel.CreateToken(tp, code)
    Dimension.SendToDimension(c, REASON_RULE)
    Dimension.AddProcedure(c)
    if c.dimension_change then c.dimension_change(nil, tp) end
end

function Utility.CheckActivateEffect(ec, e, tp, neglect_con, neglect_cost,
                                     copy_info)
    local te = ec:CheckActivateEffect(neglect_con, neglect_cost, copy_info)
    return Utility.CheckEffectCanApply(te, e, tp)
end

function Utility.ApplyActivateEffect(ec, e, tp, neglect_con, neglect_cost,
                                     copy_info)
    local te = ec:CheckActivateEffect(neglect_con, neglect_cost, copy_info)
    return Utility.ApplyEffect(te, e, tp)
end

function Utility.CheckEffectCanApply(te, e, tp)
    if not te then return false end
    local tg = te:GetTarget()
    if not tg then return true end
    return tg(te, tp, Group.CreateGroup(), PLAYER_NONE, 0, e, REASON_EFFECT,
              PLAYER_NONE, 0)
end

function Utility.ApplyEffect(te, e, tp, rc)
    if not te then return false end
    if not rc then rc = te:GetHandler() end
    local tg = te:GetTarget()
    local op = te:GetOperation()

    if tg then
        tg(te, tp, Group.CreateGroup(), PLAYER_NONE, 0, e, REASON_EFFECT,
           PLAYER_NONE, 1)
    end
    Duel.BreakEffect()
    if rc then
        rc:CreateEffectRelation(te)
        Duel.BreakEffect()
    end

    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    if g ~= nil then
        for etc in aux.Next(g) do etc:CreateEffectRelation(te) end
    end
    if op then
        op(te, tp, Group.CreateGroup(), PLAYER_NONE, 0, e, REASON_EFFECT,
           PLAYER_NONE, 1)
    end

    if rc then rc:ReleaseEffectRelation(te) end
    if g ~= nil then
        for etc in aux.Next(g) do etc:ReleaseEffectRelation(te) end
    end
    Duel.BreakEffect()
    return true
end

function Utility.IsSetCard(c, ...)
    local setcodes = {...}
    for _, setcode in ipairs(setcodes) do
        if c:IsSetCard(setcode) then return true end
    end

    return false
end

function Utility.IsSetCardListed(c, ...)
    if not c.listed_series then return false end

    local setcodes = {...}
    for _, setcode in ipairs(setcodes) do
        for _, seriecode in ipairs(c.listed_series) do
            if setcode == seriecode then return true end
        end
    end

    return false
end

function Utility.HintCard(target)
    local code = target
    if type(target) == "Card" then code = target:GetOriginalCode() end
    Duel.Hint(HINT_CARD, 0, code)
end

function Utility.GroupSelect(g, tp, min, max, ex)
    if #g < min then return Group.CreateGroup() end
    if not max then max = min end

    if #g > min then g = g:Select(tp, min, max, ex) end
    return g
end

function Utility.SelectMatchingCard(sel_player, f, player, s, o, min, max, ex, ...)
    return Utility.GroupSelect(Duel.GetMatchingGroup(f, player, s, o, ex, ...),
                               sel_player, min, max, ex)
end

function Utility.IsOwnAny(f, player, ...)
    local g = Duel.GetMatchingGroup(f, player, LOCATION_ALL, LOCATION_ALL, nil,
                                    ...)
    g:Merge(Dimension.Zones(player))
    return g:IsExists(function(c) return c:GetOwner() == player end, 1, nil)
end

function Utility.GainInfinityAtk(c, reset)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e)
        local c = e:GetHandler()
        local g = Duel.GetMatchingGroup(nil, 0, LOCATION_MZONE, LOCATION_MZONE,
                                        c)
        if #g == 0 then
            return 999999999 - c:GetAttack()
        else
            local tg, val = g:GetMaxGroup(Card.GetAttack)
            if val <= 999999999 then
                return 999999999 - c:GetAttack()
            else
                return val
            end
        end
    end)
    if reset then e1:SetReset(reset) end
    c:RegisterEffect(e1)

    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return ep ~= tp end)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.ChangeBattleDamage(ep, Duel.GetLP(ep))
    end)
    if reset then e2:SetReset(reset) end
    c:RegisterEffect(e2)
end

function Utility.AvatarInfinity(root, c)
    aux.GlobalCheck(root, function()
        local e3 = Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e3:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE +
                           EFFECT_FLAG_IGNORE_IMMUNE)
        e3:SetCode(EVENT_ADJUST)
        e3:SetCondition(function(e, tp, eg, ev, ep, re, r, rp)
            return Duel.IsExistingMatchingCard(AvatarFilter, tp, 0xff, 0xff, 1,
                                               nil)
        end)
        e3:SetOperation(function(e, tp, eg, ev, ep, re, r, rp)
            local g = Duel.GetMatchingGroup(AvatarFilter, tp, 0xff, 0xff, nil)

            g:ForEach(function(c)
                local atktes = {c:GetCardEffect(EFFECT_SET_ATTACK_FINAL)}
                for _, atkte in ipairs(atktes) do
                    if atkte:GetOwner() == c and
                        atkte:IsHasProperty(
                            EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_REPEAT +
                                EFFECT_FLAG_DELAY) then
                        atkte:SetValue(AvatarVal)
                        atkte:SetLabel(9999999)
                    end
                end

                local deftes = {c:GetCardEffect(EFFECT_SET_DEFENSE_FINAL)}
                for _, defte in ipairs(deftes) do
                    if defte:GetOwner() == c and
                        defte:IsHasProperty(
                            EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_REPEAT +
                                EFFECT_FLAG_DELAY) then
                        defte:SetValue(AvatarVal)
                        defte:SetLabel(9999999)
                    end
                end
            end)
        end)
        Duel.RegisterEffect(e3, 0)
    end)
end

function AvatarFilter(c)
    local atktes = {c:GetCardEffect(EFFECT_SET_ATTACK_FINAL)}
    local ae = nil
    local de = nil

    for _, atkte in ipairs(atktes) do
        if atkte:GetOwner() == c and
            atkte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_REPEAT +
                                    EFFECT_FLAG_DELAY) then
            ae = atkte:GetLabel()
        end
    end

    local deftes = {c:GetCardEffect(EFFECT_SET_DEFENSE_FINAL)}
    for _, defte in ipairs(deftes) do
        if defte:GetOwner() == c and
            defte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_REPEAT +
                                    EFFECT_FLAG_DELAY) then
            de = defte:GetLabel()
        end
    end

    return c:IsHasEffect(21208154) and (ae ~= 999999999 or de ~= 999999999)
end

function AvatarVal(e, c)
    local g = Duel.GetMatchingGroup(function(c)
        return c:IsFaceup() and not c:IsHasEffect(21208154)
    end, 0, LOCATION_MZONE, LOCATION_MZONE, nil)

    if #g == 0 then
        return 100
    else
        local tg, val = g:GetMaxGroup(Card.GetAttack)
        if val >= 99999999 then
            return val
        else
            return val + 100
        end
    end
end
