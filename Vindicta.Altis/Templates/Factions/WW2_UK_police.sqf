
//██╗   ██╗██╗  ██╗    ██████╗  ██████╗ ██╗     ██╗ ██████╗███████╗
//██║   ██║██║ ██╔╝    ██╔══██╗██╔═══██╗██║     ██║██╔════╝██╔════╝
//██║   ██║█████╔╝     ██████╔╝██║   ██║██║     ██║██║     █████╗  
//██║   ██║██╔═██╗     ██╔═══╝ ██║   ██║██║     ██║██║     ██╔══╝  
//╚██████╔╝██║  ██╗    ██║     ╚██████╔╝███████╗██║╚██████╗███████╗
// ╚═════╝ ╚═╝  ╚═╝    ╚═╝      ╚═════╝ ╚══════╝╚═╝ ╚═════╝╚══════╝
//http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=UK%20Police

//Updated: March 2020 by Marvis


_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tWW2_UK_police"]; 										//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "WW2 UK units. 1939-1945. Made by MatrikSky"]; 	//Template display description
_array set [T_DISPLAY_NAME, "WW2 UK Police"]; 								//Template display name
_array set [T_FACTION, T_FACTION_Police]; 									//Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, [
		"ww2_assets_c_characters_core_c", 
		"lib_weapons", 
		"geistl_main", 
		"fow_weapons", 
		"sab_boat_c", 
		"ifa3_comp_ace_main", 
		"geistl_fow_main", 
		"ifa3_comp_fow", 
		"ifa3_comp_fow_ace_settings", 
		"sab_compat_ace"
		]]; 																//Addons required to play this template

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 					//Make an array full of nil
_inf set [T_INF_default, ["LIB_UK_Rifleman"]];	//Default infantry if nothing is found

_inf set [T_INF_SL, ["WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3", "WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3", "WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3"]];
_inf set [T_INF_TL, ["WW2_UK_TL", "WW2_UK_medic", "WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3", "WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3", "WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3"]];
_inf set [T_INF_officer, ["WW2_UK_officer", "WW2_UK_medic", "WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3", "WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3", "WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3"]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_DEFAULT, ["LIB_UK_Willys_MB"]];
_veh set [T_VEH_car_unarmed, ["LIB_UK_Willys_MB", "LIB_UK_Willys_MB_Hood"]];

//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];

//==== Cargo ====
_cargo = [];

_cargo set [T_CARGO_default,	["LIB_BasicWeaponsBox_US"]];
_cargo set [T_CARGO_box_small,	["LIB_BasicWeaponsBox_US"]];
_cargo set [T_CARGO_box_medium,	["LIB_BasicWeaponsBox_UK", "LIB_BasicAmmunitionBox_US"]];
_cargo set [T_CARGO_box_big,	["LIB_WeaponsBox_Big_SU"]];

//==== Groups ====
_group = +(tDefault select T_GROUP);

//==== Arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array