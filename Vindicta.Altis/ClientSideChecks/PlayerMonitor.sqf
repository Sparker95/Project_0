#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "ClientChecks.rpt"
#include "..\OOP_light\OOP_light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Stimulus\Stimulus.hpp"
#include "..\AI\stimulusTypes.hpp"
#include "..\AI\Commander\LocationData.hpp"
#include "PlayerMonitor.hpp"
#include "..\CivilianPresence\CivilianPresence.hpp"

/*
Class: PlayerMonitor
Performs various periodic checks on client side.
Mainly we offload periodic heavy functions here, such as finding nearby objects.

!!!
Remember to ref-unref this object

Author: Sparker 19 September 2019
*/

// How far we need to travel from our previous pos to update the list of nearby locations
#define POS_TOLERANCE 15

// Maximum view distance to observe locations
#define LOCATION_VIEW_DISTANCE_MAX 2300

#define pr private

CLASS("PlayerMonitor", "MessageReceiverEx") ;

	VARIABLE("timer");			// Timer
	VARIABLE("timerUI");		// Timer for UI checks

	VARIABLE("prevPos");					// Previous pos when we updated nearby locations
	VARIABLE("unit");						// Unit (object handle) this is attached to
	VARIABLE("nearLocations");				// Nearby locations to return to other objects
	VARIABLE("currentLocation");			// The nearest location we are currently at
	VARIABLE("atFriendlyLocation");	// Bool, set to true if this location is friendly
	VARIABLE("currentLocations");			// Locations we are currently located at
	VARIABLE("currentGarrisonRecord");		// Garrison record at the current location
	VARIABLE("currentGarrison");			// Garrison linked to current garrison record
	VARIABLE("canBuild");

	METHOD("new") {
		params [P_THISOBJECT, P_OBJECT("_unit")];

		T_SETV("prevPos", [0 ARG 0 ARG 0]);

		T_SETV("unit", _unit);

		T_SETV("nearLocations", []);
		T_SETV("currentLocation", "");
		T_SETV("atFriendlyLocation", false);
		T_SETV("currentLocations", []);
		T_SETV("currentGarrisonRecord", "");
		T_SETV("currentGarrison", "");
		T_SETV("canBuild", false);


		// Create timer
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, "process");
		MESSAGE_SET_DATA(_msg, []);
		pr _updateInterval = 1.2;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);

		// Create another timer, for Ui checks
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, "processUI");
		MESSAGE_SET_DATA(_msg, []);
		pr _updateInterval = 1;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timerUI", _timer);

		_unit setVariable [PLAYER_MONITOR_UNIT_VAR, _thisObject];
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		// Delete the timer
		pr _timer = T_GETV("timer");
		DELETE(_timer);

		pr _timer = T_GETV("timerUI");
		DELETE(_timer);

		T_GETV("unit") setVariable [PLAYER_MONITOR_UNIT_VAR, nil];

	} ENDMETHOD;

	METHOD("getMessageLoop") {
		gMsgLoopPlayerChecks
	} ENDMETHOD;

	METHOD("process") {
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS");

		pr _unit = T_GETV("unit");

		// Are we dead already?
		if (!alive _unit) exitWith {
			// This will get unreferenced soon and will be deleted
		};

		// Update nearby locations if needed
		pr _prevPos = T_GETV("prevPos");
		pr _dist = _unit distance _prevPos;
		//if ((_dist) > POS_TOLERANCE) then { // What if new locations are created??
			OOP_INFO_0("UPDATING NEAR LOCATIONS");
			
			// Update nearby locations
			pr _posASL = getPosASL _unit;
			pr _nearLocs = CALLSM2("Location", "nearLocations", _posASL, LOCATION_VIEW_DISTANCE_MAX);
			T_SETV("nearLocations", _nearLocs);

			// Update current locations
			pr _locs = CALLSM1("Location", "getLocationsAtPos", _posASL);
			T_SETV("currentLocations", _locs);

			if (count _locs != 0) then {
				// Get the nearest location
				_locs = _locs apply {[CALLM0(_x, "getPos") distance2D _unit, _x]};
				_locs sort true; // Ascending
				pr _loc = _locs#0#1;
				T_SETV("currentLocation", _loc);

				// Check if the location has any garrisons we know about
				pr _gars = CALLM0(_loc, "getGarrisons");
				pr _garRecord = "";
				CRITICAL_SECTION { // We want a critical section here because garrison record can be easily deleted at any point
					_gars findIf {
						_garRecord = CALLM1(gGarrisonDBClient, "getGarrisonRecord", _x);
						_garRecord != ""
					};
					T_SETV("currentGarrisonRecord", _garRecord);
					if (_garRecord != "") then {
						pr _gar = CALLM0(_garRecord, "getGarrison");
						T_SETV("currentGarrison", _gar);
					};
				};
				T_SETV("canBuild", _garRecord != "");
				T_SETV("atFriendlyLocation", _garRecord != "");
			} else {
				T_SETV("currentGarrisonRecord", "");
				T_SETV("currentGarrison", "");
				T_SETV("canBuild", false);
				T_SETV("currentLocation", "");
				T_SETV("atFriendlyLocation", false);
			};
			
		//};

		// If our position has changed a lot, send msg to the server to process nearby locations and garrisons
		if (_dist > 200) then {
			pr _newPos = getPos _unit;
			REMOTE_EXEC_CALL_STATIC_METHOD("Location", "processLocationsNearPos", [_newPos], 2, false);
			REMOTE_EXEC_CALL_STATIC_METHOD("Garrison", "updateSpawnStateOfGarrisonsNearPos", [_newPos], 2, false);
		};

		// Check if we are aiming a weapon at any civilian
		pr _co = cursorTarget;
		if (vehicle _unit isEqualTo _unit) then {										// If we are on foot
			if (_co getVariable [CIVILIAN_PRESENCE_CIVILIAN_VAR_NAME, false]) then {	// If target is a civilian created by civ presence
				if (!(weaponLowered _unit) && {currentWeapon _unit != ""}) then {			// If we have a gun and it's not lowered
					if ((_co distance _unit) < 10) then {									// If civilian is close to us
						[_co, _unit] call CivPresence_fnc_aimAtCivilian;
					};
				};
			};
		};

		OOP_INFO_1("NEAR LOCATIONS: %1", T_GETV("nearLocations"));
		OOP_INFO_1("CURRENT LOCATIONS: %1", T_GETV("currentLocations"));

		T_SETV("prevPos", getPosASL _unit);
	} ENDMETHOD;

	METHOD("processUI") {
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS UI");

		pr _unit = T_GETV("unit");
		pr _locs = T_GETV("currentLocations");
		pr _loc = T_GETV("currentLocation");
		pr _garRecord = T_GETV("currentGarrisonRecord");
		if (_loc != "") then {
			// Set current location text
			pr _locDispName = CALLM0(_loc, "getDisplayName");
			pr _locDispColor = CALLM0(_loc, "getDisplayColor");
			CALLM2(gInGameUI, "setLocationText", _locDispName, _locDispColor);

			// Check if the location has any garrisons we know about
			pr _buildRes = -1;
			CRITICAL_SECTION { // We want a critical section here because garrison record can be easily deleted at any point
				if (_garRecord != "") then {
					if (IS_OOP_OBJECT(_garRecord)) then {
						_buildRes = CALLM0(_garRecord, "getBuildResources");
					};
				};
			};
			CALLM1(gInGameUI, "setBuildResourcesAmount", _buildRes);
		} else {
			CALLM1(gInGameUI, "setLocationText", "");
			CALLM1(gInGameUI, "setBuildResourcesAmount", -1);
		};
	} ENDMETHOD;

	METHOD("getCurrentLocations") {
		params [P_THISOBJECT];
		T_GETV("currentLocations")
	} ENDMETHOD;

	METHOD("getNearLocations") {
		params [P_THISOBJECT];
		T_GETV("nearLocations")
	} ENDMETHOD;

	METHOD("getCurrentGarrison") {
		params [P_THISOBJECT];
		T_GETV("currentGarrison")
	} ENDMETHOD;

	METHOD("isAtFriendlyLocation") {
		params [P_THISOBJECT];
		T_GETV("atFriendlyLocation")
	} ENDMETHOD;

	STATIC_METHOD("canUnitBuildAtLocation") {
		params [P_THISCLASS, "_unit"];
		pr _thisObject = _unit getVariable PLAYER_MONITOR_UNIT_VAR;
		if (!isNil "_thisObject") then {
			T_GETV("canBuild")
		} else {
			false
		};
	} ENDMETHOD;

	STATIC_METHOD("canUnitBuildFromInventory") {
		params [P_THISCLASS, "_unit"];
		
	} ENDMETHOD;

	STATIC_METHOD("isUnitAtFriendlyLocation") {
		params [P_THISCLASS, "_unit"];
		pr _thisObject = _unit getVariable PLAYER_MONITOR_UNIT_VAR;
		if (!isNil "_thisObject") then {
			T_GETV("atFriendlyLocation")
		} else {
			false
		};
	} ENDMETHOD;

ENDCLASS;