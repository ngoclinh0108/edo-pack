-- Palladium Draconic Titan of War's God
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {CARD_BLUEEYES_W_DRAGON, 410000006}
s.material_setcode = {0xdd, 0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMix(c, false, false, CARD_BLUEEYES_W_DRAGON, 410000006)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e,se,sp,st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
    end)
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

    -- tribute substitute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_EXTRA_RELEASE_NONSUM)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetValue(function(e, re, r, rp)
        return re:GetHandler() ~= e:GetHandler() and re:IsActivated() and (r & REASON_COST) ~= 0
    end)
    c:RegisterEffect(e2)

    -- indes
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- gain effect
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4cost)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.synfilter(c, val, sc, sumtype, tp)
    return c:IsSetCard(0xdd, sc, sumtype, tp) and
               c:IsRace(RACE_DRAGON, sc, sumtype, tp) and
               c:IsType(TYPE_NORMAL, sc, sumtype, tp)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0,
                                       1, 1, nil):GetFirst()
    if not tc then return end

    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD_DISABLE +
                              RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT,
                          1, 0, aux.Stringid(id, 0))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_EXTRA_ATTACK)
    ec1:SetValue(2)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)

    -- unstoppable attack
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SINGLE_RANGE)
    ec2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec2)

    -- inflict damage
    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(aux.Stringid(id, 2))
    ec3:SetCategory(CATEGORY_DAMAGE)
    ec3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    ec3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec3:SetCode(EVENT_BATTLE_DESTROYING)
    ec3:SetCondition(aux.bdocon)
    ec3:SetTarget(s.e4dmgtg)
    ec3:SetOperation(s.e4dmgop)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec3)
end

function s.e4dmgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    local dmg = bc:GetAttack()
    if bc:GetAttack() < bc:GetDefense() then dmg = bc:GetDefense() end
    if dmg < 0 then dmg = 0 end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e4dmgop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
