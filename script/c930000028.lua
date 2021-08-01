-- Divine Nordic Relic Mjollnir
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {30604579}
s.listed_series = {0x4b}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsSetCard(0x4b) and
               not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsAbleToEnterBP() or
               (Duel.GetCurrentPhase() >= PHASE_BATTLE_START and
                   Duel.GetCurrentPhase() <= PHASE_BATTLE)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                              PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0,
                          aux.Stringid(id, 0))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_EXTRA_ATTACK)
    ec1:SetValue(1)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetCategory(CATEGORY_DAMAGE)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    ec2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_PLAYER_TARGET +
                        EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                        EFFECT_FLAG_CANNOT_INACTIVATE)
    ec2:SetCode(EVENT_BATTLE_DESTROYING)
    ec2:SetLabelObject(tc)
    ec2:SetCondition(s.e1dmgcon)
    ec2:SetTarget(s.e1dmgtg)
    ec2:SetOperation(s.e1dmgop)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
end

function s.e1dmgcon(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    return eg:IsContains(tc) and tc:GetFlagEffect(id) ~= 0
end

function s.e1dmgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(1000)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 1000)
end

function s.e1dmgop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
