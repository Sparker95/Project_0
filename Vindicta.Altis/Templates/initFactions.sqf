// Initialize factions
// This variable is necessary for other factions to initialize!
["Templates\Factions\default.sqf", T_FACTION_None]					call t_fnc_initializeTemplateFromFile;

["Templates\Factions\NATO.sqf", T_FACTION_Military]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\CSAT.sqf", T_FACTION_Military]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\AAF.sqf", T_FACTION_Military]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\GUERRILLA.sqf", T_FACTION_Police]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\POLICE.sqf", T_FACTION_Police]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\CIVILIAN.sqf", T_FACTION_Civ]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AAF2017_elite.sqf", T_FACTION_Military]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AAF2017_police.sqf", T_FACTION_Police]		call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AFRF.sqf", T_FACTION_Military]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_USAF.sqf", T_FACTION_Military]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_LDF.sqf", T_FACTION_Military]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_LDF_ranger.sqf", T_FACTION_Police]			call t_fnc_initializeTemplateFromFile;
