--Table containing mobIDs of bosses that drop badges.
local BadgeTable = {
--Hellfire Ramparts
17306, --Watchkeeper Gargolmar
17308, --Omor the Unscarred
17307, --Nazan actually keeps Vazruden the Herald's mobID.

--The Blood Furnace
17381, --The Maker
17380, --Broggok
17377, --Keli'dan the Breaker

--The Shattered Halls
16807, --Grand Warlock Nethekurse
20923, --Blood Guard Porung
16809, --Warbringer O'mrogg
16808, --Warchief Kargath Bladefist

--Magtheridon's Lair
17257, --Magtheridon

--The Slave Pens
17941, --Mennu the Betrayer
17991, --Rokmar the Crackler
17942, --Quagmirran

--The Underbog
17770, --Hungarfen
18105, --Ghaz'an
17826, --Swamplord Musel'ek
17882, --The Black Stalker

--The Steamvault
17797, --Hydromancer Thespia
17796, --Mekgineer Steamrigger
17798, --Warlord Kalithresh

--Serpentshrine Cavern
21216, --Hydross the Unstable
21217, --The Lurker Below
21215, --Leotheras the Blind
21214, --Fathom-Lord Karathress
21213, --Morogrim Tidewalker
21212, --Lady Vashj

--Mana-Tombs
18341, --Pandemonius
18343, --Tavarok
18344, --Nexus-Prince Shaffar
22930, --Yor

--Auchenai Crypts
18371, --Shirrak the Dead Watcher
18373, --Exarch Maladaar

--Sethekk Halls
18472, --Darkweaver Syth
18473, --Talon King Ikiss
23035, --Anzu

--Shadow Labyrinth
18731, --Ambassador Hellmaw
18667, --Blackheart the Inciter
18732, --Grandmaster Vorpil
18708, --Murmur

--Old Hillsbrad Foothills
17848, --Lieutenant Drake
17862, --Captain Skarloc
18096, --Epoch Hunter

--The Black Morass
17879, --Chrono Lord Deja
17880, --Temporus
17881, --Aeonus

--Hyjal Summit
17767, --Rage Winterchill
17808, --Anetheron
17888, --Kaz'rogal
17842, --Azgalor
17968, --Archimonde

--The Mechanar
19219, --Mechano-Lord Capacitus
19221, --Nethermancer Sepethrea
19220, --Pathaleon the Calculator

--The Botanica
17976, --Commander Sarannis
17975, --High Botanist Freywinn
17978, --Thorngrin the Tender
17980, --Laj
17977, --Warp Splinter

--The Arcatraz
20870, --Zereketh the Unbound
20886, --Wrath-Scryer Soccothrates
20885, --Dalliah the Doomsayer
20912, --Harbinger Skyriss

--The Eye
19516, --Void Reaver
19514, --Al'ar
18805, --High Astromancer Solarian
19622, --Kael'thas Sunstrider

--Karazhan
15550, --Attumen the Huntsman
15687, --Moroes
17533, --Romulo
17534, --Julianne
17521, --The Big Bad Wolf
18168, --The Crone
16457, --Maiden of Virtue
15691, --The Curator
15688, --Terestian Illhoof
16524, --Shade of Aran
15689, --Netherspite
17225, --Nightbane
15690, --Prince Malchezaar

--Zul'Aman
23574, --Akil'zon
23576, --Nalorakk
23578, --Jan'alai
23577, --Halazzi
24239, --Hex Lord Malacrass
23863, --Zul'jin

--Gruul's Lair
18831, --High King Maulgar
19044, --Gruul the Dragonkiller

--Black Temple
22887, --High Warlord Naj'entus
22898, --Supremus
22841, --Shade of Akama
22871, --Teron Gorefiend
22948, --Gurtogg Bloodboil
23420, --Essence of Anger
22947, --Mother Shahraz
22950, --High Nethermancer Zerevor
22917, --Illidan Stormrage

--Magister's Terrace
24723, --Selin Fireheart
24744, --Vexallus
24560, --Priestess Delrissa
24664, --Kael'thas Sunstrider

--Sunwell Plateau (imcomplete)
24882, --Brutallus
25038, --Felmyst
25165, --Lady Sacrolash

--Outdoor bosses (not working yet)
17711, --Doomwalker
18728, --Doom Lord Kazzak
}

--Warning functions.
local function StartBadgeWarning()
	--Do a raid warning message with sound.
	RaidNotice_AddMessage(RaidWarningFrame, "Boss died, pick up your badge!", ChatTypeInfo["RAID_WARNING"])
	PlaySound("RaidWarning")
	
	--Initalise annoying screen flashing.
	UIFrameFlash(LowHealthFrame, 2, 2, 60, false)
end

local function StopBadgeWarning()
	UIFrameFlashRemoveFrame(LowHealthFrame)
	LowHealthFrame:Hide()
end

--Create a frame for monitoring events.
local frame = CreateFrame("Frame",UIParent)
--Register for zone changes so we know when to start monitoring combatlog.
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

--Set OnEvent handler.
local function OnEvent(event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, subevent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...
		if (subevent == "UNIT_DIED") then
			mobID = tonumber(destGUID:sub(6,12),16)
			for i,v in ipairs(BadgeTable) do
				if (v == mobID) then
					--Yay mob kill, do warning stuff.
					frame:RegisterEvent("CHAT_MSG_LOOT")
					return StartBadgeWarning()
				end
			end
		end
	elseif (event == "CHAT_MSG_LOOT") then
		local message = ...
		local item = message:match(LOOT_ITEM_SELF:gsub("%%s", "(.*)"))
		if (item) then
			local itemID = tonumber(item:match("\124Hitem:(%d+):.*"))
			if (itemID == 29434) then
				frame:UnregisterEvent("CHAT_MSG_LOOT")
				return StopBadgeWarning()
			end
		end
	elseif (event == "ZONE_CHANGED_NEW_AREA") then
		local InInstance, InstanceType = IsInInstance()
		if (InInstance and (InstanceType == "party" and GetCurrentDungeonDifficulty() == 2) or (InstanceType == "raid")) then --Register CLEU when entering heroic/raid instance.
			return frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		elseif (not InInstance and frame:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED")) then --Unregister CLEU when leaving instance.
			return frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end
frame:SetScript("OnEvent", function(frame, event, ...) OnEvent(event, ...) end)