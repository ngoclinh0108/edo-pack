-- Palladium Chaos Oracle Aknamkanon
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon procedure
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_HAND)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- code & attribute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(30208479)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1b:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e1b)

    -- cannot be target
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c) return c:IsSetCard(0x13a) end)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- change attribute
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0, LOCATION_MZONE)
    e3:SetValue(ATTRIBUTE_DARK)
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

function s.sprescon(sg, e, tp, mg)
    return aux.ChkfMMZ(1)(sg, e, tp, mg) and sg:IsExists(s.spcheck, 1, nil, sg)
end

function s.spcheck(c, sg)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and
               sg:FilterCount(Card.IsAttribute, c, ATTRIBUTE_DARK) == 1
end

function s.spfilter(c, att)
    return c:IsAttribute(att) and c:IsAbleToRemoveAsCost() and
               aux.SpElimFilter(c, true)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local rg1 = Duel.GetMatchingGroup(s.spfilter, tp,
                                      LOCATION_MZONE + LOCATION_GRAVE, 0, nil,
                                      ATTRIBUTE_LIGHT)
    local rg2 = Duel.GetMatchingGroup(s.spfilter, tp,
                                      LOCATION_MZONE + LOCATION_GRAVE, 0, nil,
                                      ATTRIBUTE_DARK)
    local rg = rg1:Clone()
    rg:Merge(rg2)

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    return ft > -2 and #rg1 > 0 and #rg2 > 0 and
               aux.SelectUnselectGroup(rg, e, tp, 2, 2, s.sprescon, 0)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local rg = Duel.GetMatchingGroup(s.spfilter, tp,
                                     LOCATION_MZONE + LOCATION_GRAVE, 0, nil,
                                     ATTRIBUTE_LIGHT + ATTRIBUTE_DARK)
    local g = aux.SelectUnselectGroup(rg, e, tp, 2, 2, s.sprescon, 1, tp,
                                      HINTMSG_REMOVE, nil, nil, true)

    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.Remove(g, POS_FACEUP, REASON_COST)
    g:DeleteGroup()
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
