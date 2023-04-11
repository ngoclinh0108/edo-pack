-- The Wicked Apostle
Duel.LoadScript("util.lua")
local s, id = GetID()

local wicked_monsters = {62180201, 57793869, 21208154}
s.listed_names = {62180201, 57793869, 21208154, 7373632}

function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    c:EnableReviveLimit()

    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- search wicked
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- triple tribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e2:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e2:SetValue(function(e, c) return c:IsLevel(10) and c:IsCode(wicked_monsters) end)
    c:RegisterEffect(e2)

    -- additional tribute summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_HAND, 0)
    e3:SetCondition(function(e) return Duel.IsMainPhase() and e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
    e3:SetTarget(function(e, c) return c:IsLevel(10) and c:IsCode(wicked_monsters) end)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- effect gain
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e4:SetCode(EVENT_BE_PRE_MATERIAL)
    e4:SetCondition(s.e4regcon)
    e4:SetOperation(s.e4regop)
    c:RegisterEffect(e4)
end

function s.e1filter(c, code) return c:IsCode(code) and c:IsAbleToHand() end

function s.e1check1(tp)
    return not Utility.IsOwnAny(Card.IsCode, tp, 62180201) or
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, 62180201)
end

function s.e1check2(tp)
    return not Utility.IsOwnAny(Card.IsCode, tp, 57793869) or
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, 57793869)
end

function s.e1check3(tp)
    return not Utility.IsOwnAny(Card.IsCode, tp, 21208154) or
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, 21208154)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return s.e1check1(tp) or s.e1check2(tp) or s.e1check3(tp) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local opt = {}
    local sel = {}
    if s.e1check1(tp) then
        table.insert(opt, aux.Stringid(id, 2))
        table.insert(sel, 1)
    end
    if s.e1check2(tp) then
        table.insert(opt, aux.Stringid(id, 3))
        table.insert(sel, 2)
    end
    if s.e1check3(tp) then
        table.insert(opt, aux.Stringid(id, 4))
        table.insert(sel, 3)
    end

    local code = nil
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    if op == 1 then
        code = 62180201
    elseif op == 2 then
        code = 57793869
    elseif op == 3 then
        code = 21208154
    end

    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, code) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, code):GetFirst()
    else
        tc = Duel.CreateToken(tp, code)
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c) return not (c:IsLevel(10) and c:IsCode(wicked_monsters)) end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    Duel.RegisterEffect(ec1b, tp)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    Duel.RegisterEffect(ec1c, tp)
end

function s.e4regcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return r == REASON_SUMMON and rc:IsFaceup() and rc:IsLevel(10) and rc:IsCode(wicked_monsters)
end

function s.e4regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    local eff = Effect.CreateEffect(c)
    eff:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    eff:SetCode(EVENT_SUMMON_SUCCESS)
    eff:SetOperation(s.e4op)
    eff:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(eff, true)
end

function s.e4filter(c) return c:IsCode(7373632) and c:IsAbleToHand() end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Utility.IsOwnAny(Card.IsCode, tp, 7373632) and not Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) then
        return
    end
    if not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 5)) then return end

    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, 7373632) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e4filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    else
        tc = Duel.CreateToken(tp, 7373632)
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
end
