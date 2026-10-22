local BUILD = function(cfg)
cfg = cfg or {}

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")

local LP  = Players.LocalPlayer
local PG  = LP:WaitForChild("PlayerGui")
local CAM = workspace.CurrentCamera
local UD  = UDim2

local C = {
	Title = tostring(cfg.Title or "XJW"), Version = tostring(cfg.Version or "v1.0"),
	Void=Color3.fromRGB(8,8,10), Bg=Color3.fromRGB(13,13,15),
	Panel=Color3.fromRGB(19,19,22), Panel2=Color3.fromRGB(30,30,34),
	Line=Color3.fromRGB(64,64,70),
	Cyan=Color3.fromRGB(0,229,255), Purple=Color3.fromRGB(90,102,181),
	Pink=Color3.fromRGB(224,122,40), Green=Color3.fromRGB(120,180,255),
	Red=Color3.fromRGB(226,90,90),
	Text=Color3.fromRGB(230,230,233), Dim=Color3.fromRGB(182,186,194),
}

C.TabNG = {}
local BLUE = Color3.fromRGB(125,190,255)
local THEMES = {
	BLUE,Color3.fromRGB(150,124,255),Color3.fromRGB(255,152,64),
	Color3.fromRGB(96,214,160),Color3.fromRGB(255,96,120),Color3.fromRGB(240,205,90),
}
local ACC = THEMES[1]
local TINT = {}
local function tint(f) TINT[#TINT+1] = f end
local function pick(obj,prop)
	local o,p = obj,prop
	tint(function(c) if o.Parent ~= nil then o[p] = c end end)
end
local function applyTheme(c)
	ACC = c
	for _,f in ipairs(TINT) do pcall(f,c) end
end

local function new(c,p)
	local i=Instance.new(c); local pt
	for k,v in pairs(p or {}) do if k=="Parent" then pt=v else i[k]=v end end
	if pt then i.Parent=pt end; return i
end
local function corner(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r),Parent=p}) end
local function stroke(p,c,t,tr) return new("UIStroke",{Color=c,Thickness=t or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p}) end
local function grad(p,a,b,r) return new("UIGradient",{Color=ColorSequence.new(a,b),Rotation=r or 0,Parent=p}) end
local WHITE = Color3.new(1,1,1)
local function rainbowSeq()
	local k = {}
	for i = 0, 11 do k[i+1] = ColorSequenceKeypoint.new(i/11, Color3.fromHSV(i/11,1,1)) end
	return ColorSequence.new(k)
end
local function textW(lbl)
	local ok, sz = pcall(function()
		return game:GetService("TextService"):GetTextSize(lbl.Text, lbl.TextSize, lbl.Font, Vector2.new(10000,10000))
	end)
	if ok and typeof(sz) == "Vector2" then return sz.X end
	return math.max(8, #tostring(lbl.Text) * (lbl.TextSize or 10) * 0.6)
end
local function pad(p,l,r,t,b) return new("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),Parent=p}) end
local function tw(i,d,p,s,dr) local t=TweenService:Create(i,TweenInfo.new(d,s or Enum.EasingStyle.Quad,dr or Enum.EasingDirection.Out),p); t:Play(); return t end
local function hex(n) local s="" for _=1,n do s=s..string.format("%X",math.random(0,15)) end return s end

local function techCorners(parent,color,len,thick,trans)
	for _,s in ipairs({{0,0,len,thick},{0,0,thick,len},{1,0,len,thick},{1,0,thick,len},
		{0,1,len,thick},{0,1,thick,len},{1,1,len,thick},{1,1,thick,len}}) do
		new("Frame",{AnchorPoint=Vector2.new(s[1],s[2]),Position=UD.new(s[1],0,s[2],0),
			Size=UD.fromOffset(s[3],s[4]),BackgroundColor3=color,BackgroundTransparency=trans or 0,
			BorderSizePixel=0,ZIndex=46,Parent=parent})
	end
end
local function diamond(parent,x,y,sz,color,trans)
	local d=new("Frame",{Position=UD.fromOffset(x,y),Size=UD.fromOffset(sz,sz),
		BackgroundColor3=color,BackgroundTransparency=trans or 0,BorderSizePixel=0,Rotation=45,Parent=parent})
	corner(d,2); return d
end
local function ring(parent,sz,color,thick,trans)
	local f=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),
		Size=UD.fromOffset(sz,sz),BackgroundTransparency=1,Parent=parent})
	corner(f,sz/2); stroke(f,color,thick,trans); return f
end
local function fitScale(g,bw,pd,mn,mx)
	local s=g:FindFirstChildOfClass("UIScale") or new("UIScale",{Scale=1,Parent=g})
	local function u() s.Scale=math.clamp((CAM.ViewportSize.X-(pd or 40))/bw, mn or .6, mx or 1) end
	u(); CAM:GetPropertyChangedSignal("ViewportSize"):Connect(u); return s
end
local function makeDraggable(t,h,onClick)
	h=h or t
	local dg,ds,sp,mv=false,nil,nil,false
	h.InputBegan:Connect(function(input,gp)
		if gp then return end
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dg,mv=true,false; ds=input.Position; sp=t.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dg then return end
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			local d=input.Position-ds; if d.Magnitude>4 then mv=true end
			local vp=CAM.ViewportSize
			t.Position=UD.new(0,math.clamp(sp.X.Offset+d.X,-t.AbsoluteSize.X+60,vp.X-60),0,
				math.clamp(sp.Y.Offset+d.Y,0,vp.Y-30))
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if not dg then return end
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dg=false; if not mv and onClick then task.defer(onClick) end
		end
	end)
end

local gui = new("ScreenGui",{Name="NeonHubUI",ResetOnSpawn=false,IgnoreGuiInset=true,
	ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=9999,Parent=PG})

local WIN_W, WIN_H = tonumber(cfg.Width) or 560, tonumber(cfg.Height) or 334
local MAIN_SCALE = 1.2

local mainHomePos = UD.fromOffset(
	math.max(8, (CAM.ViewportSize.X - WIN_W * MAIN_SCALE) / 2),
	math.max(8, (CAM.ViewportSize.Y - WIN_H * MAIN_SCALE) / 2)
)

local main = new("Frame",{
	Name="MainWindow",
	Position=mainHomePos,
	Size=UD.fromOffset(WIN_W,WIN_H),
	BackgroundColor3=C.Bg,BackgroundTransparency=0.32,BorderSizePixel=0,Visible=false,Parent=gui})
corner(main,10)
local mainStroke = stroke(main,WHITE,2,0.2)
local borderGrad = grad(mainStroke,WHITE,WHITE,0)
borderGrad.Color = rainbowSeq()
local bRing = new("Frame",{Size=UD.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
	ZIndex=45,Parent=main})
corner(bRing,10)
local ringGrad = grad(stroke(bRing,WHITE,2,0.2),WHITE,WHITE,0)
ringGrad.Color = rainbowSeq()
local themeLayer = new("Frame",{Size=UD.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
	ZIndex=44,ClipsDescendants=true,Parent=main})
local themeIdx = 1
local themeNames = {"默认","下雨","落雪","星空"}
local themeShut = function() end
local themeParts = {}
for i=1,72 do
	local f = new("Frame",{Size=UD.fromOffset(2,2),BackgroundColor3=WHITE,BackgroundTransparency=0.35,
		BorderSizePixel=0,Visible=false,ZIndex=44,Parent=themeLayer})
	corner(f,2)
	themeParts[i] = {f=f,x=0,y=0,v=0,ph=0}
end
local themeBands = {}
for i=1,3 do
	local b = new("Frame",{Size=UD.fromOffset(170,96),BackgroundColor3=WHITE,BackgroundTransparency=0.92,
		BorderSizePixel=0,Visible=false,ZIndex=44,Parent=themeLayer})
	corner(b,48)
	local g = grad(b,WHITE,WHITE,0)
	g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(96,120,255)),
		ColorSequenceKeypoint.new(0.5,Color3.fromRGB(168,112,255)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(52,180,235))})
	themeBands[i] = {f=b,g=g,ph=i*2.1,x=0,y=0}
end
local themeShoots = {}
for i=1,3 do
	local s = new("Frame",{Size=UD.fromOffset(2,18),BackgroundColor3=Color3.fromRGB(214,234,255),
		BackgroundTransparency=0,BorderSizePixel=0,Visible=false,ZIndex=44,Parent=themeLayer})
	corner(s,1)
	local sg = grad(s,WHITE,WHITE,0)
	sg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),
		NumberSequenceKeypoint.new(1,0.05)})
	themeShoots[i] = {f=s,g=sg,ph=i*1.9,x=0,y=0,v=0}
end
local function themeBounds()
	local w,h = main.Size.X.Offset, main.Size.Y.Offset
	if w < 80 then w = WIN_W end
	if h < 80 then h = WIN_H end
	return w,h
end
local function themeReset()
	local w,h = themeBounds()
	for _,p in ipairs(themeParts) do
		p.x = math.random() * (w - 10) + 4
		p.y = math.random() * h - h
		p.ph = math.random() * 6.28
	end
end
local function setTheme(i)
	themeIdx = i
	local w,h = themeBounds()
	for _,p in ipairs(themeParts) do p.f.Visible = false end
	for _,b in ipairs(themeBands) do b.f.Visible = false end
	for _,s in ipairs(themeShoots) do s.f.Visible = false end
	if i == 2 then
		themeReset()
		for n = 1,56 do
			local p = themeParts[n]
			local near = (n <= 30)
			p.v = near and (560 + math.random()*260) or (330 + math.random()*140)
			p.ph = near and (34 + math.random()*62) or (10 + math.random()*26)
			p.f.Size = near and UD.fromOffset(2, 13 + math.random()*8) or UD.fromOffset(1, 7 + math.random()*6)
			p.f.BackgroundColor3 = near and Color3.fromRGB(152,206,255) or Color3.fromRGB(114,164,220)
			p.f.BackgroundTransparency = near and (0.16 + math.random()*0.2) or (0.5 + math.random()*0.2)
			p.f.Visible = true
		end
	elseif i == 3 then
		themeReset()
		for n = 1,44 do
			local p = themeParts[n]
			local sz = 2 + math.random()*3
			p.v = 15 + sz*9 + math.random()*14
			p.ph = math.random()*6.28
			p.x = math.random() * (w - 12) + 4
			p.y = math.random() * h - h
			p.f.Size = UD.fromOffset(sz,sz)
			p.f.BackgroundColor3 = Color3.fromRGB(238,246,255)
			p.f.BackgroundTransparency = 0.44 - sz*0.06 + math.random()*0.12
			p.f.Visible = true
		end
	elseif i == 4 then
		for n = 1,62 do
			local p = themeParts[n]
			p.x = math.random() * (w - 10) + 4
			p.y = math.random() * (h - 8) + 4
			p.ph = math.random() * 6.28
			local sz = (n % 9 == 0) and 3 or (1 + math.floor(math.random()*2))
			p.f.Size = UD.fromOffset(sz,sz)
			p.f.BackgroundColor3 = (n % 5 == 0) and Color3.fromRGB(198,214,255) or WHITE
			p.f.BackgroundTransparency = 0.16 + math.random()*0.34
			p.f.Visible = true
		end
		for n,b in ipairs(themeBands) do
			b.x = math.random() * math.max(20, w - 150) - 10
			b.y = math.random() * math.max(20, h - 90) - 10
			b.ph = math.random() * 6.28
			b.f.Position = UD.fromOffset(math.floor(b.x), math.floor(b.y))
			b.f.BackgroundTransparency = 0.9 + math.random()*0.05
			b.f.Visible = true
		end
		for n,s in ipairs(themeShoots) do
			s.x = math.random() * w * 0.75
			s.y = math.random() * h * 0.45 - 26
			s.v = 430 + math.random()*220
			s.ph = 1.5 + math.random()*3.4
			s.f.Position = UD.fromOffset(math.floor(s.x), math.floor(s.y))
		end
	end
