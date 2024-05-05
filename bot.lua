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

local function isAdmin(member)
	return member:hasPermission(enums.permission.administrator)
end

local function numberOfPeople(count)
	assert(count >= 0, "People number is negative! (" .. count .. ")")
	
	if count > 1 then
		return count .. " people"
	end
	if count == 0 then
		return "no one"
	end
	if count == 1 then
		return count .. " person"
	end
	
	return ""
end

local function cmdUnbanAll(message)
	local guild = message.guild
	local author = message.author

--	if not isAdmin(guild:getMember(author.id)) then
--		message:reply("You're not an administrator of the guild!")
--		return
--	end
	
	local guildName = guild.name
	local guildBans = guild:getBans()
	print(string.format("[%s] %s (%s) decided to unban everyone (%s) from the guild", guildName, author.id, author.tag, numberOfPeople(#guildBans)))

	for _, ban in pairs(guildBans) do
		if ban:delete() then
			local reason = ban.reason or "<no reason specified>"
			print(string.format("[UNBAN] %s (%s) was banned from guild `%s` for `%s`", ban.user.tag, ban.user.id, guildName, reason))
		else
			print(string.format("[ERROR] Failed to unban %s (%s) from guild '%s'", ban.user.tag, ban.user.id, guildName))
		end
	end
end

client:on("ready", function() -- bot is ready
	print("Logged in as " .. client.user.username)
end)

started = false

client:on("messageCreate", function(message)
	if started then
		return
	end
	started = true
    local mentionedUsers = message.mentionedUsers

--    if #mentionedUsers ~= 1 or mentionedUsers.first.id ~= client.user.id then
--        return
--    end

    local guild = message.guild
--    if guild == nil then
--        message:reply("You can't PM me to use commands!")
--        return
--    end
--    local args = message.content:split(" ") -- split all arguments into a table

    -- args[1] is the bot mention
--    if args[2] == "unban-all" and #args == 2 then
		cmdUnbanAll(message)
--    end
end)

if Config.Token ~= nil then
    client:run('Bot ' .. Config.Token)
else
    print("[ERROR] No token specified!")
end
