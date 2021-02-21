-- Red-Eyes Abyss Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x3b}
s.listed_names = {CARD_REDEYES_B_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c) return c:IsLevel(1) end, 1, 1,
                         aux.FilterBoolFunction(Card.IsSetCard, 0x3b), 1, 1,
                         s.syntunerfilter)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c)
        local ct = Duel.GetMatchingGroupCount(Card.IsRace, c:GetControler(),
                                              LOCATION_GRAVE, 0, nil,
                                              RACE_DRAGON)
        return ct * 300
    end)
    c:RegisterEffect(e1)

    -- untargetable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- damage
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DECKDES + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.syntunerfilter(c, scard, sumtype, tp)
    return c:IsAttribute(ATTRIBUTE_DARK, scard, sumtype, tp) and
               c:IsRace(RACE_DRAGON, scard, sumtype, tp)
end

function s.e3filter(c) return c:IsRace(RACE_DRAGON) and c:IsAbleToGrave() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local tc = Duel.SelectMatchingCard(tp, s.e3filter, tp,
                                       LOCATION_HAND + LOCATION_DECK, 0, 1, 1,
                                       nil):GetFirst()
    if not tc then return end

    if Duel.SendtoGrave(tc, REASON_EFFECT) ~= 0 and
        tc:IsLocation(LOCATION_GRAVE) then
        local dmg;
        if tc:IsCode(CARD_REDEYES_B_DRAGON) then
            dmg = tc:GetBaseAttack()
        else
            dmg = math.ceil(tc:GetBaseAttack() / 2)
        end
        Duel.Damage(1 - tp, dmg, REASON_EFFECT)
    end
end