end
local function stepTheme(dt)
	local w,h = themeBounds()
	if themeIdx == 2 then
		for i = 1,56 do
			local p = themeParts[i]
			p.y = p.y + p.v*dt
			p.x = p.x + p.ph*dt
			if p.y > h + 8 then
				p.y = -22
				p.x = math.random() * (w - 10) + 4
			end
			if p.x > w + 6 then p.x = -6 elseif p.x < -6 then p.x = w + 6 end
			p.f.Position = UD.fromOffset(math.floor(p.x), math.floor(p.y))
		end
	elseif themeIdx == 3 then
		for i = 1,44 do
			local p = themeParts[i]
			p.ph = p.ph + dt*(0.6 + (i%4)*0.22)
			p.y = p.y + p.v*dt
			p.x = p.x + math.sin(p.ph)*26*dt
			if p.y > h + 8 then
				p.y = -10
				p.x = math.random() * (w - 10) + 4
			end
			p.f.Position = UD.fromOffset(math.floor(p.x), math.floor(p.y))
		end
	elseif themeIdx == 4 then
		for i = 1,62 do
			local p = themeParts[i]
			p.ph = p.ph + dt*(0.7 + (i%7)*0.35)
			p.f.BackgroundTransparency = 0.12 + (math.sin(p.ph)+1)*0.36
			p.f.Position = UD.fromOffset(math.floor(p.x), math.floor(p.y))
		end
		for n,b in ipairs(themeBands) do
			b.ph = b.ph + dt*0.26
			b.f.Position = UD.fromOffset(math.floor(b.x + math.sin(b.ph)*12), math.floor(b.y + math.cos(b.ph*0.7)*8))
			b.f.BackgroundTransparency = 0.9 + (math.sin(b.ph*1.3)+1)*0.025
		end
		for n,s in ipairs(themeShoots) do
			s.ph = s.ph - dt
			if s.ph <= 0 then
				s.f.Visible = false
				s.ph = 1.5 + math.random()*3.4
				s.x = math.random() * w * 0.75
				s.y = math.random() * h * 0.45 - 26
			elseif s.f.Visible then
				s.x = s.x + s.v*dt
				s.y = s.y + s.v*0.45*dt
				if s.x > w + 16 or s.y > h + 16 then s.f.Visible = false end
				s.f.Position = UD.fromOffset(math.floor(s.x), math.floor(s.y))
			else
				s.f.Visible = true
				s.ph = 0.6
				s.v = 430 + math.random()*220
			end
		end
	end
end
themeShut = function()
	for _,p in ipairs(themeParts) do p.f.Visible = false end
	for _,b in ipairs(themeBands) do b.f.Visible = false end
	for _,s in ipairs(themeShoots) do s.f.Visible = false end
	themeIdx = 1
end
_G.THEME_IDX = function() return themeIdx end
_G.THEME_PARTS = themeParts
_G.THEME_BANDS = themeBands
_G.THEME_SHOOTS = themeShoots
_G.THEME_LAYER = themeLayer

techCorners(main,C.Line,12,1,0.88)
local mainAnim = false
local mainScale = new("UIScale",{Scale=1,Parent=main})
local mainBase = 1
local userScale = 1
local function fitMain()
	mainBase = math.clamp(math.min((CAM.ViewportSize.X - 30) / WIN_W, (CAM.ViewportSize.Y - 30) / WIN_H), 0.72, MAIN_SCALE)
	if not mainAnim then mainScale.Scale = mainBase * userScale end
end
fitMain()
CAM:GetPropertyChangedSignal("ViewportSize"):Connect(fitMain)
mainHomePos = UD.fromOffset(math.max(8,(CAM.ViewportSize.X - WIN_W * mainBase) / 2),
	math.max(8,(CAM.ViewportSize.Y - WIN_H * mainBase) / 2))
main.Position = mainHomePos

local mTopGrad = grad(new("Frame",{Size=UD.new(1,-24,0,2),Position=UD.new(0,12,0,0),
	BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=main}),C.Line,C.Line,0)
mTopGrad.Transparency=NumberSequence.new(1)

local titleBar = new("Frame",{Size=UD.new(1,0,0,32),BackgroundColor3=C.Panel,
	BorderSizePixel=0,Parent=main})
corner(titleBar,8)
local titleFill = new("Frame",{Position=UD.new(0,0,0,24),Size=UD.new(1,0,0,8),
	BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=main})

local dragHandle = new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,
	Text="",AutoButtonColor=false,ZIndex=1,Parent=titleBar})

local logoMini = new("Frame",{Position=UD.fromOffset(9,5),Size=UD.fromOffset(22,22),
	BackgroundTransparency=1,BorderSizePixel=0,Parent=titleBar})
local logoOrbit = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),
	Size=UD.fromOffset(15,15),BackgroundTransparency=1,Parent=logoMini})
local logoOrbitDot = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(1,0,.5,0),
	Size=UD.fromOffset(3,3),BackgroundColor3=ACC,BorderSizePixel=0,Parent=logoOrbit})
corner(logoOrbitDot,1.5)
pick(logoOrbitDot,"BackgroundColor3")
local logoCore = diamond(logoMini,8.5,8.5,5,ACC,0)
pick(logoCore,"BackgroundColor3")
diamond(logoMini,9.5,9.5,3,C.Bg,0)
local tIcon = new("Frame",{Position=UD.fromOffset(32,0),Size=UD.fromOffset(32,32),
	BackgroundTransparency=1,Parent=titleBar})
local tOrbit = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),
	Size=UD.fromOffset(26,26),BackgroundTransparency=1,Parent=tIcon})
local tCore = diamond(tIcon,10,10,12,ACC,0)
pick(tCore,"BackgroundColor3")
diamond(tIcon,13,13,6,C.Bg,0)

local titleLbl = new("TextLabel",{Position=UD.fromOffset(68,3),Size=UD.new(1,-120,0,14),BackgroundTransparency=1,
	Text=C.Title,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=13,
	TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})
local titleGrad = grad(titleLbl,ACC,C.Purple,0)
tint(function(c) titleGrad.Color = ColorSequence.new(c,C.Purple) end)
C.SubLbl = new("TextLabel",{Position=UD.fromOffset(68,17),Size=UD.new(1,-120,0,10),BackgroundTransparency=1,
	Text=tostring(cfg.SubTitle or "由i制作"),TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=9,
	TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})
C.TabNG[C.SubLbl] = true
new("TextLabel",{Position=UD.fromOffset(136,0),Size=UD.new(1,-200,1,0),BackgroundTransparency=1,
	Text=C.Version,TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
	TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})

local onlineDot = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(1,-68,.5,0),
	Size=UD.fromOffset(6,6),BackgroundColor3=ACC,BorderSizePixel=0,Parent=titleBar})
corner(onlineDot,3)
pick(onlineDot,"BackgroundColor3")
local onlineLbl = new("TextLabel",{Position=UD.new(1,-58,.5,-5),Size=UD.fromOffset(28,10),BackgroundTransparency=1,
	Text="ONLINE",TextColor3=ACC,Font=Enum.Font.GothamMedium,TextSize=11,
	TextXAlignment=Enum.TextXAlignment.Left,Parent=titleBar})
pick(onlineLbl,"TextColor3")

local sidebar = new("Frame",{Position=UD.new(0,0,0,32),Size=UD.new(0.35,0,1,-56),
	BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=main})
new("Frame",{Position=UD.new(1,-1,0,0),Size=UD.new(0,1,1,0),
	BackgroundColor3=C.Line,BackgroundTransparency=0.35,BorderSizePixel=0,Parent=sidebar})

C.TabBlue = Color3.fromRGB(74,132,255)
local tabState = {names={},btns={},items={}}
local tabY = 10

local tabScroll = new("ScrollingFrame",{Size=UD.new(1,0,1,-72),BackgroundTransparency=1,
	BorderSizePixel=0,CanvasSize=UD.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
	ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=2,ScrollBarImageColor3=C.Line,ScrollBarImageTransparency=0.25,
	ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,Parent=sidebar})
pad(tabScroll,0,0,6,6)

local content = new("Frame",{Position=UD.new(0.35,0,0,32),Size=UD.new(0.65,0,1,-56),
	BackgroundColor3=C.Bg,BackgroundTransparency=1,ClipsDescendants=true,Parent=main})
local pages = {}
local currentTab = 0
local switchTab
local dropCtl
local function addTab(name)
	local i = #tabState.names + 1
	tabState.names[i] = name
	local on0 = (i==1)
	local item = new("Frame",{Position=UD.fromOffset(8,tabY),Size=UD.new(1,-16,0,34),
		BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=tabScroll})
	tabY = tabY + 38
	corner(item,7)
	local hili = new("Frame",{Size=UD.fromScale(1,1),BackgroundColor3=ACC,
		BackgroundTransparency=on0 and 0.55 or 1,BorderSizePixel=0,Parent=item})
	corner(hili,7)
	grad(hili,ACC,C.Panel,0)
	pick(hili,"BackgroundColor3")
	tint(function(c) hili.UIGradient.Color = ColorSequence.new(c,C.Panel) end)
	local bar = new("Frame",{Position=UD.fromOffset(0,9),Size=UD.fromOffset(3,16),
		BackgroundColor3=ACC,BackgroundTransparency=on0 and 0 or 1,BorderSizePixel=0,Parent=item})
	corner(bar,1.5)
	pick(bar,"BackgroundColor3")
	local lbl = new("TextLabel",{Position=UD.fromOffset(16,0),Size=UD.new(1,-24,1,0),
		BackgroundTransparency=1,Text=name,TextColor3=on0 and C.Text or C.Dim,
		Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=item})
	local hit = new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",
		AutoButtonColor=false,Parent=item})
	tabState.btns[i]=hit
	tabState.items[i]={item=item,hili=hili,bar=bar,lbl=lbl}
	local pg = new("ScrollingFrame",{Position=UD.fromOffset(0,0),Size=UD.new(1,0,1,0),BackgroundTransparency=1,
		BorderSizePixel=0,Visible=(i==1),CanvasSize=UD.new(0,0,0,0),
		AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,
		ScrollBarThickness=2,ScrollBarImageColor3=C.Line,ScrollBarImageTransparency=0.25,
		VerticalScrollBarInset=Enum.ScrollBarInset.ScrollBar,
		ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,Parent=content})
	pages[i] = pg
	pg:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if dropCtl and dropCtl.open then dropCtl.open() end
	end)
	hit.Activated:Connect(function() if switchTab then switchTab(i) end end)
	hit.MouseEnter:Connect(function()
		if i~=currentTab then
			tw(tabState.items[i].hili,0.15,{BackgroundTransparency=0.75})
			tw(tabState.items[i].lbl,0.15,{TextColor3=C.Text})
		end
	end)
	hit.MouseLeave:Connect(function()
		if i~=currentTab then
			tw(tabState.items[i].hili,0.15,{BackgroundTransparency=1})
			tw(tabState.items[i].lbl,0.15,{TextColor3=C.Dim})
		end
	end)
	if on0 then currentTab = 1 end
	return i, pg
