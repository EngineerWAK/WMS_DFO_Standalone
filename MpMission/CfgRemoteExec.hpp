class CfgRemoteExec
{
	class Functions
	{
		mode = 1; //0: no remoteExec, 1: white liste, 2: all autorized
		jip = 0;
		class WMS_fnc_DFO_Event	{ allowedTargets=2; }; //server side only, call from addAction on the DFO mission call Object
		
		class vxf_interaction_fnc_pointNetReceive		{ allowedTargets=0; };
		class vxf_interaction_fnc_pointNetSend			{ allowedTargets=0; };
		class vxf_interaction_fnc_pointCalculate		{ allowedTargets=0; };
		class vxf_interaction_fnc_pointDraw				{ allowedTargets=0; };
		class vxf_interaction_fnc_pointStart			{ allowedTargets=0; };
		class vxf_interaction_fnc_ButtonDown			{ allowedTargets=0; };
		class vxf_interaction_fnc_ButtonUp				{ allowedTargets=0; };
		class vxf_interaction_fnc_Drag					{ allowedTargets=0; };
		class vxf_interaction_fnc_DragStart				{ allowedTargets=0; };
		class vxf_interaction_fnc_DragStop				{ allowedTargets=0; };
		class vxf_interaction_fnc_KnobAnimate			{ allowedTargets=0; };
		class vxf_interaction_fnc_LeverAbimate			{ allowedTargets=0; };
		
		class vtx_uh60_cas_fnc_registerCautionAdvisory	{ allowedTargets=0; };
		class vtx_uh60_fd_fnc_updatePanel				{ allowedTargets=0; };
		class vtx_uh60_fms_fnc_interaction_pageChange	{ allowedTargets=0; };
		class vtx_uh60_flir_fnc_syncTurret				{ allowedTargets=0; };
		class vtx_uh60_hoist_fnc_canMoveHeliToHook		{ allowedTargets=0; };
		class vtx_uh60_hoist_fnc_deployhook				{ allowedTargets=0; };
		class vtx_uh60_hoist_fnc_lowerhookToGround		{ allowedTargets=0; };
		class vtx_uh60_hoist_fnc_moveHeliToHook			{ allowedTargets=0; };
		class vtx_uh60_hoist_fnc_moveHookToHeli			{ allowedTargets=0; };
		class vtx_uh60_hoist_fnc_raiseHookToHeli		{ allowedTargets=0; };
		class vtx_uh60_hoist_fnc_resetHook				{ allowedTargets=0; };
		class vtx_uh60_hoist_fnc_secureHook				{ allowedTargets=0; };
		class vtx_uh60_jvmf_fnc_receiveMessage			{ allowedTargets=0; };
		class vtx_uh60_jvmf_fnc_receiveReply			{ allowedTargets=0; };
		class vtx_uh60_mfd_fnc_switchpage				{ allowedTargets=0; };
		class vtx_uh60_engine_fnc_engineEH				{ allowedTargets=0; };

		class vtx_uh60_mfd_fnc_setpylonvalue			{ allowedTargets=0; };
		class vtx_uh60_flir_fnc_syncpilotcamera			{ allowedTargets=0; };
		class vtx_uh60_flir_fnc_setVisionMode			{ allowedTargets=0; };
		class vtx_uh60_flir_fnc_setFOV					{ allowedTargets=0; };
		class vtx_uh60_weapons_fnc_updatePylonAssignment{ allowedTargets=0; };
		class vtx_uh60_mfd_fnc_tac_sync					{ allowedTargets=0; };
		class vtx_uh60_weapons_fnc_interaction			{ allowedTargets=0; };
	};
	class Commands
	{
		mode=0;
		jip=0;
	};
};