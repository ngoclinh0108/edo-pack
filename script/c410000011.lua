-- Palladium Oracle Aknamkanon
local s, id = GetID()

s.listed_names = {30208479}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(30208479)
    c:RegisterEffect(code)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot be target
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c)
        return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
    end)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- banish
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(1107)
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_BATTLED)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- search spell/trap
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE + PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    aux.GlobalCheck(s, function()
        local e4reg = Effect.CreateEffect(c)
        e4reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e4reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e4reg:SetCode(EVENT_SUMMON_SUCCESS)
        e4reg:SetLabel(id)
        e4reg:SetOperation(aux.sumreg)
        Duel.RegisterEffect(e4reg, 0)
        local e4regb = e4reg:Clone()
        e4regb:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
        Duel.RegisterEffect(e4regb, 0)
        local e4regc = e4reg:Clone()
        e4regc:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(e4regc, 0)
    end)
end

function s.e1filter(c)
    return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and
               c:IsAbleToRemoveAsCost()

end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil)

    return aux.SelectUnselectGroup(g, e, tp, 2, 2, aux.ChkfMMZ(1), 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
    local rg = aux.SelectUnselectGroup(g, e, tp, 2, 2, aux.ChkfMMZ(1), 1, tp,
                                       HINTMSG_REMOVE)

    if #rg > 0 then
        rg:KeepAlive()
        e:SetLabelObject(rg)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.Remove(g, POS_FACEUP, REASON_COST)
    g:DeleteGroup()
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    e:SetLabelObject(bc)

    return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and
               c:IsStatus(STATUS_OPPO_BATTLE)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, e:GetLabelObject(), 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local bc = e:GetLabelObject()
    if not bc:IsRelateToBattle() or not bc:IsAbleToRemove() then return end

    Duel.Remove(bc, POS_FACEUP, REASON_EFFECT)
end

function s.e4filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetFlagEffect(id) ~= 0 end
    c:ResetFlagEffect(id)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e4filter, tp,
                                     LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e4filter, tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