end

local ROW_H, ROW_SP = 46, 46
local SLIDER_H, SLIDER_SP = ROW_H, ROW_SP

local headFold, foldCache = {}, {}
local foldPage
local function head(parent,text)
	local l = new("TextLabel",{Position=UD.fromOffset(4,1),Size=UD.new(1,-36,0,16),BackgroundTransparency=1,
		Text=text,TextColor3=C.TabBlue,Font=Enum.Font.GothamBold,TextSize=15,
		TextXAlignment=Enum.TextXAlignment.Left,Parent=parent})
	C.TabNG[l] = true
	local b = new("TextButton",{Position=UD.fromOffset(4 + textW(l) + 6,2),
		Size=UD.fromOffset(22,14),BackgroundColor3=C.Panel,BorderSizePixel=0,Text="▲",
		TextColor3=ACC,Font=Enum.Font.GothamBold,TextSize=10,
		TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,
		AutoButtonColor=false,Parent=parent})
	corner(b,4)
	stroke(b,C.Line,1,0.4)
	pick(b,"TextColor3")
	b.MouseEnter:Connect(function() tw(b,0.1,{BackgroundColor3=C.Panel2}) end)
	b.MouseLeave:Connect(function() tw(b,0.1,{BackgroundColor3=C.Panel}) end)
	headFold[parent] = {lbl=l,btn=b}
	b.Activated:Connect(function() foldPage(parent) end)
	return l
end
foldPage = function(pg)
	local h = headFold[pg]
	local st = foldCache[pg]
	if not st then
		st = {items={},hidden=false,seq=0}
		for _,c in ipairs(pg:GetChildren()) do
			if c:IsA("GuiObject") and c ~= h.lbl and c ~= h.btn then
				st.items[#st.items+1] = {o=c,p=c.Position,s=c.Size,v=c.Visible}
			end
		end
		table.sort(st.items,function(a,b)
			local ay = a.p.Y.Scale * 10000 + a.p.Y.Offset
			local by = b.p.Y.Scale * 10000 + b.p.Y.Offset
			return ay < by
		end)
		foldCache[pg] = st
	end
	if dropCtl.open then dropCtl.open() end
	st.hidden = not st.hidden
	st.seq = (st.seq or 0) + 1
	local my = st.seq
	h.btn.Text = st.hidden and "▼" or "▲"
	local n = #st.items
	local step = 0.045
	local keep = st.items[1]
	if st.hidden then
		for i = n,1,-1 do
			local it = st.items[i]
			local d = (n - i) * step
			if i == 1 then
				task.delay(n * step,function()
					if st.seq ~= my then return end
					it.o.Visible = false
					it.o.Size = UD.fromOffset(0,0)
					it.o.Position = it.p
				end)
			else
				task.delay(d,function()
					if st.seq ~= my then return end
					tw(it.o,0.12,{Position=UD.new(it.p.X.Scale,it.p.X.Offset,it.p.Y.Scale,it.p.Y.Offset-14)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
					task.delay(0.13,function()
						if st.seq ~= my then return end
						it.o.Visible = false
						it.o.Size = UD.fromOffset(0,0)
						it.o.Position = UD.fromOffset(0,0)
					end)
				end)
			end
		end
		task.delay(n * step + 0.3,function()
			if st.seq ~= my then return end
			pg.AutomaticCanvasSize = Enum.AutomaticSize.None
			pg.CanvasSize = UD.new(0,0,0,20)
		end)
	else
		pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
		pg.CanvasSize = UD.new(0,0,0,0)
		for i = 1,n do
			local it = st.items[i]
			local d = (i - 1) * step
			if i == 1 then
				it.o.Size = it.s
				it.o.Position = it.p
				it.o.Visible = it.v
			else
				task.delay(d,function()
					if st.seq ~= my then return end
					it.o.Size = it.s
					it.o.Position = UD.new(it.p.X.Scale,it.p.X.Offset,it.p.Y.Scale,it.p.Y.Offset-14)
					it.o.Visible = it.v
					tw(it.o,0.14,{Position=it.p},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
				end)
			end
		end
	end
end

local pageY = {}
local function nextY(p,h)
	local y = pageY[p] or 20
	pageY[p] = y + h
	return y
end

local function cardShell(parent,y,h)
	local row = new("Frame",{Position=UD.fromOffset(0,y),Size=UD.new(1,0,0,h),
		BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=parent})
	local rStroke = stroke(row,C.Line,1,1)
	local bar = new("Frame",{Position=UD.fromOffset(10,h-1),Size=UD.new(1,-20,0,1),
		BackgroundColor3=C.Line,BackgroundTransparency=0.45,BorderSizePixel=0,Parent=row})
	return row, rStroke, bar
end

local function chipRow(parent,i,step,text,z,mark)
	local o = new("TextButton",{Position=UD.fromOffset(4,(i-1)*step+2),Size=UD.new(1,-8,0,step-4),
		BackgroundColor3=C.Panel,BorderSizePixel=0,Text="",AutoButtonColor=false,
		ZIndex=z,Parent=parent})
	corner(o,6)
	local hili = new("Frame",{Size=UD.fromScale(1,1),BackgroundColor3=ACC,BackgroundTransparency=1,
		BorderSizePixel=0,ZIndex=z,Parent=o})
	corner(hili,6)
	local hg = grad(hili,ACC,C.Panel,0)
	pick(hili,"BackgroundColor3")
	tint(function(c) hg.Color = ColorSequence.new(c,C.Panel) end)
	local bar = new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,4,.5,0),
		Size=UD.fromOffset(2,9),BackgroundColor3=ACC,BackgroundTransparency=1,
		BorderSizePixel=0,ZIndex=z+1,Parent=o})
	corner(bar,1)
	pick(bar,"BackgroundColor3")
	local mk = nil
	if mark then
		mk = new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,9,.5,0),
			Size=UD.fromOffset(9,9),BackgroundColor3=C.Line,BorderSizePixel=0,ZIndex=z+1,Parent=o})
		corner(mk,2)
	end
	local lbl = new("TextLabel",{Position=UD.fromOffset(mark and 22 or 10,0),
		Size=UD.new(1,mark and -34 or -16,1,0),
		BackgroundTransparency=1,Text=text,TextColor3=C.Text,Font=Enum.Font.GothamBold,
		TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
		TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=z+1,Parent=o})
	return {btn=o,hili=hili,bar=bar,lbl=lbl,mark=mk}
end


local cfgReg, cfgMap, cfgSeq = {}, {}, {}
local function cfgAdd(label,get,set)
	cfgSeq[label] = (cfgSeq[label] or 0) + 1
	local key = label.."#"..cfgSeq[label]
	cfgMap[key] = set
	cfgReg[#cfgReg+1] = {k=key,g=get}
end

local function makeToggle(parent,y,h,label,desc,accent,cb,default)
	local row,rStroke,bar = cardShell(parent,y,h)
	local descLbl = new("TextLabel",{Position=UD.fromOffset(14,26),Size=UD.new(1,-64,0,12),
		BackgroundTransparency=1,Text=desc,TextColor3=C.Dim,Font=Enum.Font.GothamMedium,
		TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	new("TextLabel",{Position=UD.fromOffset(14,9),Size=UD.new(1,-64,0,14),BackgroundTransparency=1,
		Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	local track = new("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-14,.5,0),
		Size=UD.fromOffset(30,16),BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=row})
	corner(track,8)
	local tStroke = stroke(track,C.Line,1,0.2)
	local knob = new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,2,.5,0),
		Size=UD.fromOffset(12,12),BackgroundColor3=C.Dim,BorderSizePixel=0,Parent=track})
	corner(knob,6)
	local hit = new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,
		Text="",AutoButtonColor=false,Parent=row})
	local on = false
	local priming = true
	local function setOn(v)
		v = v and true or false
		if on == v then return end
		on = v
		tw(knob,0.18,{
			Position=on and UD.new(0,16,.5,0) or UD.new(0,2,.5,0),
			BackgroundColor3=on and ACC or C.Dim,
		},Enum.EasingStyle.Back)
		tStroke.Color = on and ACC or C.Line
		tStroke.Transparency = on and 0.2 or 0.6
		tw(bar,0.15,{BackgroundColor3=on and ACC or C.Line})
		descLbl.TextColor3 = on and ACC or C.Dim
		tw(row,0.15,{BackgroundColor3=on and C.Panel2 or C.Panel})
		if cb and not priming then pcall(cb,on) end
	end
	if default then setOn(true) end
	priming = false
	hit.Activated:Connect(function() setOn(not on) end)
	cfgAdd(label,function() return on end,setOn)
	tint(function(c)
		if on then
			knob.BackgroundColor3 = c
			tStroke.Color = c
			bar.BackgroundColor3 = c
			descLbl.TextColor3 = c
		end
	end)
	return {Set=setOn, Get=function() return on end}
end

local function makeSlider(parent,y,h,label,accent,defaultPct,cb)
	local row,rStroke,bar = cardShell(parent,y,h)
	local pct = tonumber(defaultPct) or 0
	if pct <= 1 then pct = pct*100 end
	pct = math.clamp(pct,0,100)/100
	new("TextLabel",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,14,.5,0),
		Size=UD.new(0.3,-14,0,14),BackgroundTransparency=1,
		Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	local valLbl = new("TextLabel",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-14,.5,0),
		Size=UD.fromOffset(40,14),BackgroundTransparency=1,Text=math.floor(pct*100+0.5).."%",
		TextColor3=ACC,Font=Enum.Font.GothamMedium,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Right,Parent=row})
	local track = new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0.3,0,.5,0),
		Size=UD.new(0.7,-60,0,4),BackgroundColor3=C.Void,BorderSizePixel=0,Parent=row})
	corner(track,2)
	local fill = new("Frame",{Size=UD.new(pct,0,1,0),
		BackgroundColor3=ACC,BorderSizePixel=0,Parent=track})
	corner(fill,2)
	local dot = new("Frame",{AnchorPoint=Vector2.new(.5,.5),
		Position=UD.new(pct,0,.5,0),
		Size=UD.fromOffset(12,12),BackgroundColor3=C.Text,BorderSizePixel=0,Parent=track})
	corner(dot,6); stroke(dot,C.Void,2,0)
	local hit = new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,
		Text="",AutoButtonColor=false,Parent=track})
	local dragging = false
	local function update(input)
		local p = math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
		pct = p
		fill.Size = UD.new(p,0,1,0)
		dot.Position = UD.new(p,0,.5,0)
		valLbl.Text = math.floor(p*100).."%"
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true; update(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			update(input)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			if dragging and cb then pcall(cb,math.floor(pct*100+0.5)) end
			dragging=false
		end
	end)
	local function setPct(v)
		v = tonumber(v) or (pct*100)
		if v > 1 or v < 0 then v = v/100 end
		pct = math.clamp(v,0,1)
		fill.Size = UD.new(pct,0,1,0)
		dot.Position = UD.new(pct,0,.5,0)
		valLbl.Text = math.floor(pct*100+0.5).."%"
		if cb then pcall(cb,math.floor(pct*100+0.5)) end
	end
	cfgAdd(label,function() return math.floor(pct*100+0.5) end,setPct)
	tint(function(c)
		fill.BackgroundColor3 = c
		valLbl.TextColor3 = c
	end)
	return {Set=setPct, Get=function() return math.floor(pct*100+0.5) end}
