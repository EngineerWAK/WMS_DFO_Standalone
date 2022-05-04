/**
* WMS_DFO_functions.sqf - InfantryProgram
*
* TNA-Community
* https://discord.gg/Zs23URtjwF
* © 2022 {|||TNA|||}WAKeupneo
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
* Do Not Re-Upload
*/
/*
	The DFO idea from Iceman/Project Hatchet Discord (https://discord.gg/YsRWVPvNeF) 
	was pretty close to mine when I built the module WMS_Event_ReconMission last year, which is running very basic and will probably stay this way.
	So there is the the "Chopper only" version, player (pilots?) activated and "repeatable".
	Standalone version will come after, when everything will be running fine.
	1-Build the skeleton to fit in the existing WMS_InfantryProgram framework
	2-Create a basic empty mission (probably "cargotransport") to test the call/spawn/triggers/succes/fail/cleanup
	3-Build and test each mission one by one
	4-Export a Standalone version
*/
/*
//from WMS_initSystem (WMS_DynamicFlightOps) or initServer (true)
// Start DynamicFlightOps
if (true)then {execVM "\DFO\WMS_DFO_functions.sqf"};
*/
WAK_DFO_Version			= "v0.28_2022MAY04_GitHub";
WMS_DynamicFlightOps	= true; //NOT 100% READY YET, 99%
WMS_fnc_DFO_LOGs		= true;	//For Debug
WMS_DFO_Standalone		= true; //keep true if you don't use WMS_InfantryProgram
WMS_DFO_CreateChopper	= true; //if your mission file doesn't have choppers available
WMS_DFO_Reinforcement	= true; //Each mission has it's own type of reinforcement
WMS_DFO_UseJVMF			= true; //https://github.com/Project-Hatchet/H-60
WMS_DFO_RemoveDup		= true; //delete dead NPC's primary weapon and backpack
WMS_DFO_UsePilotsList 	= true; //if you want to limit DFO use to some players
WMS_fnc_DFO_SmokeAtLZ	= true; //pop a smoke on the group you have to pickUp
WMS_DFO_CancelOnKIA		= false; //NOT READY YET //should Fail the mission when _pilot die, it's a bit hardcore especialy with AA vehicles
WMS_DFO_PilotsList		= ["76561197965501020"]; //Only those players will be able to use DFO if WMS_DFO_UsePilotsList
WMS_DFO_MaxRunning		= 1;
WMS_DFO_CoolDown		= 300;
WMS_DFO_Timer			= 1800; //timer before mission timeOut, no reset/extend
WMS_DFO_MinMaxDist		= [3000,6000];
WMS_DFO_ReinfTriggDist	= 1000; //distance trigger will call reinforcement
WMS_DFO_MkrRandomDist	= 500; //random distance to place the marker from SAR CSAR missions otherwise there is no "search"
WMS_DFO_Reward			= [500,2000,['ACE_Can_Franta','ACE_Can_RedGull','ACE_MRE_LambCurry','ACE_MRE_MeatballsPasta','ACE_bloodIV_500','ACE_morphine','ACE_quikclot']]; //["rep","money",items for chopper return]
WMS_DFO_OPFORcbtMod		= "YELLOW"; //Vehicle crew only //"WHITE" : Hold fire, engage at will/loose formation //"YELLOW" : Fire at will, keep formation //"RED" : Fire at will, engage at will/loose formation
WMS_DFO_CargoType		= ["CargoNet_01_barrels_F","C_IDAP_CargoNet_01_supplies_F","CargoNet_01_box_F"];
WMS_DFO_MissionTypes	= ["inftransport","cargotransport","airassault","casinf","casarmored","cascombined","sar","csar"];// Troop transport, Cargo transport, Air Assault, CAS (Infantry, Armoured, combined), SAR, CSAR

//VANILLA:
WMS_DFO_Choppers		= [["B_Heli_Attack_01_F","B_Heli_Light_01_armed_F"],["B_Heli_Transport_01_F"],["B_Heli_Transport_03_unarmed_green_F","I_Heli_light_03_unarmed_F"],["C_IDAP_Heli_Transport_02_F"]]; //[["pylons","pylons"],["doorGunners","doorGunners"],["transport","transport"],["medevac","medevac"]];
WMS_DFO_NPCvehicles		= [//[[AIR_HEAVY],[AIR_LIGHT],[AIR_UNARMED],[HEAVY],[APC],[LIGHT],[UNARMED],[CIV],[STATICS],["BOATS"]]
						["O_Heli_Attack_02_dynamicLoadout_F"],
						["O_Heli_Light_02_dynamicLoadout_F"],
						["O_Heli_Transport_04_covered_F"],
						["O_APC_Tracked_02_AA_F","O_MBT_02_cannon_F"],//AA first
						["O_APC_Tracked_02_cannon_F","O_APC_Wheeled_02_rcws_v2_F"],//"AA" first
						["O_MRAP_02_hmg_F","O_LSV_02_armed_F","O_G_Offroad_01_armed_F"],
						["O_Truck_02_medical_F","O_Truck_02_Ammo_F"],
						["C_Hatchback_01_F","C_Offroad_02_unarmed_F","C_Van_02_medevac_F","C_Truck_02_transport_F"],
						["O_static_AA_F","O_Mortar_01_F","O_GMG_01_high_F","O_HMG_01_high_F"],//AA first
						["O_T_Boat_Armed_01_hmg_F"]];
WMS_DFO_NPCs			= [ //[[OPFOR],[CIV_SOLDIER],[CIV]] //mainly for standalone version
						["O_crew_F","O_Soldier_GL_F","O_soldier_M_F","O_Soldier_AR_F"], //"O_Soldier_AA_F", no AA for now, it's pain in the ass for debugging //crew first //AA second
						["B_helicrew_F","B_soldier_AR_F","B_Soldier_GL_F","B_soldier_M_F","B_Soldier_F"], //crew first //in arma civillian can not have weapon...
						["C_Man_Paramedic_01_F","C_Man_UtilityWorker_01_F","C_journalist_F","C_Man_Fisherman_01_F","C_man_polo_1_F","C_Man_casual_1_F_afro_sick"]];
/*
//RHS/HATCHET
WMS_DFO_Choppers		= [["vtx_MH60M_DAP","vtx_MH60S_Pylons"],["vtx_HH60","vtx_MH60S_GAU21L","vtx_MH60M","vtx_MH60S","vtx_UH60M"],["B_Heli_Transport_03_unarmed_F","vtx_UH60M_SLICK"],["vtx_UH60M_MEDEVAC"]];//Hatchet
WMS_DFO_NPCvehicles		= [//[[AIR_HEAVY],[AIR_LIGHT],[AIR_UNARMED],[HEAVY],[APC],[LIGHT],[UNARMED],[CIV],[STATICS],["BOATS"]]
						["RHS_Ka52_vvsc","RHS_Mi24V_vvsc","RHS_Mi8MTV3_vvsc"],
						["RHS_Mi24Vt_vvsc","RHS_Mi8mt_vvsc"],
						["rhs_ka60_c","RHS_Mi8T_vvsc"],
						["rhsgref_ins_zsu234","rhsgref_ins_t72bb","rhsgref_ins_bmp2e","rhsgref_ins_2s1_at","rhs_t80ue1"],//AA first
						["rhsgref_ins_ural_Zu23","rhsgref_ins_btr70","rhsgref_ins_btr60","rhsgref_BRDM2_ins","rhs_btr80a_msv"],//"AA" first
						["rhsgref_ins_uaz_dshkm","rhsgref_ins_uaz_spg9","O_LSV_02_armed_F","O_G_Offroad_01_armed_F","rhs_tigr_sts_3camo_vmf"],
						["rhsgref_ins_uaz_open","rhsgref_ins_gaz66","rhsgref_ins_ural","rhsgref_ins_zil131_open","rhs_tigr_m_3camo_vmf"],
						["C_Hatchback_01_F","C_Offroad_02_unarmed_F","C_Van_02_medevac_F","C_Truck_02_transport_F"],
						["rhsgref_ins_ZU23","rhsgref_ins_Igla_AA_pod","rhsgref_ins_DSHKM","rhs_KORD_high_VDV"],//AA first
						["O_T_Boat_Armed_01_hmg_F"]];
WMS_DFO_NPCs			= [ //[[OPFOR],[CIV_SOLDIER],[CIV]] //mainly for standalone version
						["rhs_vdv_combatcrew","rhs_vdv_mflora_at","rhs_vdv_mflora_aa","rhs_vdv_medic","rhs_mvd_izlom_arifleman_rpk","rhs_mvd_izlom_machinegunner","rhs_vdv_efreitor","rhs_vdv_rifleman","rhs_vdv_grenadier"], //"O_Soldier_AA_F", no AA for now, it's pain in the ass for debugging //crew first //AA second
						["B_W_Helicrew_F","rhsusf_socom_swcc_crewman","rhsusf_socom_marsoc_cso_grenadier","rhsusf_socom_marsoc_marksman","rhsusf_socom_marsoc_sarc","rhsusf_socom_marsoc_jtac","rhsusf_usmc_marpat_wd_stinger","B_T_ghillie_tna_F","rhsusf_usmc_lar_marpat_wd_machinegunner","rhsusf_usmc_marpat_wd_autorifleman_m249","B_soldier_LAT2_F"], //crew first //in arma civillian can not have weapon...
						["C_Man_Paramedic_01_F","C_Man_UtilityWorker_01_F","C_journalist_F","C_Man_Fisherman_01_F","C_man_polo_1_F","C_Man_casual_1_F_afro_sick"]];
*/
WMS_DFO_Markers			= ["loc_heli","mil_end_noShadow"]; //["mission","RTB"]; //["n_support","n_hq"]; //["loc_heli","mil_end_noShadow"]
WMS_DFO_MkrColors		= ["colorOrange","colorGreen","colorRed"]; //["mission","RTB", "bigDanger"];
WMS_DFO_MissionPaths	= [["BASE","LZ1","BASE"],["BASE","LZ1","LZ2"]]; // "takeoff/mission/complet" //the first "BASE" could become "AIR" if mission called during flight
WMS_DFO_LastCall		= (time-WMS_DFO_CoolDown);
WMS_DFO_Running			= []; //KEEP EMPTY
WMS_DFO_RunReinforce	= []; //KEEP EMPTY

WMS_DFO_AceIsRunning 	= false; //this should go in WMS_InfantryProgram

publicVariable "WMS_DFO_Running";
publicVariable "WMS_DFO_MaxRunning";
publicVariable "WMS_DFO_LastCall";
publicVariable "WMS_DFO_CoolDown";
publicVariable "WMS_DFO_UsePilotsList";
publicVariable "WMS_DFO_PilotsList";
publicVariable "WMS_DFO_AceIsRunning";

//STANDALONE MISSING VAR:
if (WMS_DFO_Standalone) then {
	WMS_exileFireAndForget = false;
	WMS_AMS_MaxGrad 	= 0.15;
	WMS_exileToastMsg 	= false; //Exile Mod Notifications
	WMS_Pos_Locals 		= []; //AutoScan
	WMS_Pos_Villages	= []; //AutoScan
	WMS_Pos_Cities 		= []; //AutoScan
	WMS_Pos_Capitals 	= []; //AutoScan
	WMS_Pos_Forests 	= []; //DIY, if no position, back to random _pos
	WMS_Pos_Military 	= []; //DIY, if no position, back to random _pos
	WMS_Pos_Factory 	= []; //DIY, if no position, back to random _pos
	WMS_Pos_Custom	 	= []; //DIY, if no position, back to random _pos //Should be used for strict position (ASLW?) like ship deck, roof ("airassault"?)
};

