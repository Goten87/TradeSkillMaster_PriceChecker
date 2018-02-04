local TSM = select(2, ...)
local EventDetection = TSM:NewModule("EventDetection","AceEvent-3.0")
local Util = TSM:GetModule("Util")

function Util:Process(message, recipient, channel)
	if TSM.db.global["AddonEnabled"] == false then return end
	
	local AddonEnabled = TSM.db.global["AddonEnabled"] --- check it
	local GuildChannel = TSM.db.global["GuildChannel"] --- Only used for guild channel

	if Util:StartsWith(message, TSM.db.global["Trigger"]) == false then
		return
	end
	
	--- Price Get --
	local itemString  = Util:TrimString(string.sub(message, TSM.db.global["TriggerLength"]+1)) -- sub the item
	local itemCountIndex, endPos, itemCount, restOfString = string.find(itemString, '(%d+)')
	
	if itemCount == nil or itemCountIndex > 1 then
		itemCount = 1
	else
		itemCount = tonumber(itemCount)
		if itemCount < 1 then
			itemCount = 1
		end
	end
	

	local itemID  = TSMAPI.Item:ToItemString(itemString)
	local priceMarket = TSMAPI:GetCustomPriceValue(TSM.db.global["MarketSource"], itemId)
	local priceMin = TSMAPI:GetCustomPriceValue(TSM.db.global["MinBuyoutSource"], itemID)
	--Trying GetCustomPriceValue, though I'm not certain it's wise to allow modified prices here.
	--local priceRegion = TSMAPI:GetItemValue(itemID, TSM.db.global["Region"])
	local priceRegion = TSMAPI:GetCustomPriceValue(TSM.db.global["Region"], itemID)
	
	if priceMarket == nill then
		priceMarket = TSMAPI:GetItemValue(itemID, TSM.db.global["MarketSource"])
	end
	if priceMin == nill then
		priceMin = TSMAPI:GetItemValue(itemID, TSM.db.global["MinBuyoutSource"])
	end
	if priceRegion == nill then
		priceRegion = TSMAPI:GetItemValue(itemID, TSM.db.global["Region"])
	end
	
	if itemID == nill then
	end
	
	if itemID == nill then
		return
	end
	
	-- time functions ---
	local Current = time()
	local Past = TSMAPI:ModuleAPI("AuctionDB", "lastCompleteScanTime")
	--local TimeLastScannedHours = floor(Util:ConvertTime(Current, Past) / 3600)-- 1 min is 60 seconds and 60 minutes in 1 hour so 60 * 60 = 3600
	--local TimeLastScannedMinutes = floor(Util:ConvertTime(Current, Past) / 60) -- convert minues
	local TimeLastScanned = Util:SecondsToClock(Util:ConvertTime(Current, Past)) -- convert minues
	-----------------------------------------------------------------

	if priceMarket == nil and priceMin == nil and priceRegion == null then
		Util:SendMessage("Not seen in any scans", recipient, channel)
		return
	end

	if TSM.db.global["SeparateMassage"] == true then
		if Util:LastRunCheck() == "Yes" then

			if priceMarket ~= nil then
				Util:SendMessage(Util:ValuesFor(priceMarket, TSM.db.global["MarketText"], itemCount), recipient, channel)
			end

			if priceMin ~= nil then
				Util:SendMessage(Util:ValuesFor(priceMin, TSM.db.global["MinText"], itemCount), recipient, channel)
			end

			if priceRegion ~= nil then
				Util:SendMessage(Util:ValuesFor(priceRegion, TSM.db.global["RegionalText"], itemCount), recipient, channel)
			end

			if TSM.db.global["ShowScanned"] then
				Util:SendMessage("Scanned: "..TimeLastScanned.." Ago", recipient, channel)
			end

			TSM.LastRunDelayTime = time() --- gets the current time
		else
			return
		end
	else
		if Util:LastRunCheck() == "Yes" then
			local message = ""

			if priceMarket ~= nil then
				message = Util:ValuesFor(priceMarket, TSM.db.global["MarketText"], itemCount)
			end

			if priceMin ~= nil then
				message = message .. Util:ValuesFor(priceMin, TSM.db.global["MinText"], itemCount)
			end

			if priceRegion ~= nil then
				message = message .. Util:ValuesFor(priceRegion, TSM.db.global["RegionalText"], itemCount)
			end

			if TSM.db.global["ShowScanned"] then
				message = message .."Scanned: "..TimeLastScannedMinutes.." Ago"
			end

			Util:SendMessage(message, recipient, channel)

			TSM.LastRunDelayTime = time() --- gets the current time
		else
			return
		end
	end

end