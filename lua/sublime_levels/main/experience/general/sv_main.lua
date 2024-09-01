local path = Sublime.GetCurrentPath();

hook.Add("OnNPCKilled", path, function(npc, attacker)
    if IsValid(attacker) and not attacker:IsPlayer() then
        attacker = attacker:CPPIGetOwner()
    end
    if IsValid(attacker) then
        local xp = Sublime.Settings.Get("kills", "npc_on_kill_experience", "number");
        if xp == 0 then return end
        attacker:SL_AddExperience(xp, "for killing an npc.");
    end
end,2);

hook.Add("PlayerDeath", path, function(victim, _, attacker)

    ---
    --- We have another playerdeath hook for the TTT gamemode.
    ---

    if (Sublime.GetCurrentGamemode() == "terrortown") then
        return;
    end

    ---
    --- We have another playerdeath hook for the Murder gamemode.
    ---

    if (Sublime.GetCurrentGamemode() == "murder") then
        return;
    end

    ---
    --- Continue if not ttt or murder.
    ---

    if IsValid(attacker) and not attacker:IsPlayer() then
        attacker = attacker:CPPIGetOwner()
    end
    if IsValid(victim) and not victim:IsPlayer() then
        victim = victim:CPPIGetOwner()
    end
    if (IsValid(victim) and IsValid(attacker)) then
        
        if (victim == attacker) then return end

        if victim:IsBot() then return end

        local experience = Sublime.Settings.Get("kills", "player_on_kill_experience", "number");

        -- Headshot bonus.
        local lastHit   = victim:LastHitGroup();
        local hModifier = Sublime.Settings.Get("kills", "headshot_modifier", "number");

        if (lastHit == HITGROUP_HEAD) then
            experience = experience * hModifier;
        end

        attacker:SL_AddExperience(experience, "for killing a player.");
    end
end,2);

