/**
* WMS_DFO_init.sqf - Dynamic Flight Operations
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
*/
/*
	// from initServer
	// Start DynamicFlightOps
	if (true)then {execVM "\DFO\WMS_DFO_init.sqf"};
*/
WAK_DFO_Version			= "v1.15_2022OCT19_GitHub"; //No bohemia, a parachute is definitely not an Helicopter.
WMS_DynamicFlightOps	= true;
WMS_DFO_LOGs			= false;//For Debug
WMS_DFO_Standalone		= true; //keep true if you don't use WMS_InfantryProgram
WMS_DFO_CreateChopper	= true; //if your mission file doesn't have choppers available
WMS_DFO_Reinforcement	= true; //Each mission has it's own type of reinforcement
WMS_DFO_UseJVMF			= true; //https://github.com/Project-Hatchet/H-60
WMS_DFO_RemoveDup		= false; //delete dead NPC's primary weapon and backpack
WMS_DFO_UsePilotsList 	= false; //if you want to limit DFO use to some players
WMS_DFO_SmokeAtLZ		= true; //pop a smoke/flare on the group you have to pickUp //SAR and CSAR = false unless in water
WMS_DFO_HideLZTarget	= true; //hide the target spawned at the LZ (actualy just return it, texture only on one side)
WMS_DFO_InfUnlOverride	= false; //admins can force it "on the fly" in the console
WMS_DFO_InfUnloadType 	= 3; //0: dump, 1: land, 2: rappel (Advanced Rappeling), 3: fastrope (not yet) //this should be dynamic unless override
WMS_DFO_InfLoadType 	= 0; //0 = orderGetIn (need to land), 1 = moveInAny (no need to land but no animation)
WMS_DFO_PilotsList		= []; //Player UID, Only those players will be able to use DFO if WMS_DFO_UsePilotsList
WMS_DFO_MaxRunning		= 3; //Max missions can run in the same time
WMS_DFO_CoolDown		= 600; //time before the next mission can be called
WMS_DFO_Timer			= 1800; //timer before mission timeOut, no reset/extend
WMS_DFO_MinMaxDist		= [2000,8000]; //minimum and maximum distance the next step of the mission will be, unless "custom" position like "forest","cities", etc...
WMS_DFO_TriggMaxSpeed	= 18; //Maximum speed in the trigger to unlock the next level of the mission *1.5 for Medevac
WMS_DFO_ReinfTriggDist	= 1000; //distance trigger will call reinforcement
WMS_DFO_MkrRandomDist	= 500; //random distance to place the marker from SAR CSAR missions otherwise there is no "search"
WMS_DFO_Reward			= [500,2000,['ACE_Can_Franta','ACE_Can_RedGull','ACE_MRE_LambCurry','ACE_MRE_MeatballsPasta','ACE_bloodIV_500','ACE_morphine','ACE_quikclot']]; //["rep","money",items for chopper return]
WMS_DFO_SarSeaPosition	= "sea"; //"sea" or "random" //some maps doesnt have water
WMS_DFO_NoSeaMaps 		= ["ruha","xcam_taunus","Lythium","gm_weferlingen_summer","Enoch","tem_kujari","juju_kalahari"];
WMS_DFO_OPFORcbtMod		= "YELLOW"; //Vehicle crew only //"WHITE" : Hold fire, engage at will/loose formation //"YELLOW" : Fire at will, keep formation //"RED" : Fire at will, engage at will/loose formation
WMS_DFO_CargoType		= ["CargoNet_01_barrels_F","C_IDAP_CargoNet_01_supplies_F","CargoNet_01_box_F"];
WMS_DFO_MissionTypes	= [["inftransport","cargotransport","sar","medevac"],["airassault","casinf","casarmored","cascombined","csar"],["inftransport","cargotransport","airassault","casinf","casarmored","cascombined","csar","sar","medevac"]];// [[CHILL],[COMBAT],[RANDOM]]
WMS_DFO_Reinforcements	= ["paradrop","paradrop","paradrop","VHLpatrol","VHLpatrol","AIRpatrol","AIRassault"]; //["AIRpatrol","VHLpatrol","paradrop","AIRassault"] //TYPO!!!
WMS_DFO_NPCskills		= [0.8, 0.7, 0.2, 0.3, 0.3, 0.6, 0, 0.5, 0.5]; //"spotDistance","spotTime","aimingAccuracy","aimingShake","aimingSpeed","reloadSpeed","courage","commanding","general"
WMS_DFO_ExclusionZone	= []; //[[[x,y,z],radius],[[x,y,z],radius],[[x,y,z],radius],[[x,y,z],radius]]; will work for "random" and "sea" spawns, not for forests/locals/bases or others
/*
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
*/
//RHS/HATCHET
WMS_DFO_Choppers		= [["vtx_MH60M_DAP","vtx_MH60M_DAP_MLASS"],["vtx_HH60","vtx_MH60M","vtx_UH60M"],["B_Heli_Transport_03_unarmed_F","vtx_UH60M_SLICK"],["vtx_UH60M_MEDEVAC"]];//Hatchet
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

