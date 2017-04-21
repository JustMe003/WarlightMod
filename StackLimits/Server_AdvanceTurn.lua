function Server_AdvanceTurn_Start (game,addNewOrder)
	SkippedOrders = {};
	executedadd = false;
	AddedOrders = {};
	executedend = false;
end
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if(executedadd == false)then
		if(order.proxyType ~= 'GameOrderDeploy')then
			if(order.proxyType ~= 'GameOrderPlayCardAirlift')then
				executedadd = true;
				local ArmiesonTerr = {};
				for _, terra in pairs(game.Map.Territories)do
					ArmiesonTerr[terra.ID] = game.ServerGame.LatestTurnStanding.Territories[terra.ID].NumArmies.NumArmies;
				end
				print('T1');
				for _, terra in pairs(game.ServerGame.LatestTurnStanding.Territories)do
					if(terra.NumArmies.NumArmies > Mod.Settings.StackLimit)then
						local Effect = {};
						local ExtraArmies = ArmiesonTerr[terra.ID]-Mod.Settings.StackLimit;
						for _, terri in pairs(game.ServerGame.LatestTurnStanding.Territories)do
							if(terri.OwnerPlayerID == terra.OwnerPlayerID)then
								local PlaceFor = Mod.Settings.StackLimit-ArmiesonTerr[terri.ID];
								if(PlaceFor > ExtraArmies)then
									PlaceFor = ExtraArmies;
								end
								print('T2');
								if(PlaceFor > 0)then
									local HasArmies = ArmiesonTerr[terri.ID];
									if(HasArmies + PlaceFor > Mod.Settings.StackLimit)then
										ExtraArmies = ExtraArmies - (Mod.Settings.StackLimit-HasArmies);
										HasArmies=Mod.Settings.StackLimit;
									else
										ExtraArmies = ExtraArmies - PlaceFor;
										HasArmies = HasArmies + PlaceFor;
									end
									Effect[tablelength(Effect)+1] = WL.TerritoryModification.Create(terri.ID);
									Effect[tablelength(Effect)].SetArmiesTo = HasArmies;
									ArmiesonTerr[terri.ID] = HasArmies;
								end
							end
						end
						print('T3');
						Effect[tablelength(Effect)+1] = WL.TerritoryModification.Create(terra.ID);
						Effect[tablelength(Effect)].SetArmiesTo = Mod.Settings.StackLimit;
						ArmiesonTerr[terra.ID] = Mod.Settings.StackLimit;
						print(tablelength(AddedOrders));
						AddedOrders[tablelength(AddedOrders)+1] = WL.GameOrderEvent.Create(terra.OwnerPlayerID,"Stack Limit",{},Effect);
						print(tablelength(AddedOrders));
						SkippedOrders[tablelength(SkippedOrders)+1] = order;
						skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
					end
				end
			end
		end
	else
		if(executedend == false)then
			SkippedOrders[tablelength(SkippedOrders)+1] = order;
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		end
	end
end
function Server_AdvanceTurn_End(game,addNewOrder)
	if(executedend == false)then
		executedend = true;
		local ArmiesonTerr = {};
		for _, terra in pairs(game.Map.Territories)do
			ArmiesonTerr[terra.ID] = game.ServerGame.LatestTurnStanding.Territories[terra.ID].NumArmies.NumArmies;
		end
		if(executedadd == false)then
			executedadd = true;
			local ArmiesonTerr = {};
			for _, terra in pairs(game.ServerGame.LatestTurnStanding.Territories)do
				if(terra.NumArmies.NumArmies > Mod.Settings.StackLimit)then
					local Effect = {};
					local ExtraArmies = ArmiesonTerr[terra.ID]-Mod.Settings.StackLimit;
					for _, terri in pairs(game.ServerGame.LatestTurnStanding.Territories)do
						if(terri.OwnerPlayerID == terra.OwnerPlayerID)then
							local PlaceFor = Mod.Settings.StackLimit-ArmiesonTerr[terri.ID];
							if(PlaceFor > ExtraArmies)then
								PlaceFor = ExtraArmies;
							end
							if(PlaceFor > 0)then
								local HasArmies = ArmiesonTerr[terri.ID];
								if(HasArmies + PlaceFor > Mod.Settings.StackLimit)then
									ExtraArmies = ExtraArmies - (Mod.Settings.StackLimit-HasArmies);
									HasArmies=Mod.Settings.StackLimit;
								else
									ExtraArmies = ExtraArmies - PlaceFor;
									HasArmies = HasArmies + PlaceFor;
								end
								Effect[tablelength(Effect)+1] = WL.TerritoryModification.Create(terri.ID);
								Effect[tablelength(Effect)].SetArmiesTo = HasArmies;
								ArmiesonTerr[terri.ID] = HasArmies;
							end
						end
					end
					Effect[tablelength(Effect)+1] = WL.TerritoryModification.Create(terra.ID);
					Effect[tablelength(Effect)].SetArmiesTo = Mod.Settings.StackLimit;
					ArmiesonTerr[terra.ID] = Mod.Settings.StackLimit;
					addNewOrder(WL.GameOrderEvent.Create(terra.OwnerPlayerID,"Stack Limit",{},Effect));
				end
			end
		end
		print(tablelength(AddedOrders));
		for _, ord in pairs(AddedOrders)do
			addNewOrder(ord);
		end
		for _, ord in pairs(SkippedOrders)do
			addNewOrder(ord);
		end
	end
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
