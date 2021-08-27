-- Palladium Illusion Oracle Mana
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_MAGICIAN}

function s.initial_effect(c)
    -- code & attribute
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(CARD_DARK_MAGICIAN_GIRL)
    c:RegisterEffect(code)
    local attribute = code:Clone()
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)

    -- special summon (from hand)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con1)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1b:SetCondition(s.e1con2)
    c:RegisterEffect(e1b)

    -- special summon (from grave)
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_CUSTOM + id)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local g = Group.CreateGroup()
    g:KeepAlive()
    e2:SetLabelObject(g)
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetCode(EVENT_SUMMON_SUCCESS)
    e2reg:SetRange(LOCATION_GRAVE)
    e2reg:SetLabelObject(e2)
    e2reg:SetOperation(s.e2regop)
    c:RegisterEffect(e2reg)
    local e2reg2 = e2reg:Clone()
    e2reg2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2reg2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id + 3000000)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, tp)
    return not c:IsOriginalCode(id) and c:IsLocation(LOCATION_MZONE) and
               c:IsFaceup() and c:IsControler(tp)
end

function s.e1con1(e, tp, eg, ep, ev, re, r, rp)
    if rp == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if not tg then return false end

    return tg:IsExists(s.e1filter, 1, nil, tp)
end

function s.e1con2(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsTurnPlayer(tp) or not Duel.GetAttackTarget() then return false end
    return s.e1filter(Duel.GetAttackTarget(), tp)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if g then
        g = g:Filter(Card.IsAbleToHandAsCost, nil)
    else
        g = Group.FromCards(Duel.GetAttackTarget()):Filter(
                Card.IsAbleToHandAsCost, nil)
    end
    if chk == 0 then return #g >= 1 end

    g = Utility.GroupSelect(g, tp, 1, 1, HINTMSG_RTOHAND)
    Duel.SendtoHand(g, nil, 1, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e2filter(c, tp)
    return c:IsFaceup() and c:IsCode(CARD_DARK_MAGICIAN) and
               c:IsSummonPlayer(tp) and c:IsLocation(LOCATION_MZONE)
end

function s.e2regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = eg:Filter(s.e2filter, nil, tp)
    if #tg == 0 then return end

    for tc in aux.Next(tg) do
        tc:RegisterFlagEffect(id, RESET_CHAIN + RESET_EVENT + RESETS_STANDARD,
                              0, 1)
    end
    local g = e:GetLabelObject():GetLabelObject()
    if Duel.GetCurrentChain() == 0 then g:Clear() end
    g:Merge(tg)
    g:Remove(function(c) return c:GetFlagEffect(id) == 0 end, nil)
    e:GetLabelObject():SetLabelObject(g)

    Duel.RaiseSingleEvent(c, EVENT_CUSTOM + id, e, 0, tp, tp, 0)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   e:GetLabelObject():IsExists(s.e2filter, 1, nil, tp) and
                   c:GetFlagEffect(id) == 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, 0)
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetAttackTarget()
    if tc and tc:IsControler(1 - tp) then tc = Duel.GetAttacker() end
    if not tc then return false end

    e:SetLabelObject(tc)
    return tc ~= e:GetHandler() and tc:IsRelateToBattle() and
               tc:IsRace(RACE_SPELLCASTER) and
               tc:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK) and c:IsFaceup() and
               c:GetAttack() > 0
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttackAnnouncedCount() == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    if c:IsFacedown() or tc:IsFacedown() or not tc:IsRelateToBattle() then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(c:GetAttack())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
    tc:RegisterEffect(ec1b)
end
