-- Fusion with Eyes of Blue
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_BLUEEYES_W_DRAGON}

function s.initial_effect(c)
    -- activate
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        fusfilter = aux.FilterBoolFunction(aux.IsCodeListed,
                                           CARD_BLUEEYES_W_DRAGON),
        extrafil = function(e, tp)
            return Duel.GetMatchingGroup(
                       Fusion.IsMonsterFilter(Card.IsFaceup, Card.IsAbleToDeck),
                       tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
        end,
        extraop = Fusion.ShuffleMaterial,
        stage2 = s.e1stage2
    })
    c:RegisterEffect(e1)
end

function s.e1stage2(e, tc, tp, sg, chk)
    if chk == 0 then
        local c = e:GetHandler()

        -- piercing
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3208)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_PIERCE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1, true)

        -- indes
        local ec2 = ec1:Clone()
        ec2:SetDescription(3000)
        ec2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        ec2:SetValue(1)
        tc:RegisterEffect(ec2, true)
    end
end
