--adjust these to something sensible for your loco
IDLERPM = 200
FULLRPM = 850
MAXAMPS = 1000
lspeed = 0
block = 0
slock = 0
vlock = 0
sdistance = 0
bspeed = 0
wspeed = 0
twarning = 0
xwarning = 0
xflash = 0
sbeep = 0
rbeep = 0

--this is the smoke generation rate, higher means less smoke, towards 0 means maximum smoke
RATE = 0.04
--this controls smoke discoloration at low power settings, 1 means dark black, higher is lighter gray
COL = 4
--this controls smoke generation at high RPMs, 0 means none, 1 means a lot
RPMCF = 0.3
--this controls smoke generation at high load (amperage), meaning as above
AMPCF = 0.7
--this controls the blueness of the smoke, 1.2 is bluish smoke, 0.8 is brownish smoke
BLNSS = 1.0

RPM_ID = 1709
RPMD_ID = 1710
AMPS_ID = 1711

-- How long to stay off/on in each flash cycle
LIGHT_FLASH_OFF_SECS = 0.25
LIGHT_FLASH_ON_SECS = 0.25
-- State of flashing light
gTimeSinceLastFlash = 0
gLightFlashOn = false
tTimeSinceLastFlash = 0
tLightFlashOn = false
tFirstLightFlash = false
tTimeSinceLastUpdate = 0

function Initialise ()

gPrevRPM = 0
gPrevRPMDelta = 0
gPrevAmps = 0

--uncomment these to randomize smoke generation for each locomotive
RPMCF = math.random()
AMPCF = math.random()
BLNSS = 0.8 + (math.random() * 0.4)
COL = math.random() * 10
RATE = math.random() / 10

	Call( "BeginUpdate" )
	Call( "Exhaust:SetEmitterActive", 1 )

end


function OnControlValueChange ( name, index, value )

	if Call( "*:ControlExists", name, index ) then
		Call( "*:SetControlValue", name, index, value );
	end

end


function Update ( time )

tspeed = Call("*:GetSpeed")
sdistance = (tspeed*time) + sdistance
ntype, nspeed, ndistance = Call("GetNextSpeedLimit", 0, 0)
dtype, dstate, ddistance, daspect = Call("GetNextRestrictiveSignal", 0, 0)
xspeed = Call("*:GetCurrentSpeedLimit")
fdistance = ((tspeed)^2 - (nspeed)^2) / (2 * 0.58)
rdistance = ((tspeed)^2 - (nspeed)^2) / (2 * 0.48)
wdistance = ((tspeed)^2 - (nspeed)^2) / (2 * 0.38)
xdistance = ((tspeed^2)/(2*0.58)) + (6*tspeed)
zdistance = ((tspeed^2)/(2*0.58)) + (3*tspeed)
qdistance = ((tspeed^2)/(2*0.58))
--SysCall("ScenarioManager:ShowAlertMessageExt", tonumber(ddistance), tonumber(dstate), 0.2, 0)
oCNV = (math.floor(nspeed * 3.6))
oCNV = tostring(oCNV)
gCNV = (math.floor(lspeed * 3.6))
gCNV = tostring(gCNV)
sCNV = (math.floor(Call("*:GetControlValue", "SpeedometerKPH", 0)))
sCNV = tostring(sCNV)

	if xspeed > 100/3.6 then
		lspeed = 100/3.6
	else
		lspeed = Call("*:GetCurrentSpeedLimit")
	end

Call("*:SetControlValue", "CNV_Lspeed", 0,  tonumber(lspeed))
gTimeSinceLastFlash = gTimeSinceLastFlash + time

	if (not gLightFlashOn) and gTimeSinceLastFlash >= LIGHT_FLASH_OFF_SECS then
		Call("*:SetControlValue", "CNV_breleaseLED", 0, 1)
		gLightFlashOn = true
		gTimeSinceLastFlash = 0
	elseif gLightFlashOn and gTimeSinceLastFlash >= LIGHT_FLASH_ON_SECS then
		Call("*:SetControlValue", "CNV_breleaseLED", 0, 0)
		gLightFlashOn = false
		gTimeSinceLastFlash = 0
	end

	if (block == 1 and tspeed > lspeed) or (slock == 1 and tspeed > bspeed) or (vlock == 1 and tspeed > 6.66) then
		Call("*:SetControlValue", "CNV_breleaseLED", 0, 1)
	elseif block == 0 and slock == 0 and vlock == 0 then
		Call("*:SetControlValue", "CNV_breleaseLED", 0, 0)
	end

