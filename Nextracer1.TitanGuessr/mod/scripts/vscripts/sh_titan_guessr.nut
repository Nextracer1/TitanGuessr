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
    "sp_crashsite", 
    "sp_beacon", 
    "sp_beacon" ]

 global array<vector> locations = [ 
    <10105.51, -1051.07, 6461.09>, 
    Vector( -1388.07, -3677.17, -3051.97 ), // !? 
    Vector( -4682.75, 4092.43, 1227.92 ) , 
    <12111.38, -2976.18, 991.26>, 
    <4899.49, -1990.74, 4016.60> ]
 

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
        found = ( Distance( player.GetOrigin(), target ) < 225 )
        wait 0.1
    }


    // player found location
    #if SERVER

    Dev_PrintMessage( player, "#FOUND_LOCATION", "", 1000000 )

    for ( int i = 0; i < 5; i++ )
    {
        EmitSoundOnEntity( player, "Pilot_Killed_Indicator" )
        wait 0.01
    }


    // create guy as a marker
    entity bloke = CreatePropScript( PILOT_GHOST_MODEL, <locations[round].x, locations[round].y, locations[round].z - 55>, -player.GetAngles(), 0 )
    SetTeam( bloke, player.GetTeam() )
    Highlight_SetFriendlyHighlight( bloke, "enemy_sonar" ) // interact_object_los_line 

    #endif


    // increment round
    SetConVarInt( "guessr_round", GetConVarInt( "guessr_round" ) + 1 )
}