end

dropCtl = {}

local DROP_H = ROW_H
local OP_H = 20
local LIST_X, LIST_W = 0.70, 0.30

local function makeAction(parent,y,h,label,desc,accent,onFire)
	local row,rStroke,bar = cardShell(parent,y,h)
	new("TextLabel",{Position=UD.fromOffset(14,6),Size=UD.new(1,-96,0,14),BackgroundTransparency=1,
		Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	new("TextLabel",{Position=UD.fromOffset(14,22),Size=UD.new(1,-96,0,12),BackgroundTransparency=1,
		Text=desc,TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	local tag = new("TextLabel",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-16,.5,0),
		Size=UD.fromOffset(86,14),BackgroundTransparency=1,Text="点击触发",TextColor3=C.Dim,
		Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,
		TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	local hit = new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",
		AutoButtonColor=false,Parent=row})
	hit.MouseEnter:Connect(function()
		tw(row,0.15,{BackgroundColor3=C.Panel2})
		tag.TextColor3 = ACC
	end)
	hit.MouseLeave:Connect(function()
		tw(row,0.15,{BackgroundColor3=C.Panel})
		tag.TextColor3 = C.Dim
	end)
	hit.Activated:Connect(function()
		tw(bar,0.12,{BackgroundColor3=ACC})
		tw(row,0.12,{BackgroundColor3=C.Panel2})
		tag.Text = "已触发"
		tag.TextColor3 = ACC
		if onFire then onFire() end
		task.delay(0.45,function()
			tw(bar,0.25,{BackgroundColor3=C.Line})
			tw(row,0.25,{BackgroundColor3=C.Panel})
			tag.Text = "点击触发"
			tag.TextColor3 = C.Dim
		end)
	end)
end

local function dropHead(parent,y,h,label,desc,accent,valW)
	local row,rStroke,bar = cardShell(parent,y,h)
	new("TextLabel",{Position=UD.fromOffset(12,6),Size=UD.new(1,-180,0,14),BackgroundTransparency=1,
		Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	new("TextLabel",{Position=UD.fromOffset(12,22),Size=UD.new(1,-180,0,12),BackgroundTransparency=1,
		Text=desc,TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	local valLbl = new("TextLabel",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-24,.5,0),
		Size=UD.fromOffset(valW or 100,13),BackgroundTransparency=1,Text="",
		TextColor3=ACC,Font=Enum.Font.GothamMedium,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	local arrow = new("TextLabel",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-9,.5,0),
		Size=UD.fromOffset(11,11),BackgroundTransparency=1,Text="▼",TextColor3=ACC,
		Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center,
		TextYAlignment=Enum.TextYAlignment.Center,Parent=row})
	pick(valLbl,"TextColor3")
	pick(arrow,"TextColor3")
	return row,valLbl,arrow
end

local function buildList(y,h,count,accent,rowRef)
	local full = count * OP_H
	local list = new("ScrollingFrame",{Position=UD.new(LIST_X,0,0,0),
		Size=UD.new(LIST_W,0,0,full),BackgroundColor3=C.Panel2,BorderSizePixel=0,
		Visible=false,ZIndex=30,CanvasSize=UD.new(0,0,0,full),
		ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=2,
		ScrollBarImageColor3=ACC,ScrollBarImageTransparency=0.25,
		ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,Parent=main})
	corner(list,10)
	local lStroke = stroke(list,ACC,1,0.3)
	pick(list,"ScrollBarImageColor3")
	pick(lStroke,"Color")
	local catcher = new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",
		AutoButtonColor=false,Visible=false,ZIndex=29,Parent=main})
	local function layout()
		local mainH = main.Size.Y.Offset
		local sc = 1
		if mainH > 0 and main.AbsoluteSize.Y > 0 then sc = main.AbsoluteSize.Y / mainH end
		if sc <= 0 then sc = 1 end
		local top = (rowRef.AbsolutePosition.Y - main.AbsolutePosition.Y) / sc + h + 2
		local room = (mainH - 8) - top
		local lh = math.min(full, math.max(OP_H * 2, room))
		local ly = math.min(top, mainH - 8 - lh)
		if ly < 34 then ly = 34 end
		list.Size = UD.new(LIST_W,0,0,lh)
		list.CanvasSize = UD.new(0,0,0,full)
		return ly, true
	end
	return list,catcher,layout
end

local function wireDrop(row,arrow,list,catcher,layout)
	local hit = new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",
		AutoButtonColor=false,Parent=row})
	local open = false
	local dseq, dirY = 0, -14
	local function close()
		if not open then return end
		open = false
		dseq = dseq + 1
		local my = dseq
		catcher.Visible = false
		local ly = list.Position.Y.Offset
		tw(arrow,0.16,{Rotation=0},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
		tw(list,0.16,{Position=UD.new(LIST_X,0,0,ly + dirY)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
		task.delay(0.17,function()
			if dseq == my then list.Visible = false end
		end)
		if dropCtl.open == close then dropCtl.open = nil end
	end
	hit.MouseEnter:Connect(function() tw(row,0.15,{BackgroundColor3=C.Panel2}) end)
	hit.MouseLeave:Connect(function()
		if not open then tw(row,0.15,{BackgroundColor3=C.Panel}) end
	end)
	hit.Activated:Connect(function()
		if open then close() return end
		if dropCtl.open then dropCtl.open() end
		open = true
		dseq = dseq + 1
		dropCtl.open = close
		local ly, below = layout()
		list.CanvasPosition = Vector2.new(0,0)
		list.Visible = true
		catcher.Visible = true
		dirY = below and -14 or 14
		list.Position = UD.new(LIST_X,0,0,ly + dirY)
		tw(list,0.2,{Position=UD.new(LIST_X,0,0,ly)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
		tw(arrow,0.18,{Rotation=180},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
	end)
	catcher.Activated:Connect(function() close() end)
end

local function makeSelect(parent,y,h,label,desc,options,selIdx,accent,cb)
	local row,valLbl,arrow = dropHead(parent,y,h,label,desc,accent,100)
	local list,catcher,layout = buildList(y,h,#options,accent,row)
	local rows = {}
	local sel = selIdx or 1
	local function paint()
		for j,r in ipairs(rows) do
			local on = (j == sel)
			r.hili.BackgroundTransparency = on and 0.62 or 1
			r.bar.BackgroundTransparency = on and 0 or 1
			r.lbl.TextColor3 = on and ACC or C.Text
		end
		valLbl.Text = options[sel]
	end
	for i,name in ipairs(options) do
		local r = chipRow(list,i,OP_H,name,31,false)
		r.btn.MouseEnter:Connect(function()
			if i~=sel then tw(r.btn,0.1,{BackgroundColor3=C.Panel2}) end
		end)
		r.btn.MouseLeave:Connect(function()
			if i~=sel then tw(r.btn,0.1,{BackgroundColor3=C.Panel}) end
		end)
		r.btn.Activated:Connect(function()
			sel = i
			paint()
			if dropCtl.open then dropCtl.open() end
			if cb then pcall(cb,sel,name) end
		end)
		rows[i] = r
	end
	paint()
	cfgAdd(label,function() return sel end,function(v)
		sel = math.clamp(math.floor(tonumber(v) or sel),1,#options)
		paint()
	end)
	wireDrop(row,arrow,list,catcher,layout)
	return {
		Set=function(v) sel = math.clamp(math.floor(tonumber(v) or sel),1,#options); paint() end,
		Get=function() return sel, options[sel] end,
	}
end

local function makeMulti(parent,y,h,label,desc,options,preset,accent,cb)
	local row,valLbl,arrow = dropHead(parent,y,h,label,desc,accent,100)
	local list,catcher,layout = buildList(y,h,#options,accent,row)
	local rows = {}
	local on = {}
	for _,i in ipairs(preset or {}) do on[i] = true end
	local function paint()
		local n = 0
		for j,r in ipairs(rows) do
			local s = on[j] and true or false
			if s then n = n + 1 end
			r.hili.BackgroundTransparency = s and 0.62 or 1
			r.bar.BackgroundTransparency = s and 0 or 1
			r.lbl.TextColor3 = s and accent or C.Text
			r.mark.BackgroundColor3 = s and accent or C.Line
		end
		valLbl.Text = "已选 "..n.." 项"
	end
	tint(paint)
	for i,name in ipairs(options) do
		local r = chipRow(list,i,OP_H,name,31,true)
		r.btn.Activated:Connect(function()
			on[i] = not on[i]
			paint()
			if cb then pcall(cb,on) end
		end)
		rows[i] = r
	end
	paint()
	cfgAdd(label,function()
		local t = {}
		for i = 1,#options do if on[i] then t[#t+1] = i end end
		return t
	end,function(v)
		on = {}
		if type(v) == "table" then
			for _,x in ipairs(v) do
				local i = math.floor(tonumber(x) or 0)
				if i >= 1 and i <= #options then on[i] = true end
			end
		end
		paint()
	end)
	wireDrop(row,arrow,list,catcher,layout)
end

local function makeNumber(parent,y,h,label,desc,accent,default,min,max,cb)
	local row,rStroke,bar = cardShell(parent,y,h)
	new("TextLabel",{Position=UD.fromOffset(12,6),Size=UD.new(1,-170,0,14),BackgroundTransparency=1,
		Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	new("TextLabel",{Position=UD.fromOffset(12,22),Size=UD.new(1,-170,0,12),BackgroundTransparency=1,
		Text=desc,TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	local val = math.clamp(math.floor((tonumber(default) or 0)+0.5),min,max)
	local box = new("TextBox",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-80,.5,0),
		Size=UD.fromOffset(54,24),BackgroundColor3=C.Panel2,BorderSizePixel=0,
		Text=tostring(val),TextColor3=C.Text,Font=Enum.Font.GothamMedium,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=false,Parent=row})
	corner(box,6); stroke(box,C.Line,1,0.3)
	local function commit(v)
		val = math.clamp(math.floor((tonumber(v) or val)+0.5),min,max)
		box.Text = tostring(val)
		if cb then pcall(cb,val) end
	end
	local function stepBtn(x,txt)
		local b = new("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,x,.5,0),
			Size=UD.fromOffset(30,24),BackgroundColor3=C.Panel2,BorderSizePixel=0,
			Text=txt,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
			AutoButtonColor=false,Parent=row})
		corner(b,6)
		b.MouseEnter:Connect(function()
			tw(b,0.12,{BackgroundColor3=C.Panel})
			b.TextColor3 = ACC
		end)
		b.MouseLeave:Connect(function()
			tw(b,0.12,{BackgroundColor3=C.Panel2})
			b.TextColor3 = C.Text
		end)
		return b
	end
	local minus = stepBtn(-46,"减")
	local plus = stepBtn(-12,"加")
	box:GetPropertyChangedSignal("Text"):Connect(function()
		local t = box.Text:gsub("%D","")
		if #t > 10 then t = t:sub(1,10) end
		if t ~= box.Text then box.Text = t end
	end)
	box.Focused:Connect(function()
		box.TextColor3 = ACC
		tw(box,0.15,{BackgroundTransparency=0.2})
	end)
	box.FocusLost:Connect(function()
		box.TextColor3 = ACC
		tw(box,0.15,{BackgroundTransparency=0})
		commit(box.Text)
	end)
	minus.Activated:Connect(function() commit(val-1) end)
	plus.Activated:Connect(function() commit(val+1) end)
	cfgAdd(label,function() return val end,function(v) commit(v) end)
	return {Set=commit, Get=function() return val end}
end

local setOpen
local setPanel

local function makeInput(parent,y,h,label,desc,default,placeholder,cb)
	local row,rStroke,bar = cardShell(parent,y,h)
	new("TextLabel",{Position=UD.fromOffset(12,6),Size=UD.new(1,-270,0,14),BackgroundTransparency=1,
		Text=label,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	new("TextLabel",{Position=UD.fromOffset(12,22),Size=UD.new(1,-270,0,12),BackgroundTransparency=1,
		Text=desc,TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	local box = new("TextBox",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-12,.5,0),
		Size=UD.fromOffset(244,24),BackgroundColor3=C.Panel2,BorderSizePixel=0,
		Text=default or "",PlaceholderText=placeholder or "可输入中文",
		PlaceholderColor3=C.Dim,TextColor3=C.Text,Font=Enum.Font.Gotham,
		TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=row})
	pad(box,8,8,0,0)
	corner(box,6); stroke(box,C.Line,1,0.3)
	box.Focused:Connect(function()
		box.TextColor3 = ACC
		tw(box,0.15,{BackgroundTransparency=0.2})
	end)
	box.FocusLost:Connect(function()
		box.TextColor3 = C.Text
		tw(box,0.15,{BackgroundTransparency=0})
		if cb then pcall(cb,box.Text) end
	end)
	cfgAdd(label,function() return box.Text end,function(v) box.Text = tostring(v or "") end)
	return box
end


switchTab = function(idx)
	if idx==currentTab then return end
	if dropCtl.open then dropCtl.open() end
	for i,pg in ipairs(pages) do
		pg.Position = UD.fromOffset(0,0)
		pg.Visible = (i==idx)
	end
	for i,t in ipairs(tabState.items) do
		local sel = (i==idx)
		t.hili.BackgroundTransparency = sel and 0.55 or 1
		tw(t.lbl,0.18,{TextColor3=sel and C.Text or C.Dim})
		t.bar.BackgroundTransparency = sel and 0 or 1
	end
	currentTab = idx
end
local statusBar = new("Frame",{Position=UD.new(0,0,1,-24),Size=UD.new(1,0,0,24),
	BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=main})
corner(statusBar,8)
local sbStrip = new("Frame",{Position=UD.new(0,0,0,0),Size=UD.new(1,0,0,8),
	BackgroundColor3=C.Panel2,BorderSizePixel=0,Parent=statusBar})
local sbTopLine = new("Frame",{Position=UD.new(0,0,0,0),Size=UD.new(1,0,0,1),
	BackgroundColor3=C.Line,BackgroundTransparency=0.4,BorderSizePixel=0,Parent=statusBar})
local sBlink = new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,10,.5,0),
	Size=UD.fromOffset(5,5),BackgroundColor3=ACC,BorderSizePixel=0,Parent=statusBar})
corner(sBlink,2.5)
pick(sBlink,"BackgroundColor3")
local readyLbl = new("TextLabel",{Position=UD.fromOffset(20,0),Size=UD.fromOffset(90,24),BackgroundTransparency=1,
	Text="READY",TextColor3=ACC,Font=Enum.Font.GothamMedium,TextSize=12,
	TextXAlignment=Enum.TextXAlignment.Left,Parent=statusBar})
pick(readyLbl,"TextColor3")
local fpsVal, fpsAcc, fpsN = 0, 0, 0
local hud = new("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-8,.5,0),
	Size=UD.fromOffset(152,20),BackgroundColor3=C.Panel2,BackgroundTransparency=0.35,
	BorderSizePixel=0,ZIndex=6,Parent=statusBar})
corner(hud,10)
stroke(hud,C.Line,1,0.4)
local hudDot = new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,7,.5,0),
	Size=UD.fromOffset(5,5),BackgroundColor3=ACC,BorderSizePixel=0,ZIndex=7,Parent=hud})
corner(hudDot,2.5)
pick(hudDot,"BackgroundColor3")
local hudPing = new("TextLabel",{Position=UD.fromOffset(16,0),Size=UD.new(0,72,1,0),
	BackgroundTransparency=1,Text="PING --",TextColor3=C.Text,Font=Enum.Font.GothamMedium,
	TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7,Parent=hud})
local hudFps = new("TextLabel",{AnchorPoint=Vector2.new(1,0),Position=UD.new(1,-8,0,0),
	Size=UD.new(0,66,1,0),BackgroundTransparency=1,Text="FPS --",TextColor3=C.Text,
	Font=Enum.Font.GothamMedium,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,
	ZIndex=7,Parent=hud})
local pingItem = nil
pcall(function()
	pingItem = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
end)
local lastPing = "--"
task.spawn(function()
	while hud.Parent do
		if pingItem then
			local ok, v = pcall(function() return pingItem:GetValue() end)
			if ok and type(v) == "number" and v == v then
				lastPing = string.format("%dms", math.floor(v+0.5))
			end
		end
		hudPing.Text = "PING "..lastPing
		hudFps.Text = "FPS "..(fpsVal > 0 and tostring(fpsVal) or "--")
		task.wait(0.5)
	end
end)

local CFG_DIR = "XJW_HUB_CFG"
local function cfgFn(n)
	local f = rawget(_G,n)
	if type(f) == "function" then return f end
	local ok,g = pcall(getgenv)
	if ok and type(g) == "table" and type(g[n]) == "function" then return g[n] end
	local v
	pcall(function()
		if n == "writefile" then v = writefile
		elseif n == "readfile" then v = readfile
		elseif n == "isfile" then v = isfile
		elseif n == "isfolder" then v = isfolder
		elseif n == "makefolder" then v = makefolder
		elseif n == "listfiles" then v = listfiles
		elseif n == "delfile" then v = delfile
		elseif n == "getclipboard" then v = getclipboard
		elseif n == "setclipboard" then v = setclipboard
		elseif n == "writeclipboard" then v = writeclipboard end
	end)
	if type(v) == "function" then return v end
	return nil
end
local function cfgSerialize()
	local out = {}
	for _,r in ipairs(cfgReg) do
		local ok,v = pcall(r.g)
		if ok then
			local t
			local tv = type(v)
			if tv == "boolean" then
				t = "b:"..(v and "1" or "0")
			elseif tv == "number" then
				t = "n:"..tostring(v)
			elseif tv == "table" then
				local a = {}
				for _,x in ipairs(v) do a[#a+1] = tostring(x) end
				t = "l:"..table.concat(a,",")
			else
				t = "s:"..tostring(v):gsub("\n","\\n")
			end
			out[#out+1] = r.k.."\t"..t
		end
	end
	return table.concat(out,"\n")
end
local function cfgSave(name)
	local w = cfgFn("writefile")
	if not w then return false,"当前环境不支持写文件" end
	local isd, mk = cfgFn("isfolder"), cfgFn("makefolder")
	if isd and mk then pcall(function() if not isd(CFG_DIR) then mk(CFG_DIR) end end) end
	local ok = pcall(w,CFG_DIR.."/"..name..".cfg",cfgSerialize())
	if ok then return true,"已保存配置 "..name end
	return false,"保存失败"
end
local function cfgFiles()
	local lf = cfgFn("listfiles")
	local out = {}
	if not lf then return out end
	local ok,res = pcall(lf,CFG_DIR)
	if ok and type(res) == "table" then
		for _,p in ipairs(res) do
			local n = tostring(p):match("([^/\\]+)%.cfg$")
			if n then out[#out+1] = n end
		end
	end
	table.sort(out)
	return out
end
local function cfgLoad(name)
	local r = cfgFn("readfile")
	if not r then return false,"当前环境不支持读文件" end
	local ok,txt = pcall(r,CFG_DIR.."/"..name..".cfg")
	if not ok or type(txt) ~= "string" then return false,"读取失败" end
	local n = 0
	for line in (txt.."\n"):gmatch("([^\n]*)\n") do
		local k,v = line:match("^(.-)\t(.*)$")
		if k then
			local set = cfgMap[k]
			if set then
				local tag = v:sub(1,2)
				if tag == "b:" then
					pcall(set,v:sub(3) == "1"); n = n + 1
				elseif tag == "n:" then
					pcall(set,tonumber(v:sub(3)) or 0); n = n + 1
				elseif tag == "l:" then
					local a = {}
					for x in v:sub(3):gmatch("[^,]+") do a[#a+1] = tonumber(x) or x end
					pcall(set,a); n = n + 1
				elseif tag == "s:" then
					pcall(set,(v:sub(3):gsub("\\n","\n"))); n = n + 1
				end
			end
		end
	end
	return true,"已载入 "..name.."（"..n.." 项）"
end
local cfgBtn = new("TextButton",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(1,-130,.5,0),
	Size=UD.fromOffset(54,18),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="配置 ▾",
	TextColor3=ACC,Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false,Parent=titleBar})
corner(cfgBtn,5)
stroke(cfgBtn,C.Line,1,0.4)
pick(cfgBtn,"TextColor3")
cfgBtn.MouseEnter:Connect(function() tw(cfgBtn,0.1,{BackgroundColor3=C.Panel}) end)
cfgBtn.MouseLeave:Connect(function() tw(cfgBtn,0.1,{BackgroundColor3=C.Panel2}) end)
local cfgMask = new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",
	AutoButtonColor=false,Visible=false,ZIndex=88,Parent=main})
local cfgPanel = new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UD.new(1,-130,0,34),
	Size=UD.fromOffset(180,132),BackgroundColor3=C.Panel,BorderSizePixel=0,ZIndex=89,
	Visible=false,Parent=main})
corner(cfgPanel,8)
stroke(cfgPanel,ACC,1,0.35)
local cfgBox = new("TextBox",{Position=UD.fromOffset(8,8),Size=UD.new(1,-74,0,20),
	BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="",PlaceholderText="配置名",
	PlaceholderColor3=C.Dim,TextColor3=C.Text,Font=Enum.Font.GothamMedium,TextSize=11,
	TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=92,Parent=cfgPanel})
pad(cfgBox,6,6,0,0)
corner(cfgBox,5)
stroke(cfgBox,C.Line,1,0.35)
cfgBox.Focused:Connect(function() cfgBox.TextColor3 = ACC end)
cfgBox.FocusLost:Connect(function() cfgBox.TextColor3 = C.Text end)
local cfgSaveBtn = new("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UD.new(1,-8,0,8),
	Size=UD.fromOffset(58,20),BackgroundColor3=ACC,BorderSizePixel=0,Text="保存",
	TextColor3=C.Bg,Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false,ZIndex=92,Parent=cfgPanel})
corner(cfgSaveBtn,5)
local cfgHeadLbl = new("TextLabel",{Position=UD.fromOffset(9,33),Size=UD.new(1,-18,0,12),
	BackgroundTransparency=1,Text="全部配置",TextColor3=C.Dim,Font=Enum.Font.GothamBold,
	TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=92,Parent=cfgPanel})
local cfgList = new("ScrollingFrame",{Position=UD.fromOffset(4,49),Size=UD.new(1,-8,1,-68),
	BackgroundTransparency=1,BorderSizePixel=0,ZIndex=90,CanvasSize=UD.new(0,0,0,0),
	AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,
	ScrollBarThickness=2,ScrollBarImageColor3=ACC,ScrollBarImageTransparency=0.25,Parent=cfgPanel})
local cfgStat = new("TextLabel",{Position=UD.new(0,9,1,-16),Size=UD.new(1,-18,0,12),
	BackgroundTransparency=1,Text="",TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
	TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
	ZIndex=92,Parent=cfgPanel})
local cfgShow, cfgHide
local function cfgRow(i,text,cb,hot,del)
	local b = new("TextButton",{Position=UD.fromOffset(0,(i-1)*19),Size=UD.new(1,-14,0,18),
		BackgroundColor3=C.Panel,BorderSizePixel=0,Text="",AutoButtonColor=false,
		ZIndex=91,Parent=cfgList})
	corner(b,5)
	local lb = new("TextLabel",{Position=UD.fromOffset(7,0),Size=UD.new(1,del and -32 or -14,1,0),
		BackgroundTransparency=1,Text=text,TextColor3=hot and ACC or C.Text,
		Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
		TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=92,Parent=b})
	b.MouseEnter:Connect(function() tw(b,0.1,{BackgroundColor3=C.Panel2}) end)
	b.MouseLeave:Connect(function() tw(b,0.1,{BackgroundColor3=C.Panel}) end)
	b.Activated:Connect(cb)
	if del then
		local x = new("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UD.new(1,-6,.5,0),
			Size=UD.fromOffset(16,14),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="×",
			TextColor3=C.Dim,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,
			ZIndex=93,Parent=b})
		corner(x,4)
		x.MouseEnter:Connect(function() tw(x,0.1,{TextColor3=ACC}) end)
		x.MouseLeave:Connect(function() tw(x,0.1,{TextColor3=C.Dim}) end)
		x.Activated:Connect(del)
	end
	return b
end
local function cfgRefresh()
	local keep = cfgBox.Text
	for _,c in ipairs(cfgList:GetChildren()) do c:Destroy() end
	local files = cfgFiles()
	for i,nm in ipairs(files) do
		cfgRow(i,nm,function()
			cfgBox.Text = nm
			local ok,msg = cfgLoad(nm)
			cfgStat.Text = msg
			cfgRefresh()
		end,false,function()
			local d = cfgFn("delfile")
			if d then pcall(d,CFG_DIR.."/"..nm..".cfg") end
			cfgStat.Text = "已删除 "..nm
			cfgRefresh()
		end)
	end
	if #files == 0 then
		cfgRow(1,"暂无配置",function() end,false)
	end
	cfgBox.Text = keep
end
cfgSaveBtn.Activated:Connect(function()
	local nm = tostring(cfgBox.Text):gsub("^%s+",""):gsub("%s+$","")
	if nm == "" then nm = "config" end
	nm = nm:gsub('[\\/:*?"<>|]',"_")
	cfgBox.Text = nm
	local ok,msg = cfgSave(nm)
	cfgStat.Text = msg
	if ok then cfgRefresh() end
end)
cfgShow = function()
	cfgRefresh()
	cfgStat.Text = ""
	cfgPanel.Visible = true
	cfgMask.Visible = true
	cfgBtn.Text = "配置 ▴"
end
cfgHide = function()
	cfgPanel.Visible = false
	cfgMask.Visible = false
	cfgBtn.Text = "配置 ▾"
end
cfgBtn.Activated:Connect(function()
	if cfgPanel.Visible then cfgHide() else cfgShow() end
end)
cfgMask.Activated:Connect(function() cfgHide() end)

local statusCard = new("Frame",{Position=UD.new(0,10,1,-96),Size=UD.new(1,-20,0,64),
	BackgroundTransparency=1,BorderSizePixel=0,Parent=main})
local av2 = new("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,10,.5,0),
	Size=UD.fromOffset(34,34),BackgroundTransparency=1,Parent=statusCard})
local av2R = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),
	Size=UD.fromOffset(34,34),BackgroundTransparency=1,Parent=av2})
