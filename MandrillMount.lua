-- macro:
-- #showtooltip
-- /MandrillMount ground_mount_name,flying_mount_name,shift_mount_name,ctrl_mount_name,alt_mount_name
-- /click MandrillMount

local _,addon_table = ...

--frames
local MandrillMount = CreateFrame("Button","MandrillMount",nil,"SecureActionButtonTemplate")
local MandrillMount_aux1 = CreateFrame("Button","MandrillMount_aux1",MandrillMount,"SecureActionButtonTemplate")
local MandrillMount_aux2 = CreateFrame("Button","MandrillMount_aux2",MandrillMount,"SecureActionButtonTemplate")
local MandrillMount_aux3 = CreateFrame("Button","MandrillMount_aux3",MandrillMount,"SecureActionButtonTemplate")

--local reference to most used global references
local CanExitVehicle = CanExitVehicle
local GetInstanceInfo = GetInstanceInfo
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsFalling = IsFalling
local IsInInstance = IsInInstance
local IsMounted = IsMounted
local IsOutdoors = IsOutdoors
local IsShiftKeyDown = IsShiftKeyDown
local IsSpellKnown = IsSpellKnown
local IsSubmerged = IsSubmerged
local IsUsableSpell = IsUsableSpell
local GetMountInfoByID = C_MountJournal.GetMountInfoByID
local GetMacroInfo = GetMacroInfo
local GetMountInfo = C_MountJournal.GetMountInfo
local GetRunningMacro = GetRunningMacro
local GetShapeshiftForm = GetShapeshiftForm
local GetUnitSpeed = GetUnitSpeed
local random = random
local SetMacroIcon = SetMacroIcon
local SetMacroSpell = SetMacroSpell
local tonumber = tonumber
local type = type

--constants
local Abyssal_index = 373
local AbyssalSeaHorse = GetSpellInfo(75207)
local AzureWaterStrider = GetSpellInfo(118089)
local BearForm = GetSpellInfo(5487)
local BrokenIsles = 1220
local CatForm = GetSpellInfo(768)
local class
	_,class = UnitClass("player")
local class_mounts = {
	["DEATHKNIGHT"] = 241856,
	["DEMONHUNTER"] = 241411,
	["DRUID"]		=    783,--231437 will just change travel form. It is not cast on its own
	["HUNTER"]		= 229386,
	["MAGE"]		= 229376,
	["MONK"]		= 229385,
	["PALADIN"]		= 231435,
	["PRIEST"]		= 229377,
	["ROGUE"]		= 231434,
	["SHAMAN"]		= 231442,
	["WARLOCK"]		= 232412,
	["WARRIOR"]		= 229388,
}
local class_mount = GetSpellInfo(class_mounts[class])
local CrimsonWaterStrider = GetSpellInfo(87791)
local Draenor = 1116
local FlightForm = GetSpellInfo(165962)
local FrostwolfWarWolf = 164222
local GarrisonAbility = GetSpellInfo(161691)
local GhostWolf = GetSpellInfo(2645)
local Grommashar = 1329
local IsGarrison = {
	[1152] = true,
	[1330] = true,
	[1153] = true,
	[1154] = true,
	[1158] = true,
	[1331] = true,
	[1159] = true,
	[1160] = true
}
local MoonkinForm = GetSpellInfo(24858)
local Pandaria = 870
local RidingTurtle = GetSpellInfo(30174)
local SeaTurtle = GetSpellInfo(64731)
local SubduedSeaHorse = GetSpellInfo(98718)
local SummonRandomFavoriteMount = 150544
local Tanaan_Jungle = 1464
local TelaariTalbuk = 165803
local TravelForm = GetSpellInfo(783)
local WaterWalking = GetSpellInfo(546)
local ZenFlight = GetSpellInfo(125883)

--constants defined with other constants
local GarrisonMacro = "/cast "..GarrisonAbility
local WaterWalkingMacro = "/cast [@player]"..WaterWalking.."\n"
local SummonRandomMountMacro = "/run C_MountJournal.SummonByID(0)"

--flags
local flags = {}
local mount_owned = {}
local druid_form = {}

--non-flag variables
local zone
local timer
local GMN
local FMN
local SMN
local CMN
local AMN
local corral_mount_icon
local GarrisonOverrideSpell

--functions
local CanFly
local IsAbyssalOk
local define_shaman_macro_text
local define_druid_macro_text
local define_monk_macro_text
local define_non_shaman_non_druid_non_monk_macro_text
local IsOutdoorsVashir

MandrillMount:SetAttribute("type","macro")
MandrillMount_aux1:SetAttribute("type","macro")
MandrillMount_aux2:SetAttribute("type","macro")
MandrillMount_aux3:SetAttribute("type","macro")
MandrillMountData = {}
MandrillMount_aux1:SetAttribute("macrotext","/cancelform")
MandrillMount_aux2:SetAttribute("macrotext",GarrisonMacro.."\n/cast [nomounted]"..GhostWolf)
MandrillMount_aux3:SetAttribute("macrotext",GarrisonMacro.."\n/cast [mounted];[outdoors]"..TravelForm..";"..CatForm)
timer = GetTime()

