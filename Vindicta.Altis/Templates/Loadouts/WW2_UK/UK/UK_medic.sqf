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
_RandomHeadgear = selectRandom ["H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed", "H_LIB_UK_Helmet_Mk2_FAK", "H_LIB_UK_Helmet_Mk2_Net", "H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed", "H_LIB_UK_Helmet_Mk2_FAK", "H_LIB_UK_Helmet_Mk2_Net", "H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed", "H_LIB_UK_Helmet_Mk2_FAK", "H_LIB_UK_Helmet_Mk2_Net", "H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed", "H_LIB_UK_Helmet_Mk2_FAK", "H_LIB_UK_Helmet_Mk2_Net", "H_LIB_UK_Helmet_Mk3", "H_LIB_UK_Helmet_Mk3_Net", "fow_h_uk_jungle_hat_01", "fow_h_uk_jungle_hat_02", "fow_h_uk_jungle_hat_03", "fow_h_uk_woolen_hat", "fow_h_uk_woolen_hat02"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_LIB_UK_P37";
/*Vest*/
_RandomVest = selectRandom ["V_LIB_UK_P37_Rifleman", "V_LIB_UK_P37_Gasmask"];
this addVest _RandomVest;
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_UK_HSack", "B_LIB_UK_HSack_Cape", "B_LIB_UK_HSack_Tea", "fow_b_uk_p37"];
this addBackpack _RandomBackpack;

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_LeeEnfield_No4", "LIB_LeeEnfield_No1"];
this addWeapon _RandomWeapon;
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_10Rnd_770x56";
_RandomAtta = selectRandom ["LIB_ACC_No4_Mk2_Bayo", ""];
this addPrimaryWeaponItem _RandomAtta;

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "LIB_10Rnd_770x56";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};
this addItemToVest "LIB_US_M18";
this addItemToVest "fow_e_mk2";
this addItemToBackpack "Medikit";
for "_i" from 1 to 3 do {this addItemToBackpack "FirstAidKit";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male02engb"] call BIS_fnc_setIdentity;
