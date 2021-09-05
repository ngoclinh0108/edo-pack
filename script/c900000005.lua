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

    -- cannot attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    Divine.RegisterEffect(c, e2)

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

    -- quick attack
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 4))
    e5:SetCategory(CATEGORY_TOGRAVE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetHintTiming(TIMING_MAIN_END + TIMING_BATTLE_END)
    e5:SetCondition(s.e5con)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    Divine.RegisterEffect(c, e5)

    -- reset
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 5))
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetCode(EVENT_PHASE + PHASE_END)
    e6:SetRange(LOCATION_MZONE)
    e6:SetOperation(s.e6op)
    Divine.RegisterEffect(c, e6)

    aux.GlobalCheck(s, function()
        -- de-fusion
        local eg1 = Effect.CreateEffect(c)
        eg1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        eg1:SetCode(EVENT_ADJUST)
        eg1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local g = Duel.GetMatchingGroup(function(c)
                return c:IsCode(95286165) and c:GetFlagEffect(id) == 0
            end, tp, 0xff, 0xff, nil)

            for tc in aux.Next(g) do
                tc:RegisterFlagEffect(id, 0, 0, 0)
                local ec1 = Effect.CreateEffect(tc)
                ec1:SetDescription(aux.Stringid(id, 6))
                ec1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE +
                                    CATEGORY_RECOVER)
                ec1:SetType(EFFECT_TYPE_ACTIVATE)
                ec1:SetCode(tc:GetActivateEffect():GetCode())
                ec1:SetProperty(tc:GetActivateEffect():GetProperty() |
                                    EFFECT_FLAG_IGNORE_IMMUNE)
                ec1:SetTarget(s.eg1tg)
                ec1:SetOperation(s.eg1op)
                tc:RegisterEffect(ec1)
            end
        end)
        Duel.RegisterEffect(eg1, 0)
    end)
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
    local mc = Utility.SelectMatchingCard(tp, s.dmsfilter, tp, LOCATION_MZONE,
                                          0, 1, 1, nil, true):GetFirst()
    if not mc then return end
    mc:ResetFlagEffect(id)

    local opt = {}
    local sel = {}
    table.insert(opt, aux.Stringid(id, 0))
    table.insert(sel, 1)
    if Duel.GetLP(tp) > 1 then
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

        -- pay lp
        local lp = Duel.GetLP(tp)
        Duel.PayLPCost(tp, lp - 1)
        mc:RegisterFlagEffect(id + 100000, RESET_EVENT + RESETS_STANDARD +
                                  RESET_PHASE + PHASE_END,
                              EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 1))

        -- fusion type
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_ADD_TYPE)
        ec1:SetValue(TYPE_FUSION)
        ec1:SetCondition(function(e)
            return e:GetHandler():GetFlagEffect(id + 100000) > 0
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterEffect(mc, ec1, true)

        -- base atk/def
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec2:SetCode(EFFECT_SET_BASE_ATTACK)
        ec2:SetValue(lp - 1)
        ec2:SetCondition(function(e)
            return e:GetHandler():GetFlagEffect(id + 100000) > 0
        end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterEffect(mc, ec2, true)
        local ec2b = ec2:Clone()
        ec2b:SetCode(EFFECT_SET_BASE_DEFENSE)
        Divine.RegisterEffect(mc, ec2b, true)

        -- life point transfer
        local ec3 = Effect.CreateEffect(c)
        ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec3:SetCode(EVENT_RECOVER)
        ec3:SetRange(LOCATION_MZONE)
        ec3:SetCondition(s.e7lpcon)
        ec3:SetOperation(s.e7lpop)
        ec3:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterEffect(mc, ec3, true)

        -- unstoppable attack
        local ec4 = Effect.CreateEffect(c)
        ec4:SetType(EFFECT_TYPE_SINGLE)
        ec4:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
        ec4:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
        ec4:SetRange(LOCATION_MZONE)
        ec4:SetCondition(function(e)
            return e:GetHandler():GetFlagEffect(id + 100000) > 0
        end)
        ec4:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterEffect(mc, ec4, true)
        local spnoattack = mc:GetCardEffect(EFFECT_CANNOT_ATTACK)
        if spnoattack then spnoattack:Reset() end

        -- tribute monsters to atk/def up
        local ec5 = Effect.CreateEffect(c)
        ec5:SetDescription(aux.Stringid(id, 5))
        ec5:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
        ec5:SetType(EFFECT_TYPE_QUICK_O)
        ec5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec5:SetCode(EVENT_FREE_CHAIN)
        ec5:SetRange(LOCATION_MZONE)
        ec5:SetCountLimit(1)
        ec5:SetCondition(function(e)
            return e:GetHandler():GetFlagEffect(id + 100000) > 0
        end)
        ec5:SetCost(s.e7atkcost)
        ec5:SetOperation(s.e7atkop)
        ec5:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterEffect(mc, ec5, true)

        -- after damage calculation
        local ec6 = Effect.CreateEffect(c)
        ec6:SetCategory(CATEGORY_TOGRAVE)
        ec6:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        ec6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec6:SetCode(EVENT_BATTLED)
        ec6:SetCondition(s.e7togycon)
        ec6:SetOperation(s.e7togyop)
        ec6:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterEffect(mc, ec6, true)
    else
        local divine_evolution = mc:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
        Dimension.Change(mc, c, tp, tp, mc:GetPosition())
        if divine_evolution then
            c:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                                 RESET_EVENT + RESETS_STANDARD,
                                 EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
        end
    end
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    return (Duel.IsMainPhase() or Duel.IsBattlePhase()) and
               Duel.GetCurrentPhase() ~= PHASE_BATTLE_STEP
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE,
                                               LOCATION_MZONE, 1, c)
    end

    local g = Utility.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_MZONE,
                                         LOCATION_MZONE, 1, 1, c)
    Duel.HintSelection(g)
    Duel.SetTargetCard(g)

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    if tc:IsControler(1 - tp) then Duel.CalculateDamage(c, tc) end

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