corner(av2R,17); stroke(av2R,C.Line,1.2,0.1)
local av2Img = new("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),
	Size=UD.fromOffset(28,28),BackgroundColor3=C.Panel,BorderSizePixel=0,Parent=av2})
corner(av2Img,14)
task.spawn(function()
	local ok,th=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,
		Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
	if ok and th then av2Img.Image=th end
end)
new("TextLabel",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,50,.5,-20),
	Size=UD.new(1,-88,0,14),BackgroundTransparency=1,
	Text=LP.DisplayName,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
	TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=statusCard})
local unameLbl = new("TextLabel",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,50,.5,-6),
	Size=UD.new(1,-88,0,12),BackgroundTransparency=1,
	Text="@"..tostring(LP.Name),TextColor3=ACC,Font=Enum.Font.GothamMedium,TextSize=11,
	TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=statusCard})
pick(unameLbl,"TextColor3")
local gameLbl = new("TextLabel",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,50,.5,8),
	Size=UD.new(1,-88,0,12),BackgroundTransparency=1,
	Text="读取游戏名...",TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
	TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=statusCard})
local ageLbl = new("TextLabel",{AnchorPoint=Vector2.new(0,.5),Position=UD.new(0,50,.5,22),
	Size=UD.new(1,-88,0,12),BackgroundTransparency=1,
	Text="ONLINE",TextColor3=ACC,Font=Enum.Font.GothamMedium,
	TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=statusCard})
