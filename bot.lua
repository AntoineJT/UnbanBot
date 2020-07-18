local discordia = require("discordia")
local client = discordia.Client()
local enums = discordia.enums

-- The config loading part has been stolen from Not a Bot: https://github.com/DigitalPulseSoftware/NotaBot/blob/9a222dd2f0e513dd99552bfec0feb25e3a8df8ef/bot.lua
local function code(str)
    return string.format('```\n%s```', str)
end

Config = {}
local func, err = loadfile("config.lua", "bt", Config)
if (not func) then
	print("Failed to load config file:\n" .. code(tostring(err)))
	return
end

local ret, err = pcall(func)
if (not ret) then
	print("Failed to execute config file:\n" .. code(tostring(err)))
	return
end

discordia.extensions() -- load all helpful extensions

client:on("ready", function() -- bot is ready
	print("Logged in as " .. client.user.username)
end)

client:on("messageCreate", function(message)
    local mentionedUsers = message.mentionedUsers

    if #mentionedUsers ~= 1 or mentionedUsers.first.id ~= client.user.id then
        return
    end

    local guild = message.guild
    if guild == nil then
        message:reply("You can't PM me to use commands!")
        return
    end
    local content = message.content
    local args = content:split(" ") -- split all arguments into a table
    local author = message.author

    -- args[1] is the bot mention
    if args[2] == "unban-all" and #args == 2 then
        if not guild:getMember(author.id):hasPermission(enums.permission.administrator) then
            message:reply("You're not an administrator of the guild!")
            return
        end
        local guildName = guild.name
        print(string.format("[%s] %s decided to unban everyone from the guild", guildName, author.tag))

        for _, ban in pairs(guild:getBans()) do
            if ban:delete() then
                print(string.format("[UNBAN] %s was banned from guild `%s` for `%s`", ban.user.tag, guildName, ban.reason))
            else
                print(string.format("[ERROR] Failed to unban %s from guild '%s'", ban.user.tag, guildName))
            end
        end
    end
end)

if Config.Token ~= nil then
    client:run('Bot ' .. Config.Token)
else
    print("[ERROR] No token specified!")
end
