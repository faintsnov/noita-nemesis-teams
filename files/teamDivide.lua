
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-nemesis/files/scripts/utils.lua")

local teams = { "deer", "duck", "sheep", "fungus" }

local function shuffle(drafts, loops) 
    SetRandomSeed( GameGetFrameNum(), loops )
    for i=1,loops do
        local rnd1 = Random( 1, #drafts )
        local rnd2 = Random( 1, #drafts )
        drafts[rnd1], drafts[rnd2] = drafts[rnd2], drafts[rnd1]    
    end

    return drafts
end

function teamDivide( divides )
    if (NEMESIS==nil) then
        return
    end
    if (NEMESIS.whoamiUserId==nil) then
        GamePrint("Please wait a moment to do this.")
        return
    end

    if (divides ~= nil) then
        SetRandomSeed( divides, GameGetFrameNum() )
        local rnd1 = Random( 1, 4 )
        local rnd2 = Random( 1, 4 )
        teams[rnd1], teams[rnd2] = teams[rnd2], teams[rnd1]

        --debug GamePrint(tostring(json.encode(teams)))

        local drafts = {}
        for i=1,divides do
            drafts[i] = i
        end
        drafts = shuffle(drafts, #drafts) 

        local players = {}
        for userId, _ in pairs(PlayerList) do
            players[#players+1] = userId
        end
        players = shuffle(players, #players) 

        local playerTeams = {}
        local draft = 2
        local myteam = teams[drafts[1]]
        playerTeams[1] = { id=NEMESIS.whoamiUserId, team=myteam } -- yourself, because you are not in the playerlist
        for _, userId in pairs(players) do
            playerTeams[#playerTeams+1] = { id=userId, team=teams[drafts[draft]] }
            PlayerList[userId].team = teams[drafts[draft]]
			draft = draft + 1
            if (draft > divides) then
                draft = 1
                drafts = shuffle(drafts, divides) 
            end
        end

        dofile("mods/noita-nemesis-teams/files/joinAction.lua")
        join( myteam )

        --GamePrint(tostring(json.encode(playerTeams)))
        --json.encode(queue)

        --NEMESIS.nt_nemesis_team = team
        --GamePrintImportant("Joined the " .. team .. " team ", "Good luck")
        
        local queue = json.decode(NT.wsQueue)
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamRequest", playerTeams=playerTeams}})
        NT.wsQueue = json.encode(queue)

    end
end
