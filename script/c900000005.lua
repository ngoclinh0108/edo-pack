-- Sun Divine Beast of Ra - Immortal Phoenix
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 10000080, 95286165}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Dimension.AddProcedure(c)

    -- dimension change
    Dimension.RegisterChange(s, c, function(_, tp)
        local dmsreg = Effect.CreateEffect(c)
        dmsreg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dmsreg:SetCode(EVENT_SPSUMMON_SUCCESS)
        dmsreg:SetOperation(s.dmsregop)
        Duel.RegisterEffect(dmsreg, tp)
        local dms = Effect.CreateEffect(c)
        dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms:SetCode(EVENT_ADJUST)
        dms:SetCondition(s.dmscon)
        dms:SetOperation(s.dmsop)
        Duel.RegisterEffect(dms, tp)
    end)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_PYRO)
    Divine.RegisterEffect(c, e1)

    -- attack limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetValue(aux.TRUE)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_ATTACK_COST)
    e2b:SetCost(function(e, c, tp) return Duel.CheckLPCost(tp, 1000) end)
    e2b:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.PayLPCost(tp, 1000)
        Duel.AttackCostPaid()
    end)
    Divine.RegisterEffect(c, e2b)

    -- battle indes
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(e, tc)
        return Divine.GetDivineHierarchy(tc) <
                   Divine.GetDivineHierarchy(e:GetHandler())
    end)
    Divine.RegisterEffect(c, e3)

    -- avoid battle damage
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    -- unstoppable attack
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    e5:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(c, e5)

    -- to grave
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 4))
    e6:SetCategory(CATEGORY_TOGRAVE)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_MZONE)
    e6:SetHintTiming(TIMING_END_PHASE)
    e6:SetCost(s.e6cost)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    Divine.RegisterEffect(c, e6)

    -- reset
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 5))
    e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e7:SetCode(EVENT_PHASE + PHASE_END)
    e7:SetRange(LOCATION_MZONE)
    e7:SetOperation(s.e7op)
    Divine.RegisterEffect(c, e7)

    Divine.RegisterRaDefuse(s, id, c)
end

function s.dmsfilter(c, check_flag)
    if check_flag and c:GetFlagEffect(id) == 0 then return false end
    return Dimension.CanBeDimensionMaterial(c) and c:IsCode(CARD_RA) and
               c:IsSummonType(SUMMON_TYPE_SPECIAL) and
               c:IsSummonLocation(LOCATION_GRAVE)
end

function s.dmsregop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.dmsfilter, nil, false)
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, 0, 1)
    end
end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.dmsfilter, tp, LOCATION_MZONE, 0, 1,
                                       nil, true)
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.dmsfilter, tp,
                                          LOCATION_MZONE, 0, 1, 1, nil, true):GetFirst()
    if not mc then return end
    mc:ResetFlagEffect(id)

    local opt = {}
    local sel = {}
    table.insert(opt, aux.Stringid(id, 0))
    table.insert(sel, 1)
    if Duel.GetLP(tp) > 100 then
        table.insert(opt, aux.Stringid(id, 1))
        table.insert(sel, 2)
    end
    if Dimension.CanBeDimensionChanged(c) then
        table.insert(opt, aux.Stringid(id, 2))
        table.insert(sel, 3)
    end

    Duel.HintSelection(Group.FromCards(mc))
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    if op == 1 then
        return
    elseif op == 2 then
        Utility.HintCard(mc)
        Divine.RegisterRaFuse(id, c, mc, true)

        -- pay lp
        local paidlp = Duel.GetLP(tp)
        paidlp = paidlp - 100
        Duel.PayLPCost(tp, paidlp)
        local label = {paidlp, paidlp}

        -- register
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 1))
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(id)
        ec1:SetLabelObject(label)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        Divine.RegisterEffect(mc, ec1, true)

        -- unstoppable attack
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
        ec2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
        ec2:SetRange(LOCATION_MZONE)
        ec2:SetCondition(function(e)
            return e:GetHandler():IsHasEffect(id)
        end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        Divine.RegisterEffect(mc, ec2, true)
        local spnoattack = mc:GetCardEffect(EFFECT_CANNOT_ATTACK)
        if spnoattack then spnoattack:Reset() end

        -- tribute monsters to up atk
        local ec3 = Effect.CreateEffect(c)
        ec3:SetDescription(aux.Stringid(id, 5))
        ec3:SetCategory(CATEGORY_ATKCHANGE)
        ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
        ec3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec3:SetCode(EVENT_ATTACK_ANNOUNCE)
        ec3:SetRange(LOCATION_MZONE)
        ec3:SetCountLimit(1)
        ec3:SetCondition(s.e7atkcon)
        ec3:SetCost(s.e7atkcost)
        ec3:SetOperation(s.e7atkop)
        ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
        Divine.RegisterEffect(mc, ec3, true)

        -- after damage calculation
        local ec4 = Effect.CreateEffect(c)
        ec4:SetCategory(CATEGORY_TOGRAVE)
        ec4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        ec4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec4:SetCode(EVENT_BATTLED)
        ec4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            return Duel.GetAttacker() == e:GetHandler() and
                       e:GetHandler():IsHasEffect(id)
        end)
        ec4:SetOperation(s.e7togyop)
        ec4:SetReset(RESET_EVENT + RESETS_STANDARD)
        Divine.RegisterEffect(mc, ec4, true)
    else
        local divine_evolution = mc:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
        Dimension.Change(mc, c, tp, tp, mc:GetPosition())
        if divine_evolution then
            c:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                                 RESET_EVENT + RESETS_STANDARD,
                                 EFFECT_FLAG_CLIENT_HINT, 1, 0, 666004)
        end
    end
end

function s.e6cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE,
                                               LOCATION_MZONE, 1, c)
    end

    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, aux.TRUE, tp,
                                         LOCATION_MZONE, LOCATION_MZONE, 1, 1, c)
    Duel.HintSelection(g)
    Duel.SetTargetCard(g)

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_CHAIN)
    tc:RegisterEffect(ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b, true)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_IMMUNE_EFFECT)
    ec1c:SetValue(function(e, te) return te:GetHandler() == e:GetHandler() end)
    tc:RegisterEffect(ec1c, true)
    Duel.AdjustInstantly(tc)
    Duel.SendtoGrave(tc, REASON_EFFECT)
end

function s.e7filter(c) return c:IsCode(10000080) and c:IsType(Dimension.TYPE) end

function s.e7op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.HintSelection(Group.FromCards(c))

    local sg = Dimension.Zones(c:GetOwner()):Filter(s.e7filter, nil)
    if #sg > 0 then
        local sc = sg:GetFirst()
        local divine_evolution = c:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
        Dimension.Change(c, sc, tp, tp, c:GetPosition(), c:GetMaterial())
        if divine_evolution then
            sc:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                                  RESET_EVENT + RESETS_STANDARD,
                                  EFFECT_FLAG_CLIENT_HINT, 1, 0, 666004)
        end
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end

function s.e7atkcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c or
               (Duel.GetAttackTarget() and Duel.GetAttackTarget() == c) and
               e:GetHandler():IsHasEffect(id)
end

function s.e7atkcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 99, false, nil,
                                          c)
    e:SetLabel(g:GetSum(Card.GetBaseAttack))
    Duel.Release(g, REASON_COST)
end

function s.e7atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) or not c:IsHasEffect(id) then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(e:GetLabel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(c, ec1)
end

function s.e7togyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsHasEffect(id) then return end

    Utility.HintCard(c)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SendtoGrave(g, REASON_EFFECT)
end
