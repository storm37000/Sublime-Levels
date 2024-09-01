local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Usain Bolt";

-- The description of the skill.
SKILL.Description       = "Increases your movement speed up to a total of 25%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Agility"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "usain_bolt";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 2.5;

-- Should we enable this skill?
SKILL.Enabled           = true

if (SKILL.Enabled) then

	-- This is ran when we buy the addon.
	SKILL.OnBuy = function(ply)
		ply:SetRunSpeed(ply.sublime_default_run_speed)
		ply:SetWalkSpeed(ply.sublime_default_walk_speed)
	end

	local meta = FindMetaTable("Player")
	local oldSetRunSpeed = meta.SetRunSpeed
	local oldSetWalkSpeed = meta.SetWalkSpeed

	function meta:SetRunSpeed(iSpeed)
		local points = self:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint

		if (points >= 1 and SKILL.Enabled) then
			local modifier = 1 + (points / 100)
			iSpeed = iSpeed * modifier
		end

		oldSetRunSpeed(self, iSpeed)
	end

	function meta:SetWalkSpeed(iSpeed)
		local points = self:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint

		if (points >= 1 and SKILL.Enabled) then
			local modifier = 1 + (points / 100)
			iSpeed = iSpeed * modifier
		end

		oldSetWalkSpeed(self, iSpeed)
	end

	hook.Add("PlayerLoadout", path, function(ply)
		---
		--- This timer should be used once, and that's the initial player spawn.
		--- After the players initial spawn, the sublime_default_jump_power variable
		--- should always be available.
		---
		if (not ply.sublime_default_walk_speed or not ply.sublime_default_run_speed) then
			timer.Create("sublime_check_speed", 1, 0, function()
				if (ply.sublime_default_walk_speed or ply.sublime_default_run_speed) then
					SKILL.OnBuy(ply)
					timer.Destroy("sublime_check_speed")
				end
			end)
		else
			SKILL.OnBuy(ply)
		end
	end)
end

Sublime.AddSkill(SKILL)