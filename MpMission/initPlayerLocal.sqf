/**
 * initPlayerLocal.sqf
 *
 * TNA-Community
 * https://discord.gg/Zs23URtjwF
 * © 2021 {|||TNA|||}WAKeupneo
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
 */
 ///////////////////////////
 //Call mission From chopper
 ///////////////////////////
if (WMS_DFO_AceIsRunning)then{
	//ACE SELF ACTION
	private _actionDFO = ["RequestDFOmission","Request DFO Mission","",{
		if (WMS_DFO_UsePilotsList)then{
			if((getPlayerUID player) in WMS_DFO_PilotsList)then{
				[player,selectRandom WMS_DFO_ObjToAddAction] remoteExec ['WMS_fnc_Event_DFO', 2];
				hint 'Contacting Air Operations HQ';
			}else{
				hint 'DFO only for selected pilots, contact admins';
			};
		}else{
			[player,selectRandom WMS_DFO_ObjToAddAction] remoteExec ['WMS_fnc_Event_DFO', 2];
			hint 'Contacting Air Operations HQ';
		};
	},{
		(alive player) &&
		{vehicle player isKindOf "helicopter"} &&
		{count WMS_DFO_BasePositions != 0} &&
		{count WMS_DFO_ObjToAddAction != 0} &&
		{(count WMS_DFO_Running) < WMS_DFO_MaxRunning} &&
		{time > (WMS_DFO_LastCall+WMS_DFO_CoolDown)}
		}
	] call ace_interact_menu_fnc_createAction;
	[player, 1, ["ACE_SelfActions"], _actionDFO] call ace_interact_menu_fnc_addActionToObject;
}else {
	//REGULAR ADDACTION
	player addAction [
		"<t size='1' color='#4bff1a'>Request DFO Mission</t>", {
			if (WMS_DFO_UsePilotsList)then{
				if((getPlayerUID player) in WMS_DFO_PilotsList)then{
					[player,selectRandom WMS_DFO_ObjToAddAction] remoteExec ['WMS_fnc_Event_DFO', 2];
					hint 'Contacting Air Operations HQ';
				}else{
					hint 'DFO only for selected pilots, contact admins';
				};
			}else{
				[player,selectRandom WMS_DFO_ObjToAddAction] remoteExec ['WMS_fnc_Event_DFO', 2];
				hint 'Contacting Air Operations HQ';
			};
		}, 
		nil, 
		1, 
		true, 
		true, 
		"", 
		"
			(alive player) &&
			{vehicle player isKindOf 'helicopter'} &&
			{count WMS_DFO_BasePositions != 0} &&
			{count WMS_DFO_ObjToAddAction != 0} &&
			{(count WMS_DFO_Running) <= WMS_DFO_MaxRunning} &&
			{time > (WMS_DFO_LastCall+WMS_DFO_CoolDown)}
		",  
		5, 
		false 
	];
};