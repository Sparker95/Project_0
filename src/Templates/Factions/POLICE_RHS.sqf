
//██████╗  ██████╗ ██╗     ██╗ ██████╗███████╗
//██╔══██╗██╔═══██╗██║     ██║██╔════╝██╔════╝
//██████╔╝██║   ██║██║     ██║██║     █████╗  
//██╔═══╝ ██║   ██║██║     ██║██║     ██╔══╝  
//██║     ╚██████╔╝███████╗██║╚██████╗███████╗
//╚═╝      ╚═════╝ ╚══════╝╚═╝ ╚═════╝╚══════╝
//http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=Police

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tPoliceRHS"]; 									//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Standard Arma police with RHS based loadouts. RHSUSF, RHSAFRF and RHSGREF required."]; 	//Template display description
_array set [T_DISPLAY_NAME, "Arma 3 Police (RHS)"]; 						//Template display name
_array set [T_FACTION, T_FACTION_Police]; 							//Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, [
	"rhs_c_troops",		// RHSAFRF
	"rhsusf_c_troops",	// RHSUSAF
	"rhsgref_c_troops" //RHSGREF due to BRDMs, UAZ with DSHKMs not existing in base AFRF
]];

//====API====
_api = []; _api resize T_API_SIZE;
_api set [T_API_SIZE-1, nil]; 										//Make an array full of nil
_api set [T_API_fnc_VEH_siren, {
	params ["_vehicle", "_siren"];
	if(typeOf _vehicle in ["B_GEN_Offroad_01_gen_F"]) then {
		private _beacon = if(typeOf _vehicle in ["B_GEN_Offroad_01_gen_F"]) then { 'beaconsstart' };
		if(_siren) then {
			[_vehicle, 'CustomSoundController1', 1, 0.2] remoteExec ['BIS_fnc_setCustomSoundController'];
			_vehicle animate [_beacon, 1, true];
		} else {
			[_vehicle, 'CustomSoundController1', 0, 0.4] remoteExec ['BIS_fnc_setCustomSoundController'];
			_vehicle animate [_beacon, 0, true];
		};
	};
}];

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 					//Make an array full of nil
_inf set [T_INF_default, ["B_GEN_Soldier_F"]];	//Default infantry if nothing is found

_inf set [T_INF_SL, ["Arma3_police_rhs_1", 1, "Arma3_police_rhs_2", 1, "Arma3_police_rhs_3", 1, "Arma3_police_rhs_4", 1, "Arma3_police_rhs_5", 1.25, "Arma3_police_rhs_6", 1.25]];
_inf set [T_INF_TL, ["Arma3_police_rhs_1", 1, "Arma3_police_rhs_2", 1, "Arma3_police_rhs_3", 1, "Arma3_police_rhs_4", 1, "Arma3_police_rhs_5", 1.25, "Arma3_police_rhs_6", 1.25]];
_inf set [T_INF_officer, ["Arma3_police_officer_rhs", 1]];

//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_DEFAULT, ["B_GEN_Offroad_01_gen_F"]];
_veh set [T_VEH_car_unarmed, ["B_GEN_Offroad_01_gen_F_1"]];

//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
_drone set [T_DRONE_SIZE-1, nil];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Groups ====
_group = +(tDefault select T_GROUP);

//==== Arrays ====
_array set [T_API, _api];
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array