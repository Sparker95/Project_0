comment "Exported from Arsenal by MatrikSky";

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

/*Helmet*/
_RandomHeadgear = selectRandom ["H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_Ushanka", "H_LIB_SOV_Ushanka2"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_LIB_SOV_Strelok_summer";
/*Vest*/
this addVest "V_LIB_SOV_RA_PPShBelt_Mag";
/*Backpack*/
this addBackpack "B_LIB_GER_Panzer_Empty";

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_PTRD", "LIB_PTRD", "LIB_PTRD", "lib_PTRD_optic"];
this addWeapon _RandomWeapon;
this addWeapon "LIB_TT33";
/*WeaponItem*/
this addPrimaryWeaponItem "lib_1rnd_145x114";
this addHandgunItem "LIB_8Rnd_762x25";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "lib_1rnd_145x114";};
for "_i" from 1 to 3 do {this addItemToVest "LIB_1Rnd_145x114_T";};
for "_i" from 1 to 3 do {this addItemToBackpack "LIB_8Rnd_762x25";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Rg42";};
this addItemToVest "LIB_Rpg6";
this addItemToVest "LIB_RDG";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male03su"] call BIS_fnc_setIdentity;
