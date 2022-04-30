-- Greisen, Dracodeity of the Chronology
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_LIGHT)
    UtilityDracodeity.RegisterEffect(c, id)

    -- nondisable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_CANNOT_DISEFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, ct)
        local p = e:GetHandler():GetControler()
        local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT,
            CHAININFO_TRIGGERING_PLAYER,
            CHAININFO_TRIGGERING_LOCATION)
        local tc = te:GetHandler()
        if tc == e:GetHandler() then return true end
        return p == tp and (loc & LOCATION_ONFIELD) ~= 0 and
            tc:GetMutualLinkedGroupCount() > 0
    end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1b:SetCode(EFFECT_CANNOT_DISABLE)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetTargetRange(LOCATION_MZONE, 0)
    e1b:SetTarget(function(e, c) return c:GetMutualLinkedGroupCount() > 0 end)
    e1b:SetValue(1)
    c:RegisterEffect(e1b)

    -- gain ATK
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetCode(EVENT_CHAINING)
    e2reg:SetRange(LOCATION_MZONE)
    e2reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e2reg)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- look and sort deck
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PREDRAW)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- take card & block activate
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 4))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:GetFlagEffect(1) == 0 then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(1000)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0
        and e:GetHandler():GetMutualLinkedGroupCount() > 0
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = math.min(c:GetMutualLinkedGroupCount(), Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0))
    if ct == 0 then return end

    local _ = ct == 1 and ct or Duel.AnnounceNumberRange(tp, 1, ct)
    Duel.SortDecktop(tp, tp, ct)
    local opt = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
    if opt == 1 then Duel.MoveToDeckBottom(ct, tp) end
end

function s.e4filter(c, e, tp)
    return c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_GRAVE + LOCATION_REMOVED
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, loc, loc, 1, c, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, PLAYER_ALL, loc)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, PLAYER_ALL, loc)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local loc = LOCATION_GRAVE + LOCATION_REMOVED
    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e4filter, tp, loc, loc, 1, 1, c, e, tp):GetFirst()
    if not tc then return end
    Duel.HintSelection(Group.FromCards(tc))

    if not tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) or Duel.GetLocationCount(tp, LOCATION_MZONE) == 0
        or not Duel.SelectYesNo(tp, 1075) then
        Duel.SendtoHand(tc, tp, REASON_EFFECT)
    else
        Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end
