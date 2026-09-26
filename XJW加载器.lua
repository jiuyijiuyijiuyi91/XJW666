local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()

_G.XJW_safeLoad = function(url)
    local ok, content = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and content and #content > 0 then
        local fn = loadstring(content)
        if fn then fn() return true end
    end
    return false
end
shared = shared or {}
shared.XJW_safeLoad = _G.XJW_safeLoad

WindUI:Popup({
    Title = "XJW",
    Content = "欢迎回来\n您即将加载 XJW 中心 主脚本\n",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "通用",
            Icon = "arrow-right",
            Callback = function()
                WindUI:Notify({ Title = "正在加载", Content = "正在连接服务器...", Duration = 3 })
                task.spawn(function()
                    local ok, content = pcall(function()
                        return game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/7891/refs/heads/main/%E8%87%AA%E5%88%B6%E8%84%9A%E6%9C%AC.lua")
                    end)
                    if not ok or not content or #content == 0 then
                        WindUI:Notify({ Title = "加载失败", Content = "下载失败: " .. tostring(content), Duration = 5 })
                        return
                    end
                    local fn, compileErr = loadstring(content)
                    if not fn then
                        WindUI:Notify({ Title = "编译失败", Content = "编译错误: " .. tostring(compileErr), Duration = 5 })
                        return
                    end
                    WindUI:Notify({ Title = "加载完成", Content = "正在运行 XJW 中心...", Duration = 3 })
                    local runOk, runErr = pcall(fn)
                    if not runOk then
                        warn("[XJW加载器] 脚本运行错误: " .. tostring(runErr))
                    end
                end)
            end,
            Variant = "Primary",
        },
        {
            Title = "服务器功能",
            Callback = function()
                WindUI:Notify({ Title = "正在加载", Content = "正在连接服务器...", Duration = 3 })
                task.spawn(function()
                    local ok, content = pcall(function()
                        return game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/-.github.io/refs/heads/main/%E6%9C%8D%E5%8A%A1%E5%99%A8%E5%8A%9F%E8%83%BD.lua")
                    end)
                    if not ok or not content or #content == 0 then
                        WindUI:Notify({ Title = "加载失败", Content = "下载失败: " .. tostring(content), Duration = 5 })
                        return
                    end
                    local fn, compileErr = loadstring(content)
                    if not fn then
                        WindUI:Notify({ Title = "编译失败", Content = "编译错误: " .. tostring(compileErr), Duration = 5 })
                        return
                    end
                    WindUI:Notify({ Title = "加载完成", Content = "正在运行 服务器功能...", Duration = 3 })
                    local runOk, runErr = pcall(fn)
                    if not runOk then
                        warn("[XJW加载器] 服务器功能脚本运行错误: " .. tostring(runErr))
                    end
                end)
            end,
            Variant = "Secondary",
        }
    }
})
