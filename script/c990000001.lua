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
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_DISEFFECT)
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
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(EFFECT_CANNOT_DISABLE)
    e1b:SetTargetRange(LOCATION_MZONE, 0)
    e1b:SetTarget(function(e, c) return c:GetMutualLinkedGroupCount() > 0 end)
    e1b:SetValue(1)
    c:RegisterEffect(e1b)

    -- gain ATK
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetRange(LOCATION_MZONE)
    e2reg:SetCode(EVENT_CHAINING)
    e2reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e2reg)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- look and sort deck
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_PREDRAW)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- return previous state
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 4))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    aux.GlobalCheck(s, function()
        local e4reg = Effect.CreateEffect(c)
        e4reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e4reg:SetCode(EVENT_ADJUST)
        e4reg:SetCountLimit(1)
        e4reg:SetOperation(s.e4regop)
        Duel.RegisterEffect(e4reg, 0)
    end)
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
    local prev_loc = c:GetFlagEffectLabel(id + 100)
    local prev_tp = c:GetFlagEffectLabel(id + 200)
    local prev_pos = c:GetFlagEffectLabel(id + 300)
    local prev_seq = c:GetFlagEffectLabel(id + 400)
    if c:IsLocation(prev_loc) and c:IsControler(prev_tp)
        and c:IsPosition(prev_pos) and c:IsSequence(prev_seq) then return false end

    if not c:IsType(TYPE_MONSTER) then return true end
    return (prev_loc & LOCATION_ONFIELD) == 0 or c:IsCanBeSpecialSummoned(e, 0, tp, false, false)

end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, loc, loc, 1, c, e, tp) end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local loc = LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED
    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e4filter, tp, loc, loc, 1, 1, c, e, tp):GetFirst()
    if not tc then return end
    Duel.HintSelection(Group.FromCards(tc))

    local prev_loc = tc:GetFlagEffectLabel(id + 100)
    local prev_tp = tc:GetFlagEffectLabel(id + 200)
    local prev_pos = tc:GetFlagEffectLabel(id + 300)
    local prev_seq = tc:GetFlagEffectLabel(id + 400)

    if prev_loc == LOCATION_HAND then
        Duel.SendtoHand(tc, prev_tp, REASON_EFFECT)
    elseif prev_loc == LOCATION_GRAVE then
        Duel.SendtoGrave(tc, REASON_EFFECT, prev_tp)
    elseif prev_loc == LOCATION_REMOVED then
        Duel.Remove(tc, prev_pos, REASON_EFFECT, prev_tp)
    elseif prev_loc == LOCATION_DECK then
        Duel.SendtoDeck(tc, prev_tp, prev_seq, REASON_EFFECT)
    elseif prev_loc == LOCATION_EXTRA then
        Duel.SendtoDeck(tc, prev_tp, prev_seq, REASON_EFFECT)
    else
        if tc:IsStatus(STATUS_LEAVE_CONFIRMED) then tc:CancelToGrave() end
        if tc:IsType(TYPE_FIELD) then prev_loc = LOCATION_FZONE end
        Duel.SpecialSummon(tc, 0, tp, prev_tp, false, false, prev_pos)
        if not tc:IsPosition(prev_pos) then Duel.ChangePosition(tc, prev_pos, prev_pos, prev_pos, prev_pos, true, true) end
    end

    Duel.NegateRelatedChain(tc, RESET_TURN_SET)
end

function s.e4regop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0x7f, 0x7f, nil)
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id + 100, RESET_PHASE + PHASE_END, 0, 1, tc:GetLocation())
        tc:RegisterFlagEffect(id + 200, RESET_PHASE + PHASE_END, 0, 1, tc:GetControler())
        tc:RegisterFlagEffect(id + 300, RESET_PHASE + PHASE_END, 0, 1, tc:GetPosition())
        tc:RegisterFlagEffect(id + 400, RESET_PHASE + PHASE_END, 0, 1, tc:GetSequence())
    end
end
