-- Sun Dragon's Palladium Descendant
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_names = {95286165, CARD_RA}

function s.initial_effect(c)
    -- link summon
    Link.AddProcedure(c, aux.NOT(
                          aux.FilterBoolFunctionEx(Card.IsType, TYPE_TOKEN)), 1,
                      1)

    -- summon cannot be negate & act limit
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    sumsafe:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK
    end)
    c:RegisterEffect(sumsafe)
    local sumsafeb = Effect.CreateEffect(c)
    sumsafeb:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    sumsafeb:SetCode(EVENT_SPSUMMON_SUCCESS)
    sumsafeb:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK
    end)
    sumsafeb:SetOperation(function()
        Duel.SetChainLimitTillChainEnd(function(e, rp, tp)
            return tp == rp
        end)
    end)
    c:RegisterEffect(sumsafeb)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY +
                       EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    Divine.RegisterEffect(c, e2)

    -- extra summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_DIVINE))
    c:RegisterEffect(e3)

    -- search
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1, id)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- gain effect
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_BE_PRE_MATERIAL)
    e5:SetCondition(s.e5regcon)
    e5:SetOperation(s.e5regop)
    c:RegisterEffect(e5)

    Divine.RegisterRaDefuse(s, id, c)
end

function s.e1filter(c) return c:GetTextAttack() > 0 end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_GRAVE,
                                     LOCATION_GRAVE, 1, nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 2,
                      nil, e, tp)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS):Filter(
                   Card.IsRelateToEffect, nil, e)
    if #tg == 0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    for tc in aux.Next(tg) do
        if tc:GetTextAttack() > 0 then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_UPDATE_ATTACK)
            ec1:SetValue(tc:GetTextAttack())
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE +
                             PHASE_END)
            c:RegisterEffect(ec1)
        end
    end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, #tg))
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(#tg == 1 and EFFECT_DOUBLE_TRIBUTE or EFFECT_TRIPLE_TRIBUTE)
    ec2:SetValue(aux.TargetBoolFunction(Card.IsRace, RACE_DIVINE))
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec2)
end

function s.e4filter(c) return c:IsCode(95286165) and c:IsAbleToHand() end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp,
                                         aux.NecroValleyFilter(s.e4filter), tp,
                                         LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                         1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e5regcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return r == REASON_SUMMON and rc:IsFaceup() and rc:IsCode(CARD_RA)
end

function s.e5regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    rc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD,
                          EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 3))

    -- life point transfer
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 4))
    ec1:SetType(EFFECT_TYPE_QUICK_O)
    ec1:SetProperty(EFFECT_FLAG_NO_TURN_RESET + EFFECT_FLAG_DAMAGE_STEP +
                        EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_UNCOPYABLE)
    ec1:SetCode(EVENT_FREE_CHAIN)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetHintTiming(TIMING_DAMAGE_STEP,
                      TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
    ec1:SetCountLimit(1)
    ec1:SetCost(s.e5lpcost)
    ec1:SetTarget(s.e5lptg)
    ec1:SetOperation(s.e5lpop)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec1)
    Divine.RegisterRaFuse(id, c, rc, true)

    if not rc:IsOriginalCode(CARD_RA) then
        -- destroy
        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(1100)
        ec2:SetCategory(CATEGORY_DESTROY)
        ec2:SetType(EFFECT_TYPE_IGNITION)
        ec2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_IGNORE_IMMUNE +
                            EFFECT_FLAG_UNCOPYABLE)
        ec2:SetRange(LOCATION_MZONE)
        ec2:SetCost(s.e5descost)
        ec2:SetTarget(s.e5destg)
        ec2:SetOperation(s.e5desop)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        rc:RegisterEffect(ec2)
    end
end

function s.e5lpcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLP(tp) > 100 end

    local lp = Duel.GetLP(tp)
    e:SetLabel(lp - 100)
    Duel.PayLPCost(tp, lp - 100)
end

function s.e5lptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(aux.FALSE)
end

function s.e5lpop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local label = {
        c:GetBaseAttack() + e:GetLabel(), c:GetBaseDefense() + e:GetLabel()
    }

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 4))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_UNCOPYABLE +
                        EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(id)
    ec1:SetLabelObject(label)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
end

function s.e5descost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e5destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_MZONE,
                                LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e5desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    Duel.Destroy(tc, REASON_EFFECT)
end
