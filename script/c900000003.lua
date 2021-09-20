-- Sun Divine Beast of Ra
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_names = {95286165}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, true, true)
    Divine.RegisterRaFuse(c)
    Divine.RegisterRaDefuse(s, c)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_WINGEDBEAST)
    Divine.RegisterEffect(c, e1)

    -- life point transfer
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2b:SetCode(EVENT_SUMMON_SUCCESS)
    Divine.RegisterEffect(c, e2b)
    local e2c = e2b:Clone()
    e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
    Divine.RegisterEffect(c, e2c)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    Divine.RegisterEffect(c, e3)

    -- unstoppable attack
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    Divine.RegisterEffect(c, e4)

    -- tribute monsters to up atk
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_ATKCHANGE)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_ATTACK_ANNOUNCE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.e5con)
    e5:SetCost(s.e5cost)
    e5:SetOperation(s.e5op)
    Divine.RegisterEffect(c, e5)

    -- after damage calculation
    local e6 = Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_TOGRAVE)
    e6:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_BATTLED)
    e6:SetCondition(s.e6con)
    e6:SetOperation(s.e6op)
    Divine.RegisterEffect(c, e6)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLP(tp) > 100 end

    local paidlp = Duel.GetLP(tp) - 100
    Duel.PayLPCost(tp, paidlp)
    e:SetLabelObject({c:GetBaseAttack() + paidlp, c:GetBaseDefense() + paidlp})
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(aux.FALSE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(id)
    ec1:SetLabelObject(e:GetLabelObject())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterRaEffect(c, ec1, true)

    if c:IsSummonType(SUMMON_TYPE_SPECIAL) and
        c:IsPreviousLocation(LOCATION_GRAVE) then
        local effs = {c:GetCardEffect(EFFECT_CANNOT_ATTACK)}
        for _, eff in pairs(effs) do
            if eff:GetHandler() == c then eff:Reset() end
        end
    end
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_MZONE,
                                LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    Duel.Destroy(tc, REASON_EFFECT)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsHasEffect(id) then return end
    return Duel.GetAttacker() == c or
               (Duel.GetAttackTarget() and Duel.GetAttackTarget() == c)
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 99, false, nil,
                                          c)
    e:SetLabel(g:GetSum(Card.GetBaseAttack))
    Duel.Release(g, REASON_COST)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
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
end

function s.e6con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c and c:IsHasEffect(id)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsHasEffect(id) then return end

    Utility.HintCard(c)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SendtoGrave(g, REASON_EFFECT)
end
