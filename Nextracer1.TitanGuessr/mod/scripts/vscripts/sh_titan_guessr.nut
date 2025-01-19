global function GuessrInit

/*
global struct Round
{
    string map
    vector location
} 
 */

 global array<string> maps = [ 
    "sp_boomtown_start", 
    "sp_boomtown_end", 
    "sp_beacon", 
    "sp_crashsite", 
    "sp_sewers1",
    "sp_timeshift_spoke02",
    "sp_beacon_spoke0",
    "sp_sewers1",
    "sp_skyway_v1",
    "sp_boomtown",
    "sp_beacon",
    "sp_tday",
    "sp_skyway_v1",
    "sp_beacon_spoke0"   ]

 global array<vector> locations = [ 
    <10105.51, -1051.07, 6461.09>, 
    Vector( -1388.07, -3677.17, -3051.97 ), 
    <12111.38, -2976.18, 991.26>, 
    Vector( -4682.75, 4092.43, 1227.92 ), // 
    <10434.30, 1542.07, 332.03>, 
    <6246.36, 2764.29, 11498.30>,
    Vector( -2757.77, 11100.29, 591.38 ),
    Vector( -1516.09, 6130.01, -248.11 ), 
    <11703.93, 11387.08, 6219.35>,
    Vector( -2258.78, 12029.29, 2484 ),
    <3940.93, -1312.24, 4407.14>, // 
    Vector( -2755.38, 1944.57, 380.03 ), //
    <12583.43, 8617.51, 4745.39>, //
    Vector( -1141.60, 3615.72, 487.55 ) ] 
 

void function GuessrInit()
{
    #if SERVER
    SetConVarInt( "developer", 1 )
    PrecacheModel( PILOT_GHOST_MODEL )
    AddCallback_OnClientConnected( StartGuessring )
    #endif
}



void function StartGuessring( entity player )
{
    int round = GetConVarInt( "guessr_round" ) - 1

    // round doesn't exist:
    if ( round >= maps.len() )
    {
        #if SERVER
        Dev_PrintMessage( player, "#INVALID_ROUND", "", 1000000 )
        #endif
    }


    // round exists:
    else 
    {
        string targetMap = maps[round]
        vector targetLocation = locations[round] 
    
        // check map
        if ( GetMapName() == targetMap )
        {
            // if map is good, now start checking for location
            thread LocationThread( player, targetLocation, round )
        }
    }
}



void function LocationThread( entity player, vector target, int round )
{
    bool found = false

    while ( !found )
    {
        found = ( Distance( player.GetOrigin(), target ) < 185 )
        wait 0.1
    }


    // player found location
    #if SERVER

    Dev_PrintMessage( player, "#FOUND_LOCATION", "", 1000000 )

    entity bloke = CreatePropScript( PILOT_GHOST_MODEL, <locations[round].x, locations[round].y, locations[round].z - 55>, -player.GetAngles(), 0 )
    SetTeam( bloke, player.GetTeam() )
    Highlight_SetFriendlyHighlight( bloke, "enemy_sonar" ) // interact_object_los_line 


    for ( int i = 0; i < 5; i++ )
    {
        EmitSoundOnEntity( player, "Pilot_Killed_Indicator" )
        wait 0.01
    }


    // increment round
    SetConVarInt( "guessr_round", GetConVarInt( "guessr_round" ) + 1 )


    // hack: loading checkpoints from before the location was found breaks things, so just force overwrite them now
    CheckPoint_ForcedSilent()

    #endif
}