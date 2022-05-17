# WMS_DFO_Standalone
v1.0_2022MAY17_GitHub<br/>
	DFO Is nor ready
	
v0.1_2022APR29_GitHub<br/>

	The DFO idea from Iceman/Project Hatchet Discord (https://discord.gg/YsRWVPvNeF)
	was pretty close to mine when I built the module WMS_Event_ReconMission last year, which is running very basic and will probably stay this way.
	So there is the "Chopper only" version, player (pilots?) activated and "repeatable".
	Standalone version will come after, when everything will be running fine. (it actualy came first xD)

"Standalone" Version now include a basic mission.sqm to see how it works. But you can build your own (basically to spawn/respawn).<br/>
If you have nothing: <br/>
Launch arma3,<br/>
Open mission Editor,<br/>
Choose your map, (for example Altis)<br/>
Put a dude on the ground, (BLUFOR, otherwise you are going to get in trouble)<br/>
Save your mission:<br/>
Scenario/Save As.../MPMissions/MyAmazingMission (DO NOT BINARIZE)<br/>
ALT/TAB to your file explorer<br/>
Open: Documents\Arma 3 - Other Profiles\"YOURPROFILENAME"\mpmissions\MyAmazingMission.Altis<br/>
Copy and past CfgRemoteExec.sqf (not needed in local but do it), InitServer.sqf, Description.ext, initPlayerLocal.sqf and WMS_DFO_Functions.sqf<br/>
ALT/TAB back to arma<br/>
Click Play/Play In MultiPlayer (MP)<br/>
Click on your dude in Alpha 1-1, OK (Bottom right), Continue<br/>
Look at the map, fint the "DFO" Marker and "ALT/Left click" yourself there (teleport)<br/>
Call the mission from the screen, done.<br/>
At this point you do not have a respawn system but it does the job.<br/>

If you are building a mission.sqm:<br/>
Place your DFO Mission Object (where to call mission from, for exemple "Land_TripodScreen_01_large_F") and in the init, add:<br/>
```
if(isServer)then{
	private _ObjToAddAction = missionNameSpace getVariable ["WMS_DFO_ObjToAddAction", []];
	_ObjToAddAction pushBack this;
	missionNameSpace setVariable ["WMS_DFO_ObjToAddAction",_ObjToAddAction];
};
```
Next to the DFO Object, place an Helipad (not "Land_HelipadEmpty_F") and add in the init:<br/>
```
if(isServer)then{ 
	private _BasePositions = missionNameSpace getVariable ["WMS_DFO_BasePositions", []];
	if(surfaceIsWater position this) then {
		_BasePositions pushBack (getPosASL this);
	} else {
		_BasePositions pushBack (getPosATL this);
	}; 
	missionNameSpace setVariable ["WMS_DFO_BasePositions",_BasePositions]; 
};
```
You can have as many DFO Object as you want.<br/>

If you already have a Mission.sqm:<br/>
You can launch WMS_DFO_Standalone from:<br/>
WMS_initSystem (WMS_InfantryProgram, not Standalone).<br/>
or<br/>
in initServer:
```
if (true)then {execVM "WMS_DFO_functions.sqf"};
```
On dedicated server you need:
in CfgRemoteExec.sqf :
```
class CfgRemoteExec
{
	class Functions
	{
		mode = 1;
		jip = 0;
		class WMS_fnc_Event_DFO	{ allowedTargets=2; };
	};
	class Commands
	{
		mode=0;
		jip=0;
	};
};
```
in Description.ext :
```
class CfgNotifications
{
	class EventCustom
	{
		title = "%1";
		description = "%2";
		iconPicture = "%3";
		color[] = {0.85,0.4,0,1}; //Orange
		duration = 5;
		priority = 3;
	};
	class TaskSucceeded
	{
		title = "%1";
		iconPicture = "\A3\ui_f\data\map\MapControl\taskicondone_ca.paa";
		description = "%2";
		duration = 5;
		priority = 7;
	};
	class TaskFailed
	{
		title = "%1";
		iconPicture = "\A3\ui_f\data\map\MapControl\taskiconfailed_ca.paa";
		description = "%2";
		priority = 6;
	};
};
```
in initPlayerLocal.sqf (ACE3 Function):
```
WMS_DFO_AceIsRunning = false;
{if ("Advanced Combat Environment" in (_x select 0))then {WMS_DFO_AceIsRunning = true;}}forEach getLoadedModsInfo;
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
```
## License

&copy; 2022 {|||TNA|||}WAKeupneo

For any part of this work for which the license is applicable, this work is licensed under the [Attribution-NonCommercial-NoDerivatives 4.0 International](http://creativecommons.org/licenses/by-nc-nd/4.0/) license. See LICENSE.CC-BY-NC-ND-4.0.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" /></a>

Any part of this work for which the CC-BY-NC-ND-4.0 license is not applicable is licensed under the [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/2.0/). See LICENSE.MPL-2.0.

Any part of this work that is known to be derived from an existing work is licensed under the license of that existing work.