pick(ageLbl,"TextColor3")
task.spawn(function()
	local gn = ""
	pcall(function() gn = tostring(game.Name) end)
	if gn == "" then pcall(function() gn = "Place "..tostring(game.PlaceId) end) end
	gameLbl.Text = gn
	local ok,info = pcall(function()
		return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId,Enum.InfoType.Asset)
	end)
	if ok and info and info.Name then gameLbl.Text = tostring(info.Name) end
end)
local setArrow = new("TextButton",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(0,240,.5,0),
	Size=UD.fromOffset(22,22),BackgroundColor3=C.Panel2,BorderSizePixel=0,Text="▶",
	TextColor3=ACC,Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false,Parent=statusCard})
corner(setArrow,6); stroke(setArrow,C.Line,1,0.35)
pick(setArrow,"TextColor3")
setArrow.MouseEnter:Connect(function() tw(setArrow,0.12,{BackgroundColor3=C.Panel}) end)
setArrow.MouseLeave:Connect(function() tw(setArrow,0.12,{BackgroundColor3=C.Panel2}) end)
setArrow.Activated:Connect(function()
	if setOpen then setOpen() end
end)
local panelHome
local panelHomeX = 240
local function placeArrow()
	local w = 0
	for _, l in ipairs(statusCard:GetDescendants()) do
		if l:IsA("TextLabel") and l.Text ~= "" then
			local tw0 = textW(l)
			if tw0 > w then w = tw0 end
		end
	end
	local x = math.clamp(50 + w + 12, 60, WIN_W - 60)
	setArrow.Position = UD.new(0, x + 11, .5, 0)
	if panelHome then panelHome(x) end
end
gameLbl:GetPropertyChangedSignal("Text"):Connect(function() task.defer(placeArrow) end)

local alphaMode = 3
local alphaK = {1, 0.42, 0}
local alphaBase = {}
local alphaSkip = {[titleFill] = true, [sbTopLine] = true}
local function applyAlpha()
	local k = alphaK[alphaMode]
	main.BackgroundTransparency = 0.32 + 0.68 * k
	for _,d in ipairs(main:GetDescendants()) do
		if d:IsA("GuiObject") and not alphaSkip[d] then
			local bc = d.BackgroundColor3
			if bc==C.Bg or bc==C.Panel or bc==C.Panel2 then
				if alphaBase[d]==nil then alphaBase[d] = d.BackgroundTransparency or 0 end
				local b = alphaBase[d]
				d.BackgroundTransparency = b + (1-b) * k
			end
		end
	end
	titleFill.BackgroundTransparency = 1
	sbTopLine.BackgroundTransparency = 0.4
end
applyAlpha()

local MINI = 58
local miniHomePos = UD.fromOffset(20, CAM.ViewportSize.Y * 0.4)
local mini = new("TextButton",{
	Position = miniHomePos,
	Size=UD.fromOffset(MINI,MINI),
	BackgroundColor3=C.Bg,BackgroundTransparency=0.45,BorderSizePixel=0,Text="",
	AutoButtonColor=false,Visible=false,Parent=gui})
corner(mini,MINI/2)
local miniStroke = stroke(mini,ACC,1.4,0.3)
pick(miniStroke,"Color")
local miniScale = new("UIScale",{Scale=1,Parent=mini})

local orbit = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.fromScale(.5,.5),
	Size=UD.fromOffset(38,38),BackgroundTransparency=1,Parent=mini})
local orbitDot = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UD.new(1,0,.5,0),
	Size=UD.fromOffset(5,5),BackgroundColor3=ACC,BorderSizePixel=0,Parent=orbit})
corner(orbitDot,2.5)
pick(orbitDot,"BackgroundColor3")

local miniCore = diamond(mini,23,12,12,ACC,0)
pick(miniCore,"BackgroundColor3")
diamond(mini,26,15,6,C.Bg,0)

local xjwLbl = new("TextLabel",{Position=UD.new(0,0,0,25),Size=UD.new(1,0,0,18),
	BackgroundTransparency=1,Text="XJW",TextColor3=ACC,Font=Enum.Font.GothamBold,
	TextSize=13,TextXAlignment=Enum.TextXAlignment.Center,Parent=mini})
pick(xjwLbl,"TextColor3")

local kbPh = 0
local flowSlots = {}
local textFlowOn, borderFlowOn = true, true
local BFLOW_SPEED = 300
local TEXT_PX = 14

RunService.RenderStepped:Connect(function(dt)
	tOrbit.Rotation = tOrbit.Rotation + dt*140
	if themeIdx ~= 1 then stepTheme(dt) end
	if borderFlowOn then
		kbPh = (kbPh + dt*BFLOW_SPEED) % 360
		borderGrad.Rotation = kbPh
		ringGrad.Rotation = kbPh
	end
	if textFlowOn then
		for _, s in ipairs(flowSlots) do
			s.ph = (s.ph + dt*s.rate) % 2
			s.paint(s.ph)
		end
	end
	fpsAcc = fpsAcc + dt
	fpsN = fpsN + 1
	if fpsAcc >= 0.5 then
		fpsVal = math.floor(fpsN/fpsAcc + 0.5)
		fpsAcc, fpsN = 0, 0
	end
	if not mini.Visible then return end
	orbit.Rotation = orbit.Rotation + dt*140
	local p = (math.sin(os.clock()*3)+1)/2
	miniScale.Scale = 1 + p*0.04
end)

