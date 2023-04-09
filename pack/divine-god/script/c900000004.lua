-- Sun Divine Dragon of Ra - Sphere Mode
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 78665705}

function s.initial_effect(c)
    s.divine_hierarchy = 2
    Dimension.AddProcedure(c)

    -- dimension change
    Dimension.RegisterChange({
        handler = c,
        event_code = EVENT_SUMMON_SUCCESS,
        filter = function(c, sc) return c:IsCode(CARD_RA) and c:GetOwner() == sc:GetOwner() end,
        custom_op = function(e, tp, mc)
            local c = e:GetHandler()

            if mc:IsControler(tp) then
                local atk = 0
                local def = 0
                local mg = mc:GetMaterial()
                for tc in aux.Next(mg) do
                    atk = atk + tc:GetPreviousAttackOnField()
                    def = def + tc:GetPreviousDefenseOnField()
                end

                Utility.HintCard(c)
                s.battlemode(c, mc, atk, def)
            else
                local divine_evolution = Divine.IsDivineEvolution(mc)
                Dimension.Change(mc, c)
                if divine_evolution then Divine.DivineEvolution(c) end
            end
        end
    })

    -- cannot be Tributed, or be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    c:RegisterEffect(e1c)

    -- immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        return c ~= tc and Divine.GetDivineHierarchy(tc) < Divine.GetDivineHierarchy(c)
    end)
    c:RegisterEffect(e2)

    -- cannot attack
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e3)

    -- untargetable
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
    c:RegisterEffect(e4b)

    -- battle mode
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_BOTH_SIDE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.e5con)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e1con(e, c, minc, zone, relzone, exeff)
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

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, c, minc, zone, relzone, exeff)
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

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c, minc, zone, relzone, exeff)
    local g = e:GetLabelObject()
    local atk = 0
    local def = 0
    for tc in aux.Next(g) do
        atk = atk + tc:GetAttack()
        def = def + tc:GetDefense()
    end

    local ec0 = Effect.CreateEffect(c)
    ec0:SetType(EFFECT_TYPE_SINGLE)
    ec0:SetCode(id)
    ec0:SetLabelObject({atk, def})
    c:RegisterEffect(ec0)

    c:SetMaterial(g)
    Duel.Release(g, REASON_SUMMON + REASON_MATERIAL)
    g:DeleteGroup()
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and Duel.GetTurnCount() ~= e:GetHandler():GetTurnID()
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 78665705)
    if chk == 0 then return tp == c:GetOwner() or #g > 0 end

    if tp ~= c:GetOwner() and #g > 0 then Duel.ConfirmCards(1 - tp, g:GetFirst()) end
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()
    if chk == 0 then
        return mc and Dimension.CanBeDimensionChanged(mc) and
                   (c:GetControler() == tp or Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)
    end
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetMaterial():GetFirst()

    local atk = 0
    local def = 0
    if tc:GetCardEffect(id) ~= nil then
        local eff = tc:GetCardEffect(id)
        atk = eff:GetLabelObject()[1]
        def = eff:GetLabelObject()[2]
        eff:Reset()
    else
        atk = 4000
        def = 4000
    end

    local divine_evolution = Divine.IsDivineEvolution(c)
    Dimension.Change(c, tc, tc:GetMaterial(), tp, tp, POS_FACEUP)
    if divine_evolution then Divine.DivineEvolution(tc) end

    s.battlemode(c, tc, atk, def)
    Utility.ResetListEffect(c, nil, EFFECT_CANNOT_ATTACK)
end

function s.battlemode(c, tc, atk, def)
    -- set base atk/def
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    tc:RegisterEffect(ec1b)
end
