local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Killology";

-- The description of the skill.
SKILL.Description       = "Increases the damage output of your weapons. An increase up to a total of 10%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Weapons"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "damage_increase";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 1;

-- Should we enable this skill?
SKILL.Enabled           = true

if (SERVER and SKILL.Enabled) then
	hook.Add("EntityTakeDamage", path, function(ent, dmg)
		if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then return end

		local damage = dmg:GetDamage()

		if (damage > 0) then
			local attacker = dmg:GetAttacker()
			if not attacker:IsPlayer() then
				attacker = attacker:CPPIGetOwner()
				if attacker == nil then return end
			end
			if (IsValid(attacker)) then
				local points = attacker:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;
				if (points > 0) then
					local modifier = 1 - (points / 100)
					dmg:ScaleDamage(modifier)
				end
			end
		end
	end)
end

Sublime.AddSkill(SKILL)