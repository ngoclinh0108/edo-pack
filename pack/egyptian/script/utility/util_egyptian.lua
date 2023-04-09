-- init
if not aux.DivineProcedure then aux.DivineProcedure = {} end
if not Divine then Divine = aux.DivineProcedure end

-- constant: flag
Divine.FLAG_DIVINE_EVOLUTION = 513000065

-- function
function Divine.IsDivineEvolution(c) return c:GetFlagEffect(Divine.FLAG_DIVINE_EVOLUTION) > 0 end

function Divine.RegisterDivineEvolution(c)
    c:RegisterFlagEffect(Divine.FLAG_DIVINE_EVOLUTION, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, 666000)
end

function Divine.GetDivineHierarchy(c, get_base)
    if not c then return 0 end
    local divine_hierarchy = c.divine_hierarchy
    if not divine_hierarchy then divine_hierarchy = 0 end
    if get_base then return divine_hierarchy end

    if c:GetFlagEffect(Divine.FLAG_DIVINE_EVOLUTION) > 0 then divine_hierarchy = divine_hierarchy + 1 end

    return divine_hierarchy
end

function Divine.DivineHierarchy(s, c, divine_hierarchy)
    if divine_hierarchy then s.divine_hierarchy = divine_hierarchy end

    -- 3 tribute
    aux.AddNormalSummonProcedure(c, true, false, 3, 3)
    aux.AddNormalSetProcedure(c)

    -- summon cannot be negate
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(sumsafe)
end