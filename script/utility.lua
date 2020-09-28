-- init
if not aux.Utility then aux.Utility = {} end
if not Utility then Utility = aux.Utility end

-- function
function Utility.IsSetCardListed(c,...)
	if not c.listed_series then return false end
	local codes={...}
	for _,code in ipairs(codes) do
		for _,ccode in ipairs(c.listed_series) do
			if code==ccode then return true end
		end
	end
	return false
end