-- Display Principal
	if twarning == 1 and ntype ~= 3 then
		tTimeSinceLastFlash = tTimeSinceLastFlash + time
		if tLightFlashOn == false and tTimeSinceLastFlash >= LIGHT_FLASH_OFF_SECS then
			Call("*:SetControlValue", "CNV_GUDigits", 0,  10)
			Call("*:SetControlValue", "CNV_GDDigits", 0,  10)
			Call("*:SetControlValue", "CNV_GCDigits", 0,  10)
			tLightFlashOn = true
			tTimeSinceLastFlash = 0
		elseif tLightFlashOn == true and tTimeSinceLastFlash >= LIGHT_FLASH_ON_SECS then
			Call("*:SetControlValue", "CNV_GUDigits", 0,  tonumber(oUnits))
			Call("*:SetControlValue", "CNV_GDDigits", 0,  tonumber(oTens))
			Call("*:SetControlValue", "CNV_GCDigits", 0,  tonumber(oHundreds))
			tLightFlashOn = false
			tTimeSinceLastFlash = 0
		end
	elseif twarning == 1 and ntype == 3 then
		tTimeSinceLastFlash = tTimeSinceLastFlash + time
		if tLightFlashOn == false and tTimeSinceLastFlash >= LIGHT_FLASH_OFF_SECS then
			Call("*:SetControlValue", "CNV_GUDigits", 0,  10)
			Call("*:SetControlValue", "CNV_GDDigits", 0,  10)
			Call("*:SetControlValue", "CNV_GCDigits", 0,  10)
			tLightFlashOn = true
			tTimeSinceLastFlash = 0
		elseif tLightFlashOn == true and tTimeSinceLastFlash >= LIGHT_FLASH_ON_SECS then
			Call("*:SetControlValue", "CNV_GUDigits", 0,  11)
			Call("*:SetControlValue", "CNV_GDDigits", 0,  tonumber(oTens))
			Call("*:SetControlValue", "CNV_GCDigits", 0,  tonumber(oHundreds))
			tLightFlashOn = false
			tTimeSinceLastFlash = 0	
		end
	elseif xwarning == 1 or xflash == 1 then
		tTimeSinceLastFlash = tTimeSinceLastFlash + time
		if tLightFlashOn == false and tTimeSinceLastFlash >= LIGHT_FLASH_OFF_SECS then
			Call("*:SetControlValue", "CNV_GUDigits", 0,  10)
			Call("*:SetControlValue", "CNV_GDDigits", 0,  10)
			Call("*:SetControlValue", "CNV_GCDigits", 0,  10)
			tLightFlashOn = true
			tTimeSinceLastFlash = 0
		elseif tLightFlashOn == true and tTimeSinceLastFlash >= LIGHT_FLASH_ON_SECS then
			Call("*:SetControlValue", "CNV_GUDigits", 0,  0)
			Call("*:SetControlValue", "CNV_GDDigits", 0,  0)
			Call("*:SetControlValue", "CNV_GCDigits", 0,  10)
			tLightFlashOn = false
			tTimeSinceLastFlash = 0	
		end
	elseif twarning == 0 and xwarning == 0 then
			Call("*:SetControlValue", "CNV_GUDigits", 0,  tonumber(gUnits))
			Call("*:SetControlValue", "CNV_GDDigits", 0,  tonumber(gTens))
			Call("*:SetControlValue", "CNV_GCDigits", 0,  tonumber(gHundreds))
	end

-- Display Auxiliar
	if string.len(oCNV) == 1 then
		oCNV = ("00" .. oCNV)
	elseif string.len(oCNV) == 2 then
		oCNV = ("0" .. oCNV)
	end
	_, _, oHundreds, oTens, oUnits = string.find(oCNV, "(%d)(%d)(%d)")
	
	if dstate ~= 2 and nspeed >= lspeed then
		Call("*:SetControlValue", "CNV_OUDigits", 0,  10)
		Call("*:SetControlValue", "CNV_ODDigits", 0,  10)
		Call("*:SetControlValue", "CNV_OCDigits", 0,  10)
	elseif dstate ~= 2 and nspeed < lspeed and ntype ~= 3 then
		Call("*:SetControlValue", "CNV_OUDigits", 0,  tonumber(oUnits))
		Call("*:SetControlValue", "CNV_ODDigits", 0,  tonumber(oTens))
		Call("*:SetControlValue", "CNV_OCDigits", 0,  tonumber(oHundreds))
	elseif dstate ~= 2 and nspeed < lspeed and ntype == 3 then
		Call("*:SetControlValue", "CNV_OUDigits", 0,  11)
		Call("*:SetControlValue", "CNV_ODDigits", 0,  tonumber(oTens))
		Call("*:SetControlValue", "CNV_OCDigits", 0,  tonumber(oHundreds))
	elseif dstate == 2 then
		Call("*:SetControlValue", "CNV_OUDigits", 0,  0)
		Call("*:SetControlValue", "CNV_ODDigits", 0,  0)
		Call("*:SetControlValue", "CNV_OCDigits", 0,  10)
	end

