
#define GARRISON_TYPE_GENERAL		"general"
#define GARRISON_TYPE_AIR			"air"
#define GARRISON_TYPE_ANTIAIR		"antiair"
#define GARRISON_TYPE_PLAYER		"player"
#define GARRISON_TYPE_AMBIENT		"ambient"
#define GARRISON_TYPE_MILITANT		"militant"
#define GARRISON_TYPES_ALL			[GARRISON_TYPE_GENERAL, GARRISON_TYPE_AIR, GARRISON_TYPE_PLAYER, GARRISON_TYPE_AMBIENT, GARRISON_TYPE_MILITANT, GARRISON_TYPE_ANTIAIR]
// Garrison types that use automatic spawning logic (e.g. nearby players / enemies)
#define GARRISON_TYPES_AUTOSPAWN	[GARRISON_TYPE_GENERAL, GARRISON_TYPE_PLAYER, GARRISON_TYPE_MILITANT, GARRISON_TYPE_ANTIAIR]
#define GARRISON_TYPES_CMDR			[GARRISON_TYPE_GENERAL, GARRISON_TYPE_AIR, GARRISON_TYPE_ANTIAIR]
#define GARRISON_TYPES_AI			[GARRISON_TYPE_GENERAL, GARRISON_TYPE_AIR, GARRISON_TYPE_ANTIAIR]


//
#define GET_GARRISON_FROM_HELPER_OBJECT(obj) obj getVariable "garrison"