////////////////////////////
//FUNCTIONS:
////////////////////////////
//if local, keep this here, if multi/dedi move WMS_fnc_DFO_killStats to MPMission\Mission.map\init.sqf to remoteExec on the client(s)
WMS_fnc_DFO_killStats = { //LOCAL ON CLIENT, SERVER->remoteExec->CLIENT
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_killStats _this %1', _this]};
	params[
		["_messages", [["ERROR",00]]]
		]; 
	private _payload = "<t align='left' size='1.2'>";
	{ 
		_payload = _payload + format ["<t color='#e57234' font='EtelkaMonospacePro'>%1</t><br/>", (_x select 0)]; //orange
	}forEach _messages; 
	_payload = _payload + "</t>";
	if("CIV" in _payload)then{
		_payload = _payload + "<t align='left' color='#d60000' font='EtelkaMonospacePro' size='1.4'>FRIENDLY FIRE</t>"; //red
	};
	[ 
		parseText _payload,  
		true,  //the display can be moved anywhere on the screen options/game/layout/mission/Scenario specific texts
		nil,  
		5,
		[0.2,1.5],
		0  
	]spawn BIS_fnc_textTiles;
};
////////////////////////////
WMS_DFO_CollectPos = {
	private _worldCenter 	= [worldsize/2,worldsize/2,0]; 
	private _worldDiameter 	= ((worldsize/2)*1.413);
	if (WMS_fnc_DFO_LOGs) then {Diag_log '|WAK|TNA|WMS|[DFO] collecting LOCALS positions'};
	{WMS_Pos_Locals pushback position _x}forEach (nearestLocations [_worldCenter, ["nameLocal"],_worldDiameter]);
	if (WMS_fnc_DFO_LOGs) then {Diag_log '|WAK|TNA|WMS|[DFO] collecting VILLAGES positions'};
	{WMS_Pos_Villages pushback position _x}forEach (nearestLocations [_worldCenter, ["nameVillage"],_worldDiameter]);
	if (WMS_fnc_DFO_LOGs) then {Diag_log '|WAK|TNA|WMS|[DFO] collecting CITIES positions'};
	{WMS_Pos_Cities pushback position _x}forEach (nearestLocations [_worldCenter, ["nameCity"],_worldDiameter]);
	if (WMS_fnc_DFO_LOGs) then {Diag_log '|WAK|TNA|WMS|[DFO] collecting CAPITALS positions'};
	{WMS_Pos_Capitals pushback position _x}forEach (nearestLocations [_worldCenter, ["nameCityCapital"],_worldDiameter]);
};
WMS_fnc_DFO_ConvertTypeToCoord = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_ConvertTypeToCoord _this %1', _this]};
	params [
		["_pos",[worldSize/2,worldSize/2]],
		["_posType","random"],
		["_radiusObjects",10],
		["_MaxGrad",WMS_AMS_MaxGrad],
		["_options",[]]

	];
	private _blackList = [];
	private _return = [];
	if (WMS_DFO_Standalone) then {
		_blackList = allPlayers select {alive _x} apply {[position _x, 900]};
	}else {
		_blackList = [] call WMS_fnc_AMS_SpnAiBlkListFull;
	};
	if (_posType == "random") then {
		_return = [_pos, (WMS_DFO_MinMaxDist select 0), (WMS_DFO_MinMaxDist select 1), _radiusObjects, 0, _MaxGrad, 0, _blackList, [([] call BIS_fnc_randomPos),[]]] call BIS_fnc_findSafePos;
	} else {
		if(_posType == "forest" && {count WMS_Pos_Forests != 0})then{
			_return = selectRandom WMS_Pos_Forests;
			_return = [_return, 0, 50, 1, 0, 0, 0, [], [_return,[]]] call BIS_fnc_findSafePos;
		}else{
			if(_posType == "city" && {count (WMS_Pos_Villages+WMS_Pos_Cities+WMS_Pos_Capitals) != 0})then{
				_return = selectRandom (WMS_Pos_Villages+WMS_Pos_Cities+WMS_Pos_Capitals);
				_return = [_return, 0, 50, 5, 0, 0, 0, [], [_return,[]]] call BIS_fnc_findSafePos;
			}else{
				if(_posType == "local" && {count WMS_Pos_Locals != 0})then{
					_return = selectRandom WMS_Pos_Locals;
					_return = [_return, 0, 50, 5, 0, 0, 0, [], [_return,[]]] call BIS_fnc_findSafePos;
				}else{
					if(_posType == "military" && {count WMS_Pos_Military != 0})then{
						_return = selectRandom WMS_Pos_Military;
						_return = [_return, 0, 50, 5, 0, 0, 0, [], [_return,[]]] call BIS_fnc_findSafePos;
					}else{
						if(_posType == "sea")then{
							//use random but 2 "must be on water"
							_return = [_pos, (WMS_DFO_MinMaxDist select 0), (WMS_DFO_MinMaxDist select 1), 5, 2, 0.5, 0, _blackList, [([] call BIS_fnc_randomPos),[]]] call BIS_fnc_findSafePos;
						}else{
							if(_posType == "custom")then{
								_return = selectRandom WMS_Pos_Custom; //ASLW
							}else{
								//back to "random"
								_return = [_pos, (WMS_DFO_MinMaxDist select 0), (WMS_DFO_MinMaxDist select 1), _radiusObjects, 0, _MaxGrad, 0, _blackList, [([] call BIS_fnc_randomPos),[]]] call BIS_fnc_findSafePos;
							};
						};
					};
				};
			};
		};
	};
	//player check here, if player fallback to "random"

	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_ConvertTypeToCoord _return %1', _return]};
	_return
};
WMS_fnc_DFO_createBaseAction = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_createBaseAction _this %1', _this]};
	
	WMS_DFO_BasePositions = missionNameSpace getVariable ["WMS_DFO_BasePositions", []];
	WMS_DFO_ObjToAddAction = missionNameSpace getVariable ["WMS_DFO_ObjToAddAction", []];
	
	//private _ObjToAddAction = missionNameSpace getVariable ["WMS_DFO_ObjToAddAction", []]; //objects from mission.sqm will push themself there
	//Standalone will need to create an object to add the action where to call a mission
	if (count WMS_DFO_ObjToAddAction == 0) then { 
		//bad Idea but why not. The object should be placed in the mission editor or anytime before calling this function
		/* 
		//Init:
		private _ObjToAddAction = missionNameSpace getVariable ["WMS_DFO_ObjToAddAction", []];
		_ObjToAddAction pushBack _this;
		missionNameSpace setVariable ["WMS_DFO_ObjToAddAction",_ObjToAddAction];
		*/
		//no object to call the mission from, create the Object/Unit at a random position
		private _defaultPos = [[worldSize,worldSize,0], 0, worldSize, 22, 0, 0.10, 0, [], [([] call BIS_fnc_randomPos),[]]] call BIS_fnc_findSafePos;
		[_defaultPos,"FULL"] call WMS_fnc_DFO_BuildBase;
		_mkrName = format ["DFO_mkrBase_%1",time];
		_MkrLZ = createMarker [_mkrName, _defaultPos];
		_MkrLZ setMarkerType "b_hq";
		_MkrLZ setMarkerText "DFO";
	};
	{
		[_x]call WMS_fnc_DFO_addAction;
	}forEach WMS_DFO_ObjToAddAction;
	
	{if ("Advanced Combat Environment" in (_x select 0))then {WMS_DFO_AceIsRunning = true;}}forEach getLoadedModsInfo;

	if(WMS_DFO_UseJVMF) then {
		private _payload = "";
		private _payload2 = "";
		private _BasePositions = [];
		private _MissionTypes = "";
		//["inftransport","cargotransport","airassault","casinf","casarmored","cascombined","sar","csar"]
		if("inftransport" in WMS_DFO_MissionTypes || "cargotransport" in WMS_DFO_MissionTypes) then {_MissionTypes = _MissionTypes +"Transport, "};
		if("airassault" in WMS_DFO_MissionTypes) then {_MissionTypes = _MissionTypes +"Air Assault, "};
		if("casinf" in WMS_DFO_MissionTypes || "casarmored" in WMS_DFO_MissionTypes || "cascombined" in WMS_DFO_MissionTypes) then {_MissionTypes = _MissionTypes +"CAS, "};
		if("sar" in WMS_DFO_MissionTypes || "csar" in WMS_DFO_MissionTypes) then {_MissionTypes = _MissionTypes +"Search & Rescue"};
		if ((count WMS_DFO_BasePositions) == 0)then{
			_payload = "No DFO Bases positions registered yet";
			_payload2 = "DFO Bases are usualy around AirField (Traders)";
		}else{
			if (count WMS_DFO_BasePositions > 2) then { //JVMF 50 characteres limit per ligne
				_BasePositions = [WMS_DFO_BasePositions select 0, WMS_DFO_BasePositions select 1];
			}else {
				_BasePositions = WMS_DFO_BasePositions;
			};
			_payload = "DFO Bases Known positions (first two):";
			_payload2 = format ["%1",_BasePositions];
		};
		[
      		"WELCOME", // TITLE
       		"DFO HQ", // SENDER
       		"ALL", // RECIPIENTS
      		0, //MSG TYPE
      		[
          		"Dynamic Flight Ops is now Activated",
           		"Go to DFO base(s) to request a mission",
				_payload,
           		_payload2,
           		"Available Missions:",
           		_MissionTypes,
				"",
				"",
				"",
				""
       		], //MSG TEXT //MUST BE AT LEAST 10 LINES
       		[_BasePositions select 0], // MSG DATA //[]
       		[
            	[
                	format ["%1:%2",(date select 3),(date select 4)],
                	"DFO HQ",
                	"SENT"
            	]
        	] // REPLIES
   		] call WMS_fnc_DFO_JVMF;
	};
	publicVariable "WMS_DFO_ObjToAddAction";
	publicVariable "WMS_DFO_BasePositions";
	publicVariable "WMS_DFO_AceIsRunning";

	if (WMS_DFO_Standalone) then {
		[]call WMS_DFO_CollectPos;
		//Cleanup loop
		while {true} do {
			{
				if (((_x select 7) == "DFO")) then { //if it's not "DFO", it's really fuckedUp
					_x call WMS_fnc_DFO_Cleanup;
				};
			}forEach WMS_DFO_Running;
			{
				if ((_x select 7) == "REINF" && {time > (_x select 1)}) then { //do not call the reinforcement cleanup if time has not come
				//if ((_x select 7) == "REINF") then {
					_x call WMS_fnc_DFO_RinforceCleanup; //["HexaID", time to delete, [_grps], [_vhls], [_objects],"","","REINF"]
				};
			}forEach WMS_DFO_RunReinforce;
			uisleep 60;
		};
	};
};
WMS_fnc_DFO_BuildBase = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_BuildBase _this %1', _this]};
	params [
		"_pos",
		["_option", "HELIPAD"] //"FULL","HELIPAD"
	];
	_BaseObjects = []; //PUSHBACK
	[];
	_DFO_BaseObjects = [
		["Sign_Arrow_Large_Green_F",[-12.5,0,0],0],
		["Sign_Arrow_Large_Green_F",[0,-12.5,0],0],
		["Sign_Arrow_Large_Green_F",[12.5,0,0],0],
		["Sign_Arrow_Large_Green_F",[0,12.5,0],0],
		["Sign_Arrow_Large_Green_F",[8.8,8.8,0],45],
		["Sign_Arrow_Large_Green_F",[-8.9,8.8,0],45],
		["Sign_Arrow_Large_Green_F",[-8.8,-8.9,0],45],
		["Sign_Arrow_Large_Green_F",[8.8,-8.8,0],45]
	];
	if (_option == "FULL" || _option == "HELIPAD" ) then {
		_DFO_BaseObjects = _DFO_BaseObjects + [["Land_HelipadCircle_F",[0,0,0],0]];
	};
	if (_option == "FULL") then {
		//add The screen to call the action
		_DFO_BaseObjects = _DFO_BaseObjects + [
			["Land_TripodScreen_01_large_F",[-14.1,5.1,0],110],
			["CamoNet_INDP_open_F",[16.1,-15.3,0],128.4],
			["Campfire_burning_F",[-16.3,19,0],0],
			["Land_Cargo_House_V1_F",[-11.1,18.8,0],332.3],
			["Land_Cargo_Patrol_V1_F",[-18.9,7.5,0],108.6],
			["Land_Cargo_Patrol_V1_F",[19.5,-6.7,0],286.6],
			["Land_HBarrier_3_F",[22.5,-13.8,0],268.1],
			["Land_HBarrier_3_F",[21.1,-16.5,0],320.4],
			["Land_HBarrier_5_F",[6.7,-24.9,0],61.2],
			["Land_HBarrier_5_F",[4.2,-20.3,0],61.2],
			["Land_HBarrier_5_F",[10.8,-24.9,0],331.6],
			["Land_HBarrier_Big_F",[0,-17,0],0],
			["Land_HBarrier_Big_F",[-21,3.2,0],19.3],
			["Land_HBarrier_Big_F",[-7.9,-15.1,0],27.8],
			["Land_HBarrier_Big_F",[-14,-9.7,0],55.4],
			["Land_HBarrier_Big_F",[-16.9,-2.1,0],82.8],
			["Land_HBarrier_Big_F",[-22.6,8.8,0],110.6],
			["Land_HBarrier_Big_F",[-15.9,6,0],110.6],
			["Land_HBarrier_Big_F",[-19.1,19.8,0],138.8],
			["Land_HBarrier_Big_F",[-12.4,24.6,0],152.5],
			["Land_HBarrier_Big_F",[-7.8,15.1,0],152.5],
			["Land_HBarrier_Big_F",[0,17,0],180],
			["Land_HBarrier_Big_F",[21.3,-3.1,0],201.9],
			["Land_HBarrier_Big_F",[7.9,15,0],207.8],
			["Land_HBarrier_Big_F",[13.7,10,0],233.8],
			["Land_HBarrier_Big_F",[-7.2,21.6,0],245.1],
			["Land_HBarrier_Big_F",[16.8,2.6,0],261.2],
			["Land_HBarrier_Big_F",[23.3,-8.1,0],289],
			["Land_HBarrier_Big_F",[16.1,-5.5,0],289],
			["Land_HBarrier_Big_F",[7.8,-15.1,0],332.5],
			["Land_LampShabby_F",[11.1,-13.1,2.17],47.7],
			["Land_Medevac_house_V1_F",[10.3,-19.4,0],240.9],
			["Land_SignM_WarningMilitaryArea_english_F",[-23.3,11.1,0],107]
		];
	};
	
	private _compoRefPoint = createVehicle ["VR_Area_01_circle_4_yellow_F", _pos, [], 0, "CAN_COLLIDE"];
	private _dirCompo = (Random 359);
	_compoRefPoint setDir _dirCompo;
	{
		_object = createVehicle [(_x select 0), [0,0,4000], [], 0, "CAN_COLLIDE"];
		_object setdir _dirCompo + (_x select 2);
		_objectVectoriel = (_compoRefPoint modeltoworld  [(_x select 1 select 0),(_x select 1 select 1),0]);
		_object setposATL [(_objectVectoriel select 0),(_objectVectoriel select 1),((_x select 1) select 2)];
		_gradient = surfaceNormal position _object;
		_object setvectorup _gradient;
		_object allowDamage false;
		_object enableSimulationGlobal true;
		if ((_x select 0) == "Land_HelipadCircle_F") then {
			_object setVariable ["WMS_DFO_BaseHelipad",true];
			WMS_DFO_BasePositions pushBack (position _object);
			/*
			if(isServer)then{
				private _BasePositions = missionNameSpace getVariable ["WMS_DFO_BasePositions", []];
				_BasePositions pushBack (position this);
				missionNameSpace setVariable ["WMS_DFO_BasePositions",_BasePositions];
			};*/
		};
		_BaseObjects pushBack _object;
		if ((_x select 0) == "Land_TripodScreen_01_large_F")then{
			[_object]call WMS_fnc_DFO_addAction;
			WMS_DFO_ObjToAddAction pushBack _object;
		};
	}forEach _DFO_BaseObjects;
	if !(_option == "NOTRIGGER") then {
		private _triggMission = createTrigger ["EmptyDetector", _pos, true];  
		_triggMission setTriggerActivation ["ANYPLAYER", "PRESENT", true];
		_triggMission setTriggerArea [12.5, 12.5, 0, false];
		_triggMission setTriggerStatements  
		[ 
  			"this && ({ (getPosATL _x) select 2 <= 10 } count thislist) > 0",  
  			"	
	  			'Dynamic Flight Ops, Do not Park here' remoteExec ['hint', (owner (thisList select 0))]; 
	  			'Dynamic Flight Ops, Do not Park here' remoteExec ['systemChat', (owner (thisList select 0))]; 
			",  
  			"
	  			'Dynamic Flight Ops, Thank you for your visit' remoteExec ['hint', (owner (thisList select 0))]; 
	  			'Dynamic Flight Ops, Thank you for your visit' remoteExec ['systemChat', (owner (thisList select 0))]; 
			" 
		];
	};
	publicVariable "WMS_DFO_ObjToAddAction";
	publicVariable "WMS_DFO_BasePositions";
	deleteVehicle _compoRefPoint;
	_BaseObjects
};
WMS_fnc_DFO_addAction = { //can be called afterwards to add DFO action(s) to a new object
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_addAction _this %1', _this]};
	private ["_pos"];
	params ["_objectToActivate"];
	[ //params ["_target", "_caller", "_actionId", "_arguments"]; //condition: _target = object, _this = caller
		_objectToActivate,
		[
			"<t size='0.9' color='#80c606'>Request Air Operation</t>",//_display,
			"	
				_target = _this select 0; _caller = _this select 1;
				if (WMS_DFO_UsePilotsList)then{
					if((getPlayerUID _caller) in WMS_DFO_PilotsList)then{
						[_caller,_target] remoteExec ['WMS_fnc_Event_DFO', 2];
						hint 'Contacting Air Operations HQ';
					}else{
						hint 'DFO only for selected pilots, contact admins';
					};
				}else{
					[_caller,_target] remoteExec ['WMS_fnc_Event_DFO', 2];
					hint 'Contacting Air Operations HQ';
				};
			",
			[], //argument accessible in the script (_this select 3)
			1,
			true,
			true,
			"",
			"
			(alive _target) &&
			{(vehicle _this == _this)} &&
			{(count WMS_DFO_Running) <= WMS_DFO_MaxRunning} &&
			{time > (WMS_DFO_LastCall+WMS_DFO_CoolDown)};
			",
			5
		]
	] remoteExec [
		"addAction",
		0,
		true //jip
	];
};
WMS_fnc_DFO_CreateVhls = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_CreateVhls _this %1', _this]};
	params ["_MissionHexaID","_playerObject","_faction","_pos","_OPFORvhlCnt","_OPFORvhlType","_mission","_MissionFinish"];
		private _vhls = []; //pushback, return
		private _grps = []; //pushback, return
		private _OPFvehicles = []; //pushback
		private _infType = "OPFOR";
		private _crewCount = 3;
		//define what type of vehicle, depending what type of mission
		if (surfaceIsWater _pos) then {_OPFORvhlType = [9]};
		private _veh = objNull;
		for "_i" from 1 to _OPFORvhlCnt do {
			private _vhlType = selectRandom _OPFORvhlType; //number from an array
			private _vhlCN = selectRandom (WMS_DFO_NPCvehicles select _vhlType); ///classname from array in an array
			if (_mission == "airassault") then {
				_veh = createVehicle [_vhlCN, _MissionFinish, [], 75, "NONE"];
			}else{
				_veh = createVehicle [_vhlCN, _pos, [], 75, "NONE"];
			};
			_veh setDir (random 359);
			_OPFvehicles pushback _veh;
			_vhls pushback _veh;
			_veh setVehiclelock "LOCKEDPLAYER";
			clearMagazineCargoGlobal _veh; 
			clearWeaponCargoGlobal _veh; 
			clearItemCargoGlobal _veh; 
			clearBackpackCargoGlobal _veh;
		};
		//vehicle crew
		if (_faction != EAST) then {_infType = "CIV_ARMED"};
		{	
			private _OPFORinfGrp = createGroup [_faction, false];
			if (_x iskindof "helicopter") then {_crewCount = 2};
			for "_i" from 1 to _crewCount do { //GROUND = 3 AIR = 2
				(WMS_DFO_NPCs select 0 select 0) createUnit [(position _x), _OPFORinfGrp]; //yes, vehicle crew are flying helicopters, what a shame
			};
			_OPFORinfGrp addvehicle _x;
			(units _OPFORinfGrp) orderGetIn true;
			_grps pushback _OPFORinfGrp; //need a check on this one
			if (_mission == "airassault") then {
				[_OPFORinfGrp] call CBA_fnc_taskDefend;
				{
					_x setVariable ["lambs_danger_disableAI", true];//deactivate LambsDanger
				}forEach units _OPFORinfGrp;
				_OPFORinfGrp setVariable ["lambs_danger_disableGroupAI", true];//deactivate LambsDanger
			}else{
				[_OPFORinfGrp, _pos, 300, 4, "MOVE", "AWARE", WMS_DFO_OPFORcbtMod, "LIMITED", "COLUMN", "", [2,4,6]] call CBA_fnc_taskPatrol;
			};
			[(units _OPFORinfGrp),[_MissionHexaID,_playerObject,_mission,_infType]] call WMS_fnc_DFO_SetUnits;
		}forEach _OPFvehicles;
	[_vhls,_grps,_faction] //[[],[],side]
};
WMS_fnc_Event_DFO	= { //The one called by the addAction, filtered by WMS_DFO_MaxRunning and probably diag_fps
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_Event_DFO _this %1', _this]};
	private [
		"_createChopper","_DFO_status","_DFO_BaseHelipads","_helipadList","_grps","_vhls","_objs","_mkrs","_pos","_radiusObjects","_MaxGrad","_posTypes","_createCIVinf","_createOPFORinf","_createCIVvhl","_createOPFORvhl","_MissionHexaID","_timeToDelete",
		"_smokePickUp","_selectedChoppers","_crewCount","_OPFORvhlCnt","_OPFORvhlType","_CIVinfGrp","_CIVinfGrp2","_cargoObject","_missionName","_updatedTimer","_MissionPath","_MissionPathCoord","_posBase","_posLZ1","_posLZ2","_reinforce","_blackList","_mkrList","_triggList"
		];
	params [
		"_playerObject", //event manager won't spawn a mission but acrivate the menu for player to call a mission
		"_DFO_Object", //the object where the mission is called from
		["_mission", (selectRandom WMS_DFO_MissionTypes)]
	];
	if ((count WMS_DFO_Running) > WMS_DFO_MaxRunning) exitWith {['Too many Flight Ops already running'] remoteExec ['SystemChat',(owner _playerObject)]}; //need some Diag_log too
	_radiusObjects 	= 5;
	_MaxGrad 		= WMS_AMS_MaxGrad;
	_MissionPath 	= selectRandom WMS_DFO_MissionPaths;
	_MissionStart 	= "BASE";  //Dynamic //define where is the pickup/infantry spawn //["AIR","BASE","LZ1"] //AIR will come later, JVMF or ACE function from pilot sit
	_MissionFinish 	= "LZ1"; //Dynamic //where to bring them
	_posTypes 		= ["random"]; //"random","forest","city","local","military","sea"
	_civType 		= "unarmed"; //Dynamic //"armed"
	_missionName 	= "DFO Mission"; //Dynamic 
	_cargoObject 	= objNull;
	_CIVinfGrp 		= objNull;
	_CIVinfGrp2 	= objNull; //"airassault"
	_OPFORinfGrp 	= objNull;
	_OPFORvhlType 	= [4]; //Dynamic //[["AIR_HEAVY"],["AIR_LIGHT"],["AIR_UNARMED"],["HEAVY"],["APC"],["LIGHT"],["UNARMED"],["CIV"],["STATICS"],["BOATS"]]
	_OPFORvhlCnt 	= 1;
	_crewCount 		= 3;
	_reinforce 		= WMS_DFO_Reinforcement;
	_createCIVinf 	= false; //soldiers will be civilian as well for now, they are neutral
	_createOPFORinf = false;
	_createCIVvhl 	= false; //not used for now
	_createOPFORvhl = false;
	_createCargo 	= false;
	_smokePickUp	= false;
	_updatedTimer 	= WMS_DFO_Timer;
	_timeToDelete 	= (time+_updatedTimer);
	_selectedChoppers = selectRandom WMS_DFO_Choppers;
	_createChopper = WMS_DFO_CreateChopper;

	_grps = [[],[]]; //pushback [[OPFOR],[CIV]]
	_vhls = [[],[]]; //pushback [[OPFOR],[CIV]]
	_objs = []; //pushback
	_mkrs = []; //pushback
	_MissionPathCoord 	= []; //pushback
	_blackList 			= []; //KEEP EMPTY
	_loadoutsCIV 		= []; //KEEP EMPTY

	_pos  		= position _DFO_Object;  //default
	_posBase 	= [worldsize/2,worldsize/2,0]; //default middle of the map
	_posLZ1  	= [0,worldsize,0]; //default
	_posLZ2  	= [worldsize,0,0]; //default
	_infType 	= "CIV"; //default //"OPFOR","CIV_ARMED","CIV"
	//if the pilote is already in a chopper, no need to spawn one (call mission from chopper)
	if(vehicle _playerObject != _playerObject) then {_createChopper = false;};
	//look around if there is already a "BASE" position //"Land_HelipadSquare_F","Land_HelipadRescue_F","Land_HelipadEmpty_F","Land_HelipadCivil_F","Land_HelipadCircle_F"
	_helipadList =  nearestObjects [_pos, ["Land_HelipadSquare_F","Land_HelipadRescue_F","Land_HelipadCivil_F","Land_HelipadCircle_F"], 150];
	_DFO_BaseHelipads = [];
	if (count _helipadList != 0) then {
		{
			_DFO_status = _x getVariable ["WMS_DFO_BaseHelipad",false];
			if (_DFO_status) then {_DFO_BaseHelipads pushBack _X};
		}forEach _helipadList;
		if (count _DFO_BaseHelipads != 0) then {
			_posBase = position (_DFO_BaseHelipads select 0);
		}else {
			_posBase = position (_helipadList select 0);
			_nil = [_posBase, "notFull"] call WMS_fnc_DFO_BuildBase;
			(_helipadList select 0) setVariable ["WMS_DFO_BaseHelipad",true];
			WMS_DFO_BasePositions pushBack _posBase;
		};
	} else {
		//if not, create one
		_posBase = [_pos, 0, 150, 20, 0, _MaxGrad, 0, [], [([] call BIS_fnc_randomPos),[]]] call BIS_fnc_findSafePos;
		_nil = [_posBase] call WMS_fnc_DFO_BuildBase;
		WMS_DFO_BasePositions pushBack _posBase;
	};
	//generate Mission Hexa ID
	_MissionHexaID = [] call WMS_fnc_DFO_generateHexaID;
	//setParameters depending the mission:
	switch (_mission) do {
		case "inftransport" : {
			_missionName 	= "Infantry Transport";
			_missionStart 	= selectRandom ["BASE","LZ1"];
			_createCIVinf	= true;
			_civType 		= selectRandom ["unarmed","armed"];
			_smokePickUp	= WMS_fnc_DFO_SmokeAtLZ;
			_reinforce 		= selectRandom [false,true];
			_reinforce 		= true;
			_selectedChoppers = WMS_DFO_Choppers select 2;
			if (_missionStart == "BASE") then {_missionFinish = _MissionPath select 1;_civType = "armed";} else {_missionFinish = _MissionPath select 2};
		};
		case "cargotransport" : {
			_missionName 	= "Cargo Delivery";
			_missionStart 	= selectRandom ["BASE","LZ1"];
			_createCargo 	= true;
			_reinforce 		= false;
			_selectedChoppers = WMS_DFO_Choppers select 2;
			if (_missionStart == "BASE") then {_missionFinish = _MissionPath select 1} else {_missionFinish = _MissionPath select 2};
		};
		case "casinf" : { //mission (LZ1) succes wen target destroyed, No RTB/LZ2
			_posTypes 		= ["random","local","military"]; //"random","forest","city","local","military","sea"
			_missionName 	= "CAS Infantry";
			_MissionStart 	= "LZ1";
			_reinforce 		= selectRandom [true,false];
			_createOPFORinf = true; //AA launchers //LMG
			_selectedChoppers = WMS_DFO_Choppers select 0;
		};
		case "casarmored" : { //mission (LZ1) succes wen target destroyed, No RTB/LZ2
			_posTypes 		= ["random","local","military"]; //"random","forest","city","local","military","sea"
			_missionName 	= "CAS Armored";
			_MissionStart 	= "LZ1";
			_createOPFORvhl = true; //heavy
			_OPFORvhlType 	= [3,4];
			_OPFORvhlCnt 	= selectRandom [1,2,3];
			_reinforce 		= selectRandom [true,false];
			_selectedChoppers = WMS_DFO_Choppers select 0;
		};
		case "cascombined" : { //mission (LZ1) succes wen target destroyed, No RTB/LZ2
			_posTypes 		= ["random","local","military"]; //"random","forest","city","local","military","sea"
			_missionName 	= "CAS Combined";
			_MissionStart 	= "LZ1";
			_createOPFORvhl = true;
			_OPFORvhlType 	= [0,1,3,4,5];
			_OPFORvhlCnt 	= selectRandom [2,3,4];
			_createOPFORinf = true;
			_reinforce 		= selectRandom [true,false];
			_selectedChoppers = WMS_DFO_Choppers select 0;
		};
		case "sar" : { //"LZ1"->"BASE"
			_posTypes 		= ["random","sea","sea","forest"]; //"random","forest","city","local","military","sea"
			_missionName 	= "Search And Rescue";
			_MissionStart 	= "LZ1";
			_MissionFinish 	= "BASE";
			_createCIVinf 	= true; //not armed
			_reinforce 		= false;
			_smokePickUp	= WMS_fnc_DFO_SmokeAtLZ;
			_selectedChoppers = WMS_DFO_Choppers select 3;
		};
		case "csar" : { //"LZ1"->"BASE"
			_posTypes 		= ["random","sea"]; //"random","forest","city","local","military","sea"
			_missionName 	= "Combat Search And Rescue";
			_MissionStart 	= "LZ1";
			_MissionFinish 	= "BASE";
			_createCIVinf 	= true; //not armed
			_createOPFORvhl = true; //light
			_OPFORvhlType 	= [5];
			_smokePickUp	= WMS_fnc_DFO_SmokeAtLZ;
			_reinforce 		= selectRandom [true,false];
			_selectedChoppers = [WMS_DFO_Choppers select 1 select 0];
		};
		case "airassault" : { //destroy target or capture zone
			_posTypes 		= ["local","city","military"]; //"random","forest","city","local","military","sea"
			_missionName 	= "Air Assault";
			_createCIVinf 	= true; //military at _MissionStart or civilian at _MissionFinish or both ?
			_createOPFORinf = true;
			_createOPFORvhl = true; //light/APC
			_reinforce 		= false; //KEEP false for now or it will be a mess
			_smokePickUp	= WMS_fnc_DFO_SmokeAtLZ;
			_OPFORvhlType 	= [4,5];//[["AIR_HEAVY"],["AIR_LIGHT"],["AIR_UNARMED"],["HEAVY"],["APC"],["LIGHT"],["UNARMED"],["CIV"],["STATICS"]]
			_selectedChoppers = WMS_DFO_Choppers select 0;//[["pylons"],["doorGunners"],["transport"],["medevac"]];
			if("LZ2" in _MissionPath) then {
				_MissionStart = "LZ1"; //pickup
				_MissionFinish = "LZ2"; //drop/cover
			}else {
				_MissionStart = "BASE"; //pickup
				_MissionFinish = "LZ1"; //drop/cover
			};
		};
		case "maritime" : {_missionName = "If you see this, its fuckedUp";}; //CANCELED
	};

	//select mission position(s)
	//can be from one of the already registered zone like WMS_Pos_Villages or WMS_Pos_Forests or all mixed
	_MissionPathCoord pushBack _posBase;
	private _posType = selectRandom _posTypes;
	if (_mission == "airassault" && {_MissionStart == "LZ1"}) then {
		_posLZ1 = [_pos] call WMS_fnc_DFO_ConvertTypeToCoord;
	} else {
		_posLZ1 = [_pos,_posType] call WMS_fnc_DFO_ConvertTypeToCoord;
	};
	uisleep 1;
	_MissionPathCoord pushBack _posLZ1;
	if ("LZ2" in _MissionPath) then {
		if (_mission == "airassault") then {
			_posLZ2 = [_posLZ1,_posType] call WMS_fnc_DFO_ConvertTypeToCoord;
		}else{
			_posLZ2 = [_posLZ1] call WMS_fnc_DFO_ConvertTypeToCoord;
		};
	};
	uisleep 1;
	if ("LZ2" in _MissionPath) then{_MissionPathCoord pushBack _posLZ2}else {_MissionPathCoord pushBack _posBase};
	if (_MissionStart == "BASE")then {_pos = _posBase};
	if (_MissionStart == "LZ1")then {_pos = _posLZ1};
	if (_MissionFinish == "BASE")then {
		_MissionFinish = _posBase
	}else {
		if (_MissionFinish == "LZ1")then {
			_MissionFinish = _posLZ1
		}else {
			if (_MissionFinish == "LZ2")then {
				_MissionFinish = _posLZ2
			};
		};
	};
		
	//chopper, for the poors
	if (_createChopper) then { //should not be used with WMS_TheLastCartridges but anyway the chopper can not sell (addAction/sell), however Exile Mod will sell it (sell/Classname)
		//addAction on it "pack to get the reward" or something
		private _choppa = (selectRandom _selectedChoppers) createVehicle _posBase;
		_choppa setDir (random 359);
		clearMagazineCargoGlobal _choppa; 
		clearWeaponCargoGlobal _choppa; 
		clearItemCargoGlobal _choppa; 
		clearBackpackCargoGlobal _choppa;
		[ //params ["_target", "_caller", "_actionId", "_arguments"];
		_choppa,
		[
			"<t size='1' color='#068604'>Return Chopper to DFO HQ</t>",
			"
				_target = _this select 0; _caller = _this select 1;
				_chopperPos = position _target;
				_target enableDynamicSimulation false;
				_target enableSimulation false;
				_target setPos [worldSize,worldsize,-100];
				_target setDamage 1;
				_lootHolder = createVehicle ['WeaponHolderSimulated_scripted', _chopperPos, [], 0, 'CAN_COLLIDE'];
				for '_i' from 1 to 6 do {
					_lootHolder addItemCargoGlobal [selectRandom (WMS_DFO_Reward select 2),1];
				};
			",
			[], //argument accessible in the script (_this select 3)
			1,
			true,
			true,
			"",
			//"((getplayerUID _this) == (_target getVariable ['BuyerOwner', 0]) && (vehicle _this == _this))",
			"
				(alive _target) &&
				{(vehicle _this == _this)} &&
				{count (crew _target) == 0};
			",
			5
		]
	] remoteExec [
		"addAction",
		owner _playerObject, //0 for all players //2 server only //-2 everyone but the server
		false //JIP
	];
	};
	//CIV Vehicle
	if (_createCIVvhl) then {}; //Nothing is using civilian vehicle yet
	//OPFOR Vehicle
	if (_createOPFORvhl) then {
		if (_mission != "airassault") then {
			private _vhlReturns = [_MissionHexaID,_playerObject,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,_mission,_MissionFinish] call WMS_fnc_DFO_CreateVhls; //[_vhls,_grps,_faction] //[[],[],side]
			uisleep 1;
			if ((_vhlReturns select 2) == EAST) then {
				{(_vhls select 0) pushback _x}forEach (_vhlReturns select 0);
				{(_grps select 0) pushback _x}forEach (_vhlReturns select 1);
			}else{
				{(_vhls select 1) pushback _x}forEach (_vhlReturns select 0);
				{(_grps select 1) pushback _x}forEach (_vhlReturns select 1);
			};
		};
	};
	//create mission cargo (crate)
	if (_createCargo) then {
		_cargo = selectRandom WMS_DFO_CargoType;
		_cargoObject = _cargo createVehicle [(_pos select 0), (_pos select 1), 2];
		clearMagazineCargoGlobal _cargoObject; 
		clearWeaponCargoGlobal _cargoObject; 
		clearItemCargoGlobal _cargoObject; 
		clearBackpackCargoGlobal _cargoObject; 
		_cargoObject allowdamage false;
	};
	//create mission NPCs
	//CIV
	if (_createCIVinf) then {
		if(_civType == "armed") then {
			_loadoutsCIV = (WMS_DFO_NPCs select 1);
			_infType = "CIV_ARMED";
		} else {
			_loadoutsCIV = (WMS_DFO_NPCs select 2);
			_infType = "CIV";
		};
		if (_mission == "airassault") then {
			_CIVinfGrp = createGroup [CIVILIAN, false];
			for "_i" from 1 to (selectRandom [4,6,8]) do {
				(selectRandom (WMS_DFO_NPCs select 2)) createUnit [_missionFinish, _CIVinfGrp];		
			};
			[_CIVinfGrp, _missionFinish, 75, 5, "MOVE", "CARELESS", "BLUE", "NORMAL", "DIAMOND", "", [1,2,3]] call CBA_fnc_taskPatrol;
			_CIVinfGrp2 = createGroup [WEST, false];
			for "_i" from 1 to (selectRandom [3,4,5,6]) do {
				(selectRandom (WMS_DFO_NPCs select 1)) createUnit [_pos, _CIVinfGrp2];		
			};
			{
				_x setUnitPos "MIDDLE";
				_x allowDamage false; //you don't want those dudes to get killed by roaming AI before you pick them up
			}forEach units _CIVinfGrp2;
			(_grps select 1) pushback _CIVinfGrp2;
			_playerObject setVariable ["WMS_DFO_UnitsToManage", (units _CIVinfGrp2)];
			if (WMS_DFO_Standalone) then {
				[(units _CIVinfGrp2),[_MissionHexaID,_playerObject,"airassault","CIV_ARMED"]] call WMS_fnc_DFO_SetUnits;
			} else {
				//[(units _CIVinfGrp),'Random',100,WMS_Recon_Guards_Skill,"army"] call WMS_fnc_DynAI_SetUnitOPF; //NOPE not for now
				[(units _CIVinfGrp2),[_MissionHexaID,_playerObject,"airassault","CIV_ARMED"]] call WMS_fnc_DFO_SetUnits;
			};
		}else{
			_CIVinfGrp = createGroup [CIVILIAN, false];
			for "_i" from 1 to (selectRandom [2,4,6,8]) do {
				(selectRandom _loadoutsCIV) createUnit [_pos, _CIVinfGrp];		
			};
			{
				_x setUnitPos "MIDDLE";
				_x setVariable ["lambs_danger_disableAI", true];//deactivate LambsDanger
			}forEach units _CIVinfGrp;
			_CIVinfGrp setVariable ["lambs_danger_disableGroupAI", true];//deactivate LambsDanger
			_playerObject setVariable ["WMS_DFO_UnitsToManage", (units _CIVinfGrp)];
		};
		(_grps select 1) pushback _CIVinfGrp;
		if (WMS_DFO_Standalone) then {
			[(units _CIVinfGrp),[_MissionHexaID,_playerObject,_mission,_infType]] call WMS_fnc_DFO_SetUnits;
		} else {
			//[(units _CIVinfGrp),'Random',100,WMS_Recon_Guards_Skill,"army"] call WMS_fnc_DynAI_SetUnitOPF; //NOPE not for now
			[(units _CIVinfGrp),[_MissionHexaID,_playerObject,_mission,_infType]] call WMS_fnc_DFO_SetUnits;
		};
	};
	//OPFOR
	if (_createOPFORinf) then {
		_infType = "OPFOR";
		_OPFORinfGrp = createGroup [EAST, false];
		if (_mission == "airassault") then {
			for "_i" from 1 to (selectRandom [4,6,8,10]) do {
				(selectRandom (WMS_DFO_NPCs select 0)) createUnit [_MissionFinish, _OPFORinfGrp];
			};
			[_OPFORinfGrp] call CBA_fnc_taskDefend; //GARRISON
		}else{
			for "_i" from 1 to (selectRandom [4,6,8,10]) do {
				(selectRandom (WMS_DFO_NPCs select 0)) createUnit [_pos, _OPFORinfGrp];
			};
			[_OPFORinfGrp, _pos, 75, 5, "MOVE", "AWARE", "RED", "NORMAL", "COLUMN", "", [1,2,3]] call CBA_fnc_taskPatrol;
		};
		(_grps select 0) pushback _OPFORinfGrp;
		[(units _OPFORinfGrp),[_MissionHexaID,_playerObject,_mission,_infType]] call WMS_fnc_DFO_SetUnits;
	};
	//create mission/LZ marker
	_mkrs = [_pos,_MissionStart,[_MissionHexaID,_playerObject,nil,_mission,_MissionPathCoord,_missionName,_MissionFinish]] call WMS_fnc_DFO_CreateMkr;
	//create mission zone trigger
	//[0,1,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,3,6] //"airassault" options to create the vehicles, numbers are regular option index
	//_vhlReturns = [_MissionHexaID,_playerObject,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,_mission,_MissionFinish] call WMS_fnc_DFO_CreateVhls; //[_vhls,_grps,_faction] //[[],[],side]
	if (_mission == "airassault") then {
		_triggList = [_pos,_MissionStart,[_MissionHexaID,_playerObject,_mkrs,_mission,_MissionPathCoord,_missionName,_MissionFinish],[0,1,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,3,6]] call WMS_fnc_DFO_CreateTrigger;
	} else {
		_triggList = [_pos,_MissionStart,[_MissionHexaID,_playerObject,_mkrs,_mission,_MissionPathCoord,_missionName,_MissionFinish]] call WMS_fnc_DFO_CreateTrigger;
	};
	{_objs pushback _x}forEach _triggList;
	if (_Mission == "sar" || _Mission == "csar")then{(_triggList select 0) attachTo [(leader _CIVinfGrp), [0,0,0]];};
	//create reinforcement trigger
	private _triggListREIN = [];
	private _triggListSIGN = [];
	if (_reinforce) then {
		_triggListREIN = [_posLZ1,"reinforce",[_MissionHexaID,_playerObject,_mkrs,_mission,_MissionPathCoord,_missionName,_MissionFinish,_reinforce,_smokePickUp,nil]] call WMS_fnc_DFO_CreateTrigger;
		};
	{_objs pushback _x}forEach _triggListREIN;
	//create smoke pickup trigger
	if(_smokePickUp)then{
		_triggListSIGN = [position (leader ((_grps select 1) select 0)),"signal",[_MissionHexaID,_playerObject,_mkrs,_mission,_MissionPathCoord,_missionName,_MissionFinish,_reinforce,_smokePickUp,((_grps select 1) select 0)]] call WMS_fnc_DFO_CreateTrigger;
	};
	{_objs pushback _x}forEach _triggListSIGN;
	
	//Notifications
	if (WMS_DFO_UseJVMF) then {
		private _statusInf = "NO";
		private _statusVhl = "NO";
		private _statusRei = "NO";
		if (_createOPFORinf)then{_statusInf = "YES"};
		if (_createOPFORvhl)then{_statusVhl = "YES"};
		if (_reinforce)then{_statusRei = "YES"};
			[toUpper _mission,"DFO HQ",name _playerObject,0,[
				"Dynamic Flight Ops",
				"Mission Assigned",
				_missionName,
				format["Expected Infantry: %1",_statusInf],
				format["Expected Vehicles: %1",_statusVhl],
				format["Expected Reinforcement: %1",_statusRei],
				"","","",""
				],[_pos],[[format ["%1:%2",(date select 3),(date select 4)],"DFO HQ","SENT"]]] call WMS_fnc_DFO_JVMF;
		};
	if (WMS_exileToastMsg) then {
		_sessionID = _playerObject getVariable ['ExileSessionID',''];
		[_sessionID, 'toastRequest', ['InfoTitleAndText', ['Dynamic Flight Ops', (format ["%1 @ %2, %3min Timer",_missionName, ([round(_posLZ1 select 0), round(_posLZ1 select 1)]),round (_updatedTimer/60)])]]] call ExileServer_system_network_send_to;
	} else {
		["EventCustom", ["Dynamic Flight Ops", (format ["%1 @ %2, %3min Timer",_missionName, ([round(_posLZ1 select 0), round(_posLZ1 select 1)]),round (_updatedTimer/60)]), "\A3\ui_f\data\map\MapControl\taskiconcreated_ca.paa"]] remoteExec ["BIS_fnc_showNotification", (owner _playerObject)];
	};
	//System/Management
	WMS_DFO_LastCall = time;
	WMS_DFO_Running pushback [time,_timeToDelete,_grps,_vhls,_objs,_mkrs,_cargoObject,"DFO",[_MissionHexaID,_playerObject,_mission,_MissionPathCoord,_missionName,_MissionFinish],_MissionHexaID];
	publicVariable "WMS_DFO_Running";
	publicVariable "WMS_DFO_LastCall";
};
WMS_fnc_DFO_generateHexaID = {	//will be used to find the mission data in arrays
	private _hexaBase = [0,1,2,3,4,5,6,7,8,9,"a","b","c","e","e","f"];
	private _hexaArray = [];
	for "_i" from 1 to 8 do {
		_hexaArray pushBack	(selectRandom _hexaBase);
	};
	private _MissionHexaID = format ["%1%2%3%4%5%6%7%8",(_hexaArray select 0),(_hexaArray select 1),(_hexaArray select 2),(_hexaArray select 3),(_hexaArray select 4),(_hexaArray select 5),(_hexaArray select 6),(_hexaArray select 7)];
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_generateHexaID _MissionHexaID %1', _MissionHexaID]};
	_MissionHexaID
};
WMS_fnc_DFO_CreateMkr = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_CreateMkr _this %1', _this]};
	private ["_MkrList","_mkrType","_MkrColor","_MkrBorder","_MkrLZ","_mkrName"];
	params [
		"_pos",
		["_type","BASE"],
		["_options",[]] //[_MissionHexaID,_playerObject,nil,_mission,_MissionPathCoord,_missionName]
	];
	_MkrList = [];
	_mkrType = WMS_DFO_Markers select 0;
	_MkrColor = WMS_DFO_MkrColors select 0;
	_mission = _options select 3;
	if (_mission == "casarmored" || _mission == "cascombined") then {_MkrColor = WMS_DFO_MkrColors select 2};
	private _playerObject = _options select 1;
	private _missionName = _options select 5;
	if (_mission == "sar" || _mission == "csar") then {
		_pos = [((_pos select 0)-WMS_DFO_MkrRandomDist)+ random (WMS_DFO_MkrRandomDist *2),((_pos select 1)-WMS_DFO_MkrRandomDist)+ random (WMS_DFO_MkrRandomDist *2),0]
	};
	if !(_type == "BASE") then {
		_mkrName = format ["DFO_markerBorder_%1",time];
		_MkrBorder = createMarker [_mkrName, _pos];
		_MkrBorder setMarkerColor "colorOrange";
		_MkrBorder setMarkerShape "ELLIPSE";
		_MkrBorder setMarkerBrush "border";
		_MkrBorder setMarkerSize [300,300];
		_MkrList pushback _mkrName;
	}else {
		_MkrType = WMS_DFO_Markers select 1;
		_MkrColor = WMS_DFO_MkrColors select 1;
	};
	_mkrName = format ["DFO_markerLZ_%1",time];
	_MkrLZ = createMarker [_mkrName, _pos];
	_MkrLZ setMarkerType _mkrType;
	_MkrLZ setMarkerColor _MkrColor;
	_MkrLZ setMarkerText format ["%1 %2",_missionName,(name _playerObject)];
	_MkrList pushBack _mkrName;
	_MkrList
};
WMS_fnc_DFO_CreateTrigger = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_CreateTrigger _this %1', _this]};
	private ["_triggList","_triggMission","_triggReinf","_mission"];
	params [
		"_pos",
		["_triggType", "whatever"],
		["_options",[]], //[_MissionHexaID,_playerObject,_mkrs,_mission,_MissionPathCoord,_missionName,_MissionFinish,BOOLEAN reinforce or not,BOOLEAN smoke or not,_grp to smoke]
		["_airassaultDatas",[]] //[0,1,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,3,6] //"airassault" options to create the vehicles, numbers are regular option index
	];
	_triggList = [];
	_mission = _options select 3;
	if (_triggType isEqualTo "LZ1" || _triggType isEqualTo "BASE") then {
		if (_mission == 'airassault') then {_options pushBack _airassaultDatas};
		//trigger mission itself
		//[0,1,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,3,6] //"airassault" options to create the vehicles, numbers are regular option index
		//_vhlReturns = [_MissionHexaID,_playerObject,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,_mission,_MissionFinish] call WMS_fnc_DFO_CreateVhls; //[_vhls,_grps,_faction] //[[],[],side]
		if !(_mission == "casinf" || _mission == "casarmored" || _mission == "cascombined") then { //CAS do not need trigger, the cleanup is every minute check and no RTB
		_triggMission = createTrigger ["EmptyDetector", _pos, true]; 
		_triggMission setVariable ["WMS_DFO_triggData", _options, false];  
		_triggMission setTriggerActivation ["ANYPLAYER", "PRESENT", true]; //should be activated by the "pilot" only
		_triggMission setTriggerArea [12.5, 12.5, 0, false];
		_triggMission setTriggerStatements  
		[ 
  			"this && ({ (position _x) select 2 <= 10 } count thislist) > 0",   //getPosATL
  			"	
		  		private _datas = (thisTrigger getVariable 'WMS_DFO_triggData');
				private _pilot = (_datas select 1);
				private _mission = (_datas select 3);
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] DFO trigger LZ1 | MissionID %1 | Pilot %2 | Marker %3 | Mission %4 | Mission path %5 |', (_datas select 0), name _pilot , (_datas select 2), _mission, (_datas select 4)]};
				if (((vehicle _pilot) in thisList) && {(vehicle _pilot) isKindOf 'Helicopter'} && {speed (vehicle _pilot) < 15}) then {
					if(_mission == 'sar' || _mission == 'csar' || _mission == 'airassault' || _mission == 'inftransport') then {[vehicle _pilot , _pilot ] call WMS_fnc_DFO_infLoad};
					_datas call WMS_fnc_DFO_nextStepMkrTrigg;
					{deleteMarker _x}forEach (_datas select 2);
					deleteVehicle thisTrigger;
				}else{
					if !((vehicle _pilot) in thisList) then {	
						[(thisList select 0)] call WMS_fnc_DFO_PunishPunks;
						'Dynamic Flight Ops, mission is in progress' remoteExec ['hint', (owner (thisList select 0))];
					}else {
						'Dynamic Flight Ops, Redo your Approach, maxSpeed 15km/h' remoteExec ['hint', (owner (thisList select 0))];
					};
					if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] DFO trigger LZ1 | MissionID %1 | Pilot %2 | Marker %3 | Mission %4 | Mission path %5 |', (_datas select 0), name _pilot , (_datas select 2), _mission, (_datas select 4)]};
					
				};
			",  
  			"" 
		];
		_triggList pushBack _triggMission;
		};
	};
	if (_triggType == "reinforce") then {
		if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_CreateTrigger Creating Reinforcement Zone Trigger, %1 radius', WMS_DFO_ReinfTriggDist]};
		//trigger reinforcement
		_triggReinf = createTrigger ["EmptyDetector", _pos, true];
		_triggReinf setVariable ["WMS_DFO_triggData", _options, false];
		_triggReinf setTriggerActivation ["ANYPLAYER", "PRESENT", true]; 
		_triggReinf setTriggerArea [WMS_DFO_ReinfTriggDist, WMS_DFO_ReinfTriggDist, 0, false];
		_triggReinf setTriggerStatements  
		[ 
  			"this",
  			"	
			  	private _options = (thisTrigger getVariable 'WMS_DFO_triggData');
				private _reinforce = _options select 7;
				private _createSmoke = _options select 8;
				private _smokeGroup = _options select 9;
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] DFO trigger REINFORCE | MissionID %1 | Pilot %2 | Marker %3 | Mission %4 | Mission path %5 |', (_options select 0), name (_options select 1), (_options select 2), (_options select 3), (_options select 4)]};
				if (_reinforce) then {[_options select 0,_options select 1,_options select 3,_options select 6,_smokeGroup,(position thisTrigger)] spawn WMS_fnc_DFO_Reinforce};
				deleteVehicle thisTrigger;
			",  
  			"" 
		];// && {position thisTrigger != (_options select 4 select 0)}
		_triggList pushBack _triggReinf;
	};
	if (_triggType == "signal") then {
		if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_CreateTrigger Creating Reinforcement Zone Trigger, %1 radius', WMS_DFO_ReinfTriggDist]};
		//trigger reinforcement
		_triggReinf = createTrigger ["EmptyDetector", _pos, true];
		_triggReinf setVariable ["WMS_DFO_triggData", _options, false];
		_triggReinf setVariable ["WMS_DFO_pilot", _options select 1, false];
		_triggReinf setTriggerActivation ["ANYPLAYER", "PRESENT", true]; 
		_triggReinf setTriggerArea [WMS_DFO_ReinfTriggDist, WMS_DFO_ReinfTriggDist, 0, false];
		_triggReinf setTriggerStatements  
		[ 
  			"(vehicle (thisTrigger getVariable 'WMS_DFO_pilot')) in thisList",  
  			"	
			  	private _options = (thisTrigger getVariable 'WMS_DFO_triggData');
				private _reinforce = _options select 7;
				private _createSmoke = _options select 8;
				private _smokeGroup = _options select 9;
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] DFO trigger SIGNAL | MissionID %1 | Pilot %2 | Marker %3 | Mission %4 | Mission path %5 |', (_options select 0), name (_options select 1), (_options select 2), (_options select 3), (_options select 4)]};
				if (_createSmoke) then {
					if !(vehicle (leader _smokeGroup) == vehicle (_options select 1)) then {
						_pos = (position leader _smokeGroup);
						_smoke = 'SmokeShellPurple' createVehicle _pos;
						_smoke attachTo [(leader _smokeGroup), [0,0,0]];
						_flare = 'F_40mm_Red' createVehicle [_pos select 0, _pos select 1, 150];
						_flare setVelocity [0.01,-0.015,0];
					};
				};
				deleteVehicle thisTrigger;
			",  
  			"" 
		];// && {position thisTrigger != (_options select 4 select 0)}
		_triggList pushBack _triggReinf;
	};
	_triggList
};
WMS_fnc_DFO_Reinforce = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Reinforce _this %1', _this]};
	params [ //_options //not anymore
		"_MissionHexaID",
		"_playerObject",
		//"_mkrs",
		"_mission",
		//"_MissionPathCoord",
		//"_missionName",
		"_MissionFinish",
		//"_reinforce", //should not be false
		//"_smokePickUp", //can be false
		"_grpSmoke", //can be nil
		"_pos" //trigger position
		];
		private _typeOfReinforce = ["AIRpatrol","VHLpatrol","paradrop","AIRassault"];
		private _timer = 500+(random 120);
		private _grps = [];
		private _vhls = [];
		private _objects = [];
		private _units = [];
		private _grp = grpNull;
		private _OPFPRvhl = objNull;
		//if !(_grpSmoke isEqualTo grpNull) then { //NOPE
		/*if !(isNull _grpSmoke) then {
			if (vehicle (leader _grpSmoke) != vehicle _playerObject) then {
				_pos = position (leader _grpSmoke);
			};
		};*/
		_typeOfReinforce = selectRandom _typeOfReinforce;
		if (surfaceIsWater _pos) then {_typeOfReinforce = "AIRpatrol"};
		if(WMS_DFO_Standalone)then{
			//private _playerScore = _playerObject getVariable ["ExileScore", 5000]; //will be usefull later for reinforcement skill adjustment
			//let's test with "VHLpatrol" only
			_blackList = allPlayers select {alive _x} apply {[position _x, 900]};
			//_typeOfReinforce = "VHLpatrol"; //TEST
			if (_typeOfReinforce == "AIRpatrol") then {
				_randomPos = [_pos, WMS_DFO_ReinfTriggDist+900, WMS_DFO_ReinfTriggDist+2500, 0, 0, 0, 0, _blackList, [([] call BIS_fnc_randomPos),[]]] call BIS_fnc_findSafePos;
				_vhl = [[_randomPos select 0,_randomPos select 1, 250], (random 359), selectRandom (WMS_DFO_NPCvehicles select 0), EAST] call bis_fnc_spawnvehicle;      
				_vehic = (_vhl select 0);  
				_units = (_vhl select 1);   
				_grp = (_vhl select 2); 
				_vhls pushBack _vehic;
				_grps pushBack _grp;
				_vehic setVehicleLock "LOCKEDPLAYER";
				clearMagazineCargoGlobal _vehic;    
				clearWeaponCargoGlobal _vehic;    
				clearItemCargoGlobal _vehic;    
				clearBackpackCargoGlobal _vehic;
				[_units,[_MissionHexaID,_playerObject,_mission,"OPFOR"]] call WMS_fnc_DFO_SetUnits;
				[_grp, _pos, 300, 4, "MOVE", "AWARE", WMS_DFO_OPFORcbtMod, "LIMITED", "COLUMN", "", [2,4,6]] call CBA_fnc_taskPatrol;
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Reinforce "AIRpatrol" %1', _vhl]};
			};
			if (_typeOfReinforce == "VHLpatrol") then {
				_OPFPRvhl = selectRandom (WMS_DFO_NPCvehicles select 4); //APC
				if(_mission == "csar"||_mission == "sar"||_mission == "inftransport"||_mission == "cargotransport") then {
					_OPFPRvhl = selectRandom (WMS_DFO_NPCvehicles select 5); //light
				};
				_randomPos = [_pos, 300, WMS_DFO_ReinfTriggDist, 8, 0, 0, 0, _blackList, [([] call BIS_fnc_randomPos),[]]] call BIS_fnc_findSafePos;
				_vhl = [[_randomPos select 0,_randomPos select 1, 2], (random 359), _OPFPRvhl, EAST] call bis_fnc_spawnvehicle;      
				_vehic = (_vhl select 0);  
				_units = (_vhl select 1);   
				_grp = (_vhl select 2); 
				_vhls pushBack _vehic;
				_grps pushBack _grp;
				_vehic setVehicleLock "LOCKEDPLAYER";
				clearMagazineCargoGlobal _vehic;    
				clearWeaponCargoGlobal _vehic;    
				clearItemCargoGlobal _vehic;    
				clearBackpackCargoGlobal _vehic;
				[_units,[_MissionHexaID,_playerObject,_mission,"OPFOR"]] call WMS_fnc_DFO_SetUnits;
				[_grp, _pos, 300, 4, "MOVE", "AWARE", WMS_DFO_OPFORcbtMod, "LIMITED", "COLUMN", "", [2,4,6]] call CBA_fnc_taskPatrol;
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Reinforce "VHLpatrol" %1', _vhl]};
			};
			if (_typeOfReinforce == "paradrop") then {
				_OPFORinfGrp = createGroup [EAST, false];
				for "_i" from 1 to (selectRandom [4,5,6,7,8]) do {
					(selectRandom (WMS_DFO_NPCs select 0)) createUnit [[0,0,3000], _OPFORinfGrp];
				};
				[_OPFORinfGrp, _pos, 75, 5, "MOVE", "AWARE", "RED", "NORMAL", "COLUMN", "", [1,2,3]] call CBA_fnc_taskPatrol;
				{
					_posDrop = [[[_pos, 120]], []] call BIS_fnc_randomPos;
					removeBackpackGlobal _x;
					_x addBackpack "B_Parachute";
					_x setPosATL [_posDrop select 0,_posDrop select 1, 150];
				}forEach units _OPFORinfGrp;
				_grps pushback _OPFORinfGrp;
				[(units _OPFORinfGrp),[_MissionHexaID,_playerObject,_mission,"OPFOR"]] call WMS_fnc_DFO_SetUnits;
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Reinforce "paradrop" %1', _OPFORinfGrp]};
			};
			if (_typeOfReinforce == "AIRassault") then {
				_randomPos = [_pos, WMS_DFO_ReinfTriggDist+900, WMS_DFO_ReinfTriggDist+2500, 0, 0, 0, 0, _blackList, [([] call BIS_fnc_randomPos),[]]] call BIS_fnc_findSafePos;  
				_posLand = [_pos, 0, 250, 25, 0, 0, 0, [], [([[[_pos, 150]], []] call BIS_fnc_randomPos),[]]] call BIS_fnc_findSafePos; 
				_Helipad = "Land_HelipadEmpty_F" createVehicle _posLand;
				_objects pushBack _Helipad;
				//GUNSHIP
				_vhl1 = [[_randomPos select 0,_randomPos select 1, 250], (random 359), selectRandom (WMS_DFO_NPCvehicles select 0), EAST] call bis_fnc_spawnvehicle;
				_vehic1 = (_vhl1 select 0);
				_units1 = (_vhl1 select 1);
				_grp1 = (_vhl1 select 2);
				_vhls pushBack _vehic1;
				_grps pushBack _grp1;
				_vehic1 setVehicleLock "LOCKEDPLAYER";
				clearMagazineCargoGlobal _vehic1;
				clearWeaponCargoGlobal _vehic1;
				clearItemCargoGlobal _vehic1;
				clearBackpackCargoGlobal _vehic1;
				[_units1,[_MissionHexaID,_playerObject,_mission,"OPFOR"]] call WMS_fnc_DFO_SetUnits;
				_WPT_1 = _grp1 addWaypoint [_pos, 50];         
				_WPT_1 setWaypointType "MOVE";  
				_WPT_1 setwaypointSpeed "NORMAL";  
				_WPT_1 setWaypointCombatMode "GREEN";  
				_WPT_1 setWaypointbehaviour  "SAFE"; 
				uisleep 3;
				//TRANSPORT
				_vhl2 = [[_randomPos select 0,_randomPos select 1, 300], (random 359), selectRandom (WMS_DFO_NPCvehicles select 2), EAST] call bis_fnc_spawnvehicle;
				_vehic2 = (_vhl2 select 0);
				_units2 = (_vhl2 select 1);
				_grp2 = (_vhl2 select 2);
				_vhls pushBack _vehic2;
				_grps pushBack _grp2;
				_vehic2 setVehicleLock "LOCKEDPLAYER";
				clearMagazineCargoGlobal _vehic2;    
				clearWeaponCargoGlobal _vehic2;    
				clearItemCargoGlobal _vehic2;    
				clearBackpackCargoGlobal _vehic2;
				[_units2,[_MissionHexaID,_playerObject,_mission,"OPFOR"]] call WMS_fnc_DFO_SetUnits;
				_WPT_1b = _grp2 addWaypoint [_posLand, 25];  
				_WPT_1b setWaypointType "TR UNLOAD";  
				_WPT_1b setwaypointSpeed "NORMAL";  
				_WPT_1b setWaypointCombatMode "BLUE";  
				_WPT_1b setWaypointbehaviour  "CARELESS";  
				uisleep 1;
				//INFANTRY
				_OPFORinfGrp = createGroup [EAST, false];
				_grps pushBack _OPFORinfGrp;
				for "_i" from 1 to (selectRandom [4,5,6,7,8]) do {
					(selectRandom (WMS_DFO_NPCs select 0)) createUnit [_randomPos, _OPFORinfGrp];
				};
				[_OPFORinfGrp, _pos, 75, 4, "MOVE", "AWARE", "RED", "NORMAL", "COLUMN", "", [1,2,3]] call CBA_fnc_taskPatrol;
				_units = units _OPFORinfGrp;
				{_x moveInCargo _vehic2}forEach _units;
				[_units,[_MissionHexaID,_playerObject,_mission,"OPFOR"]] call WMS_fnc_DFO_SetUnits;
				//AIRASSAULT TRIGGER
				_triggAssault = createTrigger ["EmptyDetector", _pos, true];
				_triggAssault setVariable ["_vehic1", _vehic1, false];
				_triggAssault setVariable ["_vehic2", _vehic2, false];
				_triggAssault setTriggerActivation ["EAST", "PRESENT", true]; 
				_triggAssault setTriggerArea [300, 300, 0, false];
				_triggAssault setTriggerStatements  
				[ 
  					"(thistrigger getVariable '_vehic1') in thisList || (thistrigger getVariable '_vehic2') in thisList",
  					"	
						if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] trigger AIRASSAULT | thisList %1 | position %2 |', thisList, position thisTrigger]};
						[group (thistrigger getVariable '_vehic1'), position thisTrigger, 300, 4, 'MOVE', 'AWARE', WMS_DFO_OPFORcbtMod, 'LIMITED', 'COLUMN', '', [2,4,6]] call CBA_fnc_taskPatrol;
						deleteVehicle thisTrigger;
					",  
  					"" 
				];
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Reinforce "AIRassault" %1', _vhls]};
			};

			WMS_DFO_RunReinforce pushBack ["_MissionHexaID", (time+_timer), _grps, _vhls, _objects,"","","REINF"];

		}else{
			[_playerObject, _pos, "DFO",_typeOfReinforce] call WMS_fnc_DynAI_selScen;
		};
	};
