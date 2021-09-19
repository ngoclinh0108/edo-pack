-- Sky Divine Dragon of Osiris
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 1, true, true)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_DRAGON)
    Divine.RegisterEffect(c, e1)

    -- atk/def
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_SET_BASE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.e2val)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_SET_BASE_DEFENSE)
    Divine.RegisterEffect(c, e2b)

    -- atk/def down
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    Divine.RegisterEffect(c, e3)
    local e3b = e3:Clone()
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    Divine.RegisterEffect(c, e3b)
    local e3c = e3:Clone()
    e3c:SetCode(EVENT_CONTROL_CHANGED)
    Divine.RegisterEffect(c, e3c)
end

function s.e2val(e, c)
    local tp = c:GetControler()
    return Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) * 1000 *
               Divine.GetDivineHierarchy(c)
end

function s.e3filter(c, e, tp)
    return c:IsPosition(POS_FACEUP) and c:IsLocation(LOCATION_MZONE) and
               (not e or c:IsRelateToEffect(e)) and c:IsControler(1 - tp)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = eg:Filter(s.e3filter, nil, nil, tp)
    if chk == 0 then return c:IsAttackPos() and c:CanAttack() and #g > 0 end

    Duel.SetTargetCard(g)
    Duel.SetChainLimit(function(e) return not eg:IsContains(e:GetHandler()) end)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsAttackPos() or not c:IsRelateToEffect(e) then return end
    local tg = Duel.GetTargetCards(e):Filter(s.e3filter, nil, e, tp)
    local dg = Group.CreateGroup()

    for tc in aux.Next(tg) do
        if tc:IsPosition(POS_FACEUP_ATTACK) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_UPDATE_ATTACK)
            ec1:SetValue(-2000)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
            if tc:GetAttack() == 0 then dg:AddCard(tc) end
        elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
            local ec2 = Effect.CreateEffect(c)
            ec2:SetType(EFFECT_TYPE_SINGLE)
            ec2:SetCode(EFFECT_UPDATE_DEFENSE)
            ec2:SetValue(-2000)
            ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec2)
            if tc:GetDefense() == 0 then dg:AddCard(tc) end
        end
    end

    Duel.Destroy(dg, REASON_EFFECT)
end
