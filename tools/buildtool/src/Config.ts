export interface Preset {

    /** 
     * Path to folder with mission.sqm relative to "missionsFolder".
     * If mission.sqm is in root of "missionsFolder" should be empty string.
     * 
     * @see FolderStructureInfo.missionsFolder
    */
    readonly sourceFolder: string;

    /** 
     * Paths to custom configuration files. These are copied in place to 
     * a config directory that should be referenced by other files.
    */
    readonly configFiles: string[];

    /** 
     * Name of mission (part before mapname)
    */
    readonly missionName: string;

    readonly missionNameBase: string;

    /** 
     * Map name
    */
    readonly map: string;

    // /** 
    //  * key=>val of values to replace in config file
    //  * @see {VariablesReplacements}
    // */
    // readonly variables: VariablesReplacements;
}

export interface VariablesReplacements {
    /** Key should be name of variable as set in SQF file, its value will be replaced with one from entry. */
    readonly [key: string]: any;
}

export interface FolderStructureInfo {
    /** 
     * Folder of folders with mission.sqm.
     * Value of "sourceFolder" from Preset will be appended to this path.
     * 
     * @see {Preset}
     */
    readonly missionsFolder: string;

    /** 
     * Path to folder with mission framework files.
     */
    readonly frameworkFolder: string;
    
    /** 
     * Directory containing built missions 
     */
    readonly workDir: string;

    /*
    Directory with configuration files
    */
   readonly configDir: string;
}