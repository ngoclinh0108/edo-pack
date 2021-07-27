-- init
if not aux.UtilNordicProcedure then aux.UtilNordicProcedure = {} end
if not UtilNordic then UtilNordic = aux.UtilNordicProcedure end

-- constant
UtilNordic.ASCENDANT_TOKEN = 930000038

-- function
function UtilNordic.NordicGodEffect(c, sumtype, reborn)
    local id = c:GetOriginalCodeRule()
    
    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    sumsafe:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == sumtype
    end)
    c:RegisterEffect(sumsafe)

    -- cannot be tributed or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nofus = Effect.CreateEffect(c)
    nofus:SetType(EFFECT_TYPE_SINGLE)
    nofus:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nofus:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    nofus:SetRange(LOCATION_MZONE)
    nofus:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nofus)
    local nosync = nofus:Clone()
    nosync:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(nosync)
    local noxyz = nofus:Clone()
    noxyz:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(noxyz)
    local nolnk = nofus:Clone()
    nolnk:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(nolnk)

    if (reborn) then
        -- register the fact it was destroyed and sent to GY
        local desreg = Effect.CreateEffect(c)
        desreg:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        desreg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        desreg:SetCode(EVENT_TO_GRAVE)
        desreg:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            if not c:IsReason(REASON_DESTROY) or
                not c:IsPreviousLocation(LOCATION_ONFIELD) then
                return
            end
            c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
        end)
        c:RegisterEffect(desreg)

        -- special summon itself from GY
        local reborn = Effect.CreateEffect(c)
        reborn:SetCategory(CATEGORY_SPECIAL_SUMMON)
        reborn:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
        reborn:SetCode(EVENT_PHASE + PHASE_END)
        reborn:SetRange(LOCATION_GRAVE)
        reborn:SetCountLimit(1)
        reborn:SetCondition(function(e)
            return e:GetHandler():GetFlagEffect(id) ~= 0
        end)
        reborn:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
            local c = e:GetHandler()
            if chk == 0 then
                return c:IsCanBeSpecialSummoned(e, 1, tp, false, false)
            end
            Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
        end)
        reborn:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            if not c:IsRelateToEffect(e) then return end
            Duel.SpecialSummon(c, 1, tp, tp, false, false, POS_FACEUP)
        end)
        c:RegisterEffect(reborn)
    end
end

function UtilNordic.RebornCondition(e)
    return e:GetHandler():GetSummonType() == SUMMON_TYPE_SPECIAL + 1
end

function UtilNordic.AesirGodEffect(c)
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_SYNCHRO, true)
end