SLASH_MANDRILLMOUNT1 = "/MandrillMount"
SlashCmdList["MANDRILLMOUNT"] = function(msg)
	GMN,FMN,SMN,CMN,AMN = msg:match("%s*([^,]*)%s*,?%s*([^,]*)%s*,?%s*([^,]*)%s*,?%s*([^,]*)%s*,?%s*([^,]*)%s*")
	if GMN then
		GMN = string.upper(GMN:gsub("%s*$",""))
		if GMN=="CLASS" then
			GMN = class_mount
		end
		mount_owned[GMN] = GetSpellInfo(GMN) and true
	end
	if FMN then
		FMN = string.upper(FMN:gsub("%s*$",""))
		if FMN=="CLASS" then
			FMN = class_mount
		end
		mount_owned[FMN] = GetSpellInfo(FMN) and true
	else
		FMN = GMN
		mount_owned[FMN] = mount_owned[GMN]
	end
	if SMN then
		SMN = string.upper(SMN:gsub("%s*$",""))
		if SMN=="CLASS" then
			SMN = class_mount
		end
	end
	if CMN then
		CMN = string.upper(CMN:gsub("%s*$",""))
		if CMN=="CLASS" then
			CMN = class_mount
		end
	end
	if AMN then
		AMN = string.upper(AMN:gsub("%s*$",""))
		if AMN=="CLASS" then
			AMN = class_mount
		end
	end
	MandrillMountData["MacroName"] = GetMacroInfo(GetRunningMacro())
	MandrillMountData["GroundMountName"] = GMN
	MandrillMountData["FlyingMountName"] = FMN
	MandrillMountData["ShiftMountName"] = SMN
	MandrillMountData["CtrlMountName"] = CMN
	MandrillMountData["AltMountName"] = AMN
	flags.is_moving = GetUnitSpeed("player")~=0 or IsFalling()
	flags.just_submerged = IsSubmerged() and GetTime()-timer<1
	if not flags.in_combat then
		local macro_text
		if class=="SHAMAN" then
			macro_text = define_shaman_macro_text()
		elseif class=="DRUID" then
			macro_text = define_druid_macro_text()
		elseif class=="MONK" then
			macro_text = define_monk_macro_text()
		else
			macro_text = define_non_shaman_non_druid_non_monk_macro_text()
		end
		MandrillMount:SetAttribute("macrotext",macro_text)
	end
	if not flags.events_registered then
		MandrillMount:RegisterEvent("PLAYER_REGEN_ENABLED")
		MandrillMount:RegisterEvent("PLAYER_REGEN_DISABLED")
		MandrillMount:RegisterEvent("SPELL_UPDATE_USABLE")
		MandrillMount:RegisterEvent("UPDATE_MACROS")
		MandrillMount:RegisterEvent("MODIFIER_STATE_CHANGED")
		if class=="DRUID" then
			MandrillMount:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
		end
		flags.events_registered = true
	end
end

function CanFly()
	local can_fly = false
	if (zone==0 or zone==1 or zone==646) and (flags.ExpertRiding or flags.ArtisanRiding or flags.MasterRiding) then
		can_fly = true
	elseif zone==530 and (flags.ExpertRiding or flags.ArtisanRiding or flags.MasterRiding) then
		can_fly = true
	elseif zone==571 and (flags.ExpertRiding or flags.ArtisanRiding or flags.MasterRiding) then
		can_fly = true
	elseif zone==870 and (flags.ExpertRiding or flags.ArtisanRiding or flags.MasterRiding) then
		can_fly = true
	elseif zone==Draenor and flags.DraenorPathfinder then
		can_fly = true
	elseif zone==BrokenIsles and flags.BrokenIslesPathfinder2 then
		can_fly = true
	elseif zone==1756 then
		can_fly = true
	end
	return can_fly
end

