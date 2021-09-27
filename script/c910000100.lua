-- Millennium Memory
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(TIMING_DAMAGE_STEP)
    e0:SetTarget(Utility.MultiEffectTarget(s))
    e0:SetOperation(Utility.MultiEffectOperation(s))
    c:RegisterEffect(e0)

    -- look at top your deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    Utility.RegisterMultiEffect(s, 1, e1)

    -- add monster
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    Utility.RegisterMultiEffect(s, 2, e2)

    -- add spell/trap
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    Utility.RegisterMultiEffect(s, 3, e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    Utility.RegisterMultiEffect(s, 4, e4)

    -- protect & atk up
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 4))
    e5:SetCategory(CATEGORY_ATKCHANGE)
    e5:SetOperation(s.e5op)
    Utility.RegisterMultiEffect(s, 5, e5)
end

function s.e1filter(c) return c:IsSetCard(0x13a) and c:IsAbleToHand() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 6
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) < 6 then return end

    local g = Duel.GetDecktopGroup(tp, 6)
    Duel.ConfirmCards(tp, g)
    if g:IsExists(s.e1filter, 1, nil) and Duel.SelectYesNo(tp, 506) then
        g = Utility.GroupSelect({
            hintmsg = HINTMSG_ATOHAND,
            g = g,
            tp = tp,
            filter = s.e1filter
        })
        Duel.DisableShuffleCheck()
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
        Duel.ShuffleHand(tp)
        Duel.SortDecktop(tp, tp, 5)
    else
        Duel.SortDecktop(tp, tp, 6)
    end
end

function s.e2filter(c)
    return c:IsSetCard(0x13a) and c:IsMonster() and c:IsAbleToHand()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp,
                                         aux.NecroValleyFilter(s.e2filter), tp,
                                         LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                         1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSetCard(0x13a) and
               c:IsAbleToHand()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp,
                                         aux.NecroValleyFilter(s.e3filter), tp,
                                         LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                         1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4filter1(c) return c:IsFaceup() and c:IsReleasableByEffect() end

function s.e4filter2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rg = Duel.GetMatchingGroup(s.e4filter1, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, nil)
    local sg = Duel.GetMatchingGroup(s.e4filter2, tp, LOCATION_HAND +
                                         LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                     e, tp)
    if chk == 0 then return #rg >= 2 and #sg >= 1 end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local rg = Duel.GetMatchingGroup(s.e4filter1, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, nil)
    local sg = Duel.GetMatchingGroup(s.e4filter2, tp, LOCATION_HAND +
                                         LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                     e, tp)
    if #rg < 2 or #sg == 0 then return end

    rg = Utility.GroupSelect(HINTMSG_RELEASE, rg, tp, 2)
    if Duel.Release(rg, REASON_EFFECT) ~= 2 then return end

    sg = Utility.GroupSelect(HINTMSG_SPSUMMON, sg, tp)
    if #sg > 0 then
        Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.e5filter(c) return c:IsFaceup() and c:IsSetCard(0x13a) end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e5filter, tp, LOCATION_MZONE, 0, nil)

    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3110)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_IMMUNE_EFFECT)
        ec1:SetOwnerPlayer(tp)
        ec1:SetValue(function(e, re)
            return e:GetHandler():GetOwner() ~= re:GetHandler():GetOwner()
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
    end

    local sc = Utility.GroupSelect(HINTMSG_FACEUP, g, tp):GetFirst()
    if not sc then return end
    Duel.HintSelection(Group.FromCards(sc))
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_UPDATE_ATTACK)
    ec2:SetValue(1000)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    sc:RegisterEffect(ec2)
end
