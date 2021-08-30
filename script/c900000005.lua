-- Sun Divine Beast of Ra - Immortal Phoenix
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 10000080}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Dimension.AddProcedure(c)

    -- dimension change
    Dimension.RegisterChange(s, c, function(_, tp)
        local dms = Effect.CreateEffect(c)
        dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms:SetCode(EVENT_FREE_CHAIN)
        dms:SetCondition(Dimension.Condition(s.dmscon))
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
    e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) == 0 end)
    Divine.RegisterEffect(c, e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_SINGLE)
    e2b:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    Divine.RegisterEffect(c, e2b)

    -- battle & avoid damage
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
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    Divine.RegisterEffect(c, e3b)

    -- quick attack
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    Divine.RegisterEffect(c, e4)
    local e4b = Effect.CreateEffect(c)
    e4b:SetType(EFFECT_TYPE_SINGLE)
    e4b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4b:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    e4b:SetRange(LOCATION_MZONE)
    e4b:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) > 0 end)
    Divine.RegisterEffect(c, e4b)
    local e4c = Effect.CreateEffect(c)
    e4c:SetCategory(CATEGORY_TOGRAVE)
    e4c:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4c:SetCode(EVENT_BATTLED)
    e4c:SetCondition(s.e4togycon)
    e4c:SetOperation(s.e4togyop)
    Divine.RegisterEffect(c, e4c)

    -- reset
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EVENT_PHASE + PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetOperation(s.e5op)
    Divine.RegisterEffect(c, e5)

    -- effect gain
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e6:SetCode(EVENT_STARTUP)
    e6:SetRange(LOCATION_ALL)
    e6:SetOperation(function(e, tp)
        local c = e:GetHandler()
        local reg = Effect.CreateEffect(c)
        reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        reg:SetCode(EVENT_SPSUMMON_SUCCESS)
        reg:SetCondition(s.e6con)
        reg:SetOperation(s.e6op)
        Duel.RegisterEffect(reg, tp)
    end)
    Divine.RegisterEffect(c, e6)
end

function s.dmsfilter(c)
    return Dimension.CanBeDimensionMaterial(c) and c:IsCode(CARD_RA) and
               c:IsSummonType(SUMMON_TYPE_SPECIAL) and
               c:IsSummonLocation(LOCATION_GRAVE) and c:GetFlagEffect(id) == 0
end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetCurrentPhase() == PHASE_END then return false end
    return Duel.IsExistingMatchingCard(s.dmsfilter, tp, LOCATION_MZONE, 0, 1,
                                       nil)
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    Duel.BreakEffect()
    Utility.HintCard(id)

    local c = e:GetHandler()
    local mc = Utility.SelectMatchingCard(tp, s.dmsfilter, tp, LOCATION_MZONE,
                                          0, 1, 1, nil, 666100):GetFirst()
    if not mc then return end
    Duel.HintSelection(Group.FromCards(mc))

    local divine_evolution = mc:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
    Dimension.Change(c, mc, tp, tp, mc:GetPosition())
    if divine_evolution then
        c:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                             RESET_EVENT + RESETS_STANDARD,
                             EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
    end
end

function s.e4filter(c, sc)
    return Divine.GetDivineHierarchy(c) <= Divine.GetDivineHierarchy(sc) and
               c:IsAbleToGrave()
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_END
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_MZONE,
                                               LOCATION_MZONE, 1, c, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, 0, LOCATION_MZONE)
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc = Duel.SelectMatchingCard(tp, s.e4filter, tp, LOCATION_MZONE,
                                       LOCATION_MZONE, 1, 1, c):GetFirst()

    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_BATTLE, 0, 1)
    Duel.ForceAttack(c, tc)
end

function s.e4togycon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:GetFlagEffect(id) > 0 and Duel.GetAttacker() == c and
               c:GetBattleTarget()
end

function s.e4togyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if not bc then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_CHAIN)
    bc:RegisterEffect(ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    bc:RegisterEffect(ec1b, true)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_IMMUNE_EFFECT)
    ec1c:SetValue(function(e, te) return te:GetHandler() == e:GetHandler() end)
    bc:RegisterEffect(ec1c, true)
    Duel.AdjustInstantly(bc)

    Duel.SendtoGrave(bc, REASON_EFFECT)
