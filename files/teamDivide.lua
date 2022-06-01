
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-nemesis/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")
dofile_once("mods/noita-nemesis/files/scripts/utils.lua")

local teams = { "deer", "duck", "sheep", "fungus" }

local function shuffleTable( t )
	assert( t, "shuffleTable() expected a table, got nil" )
	local iterations = #t
	local j
	
	for i = iterations, 2, -1 do
		j = Random(1,i)
		t[i], t[j] = t[j], t[i]
	end
end

local function draftTable( m, n)
    local t = {}
    local j = 1
    for i=1,m do
        t[i] = j
        j = j + 1
        if (j > n) then
            j = 1
        end
    end
    return t
end

function teamDivide( divides )
    if (NEMESIS==nil) then
        return
    end
    if (NEMESIS.whoamiUserId==nil) then
        GamePrint("Please wait a moment to do this. Try to run start maybe resolve this.")
        return
    end

    if (divides ~= nil) then
        local sincestarted = GameGetRealWorldTimeSinceStarted()
        SetRandomSeed( sincestarted*128456903, GameGetFrameNum() * 101 )

        shuffleTable(teams) 

        local players = {}
        for userId, _ in pairs(PlayerList) do
            players[#players+1] = userId
        end
        shuffleTable(players) 

        local drafts = draftTable(#players+1, divides)
        shuffleTable(drafts) 

        local playerTeams = {}
        local myteam = teams[drafts[1]]
        playerTeams[1] = { id=NEMESIS.whoamiUserId, team=myteam } -- myself, because i am not in the playerlist
        local draft = 2
        for _, userId in pairs(players) do
            playerTeams[#playerTeams+1] = { id=userId, team=teams[drafts[draft]] }
            PlayerList[userId].team = teams[drafts[draft]]
			draft = draft + 1
        end

        dofile("mods/noita-nemesis-teams/files/joinAction.lua")
        join( myteam )

        local queue = json.decode(NT.wsQueue)
        table.insert(queue, {event="CustomModEvent", payload={name="NemesisTeamRequest", playerTeams=playerTeams}})
        NT.wsQueue = json.encode(queue)

    end
end
