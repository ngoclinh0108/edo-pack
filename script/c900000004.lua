-- Sun Divine Beast of Ra - Sphere Mode
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 78665705, 95286165}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Divine.RegisterRaDefuse(s, c)
    Dimension.AddProcedure(c)

    -- dimension change
    Dimension.RegisterChange({
        handler = c,
        event_code = EVENT_SUMMON_SUCCESS,
        filter = function(c, e)
            return c:IsCode(CARD_RA) and c:GetOwner() == e:GetOwnerPlayer() and
                       c:IsControler(1 - e:GetOwnerPlayer())
        end,
        custom_op = function(e, c, mc)
            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.DivineEvolution(c) end
        end
    })

    -- summon effect
    local sum = Effect.CreateEffect(c)
    sum:SetType(EFFECT_TYPE_CONTINUOUS)
    sum:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sum:SetCode(EVENT_SUMMON_SUCCESS)
    sum:SetCondition(s.sumcon)
    sum:SetOperation(s.sumop)
    Duel.RegisterEffect(sum, 0)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_MACHINE)
    Divine.RegisterEffect(c, e1)

    -- cannot attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    Divine.RegisterEffect(c, e2)

    -- untargetable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    Divine.RegisterEffect(c, e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    Divine.RegisterEffect(c, e3b)

    -- summon ra to opponent's field
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                       EFFECT_FLAG_SPSUM_PARAM)
    e4:SetCode(EFFECT_LIMIT_SUMMON_PROC)
    e4:SetTargetRange(POS_FACEUP_ATTACK, 1)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    e4:SetValue(SUMMON_TYPE_TRIBUTE)
    local e4grant = Effect.CreateEffect(c)
    e4grant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4grant:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e4grant:SetCode(EVENT_STARTUP)
    e4grant:SetRange(LOCATION_ALL)
    e4grant:SetCountLimit(1, id)
    e4grant:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil,
                                        CARD_RA)
        for tc in aux.Next(g) do
            local eff = tc:GetCardEffect(EFFECT_LIMIT_SUMMON_PROC)
            eff:SetDescription(aux.Stringid(id, 0))
        end

        local grant = Effect.CreateEffect(c)
        grant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
        grant:SetTargetRange(LOCATION_HAND, 0)
        grant:SetLabelObject(e4)
        grant:SetCondition(function(e)
            return Dimension.IsInDimensionZone(e:GetHandler())
        end)
        grant:SetTarget(aux.TargetBoolFunction(Card.IsCode, CARD_RA))
        Duel.RegisterEffect(grant, tp)
        c:IsHasEffect(id)
    end)
    c:RegisterEffect(e4grant)

    -- ancient chant
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_BOTH_SIDE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    Divine.RegisterEffect(c, e5)
end

function s.sumfilter(c, tp) return c:IsCode(CARD_RA) and c:IsControler(tp) end

function s.sumcon(e, _, eg)
    local c = e:GetHandler()
    return Dimension.IsInDimensionZone(c) and
               eg:IsExists(s.sumfilter, 1, nil, c:GetOwner())
end

function s.sumop(e, _, eg)
    local tc = eg:Filter(s.sumfilter, nil, e:GetOwnerPlayer()):GetFirst()
    if not tc then return end
    s.granteffect(e, tc, true)
end

