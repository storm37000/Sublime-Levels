--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Ricochet";

-- The description of the skill.
SKILL.Description       = "The bullets that hit you have a chance to ricochet back to the shooter.\nUp to 10%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Physical"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "ricochet";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 1;

-- Should we enable this skill?
SKILL.Enabled           = true

if (SERVER and SKILL.Enabled) then
	hook.Add("EntityTakeDamage", path, function(target, data)
		if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then return end

		local damage    = data:GetDamage()
		local attacker  = data:GetAttacker()
		local inflictor = data:GetInflictor()

		if (damage > 0 and data:IsDamageType(DMG_BULLET)) then

			if attacker == nil then return end
			if not attacker:IsPlayer() then
				attacker = attacker:CPPIGetOwner()
				if attacker == nil then return end
			end
			if (IsValid(attacker)) then

				if target == nil then return end
				if not target:IsPlayer() then
					target = target:CPPIGetOwner()
					if target == nil then return end
				end

				if (IsValid(target)) then
					local points = target:SL_GetInteger(SKILL.Identifier, 0)

					if (points > 0) then
						local modifier  = points * SKILL.AmountPerPoint
						local random    = math.random(1, 100)

						if (random <= modifier) then
							data:ScaleDamage(0)

							if IsValid(inflictor) and (not inflictor:IsWeapon()) and inflictor.TakeDamage then
								inflictor:TakeDamage(damage, target, inflictor)
								Sublime.Notify(target, "[" .. SKILL.Name .. "] You ricochet " .. damage .. " damage back to " .. tostring(inflictor))
							else
								attacker:TakeDamage(damage, target, inflictor)
								Sublime.Notify(target, "[" .. SKILL.Name .. "] You ricochet " .. damage .. " damage back to " .. attacker:Nick())
							end
						end
					end
				end
			end
		end
	end)
end

Sublime.AddSkill(SKILL)