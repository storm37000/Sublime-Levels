local mat = Material("pp/blurscreen");
local approach = math.Approach;
local round, min, floor, clamp = math.Round, math.min, math.floor, math.Clamp;
local ca = ColorAlpha;

---
--- DrawPanelBlur
---
function Sublime:DrawPanelBlur(panel, blur)
    local blur = (blur or 5);
    local sw = ScrW();
    local sh = ScrH();

    local x, y = panel:LocalToScreen(0, 0);
    local w, h = panel:GetSize();

    surface.SetDrawColor(0, 0, 0, 255);
    surface.SetMaterial(mat);

    local perX, perY = x / sw, y / sh;
    local perW, perH = (x + w) / sw, (y + h) / sh;

    for i = 1, blur do
        mat:SetFloat("$blur", i);
        mat:Recompute();

        render.UpdateScreenEffectTexture();
        surface.DrawTexturedRectUV(0, 0, w, h, perX, perY, perW, perH);
    end
end

local ui;
function Sublime.MakeNotification(header, desc, useDecline, useText)
    useDecline = useDecline or false;
    useText = useText or false;

    if (IsValid(ui)) then
        ui:Remove();
    end

    ui = vgui.Create("Sublime.Notification");
    ui:SetSize(500, 200);
    ui:Center();
    ui:MakePopup();
    ui:SetTitle(header)
    ui:SetDescription(desc);
    ui:SetDisplayDecline(useDecline);
    ui:SetUseTextEdit(useText);

    return ui;
end

local function charWrap(text, pxWidth)
    local total = 0

    text = text:gsub(".", function(char)
        total = total + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if total >= pxWidth then
            total = 0
            return "\n" .. char
        end

        return char
    end)

    return text, total
end

---
--- textWrap
--- Credits to FPTje.
---
function Sublime.textWrap(text, font, pxWidth)
    local total = 0

    surface.SetFont(font)

    local spaceSize = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                total = 0
            end

            local wordlen = surface.GetTextSize(word)
            total = total + wordlen

            -- Wrap around when the max width is reached
            if wordlen >= pxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, pxWidth - (total - wordlen))
                total = splitPoint
                return splitWord
            elseif total < pxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                total = wordlen - spaceSize
                return '\n' .. string.sub(word, 2)
            end

            total = wordlen
            return '\n' .. word
        end)

    return text
end

function Sublime:DrawPanelBlur(panel, blur)
    local blur = (blur or 5);
    local sw = ScrW();
    local sh = ScrH();

    local x, y = panel:LocalToScreen(0, 0);
    local w, h = panel:GetSize();

    surface.SetDrawColor(0, 0, 0, 255);
    surface.SetMaterial(mat);

    local perX, perY = x / sw, y / sh;
    local perW, perH = (x + w) / sw, (y + h) / sh;

    for i = 1, blur do
        mat:SetFloat("$blur", i);
        mat:Recompute();

        render.UpdateScreenEffectTexture();
        surface.DrawTexturedRectUV(0, 0, w, h, perX, perY, perW, perH);
    end
end

function Sublime:DrawBlur(x, y, w, h)
    local sw = ScrW();
    local sh = ScrH();

    surface.SetDrawColor(0, 0, 0, 255);
    surface.SetMaterial(mat);

    local perX, perY = x / sw, y / sh;
    local perW, perH = (x + w) / sw, (y + h) / sh;

    for i = 1, 5 do
        mat:SetFloat("$blur", i);
        mat:Recompute();

        render.UpdateScreenEffectTexture();
        surface.DrawTexturedRectUV(x, y, w, h, perX, perY, perW, perH);
    end
end

