function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	print('Custom Message');
 	if(payload.Message == "Peace")then
		local target = payload.TargetPlayerID;
		local preis = payload.Preis;
		if(target> 50)then
			local playerGameData = Mod.PlayerGameData;
			local existingpeaceoffers = ",";
 			if(playerGameData[target].Peaceoffers~=nil)then
				existingpeaceoffers=playerGameData[target].Peaceoffers;
			end
			local existingofferssplit = stringtotable(existingpeaceoffers);
			local num = 1;
			local match = false;
			while(existingofferssplit[num] ~=nil)do
				if(tonumber(existingofferssplit[num]) == playerID)then
					match = true;
				end
				num=num+2;
			end
			local rg = {};
			if(match == false)then
				playerGameData[target] = {Peaceoffers=existingpeaceoffers .. playerID .. "," .. preis .. ",",Money=Mod.PlayerGameData[target].Money};
				print(playerGameData[target].Peaceoffers);
				Mod.PlayerGameData=playerGameData;
				rg.Message ='The Offer has been submitted';
				setReturnTable(rg);
			else
				rg.Message ='The player has already a pending peace offer by you.';
				setReturnTable(rg);
			end
		else
			local rg = {};
			rg.Message = 'Peace to AI';
			setReturnTable(rg);
			--accept peace cause ai
		end
	else
		local rg = {};
		rg.Message = 'Fehler';
		setReturnTable(rg);
  	end
	if(payload.Message == "Accept Peace")then
		local playerGameData = Mod.PlayerGameData;
		local an = payload.TargetPlayerID;
		local preis = 0;
		offers = stringtotable(playerGameData[playerID].Peaceoffers);
		local num = 1;
		local remainingoffers = ",";
		while(offers[num]~=nil and offers[num+1]~=nil and offers[num+1]~="")do
			if(tonumber(offers[num])==tonumber(an))then
				preis = tonumber(offers[num+1]);
			else
				remainingoffers = remainingoffers .. offers[num] .. "," .. offers[num+1] .. ",";
			end
			num = num + 2;
		end
		if(remainingoffers == ",")then
			playerGameData[playerID].Peaceoffers = nil;
		else
			playerGameData[playerID].Peaceoffers = remainingoffers;
		end
		
		local testmg = {};
		testmg.Message = remainingoffers;
		setReturnTable(testmg);
		
		offers = stringtotable(playerGameData[an].Peaceoffers);
		remainingoffers = ",";
		num = 1;
		while(offers[num]~=nil and offers[num+1]~=nil and offers[num+1]~="")do
			if(tonumber(offers[num])~=tonumber(playerID))then
				remainingoffers = remainingoffers .. offers[num] .. "," .. offers[num+1] .. ",";
			end
			num = num + 2;
		end
		if(remainingoffers == ",")then
			playerGameData[an].Peaceoffers = nil;
		else
			playerGameData[an].Peaceoffers = remainingoffers;
		end
		playerGameData[an].Money = Mod.PlayerGameData[an].Money + preis;
		playerGameData[playerID].Money = Mod.PlayerGameData[playerID].Money - preis;
		Mod.PlayerGameData=playerGameData;
		local publicGameData = Mod.PublicGameData;
		local remainingwar = ",";
		local withtable = stringtotable(Mod.PublicGameData.War[an]);
		for _,with in pairs(withtable) do
			if(tonumber(with)~=playerID)then
				remainingwar = remainingwar .. with .. ",";
			end
		end
		publicGameData.War[an] = remainingwar;
		remainingwar = ",";
		local withtable = stringtotable(Mod.PublicGameData.War[playerID]);
		for _,with in pairs(withtable) do
			if(tonumber(with)~=an)then
				remainingwar = remainingwar .. with .. ",";
			end
		end
		publicGameData.War[playerID] = remainingwar;
		Mod.PublicGameData = publicGameData;
		local privateGameData = Mod.PrivateGameData;
		if(privateGameData.Cantdeclare == nil)then
			privateGameData.Cantdeclare = ",";
		end
		privateGameData.Cantdeclare = privateGameData.Cantdeclare .. an .. "," .. playerID .. ",";
		Mod.PrivateGameData = privateGameData;
	end
	if(payload.Message == "Request Data")then
		
	end
end
function stringtotable(variable)
	local chartable = {};
	if(variable ~= nil)then
		while(string.len(variable)>0)do
			chartable[tablelength(chartable)] = string.sub(variable, 1 , 1);
			variable = string.sub(variable, 2);
		end
		local newtable = {};
		local tablepos = 0;
		local executed = false;
		for _, elem in pairs(chartable)do
			if(elem == ",")then
				tablepos = tablepos + 1;
				newtable[tablepos] = "";
				executed = true;
			else
				if(executed == false)then
					tablepos = tablepos + 1;
					newtable[tablepos] = "";
					executed = true;
				end
				if(newtable[tablepos] == nil)then
					newtable[tablepos] = elem;
				else
					newtable[tablepos] = newtable[tablepos] .. elem;
				end
			end
		end
		return newtable;
	else
		return {};
	end
end
function tablelength(T)
	local count = 0;
	for _,elem in pairs(T)do
		count = count + 1;
	end
	return count;
end