function define_shaman_macro_text()
	local macro_text
	if CanExitVehicle() then
		macro_text = "/run VehicleExit()"
	elseif IsMounted() then
		macro_text = "/dismount [noflying]"
	elseif IsShiftKeyDown() and flags.ShiftOk and SMN=="RANDOM" then
		macro_text = WaterWalkingMacro..SummonRandomMountMacro
	elseif IsShiftKeyDown() and flags.ShiftOk then
		macro_text = WaterWalkingMacro.."/cast "..SMN
	elseif IsControlKeyDown() and flags.CtrlOk and CMN=="RANDOM" then
		macro_text = WaterWalkingMacro..SummonRandomMountMacro
	elseif IsControlKeyDown() and flags.CtrlOk then
		macro_text = WaterWalkingMacro.."/cast "..CMN
	elseif IsAltKeyDown() and flags.AltOk and AMN=="RANDOM" then
		macro_text = WaterWalkingMacro..SummonRandomMountMacro
	elseif IsAltKeyDown() and flags.AltOk then
		macro_text = WaterWalkingMacro.."/cast "..AMN
	elseif GetShapeshiftForm()==1 then
		macro_text = "/cast "..GhostWolf
	elseif flags.is_moving then
		macro_text = "/cast "..GhostWolf
	elseif flags.just_submerged and flags.FlyingOk then
		macro_text = WaterWalkingMacro.."/cast "..FMN
	elseif flags.is_submerged and flags.is_outdoor_vashjir and flags.AbyssalOk then
		macro_text = WaterWalkingMacro.."/cast "..AbyssalSeaHorse
	elseif flags.is_submerged and flags.RidingTurtleOk and flags.SeaTurtleOk then
		if random()<0.5 then
			macro_text = WaterWalkingMacro.."/cast "..RidingTurtle
		else
			macro_text = WaterWalkingMacro.."/cast "..SeaTurtle
		end
	elseif flags.is_submerged and flags.RidingTurtleOk then
		macro_text = WaterWalkingMacro.."/cast "..RidingTurtle
	elseif flags.is_submerged and flags.SeaTurtleOk then
		macro_text = WaterWalkingMacro.."/cast "..SeaTurtle
	elseif flags.is_submerged and flags.SeaHorseOk then
		macro_text = WaterWalkingMacro.."/cast "..SubduedSeaHorse
	elseif flags.FlyingOk and flags.is_submerged and FMN=="RANDOM" then
		macro_text = WaterWalkingMacro..SummonRandomMountMacro
	elseif flags.FlyingOk and FMN=="RANDOM" then
		macro_text = SummonRandomMountMacro
	elseif flags.FlyingOk and flags.is_submerged then
		macro_text = WaterWalkingMacro.."/cast "..FMN
	elseif flags.FlyingOk then
		macro_text = "/cast "..FMN
	elseif flags.GarrisonMountOk and zone~=Grommashar then
		macro_text = WaterWalkingMacro..GarrisonMacro
    elseif flags.GroundOk and GMN=="RANDOM" and zone~=Grommashar then
		macro_text = WaterWalkingMacro..SummonRandomMountMacro
	elseif flags.GroundOk and zone~=Grommashar then
		macro_text = WaterWalkingMacro.."/cast "..GMN
	else
		macro_text = "/cast "..GhostWolf
	end
	return macro_text
end
	
function define_druid_macro_text()
  -- DEFAULT_CHAT_FRAME:AddMessage( "define_druid_macro_text" )
	local macro_text
	local form = GetShapeshiftForm()
	if CanExitVehicle() then
		macro_text = "/run VehicleExit()"
	elseif IsMounted() or IsFlying() then
		macro_text = "/dismount\n/cancelform [form:3]"
	elseif IsShiftKeyDown() and flags.ShiftOk and SMN=="RANDOM" then
		macro_text = SummonRandomMountMacro
	elseif IsShiftKeyDown() and flags.ShiftOk then
		macro_text = "/cast "..SMN
	elseif IsControlKeyDown() and flags.CtrlOk and CMN=="RANDOM" then
		macro_text = SummonRandomMountMacro
	elseif IsControlKeyDown() and flags.CtrlOk then
		macro_text = "/cast "..CMN
	elseif IsAltKeyDown() and flags.AltOk and AMN=="RANDOM" then
		macro_text = SummonRandomMountMacro
	elseif IsAltKeyDown() and flags.AltOk then
		macro_text = "/cast "..AMN
	elseif form==druid_form[CatForm] and GetSpellInfo(MoonkinForm) then
		macro_text = "/cast "..MoonkinForm
	elseif form==druid_form[CatForm] then
		macro_text = "/cast "..CatForm
	elseif form==druid_form[TravelForm] and GetSpellInfo(MoonkinForm) then
		macro_text = "/cast "..MoonkinForm
	elseif form==druid_form[TravelForm] then
		macro_text = "/cast "..TravelForm
	elseif form==druid_form[FlightForm] and GetSpellInfo(MoonkinForm) then
		macro_text = "/cast "..MoonkinForm
	elseif form==druid_form[FlightForm] then
		macro_text = "/cast "..FlightForm
	elseif flags.is_moving and flags.is_outdoors then
		macro_text = "/cast "..TravelForm
	elseif flags.just_submerged and flags.FlyingOk then
		macro_text = "/cast "..FMN
	elseif flags.is_submerged and flags.is_outdoors then
		macro_text = "/cast "..TravelForm
	elseif flags.is_submerged and flags.is_outdoor_vashjir and flags.AbyssalOk then
		macro_text = "/cast "..AbyssalSeaHorse
	elseif flags.is_submerged and flags.RidingTurtleOk and flags.SeaTurtleOk then
		if random()<0.5 then
			macro_text = "/cast "..RidingTurtle
		else
			macro_text = "/cast "..SeaTurtle
		end
	elseif flags.is_submerged and flags.RidingTurtleOk then
		macro_text = "/cast "..RidingTurtle
	elseif flags.is_submerged and flags.SeaTurtleOk then
		macro_text = "/cast "..SeaTurtle
	elseif flags.is_submerged and flags.SeaHorseOk then
		macro_text = "/cast "..SubduedSeaHorse
	elseif flags.is_moving then
		macro_text = "/cast "..CatForm
	elseif flags.FlyingOk and FMN=="RANDOM" then
		macro_text = SummonRandomMountMacro
	elseif flags.FlyingOk then
		macro_text = "/cast "..FMN
	elseif flags.GarrisonMountOk and zone~=Grommashar then
		macro_text = GarrisonMacro
    elseif flags.GroundOk and GMN=="RANDOM" and zone~=Grommashar then
		macro_text = SummonRandomMountMacro
	elseif flags.GroundOk and zone~=Grommashar then
		macro_text = "/cast "..GMN
	else
		macro_text = "/cast "..CatForm
	end
  -- DEFAULT_CHAT_FRAME:AddMessage( macro_text )
	return macro_text