end

function s.e5filter(c) return c:IsCode(10000080) and c:IsType(Dimension.TYPE) end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.HintSelection(Group.FromCards(c))

    local sg = Dimension.Zones(c:GetOwner()):Filter(s.e5filter, nil)
    if #sg > 0 then
        local sc = sg:GetFirst()
        local divine_evolution = c:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
        Dimension.Change(sc, c, tp, tp, POS_FACEUP_DEFENSE, c:GetMaterial())
        if divine_evolution then
            sc:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                                  RESET_EVENT + RESETS_STANDARD,
                                  EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
        end
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end

function s.e6regfilter(c, tp)
    return c:IsControler(tp) and c:IsFaceup() and c:IsCode(CARD_RA) and
               c:IsSummonType(SUMMON_TYPE_SPECIAL) and
               c:IsSummonLocation(LOCATION_GRAVE) and c:GetFlagEffect(id) == 0
end

function s.e6con(e, tp, eg, ep, ev, re, r, rp)
    return Dimension.IsInDimensionZone(e:GetHandler()) and
               eg:IsExists(s.e6regfilter, 1, nil, tp)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.e6regfilter, tp, LOCATION_MZONE, 0, nil,
                                    tp)
    if #g == 0 or Duel.GetLP(tp) <= 1 or
        not Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then return end

    Duel.BreakEffect()
    local c = e:GetHandler()
    local mc = Utility.GroupSelect(g, tp, 1, 1, nil):GetFirst()
    if not mc then return end
    Utility.HintCard(mc)

    local lp = Duel.GetLP(tp)
    Duel.PayLPCost(tp, lp - 1)
    mc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                              PHASE_END, 0, 1)

    -- base atk/def
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(lp - 1)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(mc, ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    Divine.RegisterEffect(mc, ec1b, true)

    -- life point transfer
    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 2))
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EVENT_RECOVER)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetCondition(function(e, tp, eg, ep) return ep == tp end)
    ec2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() then return end

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
    end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(mc, ec2, true)

    -- unstoppable attack
    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(aux.Stringid(id, 3))
    ec3:SetType(EFFECT_TYPE_SINGLE)
    ec3:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE +
                        EFFECT_FLAG_CLIENT_HINT)
    ec3:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(mc, ec3, true)
    local spnoattack = mc:GetCardEffect(EFFECT_CANNOT_ATTACK)
    if spnoattack then spnoattack:Reset() end

    -- tribute any number monsters to gains atk/def
    local ec4 = Effect.CreateEffect(c)
    ec4:SetDescription(aux.Stringid(id, 4))
    ec4:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    ec4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    ec4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec4:SetCode(EVENT_ATTACK_ANNOUNCE)
    ec4:SetRange(LOCATION_MZONE)
    ec4:SetCountLimit(1)
    ec4:SetCondition(s.e6atkcon)
    ec4:SetCost(s.e6atkcost)
    ec4:SetOperation(s.e6atkop)
    ec4:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(mc, ec4, true)

    -- after damage calculation
    local ec5 = Effect.CreateEffect(c)
    ec5:SetCategory(CATEGORY_TOGRAVE)
    ec5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec5:SetCode(EVENT_BATTLED)
    ec5:SetCondition(s.e6togycon)
    ec5:SetOperation(s.e6togyop)
    ec5:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(mc, ec5, true)
end

function s.e6atkfilter(c)
    return c:IsFaceup() and c:GetTextAttack() > 0 and
               c:GetAttackAnnouncedCount() == 0
end

function s.e6atkcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c or
               (Duel.GetAttackTarget() and Duel.GetAttackTarget() == c)
end

function s.e6atkcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, s.e6atkfilter, 1, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, s.e6atkfilter, 1, 99, false, nil,
                                          c)
    Duel.Release(g, REASON_COST)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
    end
end

function s.e6atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
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

function s.e6togycon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker() == e:GetHandler()
end

function s.e6togyop(e, tp, eg, ep, ev, re, r, rp)
    Utility.HintCard(e:GetHandler())
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SendtoGrave(g, REASON_EFFECT)
end
