function Server_StartGame(game,standing)
   local playerGameData = Mod.PlayerGameData;
   for _,terr in pairs(standing.Territories)do
      if(terr.OwnerPlayerID > 50)then
         print(Mod.Settings.StartMoney);
         playerGameData[terr.OwnerPlayerID] ={ Money=tostring(Mod.Settings.StartMoney)};
      end
   end
   Mod.PlayerGameData = playerGameData;
end