end

function define_monk_macro_text()
	local macro_text
	if CanExitVehicle() then
		macro_text = "/run VehicleExit()"
	elseif IsMounted() then
		if flags.ZenFlightOk then
			macro_text = "/dismount"
		else
			macro_text = "/dismount [noflying]"
		end
	elseif IsShiftKeyDown() and flags.ShiftOk then
		if SMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..SMN
		end
	elseif IsControlKeyDown() and flags.CtrlOk then
		if CMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..CMN
		end
	elseif IsAltKeyDown() and flags.AltOk then
		if AMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..AMN
		end
	elseif flags.just_submerged and flags.FlyingOk then
		macro_text = "/cast "..FMN
	elseif flags.just_submerged and not flags.in_bg and flags.AzureOk and flags.CrimsonOk then
		if random()<0.5 then
			macro_text = "/cast "..AzureWaterStrider
		else
			macro_text = "/cast "..CrimsonWaterStrider
		end
	elseif flags.just_submerged and not flags.in_bg and flags.AzureOk then
		macro_text = "/cast "..AzureWaterStrider
	elseif flags.just_submerged and not flags.in_bg and flags.CrimsonOk then
		macro_text = "/cast "..CrimsonWaterStrider
	elseif flags.is_submerged and flags.AbyssalOk then
		macro_text = "/cast "..AbyssalSeaHorse
	elseif flags.is_submerged and flags.RidingTurtleOk and flags.SeaTurtleOk then
		if random()<0.5 then
			macro_text = "/cast "..RidingTurtle
		else
			macro_text = "/cast "..SeaTurtle
		end
	elseif flags.is_submerged and flags.RidingTurtleOk then
		macro_text = "/cast "..RidingTurtle
	elseif flags.is_submerged and flags.SeaTurtleOk then
		macro_text = "/cast "..SeaTurtle
	elseif flags.is_submerged and flags.SeaHorseOk then
		macro_text = "/cast "..SubduedSeaHorse
	elseif flags.is_moving and flags.ZenFlightOk then
		macro_text = "/cast "..ZenFlight
	elseif flags.FlyingOk then
		if FMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..FMN
		end
	elseif flags.GarrisonMountOk then
		macro_text = GarrisonMacro
    elseif flags.GroundOk then
		if GMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..GMN
		end
	else
		macro_text = ""
	end
	return macro_text
end

