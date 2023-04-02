-- Void-Eyes Infernity Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("c419.lua")
local s, id = GetID()

s.listed_series = {0xb}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_DARK), 1, 1,
        Synchro.NonTunerEx(Card.IsRace, RACE_FIEND), 1, 99)

    -- cannot be Tributed, or be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
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

    -- gain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- zero gate of the void
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL + EFFECT_FLAG_DELAY)
    e3:SetCode(511002521)
    e3:SetRange(LOCATION_EXTRA + LOCATION_GRAVE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3b:SetTargetRange(1, 0)
    e3b:SetCode(511000793)
    e3b:SetLabel(0)
    e3b:SetLabelObject(e3)
    Duel.RegisterEffect(e3b, 0)
    local e3c = e3b:Clone()
    e3c:SetLabel(1)
    Duel.RegisterEffect(e3c, 1)
end

function s.e2filter1(c) return c:IsSetCard(0xb) and c:IsMonster() and not c:IsCode(id) end

function s.e2filter2(c, code) return c:IsOriginalCode(code) and c:IsSetCard(0xb) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter1, tp, LOCATION_GRAVE, 0, nil)
    g:Remove(function(c, sc) return sc:GetFlagEffect(c:GetOriginalCode()) > 0 end, nil, c)
    if c:IsFacedown() or #g <= 0 then return end

    repeat
        local tc = g:GetFirst()
        local code = tc:GetOriginalCode()
        local cid = c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD, 1)
        c:RegisterFlagEffect(code, RESET_EVENT + RESETS_STANDARD, 0, 0)

        local ec0 = Effect.CreateEffect(c)
        ec0:SetCode(id)
        ec0:SetLabel(code)
        ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec0, true)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EVENT_ADJUST)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetLabel(cid)
        ec1:SetLabelObject(ec0)
        ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            local g = Duel.GetMatchingGroup(s.e2filter1, tp, LOCATION_GRAVE, 0, nil)
            if not g:IsExists(s.e2filter2, 1, nil, e:GetLabelObject():GetLabel()) or c:IsDisabled() then
                c:ResetEffect(e:GetLabel(), RESET_COPY)
                c:ResetFlagEffect(e:GetLabelObject():GetLabel())
            end
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1, true)

        g:Remove(s.e2filter2, nil, code)
    until #g <= 0
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) <= 0 end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CANNOT_LOSE_LP)
    ec1:SetTargetRange(1, 0)
    ec1:SetReset(RESET_CHAIN)
    Duel.RegisterEffect(ec1, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE + LOCATION_EXTRA)
    Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 or
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) == 0 then return end

    -- hint
    local ec0 = Effect.CreateEffect(c)
    ec0:SetDescription(aux.Stringid(id, 1))
    ec0:SetType(EFFECT_TYPE_SINGLE)
    ec0:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec0:SetCode(id)
    ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec0)

    -- cannot lose
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CANNOT_LOSE_DECK)
    ec1:SetTargetRange(1, 0)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_LOSE_LP)
    Duel.RegisterEffect(ec1b, tp)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
    Duel.RegisterEffect(ec1c, tp)
    local ec1d = Effect.CreateEffect(c)
    ec1d:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec1d:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_SET_AVAILABLE)
    ec1d:SetCode(EVENT_LEAVE_FIELD)
    ec1d:SetLabel(1 - tp)
    ec1d:SetLabelObject(ec1c)
    ec1d:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        e:GetLabelObject():Reset()
        Duel.Win(e:GetLabel(), WIN_REASON_ZERO_GATE)
    end)
    c:RegisterEffect(ec1d)

    -- negate activation
    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 2))
    ec2:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY + CATEGORY_ATKCHANGE)
    ec2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    ec2:SetType(EFFECT_TYPE_QUICK_O)
    ec2:SetCode(EVENT_CHAINING)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetCountLimit(1)
    ec2:SetCondition(s.e3negcon)
    ec2:SetTarget(s.e3negtg)
    ec2:SetOperation(s.e3negop)
    c:RegisterEffect(ec2)
end

function s.e3negcon(e, tp, eg, ep, ev, re, r, rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep == 1 - tp and Duel.IsChainNegatable(ev) and
               Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) == 0
end

function s.e3negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e3negop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg, REASON_EFFECT) ~= 0 and
        c:IsRelateToEffect(e) and c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(500)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
    end
end
