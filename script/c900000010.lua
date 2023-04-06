-- The Chosen Pharaoh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {39913299, 10000000, 10000020, CARD_RA, 10000040}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetHintTiming(0, TIMING_END_PHASE)
    c:RegisterEffect(act)

    -- inactivatable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e1b)
    
    -- call holactie
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetHintTiming(0, TIMING_END_PHASE)
    e2:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- leaving the field
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon "egyptian god"
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetHintTiming(0, TIMING_END_PHASE)
    e4:SetCountLimit(1, {id, 1})
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- search "the true name"
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetHintTiming(0, TIMING_END_PHASE)
    e5:SetCountLimit(1, {id, 1})
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- add or set "egyptian god" spell/trap
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 3))
    e6:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_SZONE)
    e6:SetHintTiming(0, TIMING_END_PHASE)
    e6:SetCountLimit(1, {id, 1})
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e1val(e, ct)
    local p = e:GetHandler():GetControler()
    local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER,
        CHAININFO_TRIGGERING_LOCATION)
    local tc = te:GetHandler()
    return p == tp and tc:IsCode(39913299) and (loc & LOCATION_ONFIELD) ~= 0
end

function s.e2filter1(c, code)
    local code1, code3 = c:GetOriginalCodeRule()
    return code1 == code or code3 == code
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil, 10000000) and
               Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil, 10000020) and
               Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil, CARD_RA)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.CreateToken(tp, 10000040)
    Duel.SendtoHand(tc, tp, REASON_EFFECT)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e4filter(c, e, tp) return c:IsCode(10000000, 10000020, CARD_RA) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil, e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e4filter), tp,
        LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e5filter(c) return c:IsCode(39913299) and c:IsAbleToHand() end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e5filter), tp,
        LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e6filter(c, tp)
    return c:IsSpellTrap() and c:ListsCode(10000000, 10000020, CARD_RA) and
               not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, c:GetCode()), tp, LOCATION_ONFIELD + LOCATION_GRAVE,
            0, 1, nil) and (c:IsSSetable() or c:IsAbleToHand())
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_DECK, 0, 1, nil, tp) end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.e6filter, tp, LOCATION_DECK, 0, 1, 1, nil, tp):GetFirst()
    if not tc then return end

    aux.ToHandOrElse(tc, tp, function(c) return tc:IsSSetable() end, function(c) Duel.SSet(tp, tc) end, 1159)
end
