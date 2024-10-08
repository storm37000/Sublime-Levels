local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Lifesteal";

-- The description of the skill.
SKILL.Description       = "Damaging other players or NPC's has a chance to heal you.\nUp to 10% chance and 10% lifesteal.";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Weapons"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "lifesteal";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 1;

-- Should we enable this skill?
SKILL.Enabled           = true

if (SERVER and SKILL.Enabled) then
	hook.Add("PostEntityTakeDamage", path, function(ent, dmg, took)
		if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then return end

		local damage    = dmg:GetDamage()
		local attacker  = dmg:GetAttacker()
		local inflictor = dmg:GetInflictor()

		if (damage > 0 and took) then
			if attacker == nil then return end
			if not attacker:IsPlayer() then
				attacker = attacker:CPPIGetOwner()
				if attacker == nil then return end
			end
			if IsValid(attacker) then
				local points = attacker:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint
				if (points > 0) then
					local randomNum = math.random(1, 100)
					if (randomNum <= points) then
						local toHeal = math.ceil(damage * (points / 100))
						if IsValid(inflictor) and (not inflictor:IsWeapon()) and inflictor.TakeDamage then
							inflictor:SetHealth(inflictor:Health() + toHeal)
							Sublime.Notify(attacker, "[" .. SKILL.Name .. "] Your " .. tostring(inflictor) .. " gained " .. toHeal .. " health from your damage to " .. tostring(ent))
						else
							attacker:SetHealth(attacker:Health() + toHeal)
							Sublime.Notify(attacker, "[" .. SKILL.Name .. "] You gained " .. toHeal .. " health from your damage to " .. tostring(ent))
						end
					end
				end
			end
		end
	end);
end
Sublime.AddSkill(SKILL)