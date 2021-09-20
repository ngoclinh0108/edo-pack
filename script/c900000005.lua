-- Sun Divine Beast of Ra - Immortal Phoenix
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 10000080, 95286165}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Divine.RegisterRaDefuse(s, c)
    Dimension.AddProcedure(c)

    -- dimension change (destroy)
    Dimension.RegisterChange({
        handler = c,
        custom_reg = function(c, flag_id)
            local dms = Effect.CreateEffect(c)
            dms:SetType(EFFECT_TYPE_CONTINUOUS)
            dms:SetCode(EFFECT_DESTROY_REPLACE)
            dms:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
                local g = eg:Filter(s.dmsfilter, nil, e:GetOwnerPlayer())
                if chk == 0 then return #g > 0 end
                for tc in aux.Next(g) do
                    tc:RegisterFlagEffect(flag_id, 0, 0, 1)
                end
                return true
            end)
            dms:SetValue(function(e, c)
                return s.dmsfilter(c, e:GetOwnerPlayer())
            end)
            Duel.RegisterEffect(dms, 0)
        end,
        custom_op = function(e, c, mc)
            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.DivineEvolution(c) end
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            ec1:SetCode(EFFECT_SET_BASE_ATTACK)
            ec1:SetRange(LOCATION_MZONE)
            ec1:SetValue(4000)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            Divine.RegisterRaEffect(c, ec1, true)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
            Divine.RegisterRaEffect(c, ec1b, true)
        end
    })

    -- dimension change (special summon)
    Dimension.RegisterChange({
        handler = c,
        event_code = EVENT_SPSUMMON_SUCCESS,
        filter = function(c, e)
            return c:IsCode(CARD_RA) and c:IsControler(e:GetOwnerPlayer()) and
                       c:IsSummonLocation(LOCATION_GRAVE) and c:IsAttackPos()
        end,
        custom_op = function(e, c, mc)
            local tp = e:GetHandlerPlayer()

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

            local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
            if op == 1 then
                return
            elseif op == 2 then
                s.granteffect(e, tp, mc)
            else
                local divine_evolution = Divine.IsDivineEvolution(mc)
                Dimension.Change(mc, c)
                if divine_evolution then
                    Divine.DivineEvolution(c)
                end
            end
        end
    })

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_PYRO)
    Divine.RegisterEffect(c, e1)

    -- unstoppable attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(c, e2)

    -- indes & no damage
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(e, tc)
        if Divine.GetDivineHierarchy(tc) >=
            Divine.GetDivineHierarchy(e:GetHandler()) then return false end
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                 PHASE_END, 0, 1)
        return true
    end)
    Divine.RegisterEffect(c, e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_SINGLE)
    e3b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e3b:SetValue(function(e)
        return e:GetHandler():GetFlagEffect(id) == 0 and 1 or 0
    end)
    Divine.RegisterEffect(c, e3b)

    -- to grave
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 4))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(TIMING_END_PHASE)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    Divine.RegisterEffect(c, e4)

    -- return
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 5))
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EVENT_PHASE + PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetOperation(s.e5op)
    Divine.RegisterEffect(c, e5)
end

function s.dmsfilter(c, tp)
    local re = c:GetReasonEffect()
    return c:IsControler(tp) and c:IsReason(REASON_EFFECT) and
               not c:IsReason(REASON_REPLACE) and re and re:GetHandler() == c and
               c:IsFaceup() and c:IsCode(CARD_RA)
end

function s.granteffect(e, tp, tc)
    local c = e:GetHandler()
    Utility.HintCard(tc)

    -- life point transfer
    Divine.RegisterRaFuse(c, tc, true)
    local paidlp = Duel.GetLP(tp) - 100
    Duel.PayLPCost(tp, paidlp)
    local label = {paidlp, paidlp}
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(id)
    ec1:SetLabelObject(label)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterRaEffect(tc, ec1, true)

    -- unstoppable attack
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    Divine.RegisterRaEffect(tc, ec2, true)
    local spnoattack = tc:GetCardEffect(EFFECT_CANNOT_ATTACK)
    if spnoattack then spnoattack:Reset() end

    -- tribute monsters to up atk
    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(aux.Stringid(id, 3))
    ec3:SetCategory(CATEGORY_ATKCHANGE)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    ec3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec3:SetCode(EVENT_ATTACK_ANNOUNCE)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCountLimit(1)
    ec3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return Duel.GetAttacker() == c or
                   (Duel.GetAttackTarget() and Duel.GetAttackTarget() == c) and
                   e:GetHandler():IsHasEffect(id)
    end)
    ec3:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then
            return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil,
                                              c)
        end

        local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 99, false,
                                              nil, c)
        e:SetLabel(g:GetSum(Card.GetBaseAttack))
        Duel.Release(g, REASON_COST)
    end)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsFacedown() or not c:IsRelateToEffect(e) or not c:IsHasEffect(id) then
            return
        end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(e:GetLabel())
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterRaEffect(c, ec1)
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterRaEffect(tc, ec3, true)

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
    ec4:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsHasEffect(id) then return end

        Utility.HintCard(c)
        local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
        Duel.SendtoGrave(g, REASON_EFFECT)
    end)
    ec4:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterRaEffect(tc, ec4, true)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id + 100000) == 0 and
                   Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE,
                                               LOCATION_MZONE, 1, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_MZONE,
                                      LOCATION_MZONE, 1, 1, c)
    Duel.SetTargetCard(g)

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
    c:RegisterFlagEffect(id + 100000, RESET_CHAIN, 0, 1)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
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

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.HintSelection(Group.FromCards(c))

    local tc = Dimension.Zones(c:GetOwner()):Filter(function(c)
        return c:IsCode(10000080) and c:IsType(Dimension.TYPE)
    end, nil):GetFirst()

    if tc then
        local divine_evolution = Divine.IsDivineEvolution(c)
        Dimension.Change(c, tc, c:GetMaterial())
        if divine_evolution then Divine.DivineEvolution(tc) end
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end
