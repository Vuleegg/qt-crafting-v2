local ServerName = "Quantum Roleplay"
local ServerLogo = "SERVER_LOGO"
local webhook = "YOUR WEBHOOK HERE"

function discord_logs(name, message)
    local time = os.date("*t")
    local poruka = {
        {
            ["color"] = 2061822,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"]= "time: " .. time.hour .. ":" .. time.min .. ":" .. time.sec,
            },
        }
      }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = ServerName, embeds = poruka, avatar_url = ServerLogo}), { ['Content-Type'] = 'application/json' })
end