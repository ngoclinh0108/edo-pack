-- Sky Divine Dragon of Osiris
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 1, true, true)

    -- atk/def
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetValue(s.e1val)
    Divine.RegisterEffect(c, e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    Divine.RegisterEffect(c, e1b)

    -- atk/def down
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    Divine.RegisterEffect(c, e2b)
end

function s.e1val(e, c)
    local tp = c:GetControler()
    return Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) * 1000 *
               Divine.GetDivineHierarchy(c)
end

function s.e2filter(c, e, tp)
    return c:IsPosition(POS_FACEUP) and c:IsLocation(LOCATION_MZONE) and
               (not e or c:IsRelateToEffect(e)) and c:IsControler(1 - tp)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return eg:IsExists(s.e2filter, 1, nil, nil, tp) and c:CanAttack() and
               c:IsAttackPos()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsRelateToEffect(e) end

    local g = eg:Filter(s.e2filter, nil, nil, tp)
    Duel.SetTargetCard(g)
    Duel.SetChainLimit(function(e) return not eg:IsContains(e:GetHandler()) end)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsAttackPos() then return end

    local tg = Duel.GetTargetCards(e):Filter(s.e2filter, nil, e, tp)
    local dg = Group.CreateGroup()

    for tc in aux.Next(tg) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(tc:IsAttackPos() and EFFECT_UPDATE_ATTACK or
                        EFFECT_UPDATE_DEFENSE)
        ec1:SetValue(-2000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)

        if (tc:IsAttackPos() and tc:GetAttack() == 0) or
            (tc:IsDefensePos() and tc:GetDefense() == 0) then
            dg:AddCard(tc)
        end
    end

    if #dg == 0 then return end
    Duel.BreakEffect()
    Duel.Destroy(dg, REASON_EFFECT)
end