-- Velocimetro Digital
	if string.len(gCNV) == 1 then
		gCNV = ("00" .. gCNV)
	elseif string.len(gCNV) == 2 then
		gCNV = ("0" .. gCNV)
	end
	_, _, gHundreds, gTens, gUnits = string.find(gCNV, "(%d)(%d)(%d)")

	if string.len(sCNV) == 1 then
		sCNV = ("00" .. sCNV)
	elseif string.len(sCNV) == 2 then
		sCNV = ("0" .. sCNV)
	end
	_, _, sHundreds, sTens, sUnits = string.find(sCNV, "(%d)(%d)(%d)")

	Call("*:SetControlValue", "CNV_RUDigits", 0,  tonumber(sUnits))
	Call("*:SetControlValue", "CNV_RDDigits", 0,  tonumber(sTens))
	Call("*:SetControlValue", "CNV_RCDigits", 0,  tonumber(sHundreds))
	
-- Tacografo
tTimeSinceLastUpdate = tTimeSinceLastUpdate + time
	
	if tTimeSinceLastUpdate > 1 then
		Call("*:SetControlValue", "Taco", 0, Call("*:GetControlValue", "SpeedometerKPH", 0))
		tTimeSinceLastUpdate = 0
	end

-- Sobrevelocidade
	if tspeed - 1.389 > lspeed then
		Call("*:SetControlValue", "CNV_Overspeed", 0, 1)
	else
		Call("*:SetControlValue", "CNV_Overspeed", 0, 0)
	end

	if tspeed - 2.778 > lspeed then
		Call("*:SetControlValue", "TrainBrakeControl", 0, 0.9)
		Call("*:LockControl", "TrainBrakeControl", 0, 1)
		Call("*:SetControlValue", "Regulator", 0, 0)
		block = 1
	end

	if block == 1 and Call("*:GetControlValue", "CNV_Brelease", 0) == 1 and tspeed < lspeed then
		Call("*:SetControlValue", "TrainBrakeControl", 0, 0)
		Call("*:LockControl", "TrainBrakeControl", 0, 0)
		block = 0
	end

-- Sobrevelocidade a velocidade objectivo
	if nspeed < lspeed and fdistance - ndistance >= 0 then
		Call("*:SetControlValue", "TrainBrakeControl", 0, 0.9)
		Call("*:LockControl", "TrainBrakeControl", 0, 1)
		Call("*:SetControlValue", "Regulator", 0, 0)
		bspeed = nspeed
		slock = 1
	end

	if slock == 1 and Call("*:GetControlValue", "CNV_Brelease", 0) == 1 and tspeed < bspeed then
		Call("*:SetControlValue", "TrainBrakeControl", 0, 0)
		Call("*:LockControl", "TrainBrakeControl", 0, 0)
		slock = 0
	end
	
-- Avisos de frenagem a velocidade objectivo
	if nspeed < lspeed and wdistance - ndistance >= 0 then
		wspeed = nspeed
		twarning = 1
		sbeep = 1
	end

	if wspeed == lspeed then
		wspeed = 0
		twarning = 0
	end
	
	if sbeep == 1 then
		Call("*:SetControlValue", "CNV_Beep1", 0, 1)
		sbeep = 0
	else
		Call("*:SetControlValue", "CNV_Beep1", 0, 0)
		sbeep = 0
	end
	
	if nspeed < lspeed and rdistance - ndistance >= 0 then
		rbeep = 1
	end

	if rbeep == 1 then
		Call("*:SetControlValue", "CNV_Beep2", 0, 1)
		rbeep = 0
	else
		Call("*:SetControlValue", "CNV_Beep2", 0, 0)
		rbeep = 0
	end

