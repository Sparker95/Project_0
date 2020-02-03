#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING

#include "..\..\OOP_Light\OOP_Light.h"
#include "VirtualRoute.hpp"

#define pr private

CLASS("VirtualRoute", "")

	VARIABLE_ATTR("recalculateInterval", [ATTR_PRIVATE]);

	VARIABLE_ATTR("costFn", [ATTR_PRIVATE]);
	VARIABLE_ATTR("speedFn", [ATTR_PRIVATE]);
	VARIABLE_ATTR("callbackArgs", [ATTR_PRIVATE]);

	VARIABLE_ATTR("route", [ATTR_PRIVATE]);
	VARIABLE_ATTR("pos", [ATTR_PRIVATE]);
	VARIABLE_ATTR("nextIdx", [ATTR_PRIVATE]);
	VARIABLE_ATTR("currSpeed_ms", [ATTR_PRIVATE]);

	VARIABLE_ATTR("stopped", [ATTR_PRIVATE]);
	VARIABLE_ATTR("last_t", [ATTR_PRIVATE]);

	VARIABLE_ATTR("from", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("destination", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("calculated", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("failed", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("waypoints", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("complete", [ATTR_GET_ONLY]);

	VARIABLE_ATTR("debugDraw", [ATTR_PRIVATE]);

	
	/*
	Method: new
	Initialize the route, and start evaluating it.
	
	Parameters: _from, _destination, _costFn, _speedFn

	_from - Position to start from (nearest road to here will be the actual starting position).
	_destination - Position to go to (nearest road to here will be the actual destination position).
	_recalculateInterval - NOT IMPLEMENTED, Optional,.recalcuate the route at this interval when updating. Recommended > 60s.
	_costFn - Optional, function to override cost evaluation for route nodes.
	_speedFn - Optional, function to override convoy speed, called during update.
	_async - Optional, bool, default true. If true, calculates the route in another thread. If false, calculates the route right now.
	*/
	METHOD("new") {
		params [
			"_thisObject",
			"_from",
			"_destination",
			["_recalculateInterval", -1],
			["_costFn", ""],
			["_speedFn", ""],
			["_callbackArgs", []],
			["_async", true],
			["_debugDraw", false]
		];
		
		T_SETV("from", _from);
		T_SETV("destination", _destination);
		T_SETV("recalculateInterval", _recalculateInterval);

		T_SETV("callbackArgs", _callbackArgs);

		T_SETV("debugDraw", _debugDraw);

		if(_costFn isEqualType "") then {
			pr _default_costFn = {
				params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute", "_callbackArgs"];
				_base_cost
			};
			T_SETV("costFn", _default_costFn);
		} else {
			T_SETV("costFn", _costFn);
		};

		if(_speedFn isEqualType "") then {
			pr _default_speedFn = {
				params ["_road", "_next_road", "_callbackArgs"];
#ifdef CMDR_AI_TESTING
				300
#else
				if([_road] call misc_fnc_isHighWay) exitWith {
					60 * 0.277778
				};
				40 * 0.277778
#endif
			};
			T_SETV("speedFn", _default_speedFn);
		} else {
			T_SETV("speedFn", _speedFn);
		};

		T_SETV("calculated", false);
		T_SETV("failed", false);

		T_SETV("route", []);
		T_SETV("waypoints", []);
		T_SETV("pos", []);
		T_SETV("nextIdx", 0);

		T_SETV("stopped", true);
		T_SETV("last_t", time);

		T_SETV("complete", false);

		T_SETV("currSpeed_ms", 0);

		// Function that calculates the route
		pr _calcRoute = {
			params ["_thisObject"];

			T_PRVAR(from);
			T_PRVAR(destination);
			T_PRVAR(costFn);
			T_PRVAR(callbackArgs);
			T_PRVAR(debugDraw);

			private _startRoute = [_from, 2000, gps_blacklistRoads] call bis_fnc_nearestRoad;
			private _endRoute = [_destination, 2000, gps_blacklistRoads] call bis_fnc_nearestRoad;

			if (isNull _endRoute or isNull _startRoute) exitWith {
				T_SETV("failed", true);
			};

			// TODO: either add a way to remove fake nodes again OR just use the nearest node instead of adding fake ones
			[_startRoute] call gps_core_fnc_insertFakeNode;
			[_endRoute] call gps_core_fnc_insertFakeNode;

			try {
				// This gets the node to node path.
				// TODO: add cancellation token so we can cancel route calulation on delete (token = array wrapping a bool)
				private _path = [_startRoute,_endRoute,_costFn,"",_callbackArgs] call gps_core_fnc_generateNodePath;
				if(count _path < 2) then { // Replaced <=1 with <1 because it might make one waypoint if it's not too far to traverl
					// TODO: this could do something more intelligent. Probably ties in with travel to and from actual roads.
					throw "failed";
				};
				// This fills in all the actual roads between the nodes.
				private _fullPath = [_path] call gps_core_fnc_generatePathHelpers;

				T_SETV("route", _fullPath);

				// Generating waypoints for AI navigation
				private _waypoints = [getPos (_fullPath select 0)];
				private _last_junction = 0;
				for "_i" from 0 to count _fullPath - 1 do {
					private _current = _fullPath select _i;
					if(count ([gps_allCrossRoadsWithWeight, str _current] call misc_fnc_hashTable_find) > 1) then
					{
						_waypoints pushBack (getPos (_fullPath select floor((_i + _last_junction)/2)));
						_last_junction = _i;
					};
				};
				_waypoints pushBack getPos (_fullPath select (count _fullPath - 1));

				T_SETV("waypoints", _waypoints);

				T_SETV("nextIdx", 1);
				T_SETV("pos", getPos (_fullPath select 0));

				T_PRVAR(speedFn);

				// Speed for first section
				pr _currSpeed_ms = [_fullPath select 0, _fullPath select 1, _callbackArgs] call _speedFn;
				T_SETV("currSpeed_ms", _currSpeed_ms);
				
#ifndef RELEASE_BUILD
				if(_debugDraw) then {
					T_CALLM("debugDraw", []);
				};
#endif
				// Set it last
				T_SETV("calculated", true);
			} catch {
				T_SETV("failed", true);
			};
		};

		// Calculate the route right now or asynchronously?
		if (_async) then {
			[_thisObject] spawn _calcRoute;
		} else {
			[_thisObject] call _calcRoute;
		};
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		T_CALLM("waitUntilCalculated", []);

		T_PRVAR(debugDraw);
		if(_debugDraw) then {
			T_CALLM("clearDebugDraw", []);
		};
	} ENDMETHOD;

	METHOD("waitUntilCalculated") {
		params [P_THISOBJECT];
		// Make sure calculation is terminated. If it isn't then we must have run it async, so we should be 
		// able to wait for it I guess?
		if(!T_GETV("calculated") and !T_GETV("failed")) then {
			waitUntil {
				T_GETV("calculated") or T_GETV("failed")
			};
		};
	} ENDMETHOD;

	/*
	Method: start
	Start moving during process calls.
	*/
	METHOD("start") {
		params ["_thisObject"];

		T_SETV("stopped", false);
		T_SETV("last_t", time);
	} ENDMETHOD;

	/*
	Method: stop
	Stop moving during process calls.
	*/
	METHOD("stop") {
		params ["_thisObject"];

		T_SETV("stopped", true);
		T_SETV("last_t", time);
	} ENDMETHOD;

	/*
	Method: process
	Update position, moving along route. Only moves if started.
	*/
	METHOD("process") {
		params ["_thisObject"];
		
		T_PRVAR(failed);
		T_PRVAR(stopped);
		T_PRVAR(complete);
		T_PRVAR(calculated);
		if(_failed or _stopped or _complete or !_calculated) exitWith {};

		T_PRVAR(last_t);
		// Time since last update
		pr _dt = time - _last_t;
		_dt = _dt min 30; // We want to limit the max amount of distance we can travel, otherwise it will appear that AIs teleport
		T_SETV("last_t", time);

		// How far to the next node?
		T_PRVAR(pos);
		T_PRVAR(nextIdx);
		T_PRVAR(route);
		pr _nextPos = getPos (_route select _nextIdx);
		pr _nextDist = _pos distance _nextPos;

		// How far will should we travel?
		T_PRVAR(currSpeed_ms);
		//pr _dist = _currSpeed_ms * _dt;

		// If we will reach the next node then...
		while { _currSpeed_ms * _dt >= _nextDist and _nextIdx < count _route } do {

			// Set our position to the next node.
			_pos = _nextPos;
			_nextIdx = _nextIdx + 1;
			T_SETV("nextIdx", _nextIdx);

			// If we didn't reach the end yet
			if(_nextIdx < count _route) then {
				// Reduce dt by the time it took to reach the next node
				_dt = _dt - _nextDist / _currSpeed_ms;

				// Update speed for the next section
				T_PRVAR(speedFn);
				_currSpeed_ms = [_route select _nextIdx - 1, _route select _nextIdx] call _speedFn;
				T_SETV("currSpeed_ms", _currSpeed_ms);

				_nextPos = getPos (_route select _nextIdx);
				_nextDist = _pos distance _nextPos;

				// Delete this position from the waypoint array (if it is in the waypoint array)
				pr _waypoints = T_GETV("waypoints");
				if ((_waypoints#0) isEqualTo _nextPos) then {_waypoints deleteAt 0;};
			} else {
				T_SETV("complete", true);
			};
		};

		pr _dist = _currSpeed_ms * _dt;

		// Update position
		if (_pos isEqualType objNull) then {_pos = getPos _pos}; // WTF why does it complain that _pos is object, not array??
		_pos = _pos vectorAdd (vectorNormalized (_nextPos vectorDiff _pos) vectorMultiply _dist);
		T_SETV("pos", _pos);

	} ENDMETHOD;


	/*
	Method: getConvoyPositions
	Return a set of positions and directions for convoy vehicles.

	Parameters: _number, _spacing

	_number - Number of positions to return.
	_spacing - Optional, default 20, Spacing between positions.

	Returns: Array of position, dir pairs [[pos, dir], [pos, dir], ...].
	First array element corresponds to the lead vehicle.
	*/
	METHOD("getConvoyPositions") {
		params [
			"_thisObject",
			"_number",
			["_spacing", 20]
		];
		
		// How far to the next node?
		T_PRVAR(pos);
		T_PRVAR(nextIdx);
		T_PRVAR(route);
		
		// TODO: we could return some useful defaults here instead?
		ASSERT_MSG(!T_GETV("failed"), "Route calculation failed, cannot get convoy positions");
		ASSERT_MSG(T_GETV("calculated"), "Can't call getConvoyPositions until route has finished calculating");
		
		pr _startPos = getPos (_route select 0);

		private _convoyPositions = [];

		// If we didn't move enough for the convoy to fit going back from current position
		// we will go forward from start.
		if(_pos distance _startPos < _spacing * _number) then {
			pr _currPos = _startPos;
			pr _index = 0;
			pr _nextPos = getPos (_route select (_index + 1));
			for "_i" from 0 to (_number-1) do {
				_convoyPositions pushBack [_currPos, _currPos getDir _nextPos];
				pr _distNext = _currPos distance _nextPos;
				pr _distRemaining = _spacing;
				while {_distRemaining >= _distNext} do {
					_distRemaining = _distRemaining - _distNext;
					_index = _index + 1;
					_currPos = _nextPos;
					_nextPos = getPos (_route select (_index + 1));
					_distNext = _currPos distance _nextPos;
				};
				_currPos = _currPos vectorAdd (vectorNormalized (_nextPos vectorDiff _currPos) vectorMultiply _distRemaining);
			};
			reverse _convoyPositions;
		} else {
			pr _currPos = _pos;
			pr _index = _nextIdx - 1;
			pr _prevPos = getPos (_route select _index);
			for "_i" from 0 to (_number-1) do {
				_convoyPositions pushBack [_currPos, _prevPos getDir _currPos];
				pr _distPrev = _currPos distance _prevPos;
				pr _distRemaining = _spacing;
				while {_distRemaining >= _distPrev} do {
					_distRemaining = _distRemaining - _distPrev;
					_index = _index - 1;
					_currPos = _prevPos;
					_prevPos = getPos (_route select _index);
					_distPrev = _currPos distance _prevPos;
				};
				_currPos = _currPos vectorAdd (vectorNormalized (_prevPos vectorDiff _currPos) vectorMultiply _distRemaining);
			};
		};

		_convoyPositions
	} ENDMETHOD;

	/*
	Method: debugDraw
	Draw route and waypoints on map.

	Parameters: _routeColor, _waypointColor

	_routeColor - color to use to draw the route path.
	_waypointColor - color to use to draw waypoints
	*/
	METHOD("debugDraw") {
		params [
			"_thisObject",
			["_routeColor", "ColorBlack"],
			["_waypointColor", "ColorBlack"]
		];
		
		CALLM0(_thisObject, "clearDebugDraw");

		T_PRVAR(route);

		pr _path_pos = _route apply { getPos _x };
		pr _seg_positions = [_path_pos, 20] call gps_core_fnc_RDP;

		for "_i" from 0 to (count _seg_positions - 2) do
		{
			private _start = _seg_positions select _i;
			private _end = _seg_positions select (_i + 1);
			[
				["start", _start],
				["end", _end],
				["color", _routeColor],
				["size", 8],
				["id", "gps_route_" + _thisObject + str _start + str _end]
			] call gps_test_fnc_mapDrawLine; 
		};

		 T_PRVAR(waypoints);
		 {
		 	[_x, "gps_waypoint_" + _thisObject + str _x, _waypointColor, "mil_dot"] call gps_test_fn_mkr;
		 } forEach _waypoints;
	} ENDMETHOD;

	/*
	Method: clearDebugDraw
	Clear debug markers for this route.
	*/
	METHOD("clearDebugDraw") {
		params ["_thisObject"];
		["gps_route_" + _thisObject] call gps_test_fn_clear_markers;
		["gps_waypoint_" + _thisObject] call gps_test_fn_clear_markers;
	} ENDMETHOD;

	/*
	Method: clearAllDebugDraw
	Clear debug markers for all routes.
	*/
	STATIC_METHOD("clearAllDebugDraw") {
		["gps_route_"] call gps_test_fn_clear_markers;
		["gps_waypoint_"] call gps_test_fn_clear_markers;
	} ENDMETHOD;

	/*
	Method: getPos
	Returns: current position
	*/
	METHOD("getPos") {
		params ["_thisObject"];
		T_GETV("pos")
	} ENDMETHOD;

	/*
	Method: sets the current position to the nearest position along the route.
	Returns: nothing
	*/
	METHOD("setPos") {
		params ["_thisObject", ["_pos", [], [[]]] ];

		if (T_GETV("calculated")) then {
			// Find the nearest pos in the route and its index
			pr _route = T_GETV("route");
			pr _i = 0;
			pr _count = count _route;
			pr _index = 0;
			pr _dist = (getPos (_route#0)) distance2D _pos;
			while {_i < _count} do {
				pr _p = getPos (_route#_i);
				pr _d = _p distance2D _pos;
				if (_d < _dist) then {_dist = _d; _index = _i;};
				_i = _i + 1;
			};

			// Set pos and next index
			if (_index != (_count - 1)) then { // Select the next position, so that we don't need to drive one node backwards
				_index = _index + 1;
			};
			T_SETV("nextIdx", _index);
			T_SETV("pos", getPos (_route select _index));

			// Search the route from start and delete all waypoints until this point
			_i = 0;
			pr _waypoints = T_GETV("waypoints");
			while {_i <= _index} do {
				pr _p = getPos (_route#_i);
				pr _wpid = _waypoints findIf {_x isEqualTo _p};
				if (_wpid != -1) then {
					_waypoints deleteAt _wpid;
				};
				_i = _i + 1;
			};
		} else {
			// We want to set a position before it has actually been calculated
			// It's not good but probably we can just ignore this because it means we haven't gone too far away
		};
	} ENDMETHOD;

	/*
	Method: getAIWaypoints
	Returns: array of waypoints for AI navigation, taking account the current position
	*/
	METHOD("getAIWaypoints") {
		params ["_thisObject"];
		T_GETV("waypoints")
	} ENDMETHOD;

ENDCLASS;