function define_non_shaman_non_druid_non_monk_macro_text()
	local macro_text
	if CanExitVehicle() then
		macro_text = "/run VehicleExit()"
	elseif IsMounted() then
		macro_text = "/dismount [noflying]"
	elseif IsShiftKeyDown() and flags.ShiftOk then
		if SMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..SMN
		end
	elseif IsControlKeyDown() and flags.CtrlOk then
		if CMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..CMN
		end
	elseif IsAltKeyDown() and flags.AltOk then
		if AMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..AMN
		end
	elseif flags.just_submerged and flags.FlyingOk then
		macro_text = "/cast "..FMN
	elseif flags.just_submerged and not flags.in_bg and flags.AzureOk and flags.CrimsonOk then
		if random()<0.5 then
			macro_text = "/cast "..AzureWaterStrider
		else
			macro_text = "/cast "..CrimsonWaterStrider
		end
	elseif flags.just_submerged and not flags.in_bg and flags.AzureOk then
		macro_text = "/cast "..AzureWaterStrider
	elseif flags.just_submerged and not flags.in_bg and flags.CrimsonOk then
		macro_text = "/cast "..CrimsonWaterStrider
	elseif flags.is_submerged and flags.AbyssalOk then
		macro_text = "/cast "..AbyssalSeaHorse
	elseif flags.is_submerged and flags.RidingTurtleOk and flags.SeaTurtleOk then
		if random()<0.5 then
			macro_text = "/cast "..RidingTurtle
		else
			macro_text = "/cast "..SeaTurtle
		end
	elseif flags.is_submerged and flags.RidingTurtleOk then
		macro_text = "/cast "..RidingTurtle
	elseif flags.is_submerged and flags.SeaTurtleOk then
		macro_text = "/cast "..SeaTurtle
	elseif flags.is_submerged and flags.SeaHorseOk then
		macro_text = "/cast "..SubduedSeaHorse
	elseif flags.FlyingOk then
		if FMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..FMN
		end
	elseif flags.GarrisonMountOk then
		macro_text = GarrisonMacro
    elseif flags.GroundOk then
		if GMN=="RANDOM" then
			macro_text = SummonRandomMountMacro
		else
			macro_text = "/cast "..GMN
		end
	else
		macro_text = ""
	end
	return macro_text
end

function IsOutdoorsVashir() --also imply submerged
    local is_usable
    _,_,_,_,is_usable = GetMountInfoByID(Abyssal_index)
    return is_usable --submerged, outdoors, Vashjir and has the mount
end

