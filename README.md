# WMS_DFO_Standalone
v0.1_2022APR29_GitHub<br/>

	The DFO idea from Iceman/Project Hatchet Discord (https://discord.gg/YsRWVPvNeF) <br/>
	was pretty close to mine when I built the module WMS_Event_ReconMission last year, which is running very basic and will probably stay this way.<br/>
	So there is the the "Chopper only" version, player (pilots?) activated and "repeatable".<br/>
	Standalone version will come after, when everything will be running fine.<br/>
	1-Build the skeleton to fit in the existing WMS_InfantryProgram framework<br/>
	2-Create a basic empty mission (probably "cargotransport") to test the call/spawn/triggers/succes/fail/cleanup<br/>
	3-Build and test each mission one by one<br/>
	4-Export a Standalone version<br/>


You can launch it from:<br/>
WMS_initSystem (not Standalone)<br/>
or initServer:<br/>
if (true)then {execVM "WMS_DFO_functions.sqf"};<br/>
On dedicated server you need:
in CfgRemoteExec.sqf :
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
in Description.ext :
	class CfgNotifications
	{
		class TaskSucceeded
		{
			title = "%1";
			iconPicture = "\A3\ui_f\data\map\MapControl\taskicondone_ca.paa";
			description = "%2";
			duration = 5; //
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


## License

&copy; 2022 {|||TNA|||}WAKeupneo

For any part of this work for which the license is applicable, this work is licensed under the [Attribution-NonCommercial-NoDerivatives 4.0 International](http://creativecommons.org/licenses/by-nc-nd/4.0/) license. See LICENSE.CC-BY-NC-ND-4.0.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" /></a>

Any part of this work for which the CC-BY-NC-ND-4.0 license is not applicable is licensed under the [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/2.0/). See LICENSE.MPL-2.0.

Any part of this work that is known to be derived from an existing work is licensed under the license of that existing work.