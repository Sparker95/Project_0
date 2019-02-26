loc_fnc_isLocation =
{
	params [["_loc", objNull, [objNull]]];
	private _name = _loc getVariable ["l_name", nil];
	if (isNil "_name") then	{ false } else { true };
};

loc_fnc_getType =
{
	/*
	Gets the type of location
	*/
	params ["_loc"];
	private _return = _loc getVariable ["l_type", 0];
	_return
};


loc_fnc_getMainGarrison =
{
	params ["_loc"];
	private _return = _loc getVariable ["l_garrison_main", objNull];
	_return
};

loc_fnc_getMaxInfantryCapacity =
{
	params ["_loc"];
	private _return = _loc getVariable ["l_inf_capacity", objNull];
	_return
};

loc_fnc_getPatrolWaypoints =
{
	params ["_loc"];
	private _return = _loc getVariable ["l_patrol_wp", objNull];
	_return
};

loc_fnc_getBoundingRadius =
{
	/*
	Gets the radius of a circle inside which the whole location border will fit.
	*/
	params ["_loc"];
	private _return = _loc getVariable ["l_boundingRadius", objNull];
	_return
};

loc_fnc_setMainTemplate =
{
	/*
	Sets the template for the main garrison
	*/
	params ["_loc", "_template"];
	_loc setVariable ["l_template_main", _template];
};

loc_fnc_getName =
{
	params ["_loc"];
	private _return = _loc getVariable ["l_name", "ERROR: No location"];
	_return
};

/*
loc_fnc_setAlertStateInternal =
{
	params ["_loc", "_alertState"];
	_loc setVariable ["l_alertStateInternal", _alertState, false];
};

loc_fnc_setAlertStateExternal =
{
	params ["_loc", "_alertState"];
	_loc setVariable ["l_alertStateExternal", _alertState, false];
};
*/

loc_fnc_setForceSpawnTimer =
{
	params ["_loc", "_value"];
	_loc setVariable ["l_forceSpawnTimer", _value, false];
};

loc_fnc_getEnemiesScriptHandle =
{
	params ["_loc"];
	private _return = _loc getVariable ["l_oAIEnemiesScript", objNull];
	_return
};

loc_fnc_getAlertState =
{
	params ["_loc"];
	_loc getVariable ["l_alertState", LOC_AS_none];
};