MandrillMount:SetScript("OnEvent",function(self,event,...)
	flags.is_submerged = IsSubmerged()
	if flags.is_submerged then
		flags.RidingTurtleOk = IsUsableSpell(RidingTurtle)
		flags.SeaHorseOk = IsUsableSpell(SubduedSeaHorse)
		flags.SeaTurtleOk = IsUsableSpell(SeaTurtle)
		flags.is_outdoor_vashjir = IsOutdoorsVashir()
		if flags.is_outdoor_vashjir then
			flags.AbyssalOk = IsUsableSpell(AbyssalSeaHorse)
		end
	end
	flags.just_submerged = flags.is_submerged and GetTime()-timer<1
	if flags.just_submerged then
		local instance_type
		_,instance_type = IsInInstance()
		flags.in_bg = instance_type=="pvp"
		if not flags.in_bg then
			flags.AzureOk = IsUsableSpell(AzureWaterStrider)
			flags.CrimsonOk = IsUsableSpell(CrimsonWaterStrider)
		end
	end
	flags.is_outdoors = IsOutdoors()
	_,_,_,_,_,_,_,zone = GetInstanceInfo()
	if zone==Tanaan_Jungle then
		zone = Draenor
	elseif IsGarrison[zone] then
		zone = Draenor
	end
	if zone==Draenor then
		_,_,corral_mount_icon,_,_,_,GarrisonOverrideSpell = GetSpellInfo(GarrisonAbility)
		flags.GarrisonMountOk = (GarrisonOverrideSpell==FrostwolfWarWolf or GarrisonOverrideSpell==TelaariTalbuk) and flags.is_outdoors
		flags.DraenorPathfinder = IsSpellKnown(191645)
	else
		flags.GarrisonMountOk = false
	end
	if zone==BrokenIsles then
		flags.BrokenIslesPathfinder2 = IsSpellKnown(233368)
	end
	local MacroName = MandrillMountData["MacroName"]
	if event=="PLAYER_ENTERING_WORLD" then
		GMN = MandrillMountData["GroundMountName"]
		FMN = MandrillMountData["FlyingMountName"]
		SMN = MandrillMountData["ShiftMountName"]
		CMN = MandrillMountData["CtrlMountName"]
		AMN = MandrillMountData["AltMountName"]
		if GMN then
			mount_owned[GMN] = GetSpellInfo(GMN) and true
		end
		if FMN then
			mount_owned[FMN] = GetSpellInfo(FMN) and true
		end
		mount_owned[AbyssalSeaHorse] = GetSpellInfo(AbyssalSeaHorse) and true
		mount_owned[RidingTurtle] = GetSpellInfo(RidingTurtle) and true
		mount_owned[SeaTurtle] = GetSpellInfo(SeaTurtle) and true
		mount_owned[SubduedSeaHorse] = GetSpellInfo(SubduedSeaHorse) and true
		if not (mount_owned[AbyssalSeaHorse] and mount_owned[RidingTurtle] and mount_owned[SeaTurtle] and mount_owned[SubduedSeaHorse]) then
			self:RegisterEvent("COMPANION_LEARNED")
		end
		flags.MasterRiding = IsSpellKnown(90265)
		if not flags.MasterRiding then
			flags.ArtisanRiding = IsSpellKnown(34091)
			if not flags.ArtisanRiding then
				flags.ExpertRiding = IsSpellKnown(34090)
			end
		end
		if not (flags.MasterRiding and flags.DraenorPathfinder and flags.BrokenIslesPathfinder2) then
			self:RegisterEvent("LEARNED_SPELL_IN_TAB")
		end
		if MacroName then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterEvent("SPELL_UPDATE_USABLE")
			self:RegisterEvent("UPDATE_MACROS")
			self:RegisterEvent("MODIFIER_STATE_CHANGED")
			if class=="DRUID" then
				self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
			end
		end
	elseif event=="LEARNED_SPELL_IN_TAB" then
		local arg1 = ...
		if arg1==34090 then
			flags.ExpertRiding = true
		elseif arg1==34091 then
			flags.ArtisanRiding = true
		elseif arg1==90265 then
			flags.MasterRiding = true
		elseif arg1==191645 then
			flags.DraenorPathfinder = true
		elseif arg==233368 then
			flags.BrokenIslesPathfinder2 = true
		end
		if flags.MasterRiding and flags.DraenorPathfinder and flags.BrokenIslesPathfinder2 then
			self:UnregisterEvent("LEARNED_SPELL_IN_TAB")
		end
	end
	flags.FlyingOk = not flags.in_combat and (FMN=="RANDOM" and flags.is_outdoors or IsUsableSpell(FMN)) and (zone==Pandaria or zone==Draenor or zone==BrokenIsles or IsFlyableArea()) and CanFly()
	if class=="DRUID" then
		flags.FlightFormOk = flags.FlyingOk and IsUsableSpell(FlightForm)
	elseif class=="MONK" then
		flags.ZenFlightOk = flags.FlyingOk and IsUsableSpell(ZenFlight) and IsSpellKnown(125883)
	end

	if event=="PLAYER_REGEN_DISABLED" then
		flags.in_combat = true
		if class=="SHAMAN" or class=="DRUID" then
			MandrillMount:UnregisterEvent("MODIFIER_STATE_CHANGED")
		end
		if class~="DRUID" then
			MandrillMount:UnregisterEvent("SPELL_UPDATE_USABLE")
		end
		if flags.GarrisonMountOk and (zone~=Grommashar or class~="SHAMAN") then
			if class=="SHAMAN" then
				UIErrorsFrame:Hide()
				MandrillMount:SetAttribute("macrotext","/click [form:1]MandrillMount_aux1;MandrillMount_aux2")
			elseif class=="DRUID" then
				UIErrorsFrame:Hide()
				MandrillMount:SetAttribute("macrotext","/click [form:1][form:2][form:3]MandrillMount_aux1;MandrillMount_aux3")
			else
				MandrillMount:SetAttribute("macrotext","/run if CanExitVehicle() then VehicleExit() end\n"..GarrisonMacro)
			end
		else
			if class=="SHAMAN" then
				MandrillMount:SetAttribute("macrotext","/run if CanExitVehicle() then VehicleExit() end\n/cast [nomounted]"..GhostWolf.."\n/dismount [noflying]")
			elseif class=="DRUID" then
				MandrillMount:SetAttribute("macrotext","/run if CanExitVehicle() then VehicleExit() end\n/cast [mounted];[outdoors]!"..TravelForm..";!"..CatForm.."\n/dismount [noflying]")
			else
				MandrillMount:SetAttribute("macrotext","/run if CanExitVehicle() then VehicleExit() end\n/dismount [noflying]")
			end
		end
	elseif event=="PLAYER_REGEN_ENABLED" then
		flags.in_combat = false
		UIErrorsFrame:Clear()
		UIErrorsFrame:Show()
		MandrillMount:RegisterEvent("SPELL_UPDATE_USABLE")
		MandrillMount:RegisterEvent("MODIFIER_STATE_CHANGED")
	end

	flags.GroundOk = not flags.in_combat and (GMN=="RANDOM" and flags.is_outdoors or IsUsableSpell(GMN))
	flags.ShiftOk = not flags.in_combat and (SMN=="RANDOM" and flags.is_outdoors or IsUsableSpell(SMN))
	flags.CtrlOk = not flags.in_combat and (CMN=="RANDOM" and flags.is_outdoors or IsUsableSpell(CMN))
	flags.AltOk = not flags.in_combat and (AMN=="RANDOM" and flags.is_outdoors or IsUsableSpell(AMN))

	if event=="SPELL_UPDATE_USABLE" and not flags.is_submerged then
		timer = GetTime()
	elseif event=="COMPANION_LEARNED" then
		if mount_owned[AbyssalSeaHorse]==nil then
			mount_owned[AbyssalSeaHorse] = GetSpellInfo(AbyssalSeaHorse) and true
		end
		if mount_owned[RidingTurtle]==nil then
			mount_owned[RidingTurtle] = GetSpellInfo(RidingTurtle) and true
		end
		if mount_owned[SeaTurtle]==nil then
			mount_owned[SeaTurtle] = GetSpellInfo(SeaTurtle) and true
		end
		if mount_owned[SubduedSeaHorse]==nil then
			mount_owned[SubduedSeaHorse] = GetSpellInfo(SubduedSeaHorse) and true
		end
		if FMN and mount_owned[FMN]==nil then
			mount_owned[FMN] = GetSpellInfo(FMN) and true
		end
		if GMN and mount_owned[GMN]==nil then
			mount_owned[GMN] = GetSpellInfo(GMN) and true
		end
		if mount_owned[AbyssalSeaHorse] and mount_owned[RidingTurtle] and mount_owned[SeaTurtle] and mount_owned[SubduedSeaHorse] then
			self:UnregisterEvent("COMPANION_LEARNED")
		end
	elseif event=="UPDATE_SHAPESHIFT_FORMS" then
		for i=1,GetNumShapeshiftForms() do
			local _,_,_,_,spell_id = GetShapeshiftFormInfo(i)
			local spell_info = GetSpellInfo(spell_id)
      if spell_info ~= nil then
        druid_form[spell_info] = i
      end
		end
	end
	local old_RandomOk = flags.RandomOk
	if flags.is_outdoors and not flags.in_combat then
		flags.RandomOk = true
	else
		flags.RandomOk = false
	end
	if class=="SHAMAN" then
		if IsShiftKeyDown() and SMN and SMN~="" and flags.ShiftOk then
			if SMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,SMN)
			end
		elseif IsControlKeyDown() and CMN and CMN~="" and flags.CtrlOk then
			if CMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,CMN)
			end
		elseif IsAltKeyDown() and AMN and AMN~="" and flags.AltOk then
			if AMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,AMN)
			end
		elseif flags.GarrisonMountOk and zone~=Grommashar then
			SetMacroSpell(MacroName,GarrisonAbility) --to force the action bar to use the Garrison Ability, so IsUsableAction (which affects the texture) return true in combat
			SetMacroStatus(MacroName,"enabled")
			SetMacroIcon(MacroName,corral_mount_icon)
		elseif flags.is_submerged and IsOutdoorsVashir() and (flags.AbyssalOk and mount_owned[AbyssalSeaHorse]) then
			SetMacroSpell(MacroName,AbyssalSeaHorse)
		elseif flags.is_submerged and flags.RidingTurtleOk and flags.SeaTurtleOk and mount_owned[RidingTurtle] and mount_owned[SeaTurtle] then
			if random()<0.5 then
				SetMacroSpell(MacroName,RidingTurtle)
			else
				SetMacroSpell(MacroName,SeaTurtle)
			end
		elseif flags.is_submerged and flags.RidingTurtleOk and mount_owned[RidingTurtle] then
			SetMacroSpell(MacroName,RidingTurtle)
		elseif flags.is_submerged and flags.SeaTurtleOk and mount_owned[SeaTurtle] then
			SetMacroSpell(MacroName,SeaTurtle)
		elseif flags.is_submerged and flags.SeaHorseOk and mount_owned[SubduedSeaHorse] then
			SetMacroSpell(MacroName,SubduedSeaHorse)
		elseif flags.FlyingOk then
			if FMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,FMN)
			end
		elseif flags.GroundOk and zone~=Grommashar then
			if GMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,GMN)
			end
		else
			SetMacroSpell(MacroName,GhostWolf)
		end
	elseif class=="DRUID" then	
		if IsShiftKeyDown() and SMN and SMN~="" and flags.ShiftOk then
			if SMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,SMN)
			end
		elseif IsControlKeyDown() and CMN and CMN~="" and flags.CtrlOk then
			if CMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,CMN)
			end
		elseif IsAltKeyDown() and AMN and AMN~="" and flags.AltOk then
			if AMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,AMN)
			end
		elseif flags.GarrisonMountOk and zone~=Grommashar then
			SetMacroSpell(MacroName,GarrisonAbility) --to force the action bar to use the Garrison Ability, so IsUsableAction (which affects the texture) return true in combat
			SetMacroStatus(MacroName,"enabled")
			SetMacroIcon(MacroName,corral_mount_icon)		
		elseif flags.is_submerged and IsOutdoorsVashir() and (flags.AbyssalOk and mount_owned[AbyssalSeaHorse]) then
			SetMacroSpell(MacroName,AbyssalSeaHorse)
		elseif flags.is_submerged and flags.RidingTurtleOk and flags.SeaTurtleOk and mount_owned[RidingTurtle] and mount_owned[SeaTurtle] then
			if random()<0.5 then
				SetMacroSpell(MacroName,RidingTurtle)
			else
				SetMacroSpell(MacroName,SeaTurtle)
			end
		elseif flags.is_submerged and flags.RidingTurtleOk and mount_owned[RidingTurtle] then
			SetMacroSpell(MacroName,RidingTurtle)
		elseif flags.is_submerged and flags.SeaTurtleOk and mount_owned[SeaTurtle] then
			SetMacroSpell(MacroName,SeaTurtle)
		elseif flags.is_submerged and flags.SeaHorseOk and mount_owned[SubduedSeaHorse] then
			SetMacroSpell(MacroName,SubduedSeaHorse)
		elseif flags.is_submerged then
			SetMacroSpell(MacroName,TravelForm)
		elseif flags.FlyingOk then
			if FMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,FMN)
			end
		elseif flags.GroundOk and zone~=Grommashar then
			if GMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,GMN)
			end
		elseif flags.is_outdoors then
			SetMacroSpell(MacroName,TravelForm)
		else
			SetMacroSpell(MacroName,CatForm)
		end
	else
		if IsShiftKeyDown() and SMN and SMN~="" then
			if SMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,SMN)
			end
		elseif IsControlKeyDown() and CMN and CMN~="" then
			if CMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,CMN)
			end
		elseif IsAltKeyDown() and AMN and AMN~="" then
			if AMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,AMN)
			end
		elseif GarrisonOverrideSpell==FrostwolfWarWolf or GarrisonOverrideSpell==TelaariTalbuk then
			SetMacroSpell(MacroName,GarrisonAbility) --to force the action bar to use the Garrison Ability, so IsUsableAction (which affects the texture) return true in combat
			SetMacroStatus(MacroName,flags.GarrisonMountOk and "enabled" or "disabled")
			SetMacroIcon(MacroName,corral_mount_icon)
		elseif flags.is_submerged and flags.is_outdoor_vashjir and mount_owned[AbyssalSeaHorse] then
			SetMacroSpell(MacroName,AbyssalSeaHorse)
		elseif flags.is_submerged and mount_owned[RidingTurtle] and mount_owned[SeaTurtle] then
			if random()<0.5 then
				SetMacroSpell(MacroName,RidingTurtle)
			else
				SetMacroSpell(MacroName,SeaTurtle)
			end
		elseif flags.is_submerged and mount_owned[RidingTurtle] then
			SetMacroSpell(MacroName,RidingTurtle)
		elseif flags.is_submerged and mount_owned[SeaTurtle] then
			SetMacroSpell(MacroName,SeaTurtle)
		elseif flags.is_submerged and mount_owned[SubduedSeaHorse] then
			SetMacroSpell(MacroName,SubduedSeaHorse)
		elseif (zone==Draenor or zone==BrokenIsles or IsFlyableArea()) and CanFly() and (mount_owned[FMN] or FMN=="RANDOM") then
			if FMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,FMN)
			end
		elseif mount_owned[GMN] or GMN=="RANDOM" then
			if GMN=="RANDOM" then
				SetMacroStatus(MacroName,flags.RandomOk and "enabled" or "disabled")
				SetMacroIcon(MacroName,"Interface\\Icons\\achievement_guildperk_mountup")
			else
				SetMacroSpell(MacroName,GMN)
			end
		end
	end