WMS_fnc_DFO_NextStepMkrTrigg = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_NextStepMkrTrigg _this %1', _this]};
	params [
		["_MissionHexaID","zzzzzzzz"],
		["_playerObject", objNull],
		["_mkrs",[]], //useless in this case, the new marker could go here if needed
		["_mission","sar"],
		["_MissionPathCoord", [[0,0,0],[0,0,0],[0,0,0]]],
		["_missionName","DFO Mission"],
		["_MissionFinish", [0,0,0]],
		["_airassaultDatas",[]]//[0,1,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,3,6]
		];
	//if (isnil _playerObject) exitWith { //nope
	if (_MissionHexaID ==  "zzzzzzzz") exitWith {
		if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_NextStepMkrTrigg params fuckedUp _MissionHexaID %1', _MissionHexaID]};
		};
	//create last step to finish the mission RTB Or LZ2
	private _pos = _MissionFinish;
	private _createTrigg = true;
	//CREATE THE MARKER
	private _mkrName = format ["DFO_markerEnd_%1",time];
	_MkrLZ = createMarker [_mkrName, _pos];
	_MkrLZ setMarkerType (WMS_DFO_Markers select 1);
	if (_mission == 'airassault') then {
		_MkrLZ setMarkerColor (WMS_DFO_MkrColors select 2);
		//[0,1,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,3,6] //"airassault" options to create the vehicles, numbers are regular option index
		//_vhlReturns = [_MissionHexaID,_playerObject,EAST,_pos,_OPFORvhlCnt,_OPFORvhlType,_mission,_MissionFinish] call WMS_fnc_DFO_CreateVhls; //[_vhls,_grps,_faction] //[[],[],side]
		_vhlReturns = [_MissionHexaID,_playerObject,EAST,(_airassaultDatas select 3),(_airassaultDatas select 4),(_airassaultDatas select 5),_mission,_MissionFinish] call WMS_fnc_DFO_CreateVhls; 
		//NEED TO PUSH THIS IN THE MISSION ARRAY, NOT IN A STUPID VAR
		/*private _playerVarVhls = missionNameSpace getVariable ["WMS_DFO_VehiclesToDelete",[]];
		_playerVarVhls pushBack [_MissionHexaID,(_vhlReturns select 0)];
		missionNameSpace setVariable ["WMS_DFO_VehiclesToDelete",_playerVarVhls]; //for CleanUp timeOut, death, disconnect, success? //or mayne in missionNameSpace since it include hexaID 
		private _playerVarGrps = missionNameSpace getVariable ["WMS_DFO_GroupToDelete",[]];
		_playerVarGrps pushBack [_MissionHexaID,(_vhlReturns select 1)];
		missionNameSpace setVariable ["WMS_DFO_GroupToDelete",_playerVarGrps]; //for CleanUp timeOut, death, disconnect, success? //or mayne in missionNameSpace since it include hexaID*/
		//////////
		private _result = []; 
		{ 
			_found = (_x select 9) find _MissionHexaID;
			_result pushback _found;
		}forEach WMS_DFO_Running;
		private _RefIndex = _result find 0;
		{(WMS_DFO_Running select _RefIndex select 3 select 0) pushBack _x;} forEach (_vhlReturns select 0);
		{(WMS_DFO_Running select _RefIndex select 2 select 0) pushBack _x;} forEach (_vhlReturns select 1);
		//////////
	} else {
		_MkrLZ setMarkerColor (WMS_DFO_MkrColors select 1);
	};
	_MkrLZ setMarkerText format ["%1 %2",_missionName,(name _playerObject)];
	private _playerVarMkr = missionNameSpace getVariable ["WMS_DFO_MarkerToDelete",[]];
	_playerVarMkr pushBack [_MissionHexaID,_mkrName];
	missionNameSpace setVariable ["WMS_DFO_MarkerToDelete",_playerVarMkr];
	//CREATE OBJECTS TO MARK THE ZONE
	if !(_pos isEqualTo (_MissionPathCoord select 0)) then {
		private _objects = [_pos,"NOTRIGGER"]call WMS_fnc_DFO_BuildBase;
		private _playerVarObj = missionNameSpace getVariable ["WMS_DFO_MarkerToDelete",[]];
		_playerVarObj pushBack [_MissionHexaID,_objects];
		missionNameSpace setVariable ["WMS_DFO_ObjectToDelete",_playerVarObj];
	};
	//CREATE THE TRIGGER
	private _triggMission = createTrigger ["EmptyDetector", _pos, true]; 
	private _playerVarTrigg = missionNameSpace getVariable ["WMS_DFO_TriggerToDelete",[]];
	_playerVarTrigg pushBack [_MissionHexaID,_triggMission];
	missionNameSpace setVariable ["WMS_DFO_TriggerToDelete",_playerVarTrigg]; //for CleanUp timeOut, death, disconnect, success? //or mayne in missionNameSpace since it include hexaID
	_triggMission setVariable ["WMS_DFO_triggData", [_MissionHexaID,_playerObject,_mkrName,_mission,_MissionPathCoord,_missionName,_MissionFinish], false];  
	_triggMission setTriggerActivation ["ANYPLAYER", "PRESENT", true]; //should be activated by the "pilot" only
	_triggMission setTriggerArea [12.5, 12.5, 0, false];
	_triggMission setTriggerStatements  
	[ 
  		"this && ({ (position _x) select 2 <= 10 } count thislist) > 0",   
  		"	
			private _datas = (thisTrigger getVariable 'WMS_DFO_triggData');
			private _pilot = (_datas select 1);
			private _mission = (_datas select 3);
			if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] DFO trigger END | MissionID %1 | Pilot %2 | Marker %3 | Mission %4 | Mission path %5 | ThisList %6', (_datas select 0), name (_datas select 1), (_datas select 2), (_datas select 3), (_datas select 4), thisList]};
			if (((vehicle _pilot) in thisList) && {(vehicle _pilot) isKindOf 'Helicopter'} && {speed _pilot < 15}) then {
				if(_mission == 'sar' || _mission == 'csar' || _mission == 'airassault' || _mission == 'inftransport') then {[vehicle _pilot, _pilot] call WMS_fnc_DFO_infUnLoad};
				_datas call WMS_fnc_DFO_CallForCleanup;
				deleteVehicle thisTrigger;
			}else{
				if !((vehicle _pilot) in thisList) then {	
					[(thisList select 0)] call WMS_fnc_DFO_PunishPunks;
					'Dynamic Flight Ops, Do not Park here' remoteExec ['hint', (owner (thisList select 0))];
				}else {
					'Dynamic Flight Ops, Redo your Approach, maxSpeed 15km/h' remoteExec ['hint', (owner (thisList select 0))];
				};
				
			};
		",  
  		"" 
	];
	//Notifications
	//if (WMS_DFO_UseJVMF) then {["WELCOME","DFO HQ","ALL",0,["Dynamic Flight Ops","","","","","","","","",""],[],[[format ["%1:%2",(date select 3),(date select 4)],"DFO HQ","SENT"]]] call WMS_fnc_DFO_JVMF};
	if (WMS_exileToastMsg) then {
		_sessionID = _playerObject getVariable ['ExileSessionID',''];
		[_sessionID, 'toastRequest', ['InfoTitleAndText', ['Dynamic Flight Ops', (format ["%1 @ %2, phase 2",_missionName, ([round(_pos select 0), round(_pos select 1)])])]]] call ExileServer_system_network_send_to;
	} else {
		["EventCustom", ["Dynamic Flight Ops", (format ["%1 @ %2, phase 2",_missionName, ([round(_pos select 0), round(_pos select 1)])]), "\A3\ui_f\data\map\MapControl\taskiconcreated_ca.paa"]] remoteExec ["BIS_fnc_showNotification", (owner _playerObject)];
	};
};
WMS_fnc_DFO_MissionSucces = { //reward the pilot for the great job depending the mission
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_MissionSucces _this %1', _this]};
	private [];
	params [
		"_playerObject",
		["_mission", "sar"]
	];
	private _coef = 0;
	switch (_mission) do { //["inftransport","cargotransport","airassault","casinf","casarmored","cascombined","sar","csar"];
		case "cargotransport" 	: {_coef = 0.25};
		case "inftransport" 	: {_coef = 0.3};
		case "sar" 				: {_coef = 0.5};
		case "csar" 			: {_coef = 0.75};
		case "casinf" 			: {_coef = 0.8};
		case "casarmored" 		: {_coef = 1};
		case "airassault" 		: {_coef = 1.2};
		case "cascombined" 		: {_coef = 2};
	};
	private _score = WMS_DFO_Reward select 0;
	private _money = WMS_DFO_Reward select 1;
	private _scoreAdjusted = round (_score*_coef);
	private _moneyAdjusted = round (_money*_coef);
	private _playerScore = _playerObject getVariable ["ExileScore", 0];
	private _playerMoney = _playerObject getVariable ["ExileMoney", 0];
	private _playerScoUpdated = (_playerScore+_scoreAdjusted);
	private _playerMonUpdated = (_playerMoney+_moneyAdjusted);
	_playerObject setVariable ["ExileScore", _playerScoUpdated, true];
	_playerObject setVariable ["ExileMoney", _playerMonUpdated, true];
	//need Exile specific DB access update:
	private _killerUID 	= getPlayerUID _playerObject;
	if (WMS_exileFireAndForget) then { //DB Only for Rep, poptabs stay local
		format["setAccountScore:%1:%2", _playerScoUpdated, _killerUID] call ExileServer_system_database_query_fireAndForget;
		ExileClientPlayerScore = _playerScoUpdated;
		(owner _playerObject) publicVariableClient "ExileClientPlayerScore";
		ExileClientPlayerScore = nil;
	}else {
		//need WMS_TheLastCartridges specific profileNamespace update:
		//_playerUID_ExileKills = "ExileKills_"+_killerUID;
		_playerUID_ExileMoney = "ExileMoney_"+_killerUID;
		_playerUID_ExileScore = "ExileScore_"+_killerUID;
		profileNamespace setVariable [_playerUID_ExileScore,_playerScoUpdated];
		profileNamespace setVariable [_playerUID_ExileMoney,_playerMonUpdated];
	};
	//Notifications:
	if (WMS_DFO_UseJVMF) then {["SUCCESS","DFO HQ",name _playerObject,0,["DFO Mission Success",toUpper _mission,format["Score Reward: %1",_scoreAdjusted],format["Money Reward: %1",_moneyAdjusted],"","","","","","During dev, rewards are not permanent"],[],[[format ["%1:%2",(date select 3),(date select 4)],"DFO HQ","SENT"]]] call WMS_fnc_DFO_JVMF};
	if (WMS_exileToastMsg) then {
		_sessionID = _playerObject getVariable ['ExileSessionID',''];
		[_sessionID, 'toastRequest', ['SuccessTitleAndText', ['Dynamic Flight Ops', format["Mission SUCCES! +%1 rep, +%2 poptabs",_moneyAdjusted,_scoreAdjusted]]]] call ExileServer_system_network_send_to;
	} else {
			["TaskSucceeded", ["Dynamic Flight Ops", format["Mission SUCCES! +%1 rep, +%2 $",_scoreAdjusted,_moneyAdjusted]]] remoteExec ["BIS_fnc_showNotification", (owner _playerObject)];
	};

};
WMS_fnc_DFO_PunishPunks = { //will be use to remind to those getting in the mission zone that it's not their mission, ACE broken legs and things like that
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_PunishPunks _this %1', _this]};
	params [
		"_playerObject",
		["_maxDamage",0.4],
		["_part", selectRandom ["head", "body", "leftarm", "rightarm", "leftleg", "rightleg"]], //["head", "body", "leftarm", "rightarm", "leftleg", "rightleg"] ACE
		["_projectiles", selectRandom ["stab","bullet","grenade","explosive","shell","vehiclecrash","backblast","falling"]] //["stab","bullet","grenade","explosive","shell","vehiclecrash","collision","backblast","punch","falling","ropeburn","fire"]
		];

	if (WMS_DFO_AceIsRunning) then {
		//[_playerObject, [[0.5, "Body", 1]], "bullet"] call ace_medical_damage_fnc_woundsHandlerBase;
		//[cursorTarget, 1, "body", "stab", player] call ace_medical_fnc_addDamageToUnit;
		[_playerObject, _maxDamage, _part, _projectiles, _playerObject] remoteExecCall ["ace_medical_fnc_addDamageToUnit",owner _playerObject];
	} else {
		//Bohemia:
		/*_parts = [
			"face_hub", //Unit dies at damage equal to or above 1
			"neck", //Unit dies at damage equal to or above 1
			"head", //Unit dies at damage equal to or above 1
			"pelvis", //Unit dies at damage equal to or above 1
			"spine1", //Unit dies at damage equal to or above 1
			"spine2", //Unit dies at damage equal to or above 1
			"spine3", //Unit dies at damage equal to or above 1
			"body", //Unit dies at damage equal to or above 1
			"arms", //Unit doesn't die with damage to this part
			"hands", //Unit doesn't die with damage to this part
			"legs" //Unit doesn't die with damage to this part 
		];*/
		//_playerObject setHit [selectRandom _parts,random 0.25,true,_playerObject];
		private _dmg = damage _playerObject;
		_playerObject setDamage _dmg+(random _maxDamage); //it's not sexy but it should do the job for now
	};
	};