WMS_DFO_Markers			= ["loc_heli","mil_end_noShadow"]; //["mission","RTB"]; //["n_support","n_hq"]; //["loc_heli","mil_end_noShadow"]
WMS_DFO_MkrColors		= ["colorOrange","colorGreen","colorRed"]; //["mission","RTB", "bigDanger"];
//////////////////////////////////////////
//no change under this unless ExileMod stuff
//////////////////////////////////////////
WMS_DFO_MissionPaths	= [["BASE","LZ1","BASE"],["BASE","LZ1","LZ2"]]; // "takeoff/mission/complet" //the first "BASE" could become "AIR" if mission called during flight
WMS_DFO_LastCall		= (time-WMS_DFO_CoolDown); //PushBack
WMS_DFO_Running			= []; //KEEP EMPTY
WMS_DFO_RunReinforce	= []; //KEEP EMPTY
WMS_DFO_AceIsRunning 	= false; //Automatic //this should go in WMS_InfantryProgram
//Maps custom settings
if (worldName in WMS_DFO_NoSeaMaps) then {
	WMS_DFO_SarSeaPosition	= "random";
};
//////////////////////////////////////////
publicVariable "WMS_DFO_Running";
publicVariable "WMS_DFO_MaxRunning";
publicVariable "WMS_DFO_LastCall";
publicVariable "WMS_DFO_CoolDown";
publicVariable "WMS_DFO_UsePilotsList";
publicVariable "WMS_DFO_PilotsList";
publicVariable "WMS_DFO_MissionTypes";
publicVariable "WMS_DFO_AceIsRunning";
publicVariable "WMS_DFO_Reward";
//////////////////////////////////////////
if (WMS_DFO_Standalone) then {
	//STANDALONE MISSING VAR:
	WMS_exileFireAndForget 	= false; //ExileMod
	WMS_exileToastMsg 		= false; //ExileMod Notifications
	WMS_SeaPos 			= [];
	WMS_Roads 			= [];
	WMS_AMS_MaxGrad 	= 0.15;
	WMS_Pos_Locals 		= []; //AutoScan
	WMS_Pos_Villages	= []; //AutoScan
	WMS_Pos_Cities 		= []; //AutoScan
	WMS_Pos_Capitals 	= []; //AutoScan
	WMS_Pos_Forests 	= []; //DIY, if no position, back to random _pos
	WMS_Pos_Military 	= []; //DIY, if no position, back to random _pos
	WMS_Pos_Factory 	= []; //DIY, if no position, back to random _pos
	WMS_Pos_Custom	 	= []; //DIY, if no position, back to random _pos
	//////////////////////////////////////////
	execVM "DFO\WMS_DFO_Std.sqf";
	uisleep 3;
	[]call WMS_fnc_CollectPos;
	[]call WMS_fnc_ScanForWater;
	[]call WMS_fnc_FindRoad;
};
//////////////////////////////////////////
uisleep 10;
[] call WMS_fnc_DFO_createBaseAction;
if (true) then {diag_log format ['|WAK|TNA|WMS|[DFO] WMS_DFO_Init, System Started, %1',WAK_DFO_Version]};