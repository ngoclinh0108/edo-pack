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
                    tc:RegisterFlagEffect(
                        flag_id + 1000000000 * (tc:GetOwner() + 1), 0, 0, 1)
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

    -- cannot switch control
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    Divine.RegisterEffect(c, e1)

    -- cannot be Tributed, or be used as a material
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_RELEASE)
    e2:SetTargetRange(0, 1)
    e2:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    Divine.RegisterEffect(c, e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_SINGLE)
    e2b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2b:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    Divine.RegisterEffect(c, e2b)

    -- immune & indes & no battle damage
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        return c ~= tc and Divine.GetDivineHierarchy(tc) <=
                   Divine.GetDivineHierarchy(c)
    end)
    Divine.RegisterEffect(c, e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3b:SetValue(function(e, tc)
        return Divine.GetDivineHierarchy(tc) <=
                   Divine.GetDivineHierarchy(e:GetHandler())
    end)
    Divine.RegisterEffect(c, e3b)
    local e3c = e3b:Clone()
    e3c:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    Divine.RegisterEffect(c, e3c)

    -- attack limit
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_CANNOT_ATTACK)
    e4:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) == 0 end)
    Divine.RegisterEffect(c, e4)
    local e4b = Effect.CreateEffect(c)
    e4b:SetDescription(aux.Stringid(id, 3))
    e4b:SetCategory(CATEGORY_TOGRAVE)
    e4b:SetType(EFFECT_TYPE_QUICK_O)
    e4b:SetRange(LOCATION_MZONE)
    e4b:SetCode(EVENT_FREE_CHAIN)
    e4b:SetHintTiming(TIMING_MAIN_END + TIMINGS_CHECK_MONSTER)
    e4b:SetCondition(function(e) return Duel.GetCurrentPhase() < PHASE_END end)
    e4b:SetCost(s.e4cost)
    e4b:SetTarget(s.e4tg)
    e4b:SetOperation(s.e4op)
    Divine.RegisterEffect(c, e4b)
    local e4c = Effect.CreateEffect(c)
    e4c:SetCategory(CATEGORY_TOGRAVE)
    e4c:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4c:SetCode(EVENT_BATTLED)
    e4c:SetCondition(s.e4atkcon)
    e4c:SetOperation(s.e4atkop)
    Divine.RegisterEffect(c, e4c)

    -- return
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 4))
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EVENT_PHASE + PHASE_END)
    e5:SetCountLimit(1)
    e5:SetOperation(s.e5op)
    Divine.RegisterEffect(c, e5)
end

function s.dmsfilter(c, tp)
    local re = c:GetReasonEffect()
    if c:IsReason(REASON_REPLACE) then return false end
    return c:IsReason(REASON_EFFECT) and re and re:GetHandler() == c and
               c:IsControler(tp) and c:IsFaceup() and c:IsCode(Divine.CARD_RA)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
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

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACK)
    local tc = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 1,
                                       1, c):GetFirst()
    if not tc then return end

    Duel.ForceAttack(c, tc)
end

function s.e4atkcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker() == e:GetHandler() and
               e:GetHandler():GetBattleTarget()
end

function s.e4atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if not c:GetFlagEffect(id) or not bc:IsRelateToBattle() then return end

    Duel.SendtoGrave(bc, REASON_EFFECT + REASON_RULE)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
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