end)
MandrillMount:RegisterEvent("PLAYER_ENTERING_WORLD")

hooksecurefunc("EditMacro",function(old_name_or_index,new_name)
	old_name_or_index = tonumber(old_name_or_index) or old_name_or_index
	if type(old_name_or_index)=="string" then
		local old_name = old_name_or_index
		if MandrillMountData["MacroName"]==old_name and GetMacroIndexByName(MandrillMountData["MacroName"])==0 and new_name then
			MandrillMountData["MacroName"] = new_name
		end
	elseif type(old_name_or_index)=="number" then
		if new_name and MandrillMountData["MacroName"] and GetMacroIndexByName(MandrillMountData["MacroName"])==0 then
			MandrillMountData["MacroName"] = new_name
		end
	end
end)

hooksecurefunc("DeleteMacro",function(old_name_or_index)
	old_name_or_index = tonumber(old_name_or_index) or old_name_or_index
	if type(old_name_or_index)=="string" then
		local old_name = old_name_or_index
		if MandrillMountData["MacroName"]==old_name and GetMacroIndexByName(MandrillMountData["MacroName"])==0 then
			MandrillMountData["MacroName"] = nil
		end
	elseif type(old_name_or_index)=="number" then
		if MandrillMountData["MacroName"] and GetMacroIndexByName(MandrillMountData["MacroName"])==0 then
			MandrillMountData["MacroName"] = nil
		end
	end
end)

function addon_table.fix_tooltip(macro_name,override_icon)
	if MandrillMountData["MacroName"] and macro_name==MandrillMountData["MacroName"] then
		if override_icon=="Interface\\Icons\\achievement_guildperk_mountup" then
			GameTooltip:SetSpellByID(SummonRandomFavoriteMount)
		elseif override_icon==corral_mount_icon and GetMacroSpell(macro_name)==GarrisonAbility then
			GameTooltip:SetSpellByID(GarrisonOverrideSpell)
		end
		GameTooltip:Show()
	end
end