function Sublime:DrawPanelTip(panel, str)
    if (panel.IsDrawingTip) then
        return false;
    end

    local c = Sublime.Colors;
    local p = 10; -- padding
    local d = Color(0, 0, 0, 225); -- dark

    local tip = vgui.Create("DPanel");
    tip:MakePopup();

    tip.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, c.Royal);
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, c.Black);
        self:DrawTextOutlined(str, "Sublime.18", w / 2, h / 2, c.White, c.Black, TEXT_ALIGN_CENTER, true);
    end

    tip.Think = function()
        local x, y = input.GetCursorPos();
        local w, h = surface.GetTextSize(str);

        local xPos = x - (w / 2);
        local outsideOfScreen = xPos + w > ScrW();

        if (outsideOfScreen) then
            xPos = (x - w);
        end

        tip:SetPos(xPos, y + (p * 2));
        tip:SetSize(w + p, h + p);

        if (IsValid(panel)) then
            if (not panel:IsHovered()) then
                tip:Remove();
            end
        else
            if (IsValid(tip)) then
                tip:Remove();
            end
        end
        
        tip:MakePopup();
    end

    tip.OnRemove = function()
        if (IsValid(panel)) then
            panel.IsDrawingTip = false;
        end
    end

    panel.IsDrawingTip = true;
end

