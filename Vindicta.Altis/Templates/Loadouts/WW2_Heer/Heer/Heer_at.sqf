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
_RandomHeadgear = selectRandom ["H_LIB_GER_Helmet", "H_LIB_GER_Helmet_ns", "H_LIB_GER_Helmet_os", "H_LIB_GER_Helmet", "H_LIB_GER_Helmet_ns", "H_LIB_GER_Helmet_os", "H_LIB_GER_Helmet", "H_LIB_GER_Helmet_ns", "H_LIB_GER_Helmet_os", "H_LIB_GER_Helmet_net", "H_LIB_GER_HelmetUtility", "H_LIB_GER_Helmet_Glasses", "H_LIB_GER_Cap"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
_RandomUniform = selectRandom ["U_LIB_GER_Recruit", "U_LIB_GER_Schutze", "U_LIB_GER_Soldier2", "U_LIB_GER_Schutze_HBT", "U_LIB_GER_MG_schutze_HBT", "U_LIB_GER_MG_schutze"];
this forceAddUniform _RandomUniform;
/*Vest*/
this addVest "V_LIB_GER_VestMP40";
/*Backpack*/
this addBackpack "B_LIB_GER_Panzer_Empty";

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_MP38", "LIB_MP40"];
this addWeapon _RandomWeapon;
this addWeapon "LIB_RPzB";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_32Rnd_9x19";
this addSecondaryWeaponItem "LIB_1Rnd_RPzB";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_32Rnd_9x19";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};
for "_i" from 1 to 3 do {this addItemToBackpack "LIB_1Rnd_RPzB";};
this addItemToVest "LIB_Shg24x7";
this addItemToVest "LIB_NB39";

/*Items*/
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"Default","male04ger"] call BIS_fnc_setIdentity;
