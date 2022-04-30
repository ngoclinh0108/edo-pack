-- init
if not aux.UtilityDracodeityProcedure then aux.UtilityDracodeityProcedure = {} end
if not UtilityDracodeity then UtilityDracodeity = aux.UtilityDracodeityProcedure end

-- function
function UtilityDracodeity.RegisterSummon(c, attribute)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsSummonType(SUMMON_TYPE_SPECIAL, sc, sumtype, tp) and not c:IsType(TYPE_TOKEN, sc, sumtype, tp)
    end, 3, nil, function(g, sc, sumtype, tp)
        return g:IsExists(Card.IsAttribute, 1, nil, attribute, sc, sumtype, tp)
    end)
end

function UtilityDracodeity.RegisterEffect(c, id)
    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.lnklimit)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local summon_safe = Effect.CreateEffect(c)
    summon_safe:SetType(EFFECT_TYPE_SINGLE)
    summon_safe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    summon_safe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    summon_safe:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK
    end)
    c:RegisterEffect(summon_safe)

    -- cannot switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetRange(LOCATION_MZONE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(noswitch)
end
