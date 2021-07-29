-- Moros of the Nordic Alfar
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- extra material
    local e2syn = Effect.CreateEffect(c)
    e2syn:SetType(EFFECT_TYPE_SINGLE)
    e2syn:SetCode(EFFECT_HAND_SYNCHRO)
    e2syn:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2syn:SetLabel(id)
    e2syn:SetValue(s.e2synval)
    c:RegisterEffect(e2syn)
    local e2lnk = Effect.CreateEffect(c)
    e2lnk:SetType(EFFECT_TYPE_FIELD)
    e2lnk:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2lnk:SetCode(EFFECT_EXTRA_MATERIAL)
    e2lnk:SetRange(LOCATION_HAND)
    e2lnk:SetTargetRange(1, 0)
    e2lnk:SetOperation(s.e2lnkcon)
    e2lnk:SetValue(s.e2lnkval)
    local e2lnkgrant = Effect.CreateEffect(c)
    e2lnkgrant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e2lnkgrant:SetRange(LOCATION_MZONE)
    e2lnkgrant:SetTargetRange(LOCATION_HAND, 0)
    e2lnkgrant:SetTarget(s.e2lnkgranttg)
    e2lnkgrant:SetLabelObject(e2lnk)
    c:RegisterEffect(e2lnkgrant)
    aux.GlobalCheck(s, function() s.flagmap = {} end)

    -- act limit
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- shuffle
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c) return c:IsSetCard(0x42) end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.CheckReleaseGroup(tp, s.e1filter, 1, false, 1, true, c, tp, nil,
                                  false, e:GetHandler())
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local g = Duel.SelectReleaseGroup(tp, s.e1filter, 1, 1, false, true, true,
                                      c, nil, nil, false, e:GetHandler())
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.Release(g, REASON_COST)
    g:DeleteGroup()
end

function s.e2synval(e, tc, sc)
    local c = e:GetHandler()
    if sc:IsSetCard(0x4b) and
        (not tc:IsType(TYPE_TUNER) or tc:IsHasEffect(EFFECT_NONTUNER)) and
        tc:IsSetCard(0x42) and tc:IsLocation(LOCATION_HAND) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)
        ec1:SetLabel(id)
        ec1:SetTarget(s.e2syntg)
        tc:RegisterEffect(ec1)
        return true
    else
        return false
    end
end

function s.e2syntg(e, tc, sg, tg, ntg, tsg, ntsg)
    if not tc then return true end
    local res = true

    if sg:IsExists(s.e2chk2, 1, tc) or
        (not tg:IsExists(s.e2chk1, 1, tc) and not ntg:IsExists(s.e2chk1, 1, tc) and
            not sg:IsExists(s.e2chk1, 1, tc)) then return false end
    local trg = tg:Filter(s.e2chk2, nil)
    local ntrg = ntg:Filter(s.e2chk2, nil)
    return res, trg, ntrg
end

function s.e2chk1(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or
        c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then
        return false
    end

    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() == id then return true end
    end
    return false
end

function s.e2chk2(c)
    if c:IsSetCard(0x42) then return false end
    return not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or
               c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) or
               c:GetCardEffect(EFFECT_HAND_SYNCHRO):GetLabel() ~= id
end

function s.e2lnkcon(c, e, tp, sg, mg, lc, og, chk)
    local ct = sg:FilterCount(function(c) return c:GetFlagEffect(id) > 0 end,
                              nil)
    return ct == 0 or (sg + mg):Filter(function(c, tp)
        return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
    end, nil, e:GetHandlerPlayer()):IsExists(Card.IsCode, 1, og, id)
end

function s.e2lnkval(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or not sc:IsSetCard(0x4b) then
            return Group.CreateGroup()
        else
            s.flagmap[c] = c:RegisterFlagEffect(id, 0, 0, 1)
            return Group.FromCards(c)
        end
    elseif chk == 2 then
        if s.flagmap[c] then
            s.flagmap[c]:Reset()
            s.flagmap[c] = nil
        end
    end
end

function s.e2lnkgranttg(e, c)
    return c:IsCanBeLinkMaterial() and c:IsSetCard(0x42) and
               (not c:IsType(TYPE_TUNER) or c:IsHasEffect(EFFECT_NONTUNER))
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local ex1, g1, gc1, dp1, dv1 = Duel.GetOperationInfo(ev, CATEGORY_TOHAND)
    if ep == tp and re:GetHandler():IsSetCard(0x42) and ex1 and
        (dv1 & LOCATION_DECK) == LOCATION_DECK then
        Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
    end
end

function s.e4filter1(c, tp)
    return c:IsSetCard(0x42) and c:IsAbleToDeck() and
               Duel.IsExistingMatchingCard(s.e4filter2, tp, LOCATION_DECK, 0, 1,
                                           nil, c)
end

function s.e4filter2(c, sc)
    return
        not c:IsCode(id) and not c:IsCode(sc:GetCode()) and c:IsSetCard(0x42) and
            c:IsAbleToHand()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter1, tp, LOCATION_HAND, 0, 1,
                                           nil, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.e4filter1, tp, LOCATION_HAND, 0, 1,
                                      1, nil, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or
        not Duel.IsExistingMatchingCard(s.e4filter2, tp, LOCATION_DECK, 0, 1,
                                        nil, tc) then return end
    if Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.e4filter2, tp, LOCATION_DECK, 0,
                                          1, 1, nil, tc)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end
