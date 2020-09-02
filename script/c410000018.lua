-- Palladium Sacred Oracle Mana
local s, id = GetID()

s.listed_names = {38033121}

function s.initial_effect(c)
    -- code
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(38033121)
    c:RegisterEffect(e1)

    -- special summon when destroyed
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e4filter(c, e, tp)
  return (c:IsSetCard(0x13a) or c:IsCode(38033121)) and not c:IsCode(id) and
             c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
  return (r & REASON_EFFECT + REASON_BATTLE) ~= 0
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
      return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                 Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_HAND +
                                                 LOCATION_DECK +
                                                 LOCATION_GRAVE, 0, 1, nil, e,
                                             tp)
  end
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                        LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
  if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
  local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e4filter), tp,
                                    LOCATION_HAND + LOCATION_DECK +
                                        LOCATION_GRAVE, 0, 1, 1, nil, e, tp)

  if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
