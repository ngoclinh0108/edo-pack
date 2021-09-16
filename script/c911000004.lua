-- Blue-Eyes Chaos Azure Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_BLUEEYES_W_DRAGON}
s.listed_series = {0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, 0xdd), 3, 3)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.lnklimit)
    c:RegisterEffect(splimit)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetDescription(aux.Stringid(id, 0))
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                       EFFECT_FLAG_IGNORE_IMMUNE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    sp:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(sp)

    -- untargetable & indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1b:SetValue(function(e, re, tp) return tp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- change position
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(528)
    e2:SetCategory(CATEGORY_POSITION + CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_SINGLE)
    e2b:SetCode(EFFECT_MATERIAL_CHECK)
    e2b:SetValue(s.e2val)
    c:RegisterEffect(e2b)

    -- pierce
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_PIERCE)
    e3:SetValue(DOUBLE_DAMAGE)
    c:RegisterEffect(e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.spfilter1(c)
    return c:IsType(TYPE_SPELL) and c:IsType(TYPE_RITUAL) and c:IsDiscardable()
end

function s.spfilter2(c, sc, tp)
    return c:IsCanBeLinkMaterial(sc, tp) and
               Duel.GetLocationCountFromEx(tp, tp, c, sc) > 0 and
               c:IsSummonCode(sc, SUMMON_TYPE_LINK, tp, CARD_BLUEEYES_W_DRAGON)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local g1 = Duel.GetMatchingGroup(s.spfilter1, tp, LOCATION_HAND, 0, c)
    local g2 = Duel.GetMatchingGroup(s.spfilter2, tp, LOCATION_MZONE, 0, nil, c,
                                     tp)
    return #g1 > 0 and #g2 > 0 and
               aux.SelectUnselectGroup(g1, e, tp, 1, 1, nil, 0) and
               aux.SelectUnselectGroup(g2, e, tp, 1, 1, nil, 0, c, tp)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local g1 = Duel.GetMatchingGroup(s.spfilter1, tp, LOCATION_HAND, 0, c)
    g1 = aux.SelectUnselectGroup(g1, e, tp, 1, 1, nil, 1, tp, HINTMSG_DISCARD,
                                 nil, nil, true)
    local g2 = Duel.GetMatchingGroup(s.spfilter2, tp, LOCATION_MZONE, 0, nil, c,
                                     tp)
    g2 = aux.SelectUnselectGroup(g2, e, tp, 1, 1, nil, 1, tp, HINTMSG_RELEASE,
                                 nil, nil, true)
    if #g1 > 0 and #g2 > 0 then
        g1:KeepAlive()
        g2:KeepAlive()
        e:SetLabelObject({g1, g2})
        return true
    end

    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g1 = e:GetLabelObject()[1]
    local g2 = e:GetLabelObject()[2]
    if not g1 or not g2 then return end

    c:SetMaterial(g2)
    Duel.SendtoGrave(g1, REASON_COST)
    Duel.SendtoGrave(g2, REASON_MATERIAL + REASON_LINK)

    g1:DeleteGroup()
    g2:DeleteGroup()
end

function s.e2con(e)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(id) ~= 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsCanChangePosition, tp, 0,
                                           LOCATION_MZONE, 1, nil)
    end

    local g = Duel.GetMatchingGroup(Card.IsCanChangePosition, tp, 0,
                                    LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetMatchingGroup(Card.IsCanChangePosition, tp, 0,
                                     LOCATION_MZONE, nil)
    if #tg == 0 or
        Duel.ChangePosition(tg, POS_FACEUP_DEFENSE, POS_FACEDOWN_DEFENSE,
                            POS_FACEUP_ATTACK, POS_FACEUP_ATTACK) == 0 then
        return
    end

    local og = Duel.GetOperatedGroup():Filter(Card.IsFaceup, nil)
    for tc in aux.Next(og) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec1:SetValue(0)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
        tc:RegisterEffect(ec1b)
    end
end

function s.e2val(e, c)
    local g = c:GetMaterial()
    if g:IsExists(Card.IsCode, 1, nil, CARD_BLUEEYES_W_DRAGON) then
        c:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD &
                                 ~(RESET_TOFIELD | RESET_LEAVE |
                                     RESET_TEMP_REMOVE),
                             EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 1))
    end
end

function s.e4filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsType(TYPE_NORMAL)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttackAnnouncedCount() == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_OATH +
                        EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e4filter, tp,
                                               LOCATION_HAND + LOCATION_GRAVE,
                                               0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e4filter), tp,
                                      LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1,
                                      nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
