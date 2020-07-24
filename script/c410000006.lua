-- Obelisk's Apostle
local s, id = GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
end
