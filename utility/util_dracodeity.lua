-- init
if not aux.UtilityDracodeityProcedure then aux.UtilityDracodeityProcedure = {} end
if not UtilityDracodeity then UtilityDracodeity = aux.UtilityDracodeityProcedure end

-- function
function UtilityDracodeity.RegisterSummon(c, attribute)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 3,
                      nil, function(g, sc, sumtype, tp)
        return g:IsExists(Card.IsAttribute, 1, nil, attribute, sc, sumtype, tp)
    end)
end

function UtilityDracodeity.RegisterEffect(c, id)
    c:SetUniqueOnField(1, 0, id)

    -- summon cannot be negated
    local summon_safe = Effect.CreateEffect(c)
    summon_safe:SetType(EFFECT_TYPE_SINGLE)
    summon_safe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    summon_safe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    summon_safe:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK
    end)
    c:RegisterEffect(summon_safe)
end
