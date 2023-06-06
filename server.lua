-- Bitcoin vásárlás
RegisterCommand("buybitcoin", function(source, args)
    local player = source
    local amount = tonumber(args[1]) or 0

    if amount <= 0 then
        TriggerClientEvent("output", player, "^1Hibás mennyiség!")
        return
    end

    local playerMoney = 0

    -- Ellenőrizzük a játékos pénzét
    MySQL.Async.fetchScalar("SELECT money FROM players WHERE id = @id", {["@id"] = player},
        function(result)
            if result then
                playerMoney = tonumber(result)

                -- Ellenőrizzük, hogy van-e elég pénze a játékosnak a vásárláshoz
                local totalPrice = Config.bitcoinPrice * amount
                if playerMoney >= totalPrice then
                    -- Kiszámítjuk az új pénzösszeget és frissítjük az adatbázist
                    local newMoney = playerMoney - totalPrice

                    MySQL.Async.execute("UPDATE players SET money = @money WHERE id = @id",
                        {["@money"] = newMoney, ["@id"] = player},
                        function(rowsChanged)
                            if rowsChanged > 0 then
                                -- Elmentjük a bitcoin mennyiségét az adatbázisba
                                MySQL.Async.execute("INSERT INTO bitcoin (player_id, amount) VALUES (@player, @amount)",
                                    {["@player"] = player, ["@amount"] = amount},
                                    function(rowsInserted)
                                        if rowsInserted > 0 then
                                            TriggerClientEvent("output", player, "^2Sikeres bitcoin vásárlás! Vásárolt mennyiség: " .. amount)
                                        else
                                            TriggerClientEvent("output", player, "^1Hiba történt a bitcoin vásárlás közben!")
                                        end
                                    end)
                            else
                                TriggerClientEvent("output", player, "^1Hiba történt a pénz levonása közben!")
                            end
                        end)
                else
                    TriggerClientEvent("output", player, "^1Nincs elég pénzed a vásárláshoz!")
                end
            else
                TriggerClientEvent("output", player, "^1Hiba történt a játékos adatok lekérdezése közben!")
            end
        end)
end)

-- Bitcoin eladás
RegisterCommand("sellbitcoin", function(source, args)
    local player = source
    local amount = tonumber(args[1]) or 0

    if amount <= 0 then
        TriggerClientEvent("output", player, "^1Hibás mennyiség!")
        return
    end

    local playerBitcoin = 0

    -- Ellenőrizzük a játékos bitcoinjainak mennyiségét
    MySQL.Async.fetchScalar("SELECT amount FROM bitcoin WHERE player_id = @player", {["@player"] = player},
        function(result)
            if result then
                playerBitcoin = tonumber(result)

                -- Ellenőrizzük, hogy van-e elég bitcoinja a játékosnak az eladáshoz
                if playerBitcoin >= amount then
                    -- Kiszámítjuk az új bitcoin mennyiséget és frissítjük az adatbázist
                    local newBitcoinAmount = playerBitcoin - amount

                    MySQL.Async.execute("UPDATE bitcoin SET amount = @amount WHERE player_id = @player",
                        {["@amount"] = newBitcoinAmount, ["@player"] = player},
                        function(rowsChanged)
                            if rowsChanged > 0 then
                                -- Kiszámítjuk az eladott bitcoin értékét és hozzáadjuk a játékos pénzéhez
                                local sellPrice = Config.bitcoinPrice * amount
                                local playerMoney = 0

                                MySQL.Async.fetchScalar("SELECT money FROM players WHERE id = @id", {["@id"] = player},
                                    function(result)
                                        if result then
                                            playerMoney = tonumber(result)

                                            local newMoney = playerMoney + sellPrice

                                            MySQL.Async.execute("UPDATE players SET money = @money WHERE id = @id",
                                                {["@money"] = newMoney, ["@id"] = player},
                                                function(rowsChanged)
                                                    if rowsChanged > 0 then
                                                        TriggerClientEvent("output", player, "^2Sikeres bitcoin eladás! Eladott mennyiség: " .. amount)
                                                    else
                                                        TriggerClientEvent("output", player, "^1Hiba történt a pénz hozzáadása közben!")
                                                    end
                                                end)
                                        else
                                            TriggerClientEvent("output", player, "^1Hiba történt a játékos adatok lekérdezése közben!")
                                        end
                                    end)
                            else
                                TriggerClientEvent("output", player, "^1Hiba történt a bitcoin mennyiség frissítése közben!")
                            end
                        end)
                else
                    TriggerClientEvent("output", player, "^1Nincs elég bitcoinod az eladáshoz!")
                end
            else
                TriggerClientEvent("output", player, "^1Hiba történt a bitcoin adatok lekérdezése közben!")
            end
        end)
end)
