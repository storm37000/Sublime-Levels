--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Healthy";

-- The description of the skill.
SKILL.Description       = "Increases your health up to 25%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Physical"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "health_increase";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 5;
SKILL.AmountPerPoint    = 5;

-- Should we enable this skill?
SKILL.Enabled           = true;

SKILL.OnBuy = function(ply)
    if (not SKILL.Enabled) then
        return;
    end

    local points = ply:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

    if (points < 1) then
        return;
    end

    local modifier  = 1 + (points / 100);
    local health    = ply.sublime_default_max_health * modifier;
    
    ply:SetHealth(health);
    ply:SetMaxHealth(health);
end

if (SERVER) then
    hook.Add("PlayerLoadout", path, function(ply)
        if (not ply.sublime_default_max_health) then
            ply.sublime_default_max_health = ply:GetMaxHealth();
        end

        SKILL.OnBuy(ply);
    end);

    hook.Add("PlayerInitialSpawn", path, function(ply)
        timer.Simple(2, function()
            if (not IsValid(ply)) then
                return;
            end

            SKILL.OnBuy(ply);
        end);
    end);
end

Sublime.AddSkill(SKILL);