function Sublime:CreateDropDownMenu(playerName, options)
    local c = Sublime.Colors;
    local p = 10; -- padding
    local d = Color(0, 0, 0, 225); -- dark
    
    local screenWidth = ScrW();
    local screenHeight = ScrH();

    local menu = vgui.Create("DPanel");
    local x, y = input.GetCursorPos();

    surface.SetFont("Sublime.18");
    local maxWidth = surface.GetTextSize(playerName) + (p * 3)

    if (maxWidth < 200) then
        maxWidth = 200;
    end

    for i = #options, 1, -1 do
        local option = options[i];

        if (option) then
            if (not option.hasAccess) then
                table.remove(options, i);
            end
        end
    end

    local menuTall = 30 + (#options * 30);

    if ((y + menuTall) > screenHeight) then
        y = screenHeight - menuTall;
    end

    if ((x + maxWidth) > screenWidth) then
        x = screenWidth - maxWidth;
    end

    menu:SetPos(x - p, y - p);
    menu:SetSize(maxWidth, menuTall);

    menu.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, c.Royal);
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, c.Black);
    end

    menu.Think = function()
        local x, y = input.GetCursorPos();
        local pX, pY = menu:GetPos();

        if (x < pX or y < pY or x > (pX + menu:GetWide()) or y > (pY + menu:GetTall())) then
            menu:Remove();
        end
    end

    local name = menu:Add("DLabel");
    name:SetText("");
    name:SetSize(menu:GetWide(), 30);
    name:SetPos(0, 0);

    name.Paint = function(panel, w, h)
        surface.SetDrawColor(0, 0, 0, 0);
        surface.DrawRect(0, 0, w, h);

        surface.SetDrawColor(c.Royal);
        surface.DrawRect(0, h - 1, w, 1)

        self:DrawTextOutlined(playerName, "Sublime.18", w / 2, h / 2, c.Royal, c.Black, TEXT_ALIGN_CENTER, true);
    end

    for i = 1, #options do
        local data      = options[i];
        local text      = data.text;
        local func      = data.func;
        local access    = data.hasAccess;
        local tip       = data.tip;

        if (access == false) then
            continue;
        end

        local button = menu:Add("DButton");
        button:SetText("");
        button:SetSize(menu:GetWide(), 30);
        button:SetPos(0, i * 30);

        button.Paint = function(panel, w, h)
            local clr = ca(c.White, 150);

            if (panel:IsHovered()) then
                clr = c.Royal;
            end

            surface.SetDrawColor(0, 0, 0, 0);
            surface.DrawRect(0, 0, w, h);

            if (i ~= #options) then
                surface.SetDrawColor(ColorAlpha(c.Grey, 25));
                surface.DrawRect(0, h - 1, w, 1)
            end 

            if (panel:IsHovered() and tip) then
                if (panel.HoverTime < CurTime()) then
                    self:DrawPanelTip(panel, tip);
                end
            else
                panel.HoverTime = CurTime() + 0.25;
            end

            self:DrawTextOutlined(text, "Sublime.18", w / 2, h / 2, clr, c.Black, TEXT_ALIGN_CENTER, true);
        end

        button.DoClick = function()
            func();
            menu:Remove();
        end

        button.DoRightClick = function()
            menu:Remove();
        end
    end

    menu:MakePopup();

    return menu;
end

function Sublime:DoHoverAnim(panel, current, hover, not_hover, custom)
    if (panel:IsHovered() or custom) then
        local want    = hover[1];
        local change  = hover[2]
        
        current = approach(current, want, change);
    else
        local want   = not_hover[1];
        local change = not_hover[2];

        if (current > want) then
            current = approach(current, want, change);
        end
    end

    return current;
end

function Sublime:DrawMaterialRotatedOutline(posx, posy, width, height, material, b_color, color, rotate)
    surface.SetDrawColor(b_color);
    surface.SetMaterial(material);
    surface.DrawTexturedRectRotated(posx + 1, posy + 1, width, height, rotate);

    surface.SetDrawColor(color);
    surface.DrawTexturedRectRotated(posx, posy, width, height, rotate);
end

function Sublime:DrawMaterialOutline(posx, posy, width, height, material, b_color, color)
    surface.SetDrawColor(b_color);
    surface.SetMaterial(material);
    surface.DrawTexturedRect(posx + 1, posy + 1, width, height);

    surface.SetDrawColor(color);
    surface.DrawTexturedRect(posx, posy, width, height);
end

local tex_corner8	= surface.GetTextureID( "gui/corner8" )
local tex_corner16	= surface.GetTextureID( "gui/corner16" )

function Sublime:DrawRoundedGradient(panel, bordersize, x, y, w, h, color1, color2)
	x = round(x);
	y = round(y);
	w = round(w);
	h = round(h);
	bordersize = min(round(bordersize), floor(w / 2));

    local lx, ly;

    if (IsValid(panel)) then
        lx, ly = panel:LocalToScreen(x, y);
    else
        lx, ly = x, y;
    end
    
    self:DrawLinearGradient(lx + bordersize, ly, w - bordersize * 2, h, 
    {
        {offset = 0, color = color1}, 
        {offset = 1, color = color2}
    });

    surface.SetDrawColor(color1);
    surface.DrawRect(x, y + bordersize, bordersize, h - bordersize * 2);

    surface.SetDrawColor(color2);
    surface.DrawRect(x + w - bordersize, y + bordersize, bordersize, h - bordersize * 2);

	local tex = tex_corner8;
	if (bordersize > 8) then tex = tex_corner16 end

	surface.SetTexture(tex);
	surface.DrawTexturedRectUV(x + w - bordersize, y, bordersize, bordersize, 1, 0, 0, 1);
	surface.DrawTexturedRectUV(x + w - bordersize, y + h - bordersize, bordersize, bordersize, 1, 1, 0, 0);

    surface.SetDrawColor(color1);

	surface.DrawTexturedRectUV(x, y, bordersize, bordersize, 0, 0, 1, 1);
	surface.DrawTexturedRectUV(x, y + h -bordersize, bordersize, bordersize, 0, 1, 1, 0);
end

function Sublime:LightenColor(color, value)
    return Color(
        clamp(color.r + (value / 255) * 255, 0, 255),
        clamp(color.g + (value / 255) * 255, 0, 255),
        clamp(color.b + (value / 255) * 255, 0, 255),
        color[4]
    );
end

function Sublime:DarkenColor(color, value)
    return Color(
        clamp(color.r - (value / 255) * 255, 0, 255),
        clamp(color.g - (value / 255) * 255, 0, 255),
        clamp(color.b - (value / 255) * 255, 0, 255),
        color[4]
    ); 
end

function Sublime:DrawTextOutlined(str, font, posx, posy, clr, clr2, tpos1, doHeightCenter)
    str = tostring(str);
    surface.SetFont(font);

    local textHeight = 0;
    if (doHeightCenter) then 
        local _, lineHeight = surface.GetTextSize('\n');
        local lineCount = 1;

        for i = 1, str:len() do 
            if (str[i] == '\n') then
                lineCount = lineCount + 1;
            end
        end
        
        textHeight = lineCount * lineHeight 
    end

    draw.DrawText(str, font, posx + 1, posy + 1 - (textHeight / 4), clr2, tpos1);
    draw.DrawText(str, font, posx, posy - (textHeight / 4), clr, tpos1);

    return textHeight / 2;
end

net.Receive("Sublime.Notify", function()
    local red       = Sublime.Colors.Red;
    local white     = Sublime.Colors.White;

    //28.11.2021. Daniel.
    local prefix    = net.ReadString();
    local source    = net.ReadString();

    if (not Sublime.Settings.Get("other", "experience_notifications", "boolean")) then
        return;
    end

    chat.AddText(red, prefix, white, ": ", white, source);
end);