WMS_fnc_DFO_JVMF = { //if (WMS_DFO_UseJVMF) then {[blablablabla] call WMS_fnc_DFO_JVMF;};
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_JVMF _this %1', _this]};
	//Hatchet stuff as reference:
	/*
        case 0: {"FRTXT "};
        case 1: {"CASREQ"};
        case 2: {"POSRPT"};
        case 3: {"MEDEVC"};
    */
	_this call vtx_uh60_jvmf_fnc_attemptSendMessage;
	};
WMS_fnc_DFO_SetUnits = { //For Standalone but not only //will use regular loadout from unit classname
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_SetUnits _this %1', _this]};
	private [];
	params [
		"_units",
		//["_infType","CIV"], //"OPFOR","CIV_ARMED","CIV"
		["_options", []], //[_MissionHexaID,_playerObject,_mission,_infType] //_infType= "OPFOR","CIV_ARMED","CIV"
		["_skills",[0.80, 0.8, 0.25, 0.3, 0.3, 0.6, 0, 0.6, 0.6]] //WMS_AMS_skilleasy
	];
	{
		//setSkill
		_x setSkill ["spotDistance", 	(_skills select 0)];
		_x setSkill ["spotTime", 		(_skills select 1)];
		_x setSkill ["aimingAccuracy", 	(_skills select 2)];
		_x setSkill ["aimingShake", 	(_skills select 3)];
		_x setSkill ["aimingSpeed", 	(_skills select 4)];
		_x setSkill ["reloadSpeed", 	(_skills select 5)];
		_x setSkill ["courage", 		(_skills select 6)];
		_x setSkill ["commanding", 		(_skills select 7)];
		_x setSkill ["general", 		(_skills select 8)];
		_x setVariable ["WMS_skills",_skills,true]; //will be used for AI killfeed on player EH killed (WMS_InfantryProgram)
		_x setVariable ["WMS_DFO_options",_options];
		_x allowFleeing 0;

		_x addEventHandler ["Killed", " 
		[(_this select 0),(_this select 1),(_this select 2)] call WMS_fnc_DFO_UnitEH;
		"];//params ["_unit", "_killer", "_instigator", "_useEffects"];
	}forEach _units
}; 
WMS_fnc_DFO_UnitEH = { //For Standalone but not only
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_UnitEH _this %1', _this]};
	private ["_playerUID_ExileKills","_killerUID","_playerKills","_dist","_options","_payload"];
	params [
		"_killed",
		"_killer",
		"_instigator"
	];
	_options = _killed getVariable ["WMS_DFO_options",[]]; //[_MissionHexaID,_playerObject,_mission,_infType] //_infType= "OPFOR","CIV_ARMED","CIV"
	if (isPlayer _instigator) then {_killer = _instigator}; //TEST
	if (isplayer _killer) then {
		_dist = (_killer distance _killed);
		_payload = [[format ["KIA %1, %2M AWAY, %3 ", toUpper(name _killed),round _dist, (_options select 3)]]];
		if (_killer == (_options select 1) || vehicle _killer == vehicle (_options select 1)) then { //multi chopper missions will become a problem so no punishment on the player, just cleanup the bodies
			if (WMS_DFO_RemoveDup) then {
				_killed removeWeapon (primaryWeapon _killed);
				_killed removeWeapon (secondaryWeapon _killed); //launcher
				removeAllWeapons _killed;
				removeBackpackGlobal _killed;
			};
			moveOut _killed;
			if !(WMS_DFO_Standalone) then { //displayKillStats needs to be client side in MPmission
				[_payload,"DFO"] remoteExec ['WMS_fnc_displayKillStats',(owner _killer)];
				//add kill count WMS_InfantryProgram/ExileMod
			}else {
				[_payload] remoteExec ['WMS_fnc_DFO_killStats',(owner _killer)];
			};
			[format ["Killed %1, %2m away, %3 ", (name _killed),round _dist, (_options select 3)]] remoteExec ['SystemChat',(owner _killer)];
			//KILL COUNT
			_playerKills = _killer getVariable ["ExileKills", 0];
			_playerKills = _playerKills+1;
			_killer setVariable ["ExileKills", _playerKills, true];
			_killerUID 	= getPlayerUID _killer;
			if (WMS_exileFireAndForget) then {
				format["addAccountKill:%1", getPlayerUID _killer] call ExileServer_system_database_query_fireAndForget;
				ExileClientPlayerKills = _playerKills;
				(owner _killer) publicVariableClient "ExileClientPlayerKills";
				ExileClientPlayerKills = nil;
			} else {
				_playerUID_ExileKills = "ExileKills_"+_killerUID;
  				profileNamespace setVariable [_playerUID_ExileKills,_playerKills];
			};
		} else {
			_killed removeWeapon (primaryWeapon _killed);
			_killed removeWeapon (secondaryWeapon _killed); //launcher
			removeAllItems _killed;
			removeAllWeapons _killed;
			removeBackpackGlobal _killed;
			removeVest _killed;
			moveOut _killed;
		};
		if !((_options select 3) == "OPFOR")then {
			//here need a selectRandom broken limbs for the _killer
			[_killer] call WMS_fnc_DFO_PunishPunks;
			_killed removeWeapon (primaryWeapon _killed);
			_killed removeWeapon (secondaryWeapon _killed); //launcher
			removeAllWeapons _killed;
			removeAllItems _killed;
			removeBackpackGlobal _killed;
			removeVest _killed;
			"SmokeShellYellow" createVehicle (position _killed);
		};
		
	} else {
		_killed removeWeapon (primaryWeapon _killed);
		_killed removeWeapon (secondaryWeapon _killed); //launcher
		removeAllItems _killed;
		removeAllWeapons _killed;
		removeBackpackGlobal _killed;
	};
};
WMS_fnc_DFO_infLoad = { //easy way: _unit moveInCargo _chopper;
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_infLoad _this %1', _this]};
	params [
		"_vehiceObject",
		"_pilotObject"
	];
	private _Units = _pilotObject getVariable ["WMS_DFO_UnitsToManage", []];
	{
		if (alive _x) then {
			_x assignAsCargo _vehiceObject;
			_x setUnitPos "AUTO";
			_x allowDamage true;
		};
	}forEach _Units;
	if (surfaceIsWater (position _vehiceObject)) then {
		{_x moveInCargo _vehiceObject}forEach _units;
	}else {
		if (side (_units select 0) == WEST ) then { //That would be "airassault"
			{_x moveInAny _vehiceObject}forEach _units;
		}else{
			_Units orderGetIn true;
		};
	};	
}; 
WMS_fnc_DFO_infUnLoad = { //easy way: moveOut _unit;
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_infUnLoad _this %1', _this]};
	params [
		"_vehiceObject",
		"_pilotObject"
	];
	{
		if (!(isPlayer _x) && {group _x != group _pilotObject}) then {
			moveOut _x;
			//[_vehiceObject] call AR_Rappel_All_Cargo; //need to test on dedi
			unassignVehicle _x;
			if (side _x == BLUFOR && {_x == Leader _x})then {;
				[group _x, position _x, 75, 5, "MOVE", "AWARE", "RED", "NORMAL", "COLUMN", "", [1,2,3]] call CBA_fnc_taskPatrol;
			}
		};
	}forEach crew _vehiceObject;
};
WMS_fnc_DFO_CallForCleanup = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_CallForCleanup _this %1', _this]};
	params ["_MissionHexaID","_playerObject","_mkrName","_mission","_MissionPathCoord"];
	private _result = []; 
	{ 
		_found = _x find _MissionHexaID;
		_result pushback _found;
	}forEach WMS_DFO_Running;
	_DFOeventArrayRef = _result find 9; //NOT 0 FOR THIS ONE

	if (_DFOeventArrayRef == -1) exitWith {if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_CallForCleanup MissionID %1 doesnt exist, result', _MissionHexaID,_result]};};
	private _DFOeventArray = WMS_DFO_Running select _DFOeventArrayRef;
	[_DFOeventArray]spawn {
		uisleep 15;
		(_this select 0) call WMS_fnc_DFO_Cleanup;
	};
};
WMS_fnc_DFO_RinforceCleanup = { //["HexaID", time to delete, [_grps], [_vhls], [_objects],"","","REINF"]
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_RinforceCleanup _this %1', _this]};
	private ["_HexaID","_timer","_grps","_vhls","_objects"];
	_HexaID = (_this select 0); //""
	_timer 	= (_this select 1); //number
	_grps 	= (_this select 2); //[]
	_vhls 	= (_this select 3); //[]
	_objects = (_this select 4); //[]

	if (time > _timer) then {
		//maybe add a player distance check before
		{
			{deleteVehicle _x;} forEach (units _x);
			deleteGroup _x;
		} forEach _grps;
		{deleteVehicle _x;} forEach _vhls;
		{deleteVehicle _x;} forEach _objects;
		WMS_DFO_Running deleteAt (WMS_DFO_Running find _this);
	};
		
};
WMS_fnc_DFO_Cleanup = {
	if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup _this %1', _this]};
	private [
		"_timeToDelete","_grpArrays","_grpOPFOR","_grpCIV","_vhl","_vhlOPFOR","_vhlCIV","_obj","_mkr","_cargo",
		"_mission","_passenger","_options","_MissionFinish","_succes","_cntOPFOR","_cntVhlOPFOR","_cntCIV","_playerObject"
		];
	_timeToDelete 	= (_this select 1);
	_grpArrays 		= (_this select 2); //[[],[]]
	_grpOPFOR 		= _grpArrays select 0; //[]
	_grpCIV 		= _grpArrays select 1; //[]
	_vhl 			= (_this select 3); //[[],[]]
	_vhlOPFOR 		= _vhl select 0; //[]
	_vhlCIV 		= _vhl select 1; //[]
	_obj 			= (_this select 4); //[mines, signs, triggers, Jump Target, whatever]
	_mkr 			= (_this select 5); //[]
	_cargo 			= (_this select 6); //object //no waypoints, can be used for the cargoObject
	_options 		= (_this select 8); //[_MissionHexaID,_playerObject,_mission,_MissionPathCoord] //_MissionFinish should be (_MissionPathCoord select 2)
	_playerObject 	=  _options select 1;
	_mission 		= _options select 2;
	_MissionFinish 	= _options select 5;
	_succes 		= false;
	_cntOPFOR 		= 0;
	_cntVhlOPFOR 	= 0;
	_cntCIV 		= 0;
	_passenger 		= 0;
	{
		_cntOPFOR = _cntOPFOR + ({alive _x} count units _x);
	} foreach _grpOPFOR;
	{
		_cntCIV = _cntCIV + ({alive _x} count units _x);
		_passenger = _cntCIV + ({vehicle _x != _x} count units _x);
	} foreach _grpCIV;
	switch (_mission) do {
		case "inftransport": { //CIV Alive at _MissionFinish, _cntCIV != 0
			if(_cntCIV != 0 && {(position (leader (_grpCIV select 0))) distance _MissionFinish < 30}) then {_succes = true};
		};
		case "cargotransport": { //_cargo at _MissionFinish, alive _cargo
			if(alive _cargo && {(position _cargo) distance _MissionFinish < 12.5}) then {_succes = true};
		};
		case "casinf": { //mission (LZ1) succes wen target destroyed, No RTB/LZ2, _cntOPFOR = 0
			if(_cntOPFOR == 0 && {_cntVhlOPFOR == 0}) then {_succes = true};
		};
		case "casarmored": { //mission (LZ1) succes wen target destroyed, No RTB/LZ2, _cntOPFOR = 0
			if (count _vhlOPFOR != 0) then {
				{if(alive _x)then{_cntVhlOPFOR = _cntVhlOPFOR+1}}forEach _vhlOPFOR;
			};
			if(_cntOPFOR == 0 && {_cntVhlOPFOR == 0}) then {_succes = true};
		};
		case "cascombined": { //mission (LZ1) succes wen target destroyed, No RTB/LZ2, _cntOPFOR = 0
			if (count _vhlOPFOR != 0) then {
				{if(alive _x)then{_cntVhlOPFOR = _cntVhlOPFOR+1}}forEach _vhlOPFOR;
			};
			if(_cntOPFOR == 0 && {_cntVhlOPFOR == 0}) then {_succes = true};
		};
		case "sar": { //"LZ1"->"BASE" succes wen passenger at _MissionFinish, _cntCIV != 0
			if(_cntCIV != 0 && {(position (leader (_grpCIV select 0))) distance _MissionFinish < 25}) then {_succes = true};
		};
		case "csar": { //"LZ1"->"BASE" succes wen passenger at _MissionFinish, no need to kill OPFOR, _cntCIV != 0
			if(_cntCIV != 0 && {(position (leader (_grpCIV select 0))) distance _MissionFinish < 25}) then {_succes = true};
		};
		case "airassault": { //destroy target or capture zone at _MissionFinish, _cntOPFOR = 0, _vhlOPFOR != alive //the capture will do a "call for Cleanup/victory"
			if (count _vhlOPFOR != 0) then {
				{if(alive _x)then{_cntVhlOPFOR = _cntVhlOPFOR+1}}forEach _vhlOPFOR;
			};

			if(_cntOPFOR == 0 && {_cntVhlOPFOR == 0} && {_cntCIV != 0}) then {_succes = true};
		};
		case "maritime": { //this one will definitly need way more work
		};
	};
	//WMS_DFO_MarkerToDelete, WMS_DFO_TriggerToDelete, WMS_DFO_ObjectToDelete could be pushBack too
	if (_succes == true || time >= _timeToDelete) then {
		private _MarkerToDelete = missionNameSpace getVariable ["WMS_DFO_MarkerToDelete",[]];
		if (count _MarkerToDelete != 0) then {
			private _result = []; 
			{ 
				_found = _x find (_options select 0);
				_result pushback _found;
			}forEach _MarkerToDelete;
			_MarkerToDeleteRef = _result find 0;
			if (_MarkerToDeleteRef != -1) then {
				private _MarkerToDeleteData = _MarkerToDelete select _MarkerToDeleteRef;
				if (count _MarkerToDeleteData == 2) then {
					if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup _MarkerToDeleteData %1', _MarkerToDeleteData]};
					deleteMarker (_MarkerToDeleteData select 1);
					_MarkerToDelete deleteAt _MarkerToDeleteRef;
					missionNameSpace setVariable ["WMS_DFO_MarkerToDelete",_MarkerToDelete];
				};
			}else{
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup Mission HexaID not found %1 in %2', (_options select 0),_MarkerToDelete]};
			};
		}else{
			if (WMS_fnc_DFO_LOGs) then {'|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup No Marker to Delete'};
		};

		private _TriggerToDelete = missionNameSpace getVariable ["WMS_DFO_TriggerToDelete",[]]; // [[_MissionHexaID,_triggName]]
		if (count _TriggerToDelete != 0) then {
			private _result = []; 
			{ 
				_found = _x find (_options select 0);
				_result pushback _found;
			}forEach _TriggerToDelete;
			_TriggerToDeleteRef = _result find 0;
			if (_TriggerToDeleteRef != -1) then {
				private _TriggerToDeleteData = _TriggerToDelete select _TriggerToDeleteRef;
				if (count _TriggerToDeleteData == 2) then {
					if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup _TriggerToDeleteData %1', _TriggerToDeleteData]};
					missionNameSpace setVariable ["WMS_DFO_TriggerToDelete",_TriggerToDelete];
					deleteVehicle  (_TriggerToDeleteData select 1);
					_TriggerToDelete deleteAt _TriggerToDeleteRef;
				};
			}else{
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup Mission HexaID not found %1 in %2', (_options select 0),_TriggerToDelete]};
			};
		}else{
			if (WMS_fnc_DFO_LOGs) then {'|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup No Trigger to Delete'};
		};

		//Units/Groups spawned at LZ2 will also need a custom cleanup
		private _ObjectToDelete = missionNameSpace getVariable ["WMS_DFO_ObjectToDelete",[]]; // [[_MissionHexaID,_triggName]]
		if (count _ObjectToDelete != 0) then {
			private _result = []; 
			{ 
				_found = _x find (_options select 0);
				_result pushback _found;
			}forEach _ObjectToDelete;
			_ObjectToDeleteRef = _result find 0;
			if (_ObjectToDeleteRef != -1) then {
				private _ObjectToDeleteData = _ObjectToDelete select _ObjectToDeleteRef;
				if (count _ObjectToDeleteData == 2) then {
					if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup _ObjectToDeleteData %1', _ObjectToDeleteData]};
					missionNameSpace setVariable ["WMS_DFO_ObjectToDelete",_ObjectToDelete];
					{deleteVehicle _x}forEach (_ObjectToDeleteData select 1);
					_ObjectToDelete deleteAt _ObjectToDeleteRef;
				};
			}else{
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup Mission HexaID not found %1 in %2', (_options select 0),_ObjectToDelete]};
			};
		}else{
			if (WMS_fnc_DFO_LOGs) then {'|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup No Object to Delete'};
		};
		/*private _vehiclesToDelete = missionNameSpace getVariable ["WMS_DFO_VehiclesToDelete",[]]; // [[_MissionHexaID,_triggName]]
		if (count _vehiclesToDelete != 0) then {
			private _result = []; 
			{ 
				_found = _x find (_options select 0);
				_result pushback _found;
			}forEach _vehiclesToDelete;
			_vehiclesToDeleteRef = _result find 0;
			if (_vehiclesToDeleteRef != -1) then {
				private _vehiclesToDeleteData = _vehiclesToDelete select _vehiclesToDeleteRef;
				if (count _vehiclesToDeleteData == 2) then {
					if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup _vehiclesToDeleteData %1', _vehiclesToDeleteData]};
					missionNameSpace setVariable ["WMS_DFO_VehiclesToDelete",_vehiclesToDelete];
					{deleteVehicle _x}forEach (_vehiclesToDeleteData select 1);
					_vehiclesToDelete deleteAt _vehiclesToDeleteRef;
				};
			}else{
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup Mission HexaID not found %1 in %2', (_options select 0),_vehiclesToDelete]};
			};
		}else{
			if (WMS_fnc_DFO_LOGs) then {'|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup No Vehicles to Delete'};
		};
		//Units/Groups spawned at LZ2 will also need a custom cleanup
		private _GroupToDelete = missionNameSpace getVariable ["WMS_DFO_GroupToDelete",[]]; // [[_MissionHexaID,group]]
		if (count _GroupToDelete != 0) then {
			private _result = []; 
			{ 
				_found = _x find (_options select 0);
				_result pushback _found;
			}forEach _GroupToDelete;
			_GroupToDeleteRef = _result find 0;
			if (_GroupToDeleteRef != -1) then {
				private _GroupToDeleteData = _GroupToDelete select _GroupToDeleteRef;
				if (count _GroupToDeleteData == 2) then {
					if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup _GroupToDelete %1', _GroupToDeleteData]};
					missionNameSpace setVariable ["WMS_DFO_GroupToDelete",_GroupToDelete];
					{deleteGroup _x}forEach (_GroupToDeleteData select 1);
					_GroupToDelete deleteAt _GroupToDeleteRef;
				};
			}else{
				if (WMS_fnc_DFO_LOGs) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup Mission HexaID not found %1 in %2', (_options select 0),_GroupToDelete]};
			};
		}else{
			if (WMS_fnc_DFO_LOGs) then {'|WAK|TNA|WMS|[DFO] WMS_fnc_DFO_Cleanup No Groups to Delete'};
		};*/
		{
			{moveOut _x; deleteVehicle _x;} forEach units _x;
		} forEach _grpCIV;
		{deleteVehicle _x;} forEach _vhlOPFOR; 
		{deleteVehicle _x;} forEach _vhlCIV;
		{deleteVehicle _x;} forEach _obj; 
		{deleteMarker _x;} forEach _mkr; 
		{deleteGroup _x;} forEach _grpOPFOR; 
		{deleteGroup _x;} forEach _grpCIV;
		//deleteVehicle _cargo; //I guess cargo can stay, its not a big deal
		_playerObject setVariable ["WMS_DFO_UnitsToManage", nil];
		WMS_DFO_Running deleteAt (WMS_DFO_Running find _this); //BE SURE ABOUT THIS ONE, HexaID Check
	};
	if (_succes == true) then {
		//VICTORY!!!
		{
			{_x setDamage 1} forEach units _x;
		} forEach _grpOPFOR; 
		//send victory message and rewards
		[_playerObject,_mission]call WMS_fnc_DFO_MissionSucces;
	};
	if (time >= _timeToDelete) then {
		//FAIL!!!
		{
			{moveOut _x; deleteVehicle _x;} forEach units _x;
		} forEach _grpOPFOR;
		detach _cargo;
		deleteVehicle _cargo;
		//send fail message
		if (WMS_DFO_UseJVMF) then {["FAIL","DFO HQ",name _playerObject,0,["Dynamic Flight Ops","Mission Faild","","","","","","","",""],[],[[format ["%1:%2",(date select 3),(date select 4)],"DFO HQ","SENT"]]] call WMS_fnc_DFO_JVMF};
		if (WMS_exileToastMsg) then {
			_sessionID = _playerObject getVariable ['ExileSessionID',''];
			[_sessionID, 'toastRequest', ['ErrorTitleAndText', ['Dynamic Flight Ops', 'Mission FAILED!!!']]] call ExileServer_system_network_send_to;
		} else {
			["TaskFailed", ["Dynamic Flight Ops", "Mission FAILED!!!"]] remoteExec ["BIS_fnc_showNotification", (owner _playerObject)];
		};
	};
};
//////////
[] call WMS_fnc_DFO_createBaseAction;
if (WMS_fnc_DFO_LOGs) then {'|WAK|TNA|WMS|[DFO] WMS_DFO_Functions, System Started'};