-- Sobrevelocidade a paragem absoluta
	if dstate == 2 and qdistance - ddistance >= 0 then
		Call("*:SetControlValue", "TrainBrakeControl", 0, 0.9)
		Call("*:LockControl", "TrainBrakeControl", 0, 1)
		Call("*:SetControlValue", "Regulator", 0, 0)
		vlock = 1
	end

	if vlock == 1 and Call("*:GetControlValue", "CNV_Brelease", 0) == 1 and tspeed < 6.66 then
		Call("*:SetControlValue", "TrainBrakeControl", 0, 0)
		Call("*:LockControl", "TrainBrakeControl", 0, 0)
		vlock = 0
	end

-- Avisos Aproximacao sinal fechado
	if dstate == 2 and xdistance - ddistance >= 0 then
		xwarning = 1
		xflash = 1
		sbeep = 1
	else
		xwarning = 0
	end
	
	if dstate == 2 and zdistance - ddistance >= 0 then
		rbeep = 1
	end

	if xflash == 1 and dstate ~= 2 then
		xflash = 0
	end

-- Luzes
	if Call("*:GetControlValue", "Headlights", 0) == 0 then
		Call("ActivateNode", "farolfrente", 0)
		Call("Farol Frente:Activate", 0)
		Call("ActivateNode", "faroltras", 0)
		Call("Farol Tras:Activate", 0)
	elseif Call("*:GetControlValue", "Headlights", 0) == 1 then
		Call("ActivateNode", "farolfrente", 1)
		Call("Farol Frente:Activate", 1)
		Call("ActivateNode", "faroltras", 0)
		Call("Farol Tras:Activate", 0)
	elseif Call("*:GetControlValue", "Headlights", 0) == 2 then
		Call("ActivateNode", "farolfrente", 0)
		Call("Farol Frente:Activate", 0)
		Call("ActivateNode", "faroltras", 1)
		Call("Farol Tras:Activate", 1)
	end

	if Call("*:GetControlValue", "LuzCauda", 0) == 0 then
		Call("ActivateNode", "fvermelhofrente", 0)
		Call("ActivateNode", "fvermelhotras", 0)
		Call("Farolim Vermelho Esquerdo Frente:Activate", 0)
		Call("Farolim Vermelho Direito Frente:Activate", 0)
		Call("Farolim Vermelho Esquerdo Tras:Activate", 0)
		Call("Farolim Vermelho Direito Tras:Activate", 0)
	elseif Call("*:GetControlValue", "LuzCauda", 0) == 1 then
		Call("ActivateNode", "fvermelhofrente", 1)
		Call("ActivateNode", "fvermelhotras", 0)
		Call("Farolim Vermelho Esquerdo Frente:Activate", 1)
		Call("Farolim Vermelho Direito Frente:Activate", 1)
		Call("Farolim Vermelho Esquerdo Tras:Activate", 0)
		Call("Farolim Vermelho Direito Tras:Activate", 0)
	elseif Call("*:GetControlValue", "LuzCauda", 0) == 2 then
		Call("ActivateNode", "fvermelhofrente", 0)
		Call("ActivateNode", "fvermelhotras", 1)
		Call("Farolim Vermelho Esquerdo Frente:Activate", 0)
		Call("Farolim Vermelho Direito Frente:Activate", 0)
		Call("Farolim Vermelho Esquerdo Tras:Activate", 1)
		Call("Farolim Vermelho Direito Tras:Activate", 1)
	end

	if Call("*:GetControlValue", "CabLight", 0) == 0 then
		Call("CabLight:Activate", 0)
	else
		Call("CabLight:Activate", 1)
	end

-- Get rpm values for this vehicle.
rpm = Call( "*:GetControlValue", "RPM", 0 )
rpm_change = Call( "*:GetControlValue", "RPMDelta", 0 )
amps = Call("*:GetControlValue", "Ammeter", 0)

--compute control values as ratio to max
gCurRPM = (rpm - IDLERPM) / (FULLRPM - IDLERPM);
gCurAmps = amps / MAXAMPS;

exhaustrate = RATE - RATE * ((( gCurRPM * RPMCF ) + (( gCurAmps ) * AMPCF )))
exh_col = (( MAXAMPS - amps ) / MAXAMPS ) * COL
	Call( "Exhaust:SetEmitterRate", exhaustrate )
	Call( "Exhaust:SetEmitterColour", exh_col, exh_col, exh_col*BLNSS )

end