function s.e6filter(c) return c:IsCode(10000080) and c:IsType(Dimension.TYPE) end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.HintSelection(Group.FromCards(c))

    local sg = Dimension.Zones(c:GetOwner()):Filter(s.e6filter, nil)
    if #sg > 0 then
        local sc = sg:GetFirst()
        local divine_evolution = c:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
        Dimension.Change(c, sc, tp, tp, c:GetPosition(), c:GetMaterial())
        if divine_evolution then
            sc:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                                  RESET_EVENT + RESETS_STANDARD,
                                  EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
        end
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end

function s.e7lpcon(e, tp, eg, ep)
    return ep == tp and e:GetHandler():GetFlagEffect(id + 100000) > 0
end

function s.e7lpop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or
        c:GetFlagEffect(id + 100000) == 0 then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(c:GetBaseAttack() + ev)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(c, ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(c:GetBaseDefense() + ev)
    Divine.RegisterEffect(c, ec1b, true)

    Duel.SetLP(tp, 1, REASON_EFFECT)
end

function s.e7atkfilter(c)
    return c:IsFaceup() and c:GetTextAttack() > 0 and
               c:GetAttackAnnouncedCount() == 0
end

function s.e7atkcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, s.e7atkfilter, 1, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, s.e7atkfilter, 1, 99, false, nil,
                                          c)
    Duel.Release(g, REASON_COST)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
    end
end

function s.e7atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) or
        c:GetFlagEffect(id + 100000) == 0 then return end
    local g = e:GetLabelObject()
    if not g then return end

    local atk = 0
    for tc in aux.Next(g) do
        if tc:GetBaseAttack() > 0 then atk = atk + tc:GetBaseAttack() end
    end
    g:DeleteGroup()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(c, ec1)
end

function s.e7togycon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c and c:GetFlagEffect(id + 100000) > 0
end

function s.e7togyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:GetFlagEffect(id + 100000) == 0 then return end

    Utility.HintCard(e:GetHandler())
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SendtoGrave(g, REASON_EFFECT)
end

function s.eg1filter(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsCode(CARD_RA)
end

function s.eg1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.eg1filter, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc = Duel.SelectTarget(tp, s.eg1filter, tp, LOCATION_MZONE,
                                 LOCATION_MZONE, 1, 1, nil):GetFirst()

    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tc:GetControler(),
                          tc:GetAttack())
end

function s.eg1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    local atk = tc:GetAttack()
    tc:ResetFlagEffect(id + 100000)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(0)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(tc, ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    Divine.RegisterEffect(tc, ec1b, true)

    Duel.Recover(tc:GetControler(), atk, REASON_EFFECT)
end
