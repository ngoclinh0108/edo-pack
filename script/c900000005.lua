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
            local atk = mc:GetAttack()
            local def = mc:GetDefense()

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
            Divine.RegisterGrantEffect(c, ec1, true)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
            ec1b:SetValue(def)
            Divine.RegisterGrantEffect(c, ec1b, true)
        end
    })

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetValue(RACE_PYRO)
    Divine.RegisterEffect(c, e1)

    -- cannot switch control
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    Divine.RegisterEffect(c, e2)

    -- cannot be Tributed, or be used as a material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_CANNOT_RELEASE)
    e3:SetTargetRange(0, 1)
    e3:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    Divine.RegisterEffect(c, e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_SINGLE)
    e3b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e3b:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    Divine.RegisterEffect(c, e3b)

    -- immune & indes & no battle damage
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        return c ~= tc and Divine.GetDivineHierarchy(tc) <=
                   Divine.GetDivineHierarchy(c)
    end)
    Divine.RegisterEffect(c, e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4b:SetValue(function(e, tc)
        return Divine.GetDivineHierarchy(tc) <=
                   Divine.GetDivineHierarchy(e:GetHandler())
    end)
    Divine.RegisterEffect(c, e4b)
    local e4c = e4b:Clone()
    e4c:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    Divine.RegisterEffect(c, e4c)

    -- attack limit
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_CANNOT_ATTACK)
    e5:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) == 0 end)
    Divine.RegisterEffect(c, e5)
    local e5b = Effect.CreateEffect(c)
    e5b:SetDescription(aux.Stringid(id, 3))
    e5b:SetCategory(CATEGORY_TOGRAVE)
    e5b:SetType(EFFECT_TYPE_QUICK_O)
    e5b:SetRange(LOCATION_MZONE)
    e5b:SetCode(EVENT_FREE_CHAIN)
    e5b:SetHintTiming(TIMING_MAIN_END + TIMINGS_CHECK_MONSTER)
    e5b:SetCondition(function(e) return Duel.GetCurrentPhase() < PHASE_END end)
    e5b:SetCost(s.e5cost)
    e5b:SetTarget(s.e5tg)
    e5b:SetOperation(s.e5op)
    Divine.RegisterEffect(c, e5b)
    local e5c = Effect.CreateEffect(c)
    e5c:SetCategory(CATEGORY_TOGRAVE)
    e5c:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e5c:SetCode(EVENT_BATTLED)
    e5c:SetCondition(s.e5atkcon)
    e5c:SetOperation(s.e5atkop)
    Divine.RegisterEffect(c, e5c)

    -- return
    local e8 = Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id, 4))
    e8:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCode(EVENT_PHASE + PHASE_END)
    e8:SetCountLimit(1)
    e8:SetOperation(s.e8op)
    Divine.RegisterEffect(c, e8)
end

function s.dmsfilter(c, tp)
    local re = c:GetReasonEffect()
    if c:IsReason(REASON_REPLACE) then return false end
    return c:IsReason(REASON_EFFECT) and re and re:GetHandler() == c and
               c:IsControler(tp) and c:IsFaceup() and c:IsCode(Divine.CARD_RA)
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and c:IsAttackPos() and
                   Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE,
                                               1, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, 0, LOCATION_MZONE)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_BATTLE, 0, 1)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACK)
    local tc = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 1,
                                       1, c):GetFirst()
    if not tc then return end

    Duel.ForceAttack(c, tc)
end

function s.e5atkcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker() == e:GetHandler() and
               e:GetHandler():GetBattleTarget()
end

function s.e5atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if not c:GetFlagEffect(id) or not bc:IsRelateToBattle() then return end

    Duel.SendtoGrave(bc, REASON_EFFECT + REASON_RULE)
end

function s.e8op(e, tp, eg, ep, ev, re, r, rp)
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
