local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Feuerfest";

-- The description of the skill.
SKILL.Description       = "Reduces damage from fire up to a total of 75%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Physical"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "fire_damage_resistance";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 7.5;

-- Should we enable this skill?
SKILL.Enabled           = true

if (SERVER and SKILL.Enabled) then
	hook.Add("EntityTakeDamage", path, function(ent, dmg)
		if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then return end

		if (dmg:GetDamage() > 1 and dmg:IsDamageType(DMG_BURN)) then

			local ply
			if not ent:IsPlayer() then
				ply = ent:CPPIGetOwner()
				if ply == nil then return end
			else
				ply = ent
			end
			if IsValid(ply) then
				local points = ply:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint

				if (points > 0) then
					local modifier = 1 - (points / 100)
					dmg:ScaleDamage(modifier)
				end
			end
		end
	end)
end

Sublime.AddSkill(SKILL);