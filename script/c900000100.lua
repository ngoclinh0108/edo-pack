-- Emissary of the Divine Beasts
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_names = {
    Divine.CARD_OBELISK, 79868386, Divine.CARD_SLIFER, 42469671, Divine.CARD_RA,
    4059313, Divine.CARD_DEFUSION
}
s.listed_names = {0x13a}

function s.initial_effect(c)
    -- link summon
    Link.AddProcedure(c, s.lnkfilter, 1, 1)

    -- summon cannot be negate & act limit
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
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
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e2)

    -- triple tribute
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e3:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e3:SetValue(function(e, c) return c:IsRace(RACE_DIVINE) end)
    c:RegisterEffect(e3)

    -- add card
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BE_PRE_MATERIAL)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.lnkfilter(c, sc, sumtype, tp)
    return c:IsSetCard(0x13a, sc, sumtype, tp) and
               not c:IsType(TYPE_TOKEN, sc, sumtype, tp)
end

function s.e1filter(c) return c:GetAttack() > 0 end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_GRAVE, 0, 1, nil,
                                     e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_GRAVE, 0, 1, 3, nil, e, tp)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS):Filter(
                   Card.IsRelateToEffect, nil, e)
    if #tg == 0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local atk = tg:GetSum(Card.GetAttack)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return r == REASON_SUMMON and rc:IsFaceup()
end

function s.e4check(tp, code)
    return not Utility.IsOwnAny(Card.IsCode, tp, code) or
               Duel.IsExistingMatchingCard(function(c)
            return c:IsCode(code) and c:IsAbleToHand()
        end, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local sel = {}
    local opt = {}
    table.insert(opt, 666000)
    table.insert(sel, 0)
    if (rc:IsOriginalCodeRule(Divine.CARD_OBELISK)) then
        if s.e4check(tp, 79868386) then
            table.insert(opt, aux.Stringid(id, 0))
            table.insert(sel, 79868386)
        end
    elseif (rc:IsOriginalCodeRule(Divine.CARD_SLIFER)) then
        if s.e4check(tp, 42469671) then
            table.insert(opt, aux.Stringid(id, 1))
            table.insert(sel, 42469671)
        end
    elseif (rc:IsOriginalCodeRule(Divine.CARD_RA)) then
        if s.e4check(tp, 4059313) then
            table.insert(opt, aux.Stringid(id, 2))
            table.insert(sel, 4059313)
        end
        if s.e4check(tp, Divine.CARD_DEFUSION) then
            table.insert(opt, aux.Stringid(id, 3))
            table.insert(sel, Divine.CARD_DEFUSION)
        end
    end

    if #opt <= 1 then return end
    local code = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    if code == 0 then return end

    local tc
    if not Utility.IsOwnAny(Card.IsCode, tp, code) then
        tc = Duel.CreateToken(tp, code)
    else
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, function(c)
            return c:IsCode(code) and c:IsAbleToHand()
        end, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    end

    if not tc then return end
    Utility.HintCard(c)
    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
end
