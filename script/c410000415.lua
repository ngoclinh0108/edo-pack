-- Neos Polymerization
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_NEOS, 42015635}

function s.initial_effect(c)
    -- fusion summon
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        fusfilter = aux.FilterBoolFunction(aux.IsMaterialListCode, CARD_NEOS),
        extrafil = s.e1extramat,
        extratg = s.e1extratg,
        stage2 = s.e1sumop,
        exactcount = 2,
        chkf = FUSPROC_NOTFUSION | FUSPROC_LISTEDMATS,
        value = 0
    })
    c:RegisterEffect(e1)
    if not AshBlossomTable then AshBlossomTable = {} end
    table.insert(AshBlossomTable, e1)

    -- destroy replace
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
end

function s.e1extramat(e, tp, mg)
    return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave), tp,
                                 LOCATION_DECK, 0, nil)
end

function s.e1extratg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    if Duel.IsEnvironment(42015635) then
        e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                          EFFECT_FLAG_CANNOT_INACTIVATE)
    else
        e:SetProperty(0)
    end
end

function s.e1sumop(e, tc, tp, mg, chk)
    local c = e:GetHandler()

    if chk == 1 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3061)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        ec1:SetValue(aux.tgoval)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
    end

    if chk == 2 then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(666003)
        ec2:SetType(EFFECT_TYPE_FIELD)
        ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
        ec2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        ec2:SetTargetRange(1, 0)
        ec2:SetTarget(function(e, c) return c:IsLocation(LOCATION_EXTRA) end)
        ec2:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec2, tp)
    end
end

function s.e2filter(c, tp)
    return
        c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and
            c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c, CARD_NEOS) and
            not c:IsReason(REASON_REPLACE) and
            c:IsReason(REASON_EFFECT + REASON_BATTLE)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsAbleToDeck() and eg:IsExists(s.e2filter, 1, nil, tp)
    end
    return Duel.SelectEffectYesNo(tp, c, 96)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
end

function s.e2val(e, c) return s.e2filter(c, e:GetHandlerPlayer()) end
