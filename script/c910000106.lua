-- Palladium Magical Circle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetTarget(s.e0tg)
    e0:SetOperation(s.e0op)
    c:RegisterEffect(e0)
    s.eff = {}

    -- look at top your deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    s.eff[1] = e1

    -- add monster
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    s.eff[2] = e2

    -- add spell/trap
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    s.eff[3] = e3

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    s.eff[4] = e4
end

function s.e0tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        for i = 1, #s.eff, 1 do
            if s.eff[i]:GetTarget()(e, tp, eg, ep, ev, re, r, rp, chk) then
                return true
            end
        end
        return false
    end

    local opt = {}
    local sel = {}
    for i = 1, #s.eff, 1 do
        if s.eff[i]:GetTarget()(e, tp, eg, ep, ev, re, r, rp, 0) then
            table.insert(opt, s.eff[i]:GetDescription())
            table.insert(sel, i)
        end
    end

    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    e:SetLabel(op)
    e:SetCategory(s.eff[op]:GetCategory())
    s.eff[op]:GetTarget()(e, tp, eg, ep, ev, re, r, rp, chk)
end

function s.e0op(e, tp, eg, ep, ev, re, r, rp)
    s.eff[e:GetLabel()]:GetOperation()(e, tp, eg, ep, ev, re, r, rp)
end

function s.e1filter(c) return c:IsSetCard(0x13a) and c:IsAbleToHand() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 5
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) < 5 then return end

    local g = Duel.GetDecktopGroup(tp, 5)
    Duel.ConfirmCards(tp, g)
    if g:IsExists(s.e1filter, 1, nil) and Duel.SelectYesNo(tp, 506) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        g = g:FilterSelect(tp, s.e1filter, 1, 1, nil)

        Duel.DisableShuffleCheck()
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
        Duel.ShuffleHand(tp)
        Duel.SortDecktop(tp, tp, 4)
    else
        Duel.SortDecktop(tp, tp, 5)
    end
end

function s.e2filter(c)
    return c:IsSetCard(0x13a) and c:IsRace(RACE_SPELLCASTER) and
               c:IsAbleToHand()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e2filter), tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and
               Utility.IsSetCardListed(c, 0x13a) and not c:IsCode(id) and
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
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e3filter), tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)
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

    rg = Utility.GroupSelect(HINTMSG_RELEASE, rg, tp, 2, 2, nil)
    -- local rg = Duel.SelectMatchingCard(tp, s.e4filter1, tp, LOCATION_MZONE,
    --                                    LOCATION_MZONE, 2, 2, nil)
    -- if #rg ~= 2 or Duel.Release(rg, REASON_EFFECT) ~= 2 then return end

    -- Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    -- local sg = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e3filter),
    --                                    tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1,
    --                                    1, nil)
    -- if #sg > 0 then
    --     Duel.SendtoHand(g, nil, REASON_EFFECT)
    --     Duel.ConfirmCards(1 - tp, g)
    -- end
end
