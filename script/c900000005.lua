-- Sun Divine Beast of Ra - Immortal Phoenix
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {Divine.CARD_RA, Divine.CARD_RA_SPHERE}

function s.initial_effect(c)
    s.divine_hierarchy = 2
    Dimension.AddProcedure(c)

    -- dimension change (special summon)
    Dimension.RegisterChange({
        handler = c,
        flag_id = id + 100000,
        event_code = EVENT_SPSUMMON_SUCCESS,
        filter = function(c, sc)
            return
                c:IsCode(Divine.CARD_RA) and c:GetOwner() == sc:GetOwner() and
                    c:IsPreviousLocation(LOCATION_GRAVE)
        end,
        custom_op = function(e, tp, mc)
            local c = e:GetHandler()
            Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
            local op = Duel.SelectOption(tp, aux.Stringid(id, 1),
                                         aux.Stringid(id, 2))
            if op == 0 then return end

            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.DivineEvolution(c) end
        end
    })

    -- dimension change (self destroy)
    Dimension.RegisterChange({
        handler = c,
        flag_id = id + 200000,
        custom_reg = function(c, flag_id)
            local dms = Effect.CreateEffect(c)
            dms:SetType(EFFECT_TYPE_CONTINUOUS)
            dms:SetCode(EFFECT_DESTROY_REPLACE)
            dms:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
                local sc = e:GetHandler()
                local g = eg:Filter(s.dmsfilter, nil, sc:GetOwner())
                if chk == 0 then return #g > 0 end
                for tc in aux.Next(g) do
                    tc:RegisterFlagEffect(flag_id, 0, 0, 1)
                end
                return true
            end)
            dms:SetValue(function(e, c)
                return s.dmsfilter(c, e:GetHandler():GetOwner())
            end)
            Duel.RegisterEffect(dms, 0)
        end,
        custom_op = function(e, tp, mc)
            local c = e:GetHandler()
            local atk = mc:GetBaseAttack()
            local def = mc:GetBaseDefense()

            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.DivineEvolution(c) end

            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            ec1:SetRange(LOCATION_MZONE)
            ec1:SetCode(EFFECT_SET_BASE_ATTACK)
            ec1:SetValue(atk)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            Divine.RegisterRaEffect(c, ec1, true)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
            ec1b:SetValue(def)
            Divine.RegisterRaEffect(c, ec1b, true)
        end
    })

    -- effects cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE)
    Divine.RegisterEffect(c, e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1b:SetTargetRange(1, 0)
    e1b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    Divine.RegisterEffect(c, e1b)
    local e1c = e1b:Clone()
    e1c:SetCode(EFFECT_CANNOT_DISEFFECT)
    Divine.RegisterEffect(c, e1c)

    -- race
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_ADD_RACE)
    e2:SetValue(RACE_PYRO)
    Divine.RegisterEffect(c, e2)

    -- cannot switch control
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    Divine.RegisterEffect(c, e3)

    -- cannot be Tributed, or be used as a material
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_CANNOT_RELEASE)
    e4:SetTargetRange(0, 1)
    e4:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    Divine.RegisterEffect(c, e4)
    local e4b = Effect.CreateEffect(c)
    e4b:SetType(EFFECT_TYPE_SINGLE)
    e4b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e4b:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    Divine.RegisterEffect(c, e4b)

    -- immune & indes & no battle damage
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        return c ~= tc and Divine.GetDivineHierarchy(c) >=
                   Divine.GetDivineHierarchy(tc)
    end)
    Divine.RegisterEffect(c, e5)
    local e5b = e5:Clone()
    e5b:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e5b:SetValue(function(e, tc)
        return Divine.GetDivineHierarchy(e:GetHandler()) >=
                   Divine.GetDivineHierarchy(tc)
    end)
    Divine.RegisterEffect(c, e5b)
    local e5c = e5b:Clone()
    e5c:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    Divine.RegisterEffect(c, e5c)

    -- attack limit
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_CANNOT_ATTACK)
    e6:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) == 0 end)
    Divine.RegisterEffect(c, e6)
    local e6b = Effect.CreateEffect(c)
    e6b:SetDescription(aux.Stringid(id, 3))
    e6b:SetCategory(CATEGORY_TOGRAVE)
    e6b:SetType(EFFECT_TYPE_QUICK_O)
    e6b:SetRange(LOCATION_MZONE)
    e6b:SetCode(EVENT_FREE_CHAIN)
    e6b:SetHintTiming(TIMING_MAIN_END + TIMINGS_CHECK_MONSTER)
    e6b:SetCondition(function(e) return Duel.GetCurrentPhase() < PHASE_END end)
    e6b:SetCost(s.e6cost)
    e6b:SetTarget(s.e6tg)
    e6b:SetOperation(s.e6op)
    Divine.RegisterEffect(c, e6b)
    local e6c = Effect.CreateEffect(c)
    e6c:SetCategory(CATEGORY_TOGRAVE)
    e6c:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e6c:SetCode(EVENT_BATTLED)
    e6c:SetCondition(s.e6atkcon)
    e6c:SetOperation(s.e6atkop)
    Divine.RegisterEffect(c, e6c)

    -- return
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 4))
    e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCode(EVENT_PHASE + PHASE_END)
    e7:SetCountLimit(1)
    e7:SetOperation(s.e7op)
    Divine.RegisterEffect(c, e7)
end

function s.dmsfilter(c, tp)
    local re = c:GetReasonEffect()
    if c:IsReason(REASON_REPLACE) then return false end
    return c:IsReason(REASON_EFFECT) and re and re:GetHandler() == c and
               c:IsControler(tp) and c:IsFaceup() and c:IsCode(Divine.CARD_RA)
end

function s.e6cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE,
                                               1, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, 0, LOCATION_MZONE)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_BATTLE, 0, 1)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACK)
    local tc = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 1,
                                       1, c):GetFirst()
    if not tc then return end

    Duel.ForceAttack(c, tc)
end

function s.e6atkcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker() == e:GetHandler() and
               e:GetHandler():GetBattleTarget()
end

function s.e6atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if not c:GetFlagEffect(id) or not bc:IsRelateToBattle() then return end

    Duel.SendtoGrave(bc, REASON_EFFECT + REASON_RULE)
end

function s.e7op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.HintSelection(Group.FromCards(c))

    local tc = Dimension.Zones(c:GetOwner()):Filter(function(c)
        return c:IsCode(Divine.CARD_RA_SPHERE) and c:IsType(Dimension.TYPE)
    end, nil):GetFirst()

    if tc then
        local divine_evolution = Divine.IsDivineEvolution(c)
        Dimension.Change(c, tc, c:GetMaterial())
        if divine_evolution then Divine.DivineEvolution(tc) end
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end
