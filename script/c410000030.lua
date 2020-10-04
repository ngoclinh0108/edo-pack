-- Palladium Immortal Soldier of Sun's God
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {410000008, 6368038, CARD_RA}
s.material = {410000008, 6368038}
s.material_setcode = {0xbd, 0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMix(c, false, false, 6368038, 410000008)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.fuslimit)
    c:RegisterEffect(splimit)

    -- immunity
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, tc, tp, sumtp) return tc == e:GetHandler() end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)
    local e1c = e1b:Clone()
    e1c:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(e1c)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdocon)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- summon ra
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- recover
    local e5 = Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_RECOVER)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1, id)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- reborn
    local e6 = Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e6:SetCode(EVENT_TO_GRAVE)
    e6:SetRange(LOCATION_GRAVE)
    e6:SetCondition(s.e6con)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local bc = Duel.GetAttackTarget()
    if chk == 0 then return bc:GetBaseAttack() > 0 end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = Duel.GetAttackTarget()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(bc:GetBaseAttack())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end

function s.e3con() return Duel.IsMainPhase() end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetFlagEffect(id) == 0 end
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1,
                                c)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then
        return
    end

    if c:UpdateAttack(-1000, RESET_EVENT + RESETS_STANDARD, c) == -1000 then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end

function s.e4con() return Duel.IsMainPhase() end

function s.e4filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and c:IsCode(CARD_RA)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsReleasable() end
    Duel.Release(c, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if c:GetSequence() < 5 then ft = ft + 1 end

    if chk == 0 then
        return
            Duel.IsExistingMatchingCard(s.e4filter, tp, loc, 0, 1, nil, e, tp) and
                ft > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e4filter, tp, loc, 0, 1, 1, nil, e,
                                       tp):GetFirst()
    if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, true, false, POS_FACEUP) then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, 0, 1)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_BASE_ATTACK)
        ec1:SetValue(4000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
        tc:RegisterEffect(ec1b)

        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec2:SetCode(EVENT_PHASE + PHASE_END)
        ec2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            return e:GetLabelObject():GetFlagEffect(id) ~= 0
        end)
        ec2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            Duel.SendtoGrave(e:GetLabelObject(), REASON_COST)
        end)
        ec2:SetCountLimit(1)
        ec2:SetReset(RESET_PHASE + PHASE_END)
        ec2:SetLabelObject(tc)
        Duel.RegisterEffect(ec2, tp)
    end
    Duel.SpecialSummonComplete()
end

function s.e5filter(c)
    return c:IsFaceup() and c:IsOriginalAttribute(ATTRIBUTE_DIVINE) and
               c:GetAttack() > 0
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, s.e5filter, 1, false, nil, nil)
    end

    local tc =
        Duel.SelectReleaseGroupCost(tp, s.e5filter, 1, 1, false, nil, nil):GetFirst()
    local rec = tc:GetAttack()
    Duel.Release(tc, REASON_COST)

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(rec)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, rec)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Recover(p, d, REASON_EFFECT)
end

function s.e6filter(c, tp)
    return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and
               c:IsCode(CARD_RA, 10000080, 10000090)
end

function s.e6con(e, tp, eg, ep, ev, re, r, rp)
    return not eg:IsContains(e:GetHandler()) and
               eg:IsExists(s.e6filter, 1, nil, tp)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetChainLimit(aux.FALSE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    if Duel.SpecialSummon(c, 0, tp, tp, true, true, POS_FACEUP) ~= 0 then
        c:CompleteProcedure()
    end
end