main:GetPropertyChangedSignal("Position"):Connect(function()
	if main.Visible and not mainAnim then mainHomePos = main.Position end
end)
mini:GetPropertyChangedSignal("Position"):Connect(function()
	if mini.Visible then miniHomePos = mini.Position end
end)

local uiOpen = false
local mainMove
local moveSeq = 0
local silkBlur = new("BlurEffect",{Size=0,Parent=Lighting})
local function silkFX(peak,dur)
	tw(silkBlur,dur*0.42,{Size=peak},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
	task.delay(dur*0.42,function()
		tw(silkBlur,dur*0.58,{Size=0},Enum.EasingStyle.Quad,Enum.EasingDirection.InOut)
	end)
end
local function slideMain(target,dur,done,style,dir)
	moveSeq = moveSeq + 1
	local my = moveSeq
	mainAnim = true
	if mainMove then mainMove:Cancel() end
	mainMove = tw(main,dur,{Position=target},style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out)
	task.delay(dur+0.03,function()
		if moveSeq ~= my then return end
		mainMove = nil
		if done then done() end
		mainAnim = false
	end)
end
local function offscreenPos()
	return UD.new(mainHomePos.X.Scale,mainHomePos.X.Offset,mainHomePos.Y.Scale,
		mainHomePos.Y.Offset + math.max(120,CAM.ViewportSize.Y - mainHomePos.Y.Offset))
end
local function setMainVisible(v)
	if v == uiOpen and main.Visible == v then return end
	uiOpen = v
	if dropCtl.open then dropCtl.open() end
	if v then
		main.Visible = true
		main.Position = offscreenPos()
		mainScale.Scale = mainBase * userScale
		silkFX(6,0.42)
		slideMain(mainHomePos,0.42,nil,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
	else
		silkFX(7,0.4)
		slideMain(offscreenPos(),0.4,function()
			if not uiOpen then
				main.Visible = false
				main.Position = mainHomePos
				mainScale.Scale = mainBase * userScale
			end
		end,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
	end
end

makeDraggable(mini, mini, function()
	setMainVisible(not uiOpen)
end)
makeDraggable(main, dragHandle)

local RS_MIN_W, RS_MIN_H = 280, 320

local function makeGrip(ax,ay,dots)
	local g = new("TextButton",{AnchorPoint=Vector2.new(ax,ay),Position=UD.new(ax,0,ay,0),
		Size=UD.fromOffset(26,26),BackgroundTransparency=1,Text="",AutoButtonColor=false,
		ZIndex=10,Parent=main})
	for _,d in ipairs(dots) do
		local dot = new("Frame",{Position=UD.fromOffset(d[1],d[2]),Size=UD.fromOffset(4,4),
			BackgroundColor3=ACC,BackgroundTransparency=0.25,BorderSizePixel=0,
			ZIndex=10,Parent=g})
		corner(dot,2)
		pick(dot,"BackgroundColor3")
	end
	return g
end

local tlGrip = makeGrip(0,0,{{3,3},{3,10},{10,3}})
local brGrip = makeGrip(1,1,{{19,19},{19,12},{12,19}})

local function makeResizer(grip,fromTL)
	local dg, ds, sp, ss = false, nil, nil, nil
	grip.InputBegan:Connect(function(input,gp)
		if gp then return end
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dg, ds, sp, ss = true, input.Position, main.Position, main.Size
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dg then return end
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			local s = mainScale.Scale
			local vp = CAM.ViewportSize
			local mw = math.max(RS_MIN_W,(vp.X-20)/s)
			local mh = math.max(RS_MIN_H,(vp.Y-20)/s)
			local dx = (input.Position.X-ds.X)/s
			local dy = (input.Position.Y-ds.Y)/s
			local w = math.clamp(fromTL and (ss.X.Offset-dx) or (ss.X.Offset+dx),RS_MIN_W,mw)
			local h = math.clamp(fromTL and (ss.Y.Offset-dy) or (ss.Y.Offset+dy),RS_MIN_H,mh)
			main.Size = UD.fromOffset(math.floor(w),math.floor(h))
			if fromTL then
				main.Position = UD.fromOffset(
					math.floor(sp.X.Offset+(ss.X.Offset-w)*s),
					math.floor(sp.Y.Offset+(ss.Y.Offset-h)*s))
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if not dg then return end
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dg=false
			if dropCtl.open then dropCtl.open() end
		end
	end)
end

makeResizer(tlGrip,true)
makeResizer(brGrip,false)

local function buildSetPanel()
	local function pBtn(x,y,w,h,label,accent,fn)
		local b = new("TextButton",{Position=UD.fromOffset(x,y),Size=UD.fromOffset(w,h),
			BackgroundColor3=C.Panel2,BackgroundTransparency=0.25,BorderSizePixel=0,Text=label,
			TextColor3=accent and ACC or C.Text,Font=Enum.Font.GothamBold,TextSize=11,
			AutoButtonColor=false,ZIndex=55,Parent=setPanel})
		corner(b,6)
		stroke(b,C.Line,1,0.35)
		if accent then pick(b,"TextColor3") end
		b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=C.Panel}) end)
		b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=C.Panel2}) end)
		b.Activated:Connect(fn)
		return b
	end
	local offX, offY = panelHomeX, -96
	setPanel = new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UD.new(0,offX,1,offY),
		Size=UD.fromOffset(152,204),BackgroundColor3=C.Bg,BackgroundTransparency=0.38,
		BorderSizePixel=0,Visible=false,ZIndex=54,Parent=main})
	corner(setPanel,10)
	stroke(setPanel,C.Line,1,0.2)
	local pGrab = new("TextButton",{Size=UD.fromScale(1,1),BackgroundTransparency=1,Text="",
		AutoButtonColor=false,ZIndex=54,Parent=setPanel})
	local pDrag, pFrom, pBase, pMoved = false, nil, nil, false
	pGrab.InputBegan:Connect(function(input,gp)
		if gp then return end
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			pDrag = true
			pFrom = input.Position
			pBase = Vector2.new(offX,offY)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not pDrag then return end
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			local d = input.Position - pFrom
			pMoved = true
			local sc = mainScale.Scale
			if sc <= 0 then sc = 1 end
			offX = math.clamp(pBase.X + d.X / sc, -152, WIN_W - 24)
			offY = math.clamp(pBase.Y + d.Y / sc, -WIN_H + 40, WIN_H - 40)
			setPanel.Position = UD.new(0,offX,1,offY)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if not pDrag then return end
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			pDrag = false
		end
	end)
	panelHome = function(x)
		if pMoved then return end
		panelHomeX = math.clamp(x, 8, WIN_W - 160)
		offX = panelHomeX
		setPanel.Position = UD.new(0,offX,1,offY)
	end
	new("TextLabel",{Position=UD.fromOffset(14,8),Size=UD.fromOffset(88,14),BackgroundTransparency=1,
		Text="UI 设置",TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,ZIndex=55,Parent=setPanel})
	local closeBtn = new("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UD.new(1,-8,0,6),
		Size=UD.fromOffset(18,18),BackgroundColor3=C.Panel2,BackgroundTransparency=0.25,BorderSizePixel=0,Text="X",
		TextColor3=C.Dim,Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false,
		ZIndex=55,Parent=setPanel})
	corner(closeBtn,5)
	closeBtn.Activated:Connect(function() setOpen(false) end)
	local txtBtn
	txtBtn = pBtn(14,30,124,24,"文字渐变 开",false,function()
		textFlowOn = not textFlowOn
		txtBtn.Text = textFlowOn and "文字渐变 开" or "文字渐变 关"
		for _,s in ipairs(flowSlots) do s.g.Enabled = textFlowOn end
		if textFlowOn then
			for _,s in ipairs(flowSlots) do s.paint(s.ph) end
		end
	end)
	local brdBtn
	brdBtn = pBtn(14,56,124,24,"彩虹边框 开",false,function()
		borderFlowOn = not borderFlowOn
		bRing.Visible = borderFlowOn
		mainStroke.Transparency = borderFlowOn and 0.2 or 1
		brdBtn.Text = borderFlowOn and "彩虹边框 开" or "彩虹边框 关"
	end)
	new("TextLabel",{Position=UD.fromOffset(14,118),Size=UD.fromOffset(110,12),BackgroundTransparency=1,
		Text="UI主题",TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
		TextXAlignment=Enum.TextXAlignment.Left,ZIndex=55,Parent=setPanel})
	local themeRow = new("TextButton",{Position=UD.fromOffset(14,132),Size=UD.fromOffset(124,24),
		BackgroundColor3=C.Panel2,BackgroundTransparency=0.25,BorderSizePixel=0,Text="",
		AutoButtonColor=false,ZIndex=55,Parent=setPanel})
	corner(themeRow,10)
	stroke(themeRow,C.Line,1,0.35)
	local themeTx = new("TextLabel",{Position=UD.fromOffset(10,0),Size=UD.new(1,-28,1,0),
		BackgroundTransparency=1,Text="UI主题："..themeNames[1],TextColor3=C.Text,
		Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
		ZIndex=55,Parent=themeRow})
	local themeAr = new("TextLabel",{AnchorPoint=Vector2.new(1,0.5),Position=UD.new(1,-9,0.5,0),
		Size=UD.fromOffset(11,11),BackgroundTransparency=1,Text="▼",TextColor3=ACC,
		Font=Enum.Font.GothamBold,TextSize=10,ZIndex=55,Parent=themeRow})
	local themeH = #themeNames*24 + 8
	local themeList = new("Frame",{Position=UD.fromOffset(14,132-2-themeH),Size=UD.fromOffset(124,themeH),
		BackgroundColor3=C.Panel2,BorderSizePixel=0,Visible=false,ZIndex=60,Parent=setPanel})
	corner(themeList,10)
	stroke(themeList,ACC,1,0.3)
	local themeRows = {}
	local function paintTheme()
		for j,r in ipairs(themeRows) do
			local on = (j == themeIdx)
			r.hili.BackgroundTransparency = on and 0.62 or 1
			r.bar.BackgroundTransparency = on and 0 or 1
			r.lbl.TextColor3 = on and ACC or C.Text
		end
		themeTx.Text = "UI主题："..themeNames[themeIdx]
	end
	for i,name in ipairs(themeNames) do
		local r = chipRow(themeList,i,24,name,61,false)
		r.btn.Activated:Connect(function()
			setTheme(i)
			paintTheme()
			themeList.Visible = false
			themeAr.Rotation = 0
		end)
		themeRows[i] = r
	end
	paintTheme()
	themeRow.Activated:Connect(function()
		themeList.Visible = not themeList.Visible
		tw(themeAr,0.16,{Rotation = themeList.Visible and 180 or 0},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
	end)
	themeShut = function()
		themeList.Visible = false
		themeAr.Rotation = 0
	end
	new("TextLabel",{Position=UD.fromOffset(14,158),Size=UD.fromOffset(110,11),BackgroundTransparency=1,
		Text="UI透明度",TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
		TextXAlignment=Enum.TextXAlignment.Left,ZIndex=55,Parent=setPanel})
	local alphaNames = {"全透明","半透明","默认"}
	local alphaBtns, alphaStr = {}, {}
	local function paintAlpha()
		for i,b in ipairs(alphaBtns) do
			local on = (i==alphaMode)
			b.BackgroundColor3 = on and ACC or C.Panel2
			b.BackgroundTransparency = on and 0.15 or 0.4
			b.TextColor3 = on and WHITE or C.Text
			alphaStr[i].Color = on and ACC or C.Line
			alphaStr[i].Transparency = on and 0.1 or 0.4
		end
	end
	for i,nm in ipairs(alphaNames) do
		local b = new("TextButton",{Position=UD.fromOffset(14+(i-1)*41,172),Size=UD.fromOffset(39,24),
			BackgroundColor3=C.Panel2,BackgroundTransparency=0.4,BorderSizePixel=0,Text=nm,
			TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,
			AutoButtonColor=false,ZIndex=55,Parent=setPanel})
		corner(b,6)
		alphaStr[i] = stroke(b,C.Line,1,0.4)
		b.Activated:Connect(function()
			alphaMode = i
			applyAlpha()
			paintAlpha()
		end)
		alphaBtns[i] = b
	end
	paintAlpha()
	tint(paintAlpha)
	local armed = false
	local unBtn
	unBtn = pBtn(14,88,124,24,"卸载 UI",true,function()
		if not armed then
			armed = true
			unBtn.Text = "再点一次确认"
			task.delay(3,function()
				if armed then
					armed = false
					unBtn.Text = "卸载 UI"
				end
			end)
			return
		end
		armed = false
		gui:Destroy()
	end)
	local sOpen, sSeq = false, 0
	setOpen = function(v)
		if v == nil then v = not sOpen end
		sOpen = v
		sSeq = sSeq + 1
		themeShut()
		local my = sSeq
		tw(setArrow,0.16,{Rotation = v and 90 or 0},Enum.EasingStyle.Quint)
		if v then
			setPanel.Visible = true
			setPanel.Position = UD.new(0,offX,1,offY+16)
			tw(setPanel,0.2,{Position=UD.new(0,offX,1,offY)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
		else
			tw(setPanel,0.18,{Position=UD.new(0,offX,1,offY+16)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
			task.delay(0.19,function()
				if sSeq == my then setPanel.Visible = false end
			end)
		end
	end
end


buildSetPanel()
applyAlpha()
applyTheme(ACC)
local function gradSlot(lbl)
	local g = lbl:FindFirstChildOfClass("UIGradient") or new("UIGradient",{Parent=lbl})
	g.Rotation = 0
	pcall(function()
		lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
		lbl.TextStrokeTransparency = 0.85
	end)
	local per, sp = 0.5, 70
	local function geo()
		local bw = lbl.AbsoluteSize.X
		local tw0 = textW(lbl)
		local m = math.clamp(math.floor(tw0/70)+1, 1, 6) * 2
		sp = math.max(7, tw0 / m)
		per = 0.5
		if bw > 0 then per = sp / bw end
		per = math.clamp(per, 1/17, 0.5)
	end
	geo()
	local slot = {g = g, ph = 0, rate = 1}
	local function paint(ph)
		local bc = BLUE
		local k = {}
		local n0 = math.floor(ph)
		local lastc = (n0 % 2 == 0) and WHITE or bc
		k[1] = ColorSequenceKeypoint.new(0, lastc)
		local n = n0 + 1
		local top = n0 + math.ceil(1/per) + 2
		if top - n0 > 16 then top = n0 + 16 end
		while n <= top do
			local t = per * (n - ph)
			if t > 1 - 1e-4 then break end
			if t > 1e-4 then
				lastc = (n % 2 == 0) and WHITE or bc
				k[#k+1] = ColorSequenceKeypoint.new(t, lastc)
			end
			n = n + 1
		end
		if k[#k].Time < 1 - 1e-4 then k[#k+1] = ColorSequenceKeypoint.new(1, lastc) end
		g.Color = ColorSequence.new(k)
		g.Enabled = textFlowOn
	end
	lbl.TextColor3 = WHITE
	slot.paint = function(ph) pcall(paint,ph) end
	slot.rate = math.clamp(TEXT_PX/sp, 0.05, 3)
	paint(0)
	flowSlots[#flowSlots+1] = slot
	local function refresh()
		geo()
		slot.rate = math.clamp(TEXT_PX/sp, 0.05, 3)
		paint(slot.ph)
	end
	lbl:GetPropertyChangedSignal("Text"):Connect(refresh)
	lbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
	tint(function(c) lbl.TextColor3 = WHITE; paint(slot.ph) end)
end

local regText = {}

local function scanTexts()
	for _, d in ipairs(gui:GetDescendants()) do
		if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and d.Text ~= "" and not regText[d] then
			regText[d] = true
			if C.TabNG[d] then return end
			pcall(function()
				d.TextStrokeColor3 = Color3.fromRGB(0,0,0)
				d.TextStrokeTransparency = 0.85
			end)
			gradSlot(d)
		end
	end
end
task.spawn(function()
	RunService.Heartbeat:Wait()
	scanTexts()
	placeArrow()
	while main.Parent do
		task.wait(0.25)
		scanTexts()
	end
end)

mini.Visible = true
setMainVisible(true)

task.spawn(function()
	while main.Parent do
		local p = (math.sin(os.clock()*2)+1)/2
		mainStroke.Transparency = borderFlowOn and 0.2 or 1
		sBlink.BackgroundTransparency = p*0.4
		task.wait(0.8)
	end
end)

local UIKIT = {}
UIKIT.section = function(parent,y,text)
	new("TextLabel",{Position=UD.fromOffset(4,y+2),Size=UD.new(1,-36,0,16),BackgroundTransparency=1,
		Text=text,TextColor3=C.TabBlue,Font=Enum.Font.GothamBold,TextSize=15,
		TextXAlignment=Enum.TextXAlignment.Left,Parent=parent})
end

UIKIT.paragraph = function(parent,y,h,title,desc)
	local row = cardShell(parent,y,h)
	new("TextLabel",{Position=UD.fromOffset(12,6),Size=UD.new(1,-24,0,14),BackgroundTransparency=1,
		Text=title,TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
	new("TextLabel",{Position=UD.fromOffset(12,22),Size=UD.new(1,-24,0,12),BackgroundTransparency=1,
		Text=desc,TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=11,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
end

local noteSlots = {}
UIKIT.notify = function(o)
	o = o or {}
	local dur = tonumber(o.Duration) or 1
	if dur <= 0 then dur = 1 end
	local slot = 1
	while noteSlots[slot] do slot = slot + 1 end
	noteSlots[slot] = true
	local top = 12 + (slot - 1) * 34
	local card = new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UD.new(1,40,0,top),
		Size=UD.fromOffset(150,30),BackgroundColor3=C.Panel2,BorderSizePixel=0,
		BackgroundTransparency=0.05,Parent=gui,ZIndex=900})
	corner(card,6)
	stroke(card,ACC,1,1)
	new("TextLabel",{Position=UD.fromOffset(10,4),Size=UD.new(1,-20,0,12),BackgroundTransparency=1,
		Text=tostring(o.Title or "提示"),TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=11,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=card,ZIndex=901})
	new("TextLabel",{Position=UD.fromOffset(10,16),Size=UD.new(1,-20,0,10),BackgroundTransparency=1,
		Text=tostring(o.Content or ""),TextColor3=C.Dim,Font=Enum.Font.GothamMedium,TextSize=10,
		TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=card,ZIndex=901})
	new("Frame",{Position=UD.new(0,0,1,-3),Size=UD.new(1,0,0,3),BackgroundColor3=C.Panel,
		BackgroundTransparency=0.55,BorderSizePixel=0,Parent=card,ZIndex=901})
	local bar = new("Frame",{Position=UD.new(0,0,1,-3),Size=UD.new(1,0,0,3),BackgroundColor3=ACC,
		BackgroundTransparency=0,BorderSizePixel=0,Parent=card,ZIndex=902})
	corner(bar,1.5)
	tw(card,0.15,{Position=UD.new(1,-12,0,top)})
	tw(bar,dur,{Size=UD.new(0,0,0,3)},Enum.EasingStyle.Linear)
	task.spawn(function()
		task.wait(dur)
		noteSlots[slot] = nil
		card:Destroy()
	end)
end

local windowObj = {}
function windowObj:Tab(o)
	o = o or {}
	local idx, pg = addTab(tostring(o.Title or "标签"))
	head(pg, tostring(o.Title or "标签"))
	local tab = {Page=pg, Index=idx}
	function tab:Section(p)
		local y = nextY(pg,32)
		UIKIT.section(pg,y,tostring(type(p)=="table" and p.Title or p or ""))
	end
	function tab:Paragraph(p)
		UIKIT.paragraph(pg,nextY(pg,ROW_H),ROW_H,tostring(p.Title or ""),tostring(p.Desc or ""))
	end
	function tab:Button(p)
		return makeAction(pg,nextY(pg,ROW_H),ROW_H,tostring(p.Title or ""),tostring(p.Desc or ""),ACC,p.Callback)
	end
	function tab:Toggle(p)
		return makeToggle(pg,nextY(pg,ROW_H),ROW_H,tostring(p.Title or ""),tostring(p.Desc or ""),ACC,p.Callback,p.Default)
	end
	function tab:Slider(p)
		return makeSlider(pg,nextY(pg,SLIDER_H),SLIDER_H,tostring(p.Title or ""),ACC,tonumber(p.Default) or 0,p.Callback)
	end
	function tab:Input(p)
		return makeInput(pg,nextY(pg,ROW_H),ROW_H,tostring(p.Title or ""),tostring(p.Desc or ""),tostring(p.Default or ""),p.Placeholder,p.Callback)
	end
	function tab:Dropdown(p)
		return makeSelect(pg,nextY(pg,DROP_H),DROP_H,tostring(p.Title or ""),tostring(p.Desc or ""),p.Values or {"选项一"},tonumber(p.Default) or 1,ACC,p.Callback)
	end
	function tab:MultiDropdown(p)
		return makeMulti(pg,nextY(pg,DROP_H),DROP_H,tostring(p.Title or ""),tostring(p.Desc or ""),p.Values or {"选项一"},p.Default,ACC,p.Callback)
	end
	function tab:Number(p)
		return makeNumber(pg,nextY(pg,ROW_H),ROW_H,tostring(p.Title or ""),tostring(p.Desc or ""),ACC,tonumber(p.Default) or 0,tonumber(p.Min) or 0,tonumber(p.Max) or 100,p.Callback)
	end
	if idx == 1 then switchTab(idx) end
	return tab
end
function windowObj:Notify(o) UIKIT.notify(o) end
function windowObj:SetTitle(s) titleLbl.Text = tostring(s) end
function windowObj:Destroy() gui:Destroy() end

return windowObj
end

local API = {}
API.CreateWindow = function(self,cfg) return BUILD(cfg) end
return API
