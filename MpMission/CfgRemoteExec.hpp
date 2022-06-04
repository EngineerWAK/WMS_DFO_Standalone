class CfgRemoteExec
{
	class Functions
	{
		mode = 1; //0: no remoteExec, 1: white liste, 2: all autorized
		jip = 0;
		class WMS_fnc_DFO_Event	{ allowedTargets=2; }; //server side only, call from addAction on the DFO mission call Object
	};
	class Commands
	{
		mode=0;
		jip=0;
	};
};