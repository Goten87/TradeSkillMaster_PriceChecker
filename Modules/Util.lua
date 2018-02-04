local TSM = select(2, ...)
local Util = TSM:NewModule("Util")

function Util:ConvertPriceToMoney(price, currency)
	local amount
	if price == nil then price = 0 end -- make sure it is a number
	if currency == "Gold" then
		amount = floor(price/10000) -- divide price by 10000 to decide gold and floor it to get rid of hang overs
		return amount or 0 -- Make sure it always returns a number
	elseif currency == "Silver" then
		amount = floor(strsub(price, -4) / 100) -- strsub will only see the last 4 numbers of a sentece and divide it by 100
		return amount or 0
	elseif currency == "Copper" then
		amount = floor(strsub(price, -2)) -- no division needed for 10th's
		return amount or 0
	end
end

function Util:ConvertTime(Current, Past)
	local Current = Current
	local Past = Past
	local Difference = (Current - Past)
	return Difference
end

function Util:SecondsToClock(seconds)
	local seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00:00";
	else
		days = string.format("%02.f", math.floor(seconds/86400));
		hours = string.format("%02.f", math.floor(seconds/3600 - (days*24)));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return format("%d days %02d Hours %02d Minute %02d Seconds",days,hours,minutes,secs)
	end
end

function Util:LastRunCheck()
	local Current = time()
	local Past = (TSM.LastRunDelayTime + TSM.db.global["LockOutTime"])
	if Current > Past then
		return "Yes"
	else
		return "No"
	end
end

function Util:TrimString(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function Util:StartsWith(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function TSM:TriggeredEvent(message, recipient, channel)
	Util:Process(message, recipient, channel)
end

function Util:ValuesFor(marketPrice, marketName, itemCount)
	-- Market Prices --
	local marketGold = Util:ConvertPriceToMoney(marketPrice,"Gold")
	local marketSilver = Util:ConvertPriceToMoney(marketPrice,"Silver")
	local marketCopper  = Util:ConvertPriceToMoney(marketPrice,"Copper")
	local multipliedMarketGold = Util:ConvertPriceToMoney(marketPrice*itemCount,"Gold")
	local multipliedMarketSilver = Util:ConvertPriceToMoney(marketPrice*itemCount,"Silver")
	local multipliedMarketCopper = Util:ConvertPriceToMoney(marketPrice*itemCount,"Copper")

	local icon = "g"
	local leftBracket = "["
	local rightBracket = "]"
	local gold = "."
	local copper = ""
	
	if TSM.db.global["UseRaidIcon"] then
		icon = "g{rt2}"
	end
	
	if not TSM.db.global["ShowBrackets"] then
		leftBracket = ""
		rightBracket = ""
	end
	
	if TSM.db.global["ShowCopper"] then
		if TSM.db.global["ShowFullCurrency"] then
			if itemCount > 1 then
				copper = "Silver "..multipliedMarketCopper
			else
				copper = "Silver "..marketCopper
			end

			gold = "Gold "

			if TSM.db.global["UseRaidIcon"] then
				icon = "Copper{rt2}"
			else
				icon = "Copper"
			end
		else
			if itemCount > 1 then
				copper = "S"..multipliedMarketCopper
			else
				copper = "S"..marketCopper
			end

			gold = "G"

			if TSM.db.global["UseRaidIcon"] then
				icon = "C{rt2}"
			else
				icon = "C"
			end
		end
	end
	
	if itemCount > 1 then
		message = marketName.." x"..itemCount.." "..leftBracket..Util:FormatThousand(multipliedMarketGold)..gold..multipliedMarketSilver..copper..icon..rightBracket.." "
	else
		message = marketName.." "..leftBracket..Util:FormatThousand(marketGold)..gold..marketSilver..copper..icon..rightBracket.." "
	end
	
	return message
end

function Util:SendMessage(message, recipient, channel)
	if channel == "Guild" then
		if TSM.db.global["GuildChannel"] == "None" then return end
		SendChatMessage(message, TSM.db.global["GuildChannel"], "Common", recipient)
	elseif channel == "Whisper" then
		SendChatMessage(message, "WHISPER", "Common", recipient)
	elseif channel == "Officer" then
		if TSM.db.global["OfficerChannel"] == "None" then return end
		SendChatMessage(message, TSM.db.global["OfficerChannel"], "Common", recipient)
	elseif channel == "Party" then
		if TSM.db.global["PartyChannel"] == "None" then return end
		SendChatMessage(message, TSM.db.global["PartyChannel"], "Common", recipient)
	elseif channel == "Say" then
		if TSM.db.global["Channel"] == "None" then return end
		SendChatMessage(message, TSM.db.global["Channel"], "Common", recipient)
	elseif channel == "BNET" then
		BNSendWhisper(recipient, message)
	end
end

function Util:FormatThousand(value)
	local s = string.format("%d", math.floor(value))
	local pos = string.len(s) % 3
	if pos == 0 then pos = 3 end
	return string.sub(s, 1, pos)
		.. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
		--.. string.sub(string.format("%.2f", v - math.floor(v)), 2)
end