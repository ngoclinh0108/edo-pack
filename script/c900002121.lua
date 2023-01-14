-- Evil Fusion
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x6008}

function s.initial_effect(c)
    c:RegisterEffect(Fusion.CreateSummonEff({
        handler = c,
        fusfilter = aux.FilterBoolFunction(Card.IsRace, RACE_FIEND),
        extrafil = function(e, tp)
            local g = Duel.GetMatchingGroup(function(c) return c:IsAbleToGrave() and c:IsSetCard(0x6008) end, tp, LOCATION_DECK,
                0, nil)
            local check = function(tp, sg, fc) return sg:FilterCount(Card.IsLocation, nil, LOCATION_DECK) <= 1 end
            return g, check
        end,
        stage2 = s.stage2
    }))
end

function s.stage2(e, tc, tp, sg, chk)
    local c = e:GetHandler()
    if chk == 1 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3061)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        ec1:SetValue(aux.tgoval)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 2)
        tc:RegisterEffect(ec1)
    end
end
