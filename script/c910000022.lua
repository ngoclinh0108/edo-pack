-- Chaos-Eyes Oracle Dragoon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {71703785, CARD_BLUEEYES_W_DRAGON}
s.material_setcode = {0x13a, 0xdd}
s.listed_names = {71703785, CARD_BLUEEYES_W_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, 71703785, {
        CARD_BLUEEYES_W_DRAGON, function(c, sc, sumtype, tp)
            return c:IsRace(RACE_DRAGON, sc, sumtype, tp) and
                       c:IsType(TYPE_EFFECT, sc, sumtype, tp)
        end
    })

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or
                   aux.fuslimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e1b)
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_SINGLE)
    e1c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetValue(aux.tgoval)
    c:RegisterEffect(e1c)
    local e1d = e1c:Clone()
    e1d:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1d:SetValue(1)
    c:RegisterEffect(e1d)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_SINGLE)
    e2b:SetCode(EFFECT_MATERIAL_CHECK)
    e2b:SetValue(s.e2matval)
    c:RegisterEffect(e2b)

    -- negate
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 4))
    e3:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:GetFlagEffect(id) > 0 then
        return c:GetFlagEffect(id + 100000) < 2
    else
        return c:GetFlagEffect(id + 100000) < 1
    end
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ct1 = Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    local ct2 = Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_SZONE, nil)
    if chk == 0 then return ct1 > 0 or ct2 > 0 end

    if (ct1 > ct2 and ct2 ~= 0) or ct1 == 0 then ct1 = ct2 end
    if ct1 ~= 0 then
        local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, ct1, 0, 0)
    end

    c:RegisterFlagEffect(id + 100000, RESET_EVENT + RESETS_STANDARD +
                             RESET_PHASE + PHASE_END, 0, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g1 = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    local g2 = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_SZONE, nil)
    if #g1 == 0 and #g2 == 0 then return end

    local ct = 0
    if #g1 == 0 then
        ct = Duel.Destroy(g2, REASON_EFFECT)
    elseif #g2 == 0 then
        ct = Duel.Destroy(g1, REASON_EFFECT)
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
        local opt = Duel.SelectOption(tp, aux.Stringid(id, 2),
                                      aux.Stringid(id, 3))
        if opt == 0 then
            ct = Duel.Destroy(g1, REASON_EFFECT)
        else
            ct = Duel.Destroy(g2, REASON_EFFECT)
        end
    end

    if not c:IsRelateToEffect(e) or c:IsFacedown() or ct == 0 then return end
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(ct * 500)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e2matval(e, c)
    if c:GetMaterial():IsExists(Card.IsCode, 1, nil, CARD_BLUEEYES_W_DRAGON) then
        c:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD &
                                 ~(RESET_TOFIELD | RESET_TEMP_REMOVE |
                                     RESET_LEAVE), EFFECT_FLAG_CLIENT_HINT, 1,
                             0, aux.Stringid(id, 0))
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return rc ~= c and Duel.IsChainNegatable(ev)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp,
                                           LOCATION_HAND, 0, 1, nil)
    end

    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end

    if rc:IsMonster() and c:IsRelateToEffect(e) and c:IsFaceup() then
        local atk = rc:GetTextAttack()
        if atk < 0 then atk = 0 end
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
    end
end
