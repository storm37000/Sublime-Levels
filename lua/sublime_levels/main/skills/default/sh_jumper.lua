--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Jumper";

-- The description of the skill.
SKILL.Description       = "Increases your jump power up to a total of 50%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Agility"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "jumper";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 5;
SKILL.AmountPerPoint    = 10;

-- Should we enable this skill?
SKILL.Enabled           = true;

if SKILL.Enabled then

	-- This is ran when we buy the addon.
	SKILL.OnBuy = function(ply)
		ply:SetJumpPower(ply.sublime_default_jump_power);
	end

	local meta = FindMetaTable("Player");
	local oldJumpPower = meta.SetJumpPower;

	function meta:SetJumpPower(iPower)
		local points = self:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

		if (points >= 1 and SKILL.Enabled) then
			local modifier = 1 + (points / 100);
			iPower = iPower * modifier;
		end

		oldJumpPower(self, iPower);
	end

	hook.Add("PlayerLoadout", path, function(ply)
		---
		--- This timer should be used once, and that's the initial player spawn.
		--- After the players initial spawn, the sublime_default_jump_power variable
		--- should always be available.
		---
		if (not ply.sublime_default_jump_power) then
			timer.Create("sublime_check_jump", 1, 0, function()
				if (ply.sublime_default_jump_power) then
					SKILL.OnBuy(ply)
					timer.Destroy("sublime_check_jump")
				end
			end)
		else
			SKILL.OnBuy(ply)
		end
	end)
end

Sublime.AddSkill(SKILL);