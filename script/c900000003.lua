-- Sun Divine Beast of Ra
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {78665705, 900000004, 95286165}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, true, true)
    Divine.RegisterRaFuse(c)
    Divine.RegisterRaDefuse(s, c)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_WINGEDBEAST)
    Divine.RegisterEffect(c, e1)

    -- atk/def
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetOperation(s.e2op)
    Divine.RegisterEffect(c, e2)

    -- life point transfer
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    Divine.RegisterEffect(c, e3)

    -- destroy
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    Divine.RegisterEffect(c, e4)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsSummonType(SUMMON_TYPE_TRIBUTE) then return end

    local g1 = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil,
                                     78665705)
    local g2 = Dimension.Zones(tp):Filter(Card.IsOriginalCode, nil, 900000004)
    if #g1 == 0 and #g2 == 0 then return end
    if #g1 > 0 and #g2 > 0 then
        if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            local sc =
                Utility.GroupSelect(HINTMSG_CONFIRM, g1, tp, 1, 1, nil):GetFirst()
            Duel.ConfirmCards(1 - tp, sc)
            if sc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
        else
            return
        end
    end

    -- calculate atk/def
    local atk = 0
    local def = 0
    local mg = c:GetMaterial()
    for mc in aux.Next(mg) do
        if mc:GetPreviousAttackOnField() > 0 then
            atk = atk + mc:GetPreviousAttackOnField()
        end
        if mc:GetPreviousDefenseOnField() > 0 then
            def = def + mc:GetPreviousDefenseOnField()
        end
    end

    -- set base atk/def
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(c, ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    Divine.RegisterEffect(c, ec1b, true)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLP(tp) > 100 end

    local paidlp = Duel.GetLP(tp) - 100
    Duel.PayLPCost(tp, paidlp)
    e:SetLabelObject({c:GetBaseAttack() + paidlp, c:GetBaseDefense() + paidlp})
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(aux.FALSE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(id)
    ec1:SetLabelObject(e:GetLabelObject())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterRaEffect(c, ec1, true)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_MZONE,
                                LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    Duel.Destroy(tc, REASON_EFFECT)
end