function s.e4con(e, c, minc, zone, relzone, exeff)
    if c == nil then return true end
    if exeff then
        local ret = exeff:GetValue()
        if type(ret) == "function" then
            ret = {ret(exeff, c)}
            if #ret > 1 then zone = (ret[2] >> 16) & 0x7f end
        end
    end
    local tp = c:GetControler()
    local mg = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    mg = mg:Filter(Auxiliary.IsZone, nil, relzone, tp)
    return minc <= 3 and Duel.CheckTribute(c, 3, 3, mg, 1 - tp, zone)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, c, minc, zone, relzone, exeff)
    if exeff then
        local ret = exeff:GetValue()
        if type(ret) == "function" then
            ret = {ret(exeff, c)}
            if #ret > 1 then zone = (ret[2] >> 16) & 0x7f end
        end
    end
    local mg = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    mg = mg:Filter(Auxiliary.IsZone, nil, relzone, tp)
    local g = Duel.SelectTribute(tp, c, 3, 3, mg, 1 - tp, zone, true)
    if g and #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp, c, minc, zone, relzone, exeff)
    local g = e:GetLabelObject()
    c:SetMaterial(g)
    Duel.Release(g, REASON_SUMMON + REASON_MATERIAL)
    g:DeleteGroup()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH +
                        EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(id)
    ec1:SetTargetRange(1, 0)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil,
                                    78665705)
    if chk == 0 then return tp == c:GetOwner() or #g > 0 end

    if tp == c:GetOwner() and
        (#g == 0 or not Duel.SelectYesNo(tp, aux.Stringid(id, 4))) then
        return
    end

    local sg = Utility.GroupSelect(HINTMSG_CONFIRM, g, tp, 1, 1, nil)
    Duel.ConfirmCards(1 - tp, sg)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()
    if chk == 0 then
        return Dimension.IsAbleToDimension(c) and mc and
                   (c:GetControler() == tp or
                       Duel.GetLocationCount(tp, LOCATION_MZONE) > 0) and
                   Dimension.CanBeDimensionSummoned(mc, e, tp) and
                   not Duel.IsPlayerAffectedByEffect(tp, id)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, mc, 1, 0, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()
    local is_control = tp == c:GetControler()

    local divine_evolution = Divine.IsDivineEvolution(c)
    if not Dimension.SendToDimension(c, REASON_COST) then return end
    Duel.BreakEffect()

    local seq = is_control and c:GetPreviousSequence() or nil
    if not Dimension.Summon(mc, tp, tp, c:GetPreviousPosition(), seq) then
        return
    end
    if divine_evolution then Divine.DivineEvolution(mc) end

    s.granteffect(e, mc, false)
end

function s.granteffect(e, tc, hint)
    local c = e:GetHandler()
    if hint then Utility.HintCard(c) end
    Divine.RegisterRaFuse(c, tc, true)

    -- calculate atk/def
    local atk = 4000
    local def = 4000
    if tc:IsSummonType(SUMMON_TYPE_TRIBUTE) then
        atk = 0
        def = 0
        local mg = tc:GetMaterial()
        for mc in aux.Next(mg) do
            if mc:GetPreviousAttackOnField() > 0 then
                atk = atk + mc:GetPreviousAttackOnField()
            end
            if mc:GetPreviousDefenseOnField() > 0 then
                def = def + mc:GetPreviousDefenseOnField()
            end
        end
    end

    -- set base atk/def
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterRaEffect(tc, ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    Divine.RegisterRaEffect(tc, ec1b, true)

    -- unstoppable attack
    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 5))
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    ec2:SetRange(LOCATION_MZONE)
    Divine.RegisterRaEffect(tc, ec2, true)
    local spnoattack = tc:GetCardEffect(EFFECT_CANNOT_ATTACK)
    if spnoattack then spnoattack:Reset() end

    -- destroy
    if not tc:IsOriginalCode(CARD_RA) then
        local ec3 = Effect.CreateEffect(c)
        ec3:SetDescription(aux.Stringid(id, 6))
        ec3:SetCategory(CATEGORY_DESTROY)
        ec3:SetType(EFFECT_TYPE_IGNITION)
        ec3:SetProperty(EFFECT_FLAG_CARD_TARGET)
        ec3:SetRange(LOCATION_MZONE)
        ec3:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
            if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
            Duel.PayLPCost(tp, 1000)
        end)
        ec3:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
            if chk == 0 then
                return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_MZONE,
                                             LOCATION_MZONE, 1, nil)
            end

            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
            local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_MZONE,
                                        LOCATION_MZONE, 1, 1, nil)
            Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
        end)
        ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local tc = Duel.GetFirstTarget()
            if not tc or not tc:IsRelateToEffect(e) then return end
            Duel.Destroy(tc, REASON_EFFECT)
        end)
        Divine.RegisterRaEffect(tc, ec3, true)
    end

    -- life point transfer
    local ec4 = Effect.CreateEffect(c)
    ec4:SetDescription(aux.Stringid(id, 7))
    ec4:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    ec4:SetType(EFFECT_TYPE_IGNITION)
    ec4:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    ec4:SetRange(LOCATION_MZONE)
    ec4:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then return Duel.GetLP(tp) > 100 end
        local paidlp = Duel.GetLP(tp) - 100
        Duel.PayLPCost(tp, paidlp)

        e:SetLabelObject({
            c:GetBaseAttack() + paidlp, c:GetBaseDefense() + paidlp
        })
    end)
    ec4:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end
        Duel.SetChainLimit(aux.FALSE)
    end)
    ec4:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 7))
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(id)
        ec1:SetLabelObject(e:GetLabelObject())
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        Divine.RegisterEffect(c, ec1, true)
    end)
    Divine.RegisterRaEffect(tc, ec4, true)
end
