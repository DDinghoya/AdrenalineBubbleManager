dofile("git/shared.lua")

if files.exists("ux0:/app/ONEUPDATE") then
	game.delete("ONEUPDATE") -- Exists delete update app
end

UPDATE_PORT = channel.new("UPDATE_PORT")

local scr_flip = screen.flip
function screen.flip()
	scr_flip()
	if UPDATE_PORT:available() > 0 then
		local version = UPDATE_PORT:pop()
		local major = (version >> 0x18) & 0xFF;
		local minor = (version >> 0x10) & 0xFF;
		if custom_msg(string.format("\n%s v%s", APP_PROJECT, string.format("%X.%02X",major, minor).." "..strings.update_msg1.."\n\n"..strings.update_msg2), 1) == 1 then
			buttons.homepopup(0)
			
			local url = string.format("https://github.com/%s/%s/releases/download/%s/%s", APP_REPO, APP_PROJECT, string.format("%X.%02X",major, minor), APP_PROJECT..".vpk")
			local path = "ux0:data/"..APP_PROJECT..".vpk"
			local onAppInstallOld = onAppInstall
			function onAppInstall(step, size_argv, written, file, totalsize, totalwritten)
				return 10 -- Ok code
			end
			local onNetGetFileOld = onNetGetFile
			function onNetGetFile(size,written,speed)
				if back then back:blit(0,0) end
				screen.print(10,10,strings.downupdate)
				screen.print(10,30,strings.size_msg..": "..tostring(size).." "..strings.written_msg..": "..tostring(written).." "..strings.speed_msg.." "..tostring(speed)..strings.kbs_msg)
				screen.print(10,50,strings.percent_msg..": "..math.floor((written*100)/size).."%")
				draw.fillrect(0,520,((written*960)/size),24,color.new(0,255,0))
				screen.flip()
				buttons.read()
				if buttons.circle then return 0 end --Cancel or Abort
				return 1;
			end
			local res = http.getfile(url, path)
			if res then -- Success!
				files.mkdir("ux0:/data/1luapkg")
				files.copy("eboot.bin","ux0:/data/1luapkg")
				files.copy("updater/script.lua","ux0:/data/1luapkg/")
				files.copy("updater/param.sfo","ux0:/data/1luapkg/sce_sys/")
				game.installdir("ux0:/data/1luapkg")
				files.delete("ux0:/data/1luapkg")
				game.launch(string.format("ONEUPDATE&%s&%s",os.titleid(),path)) -- Goto installer extern!
			end
			onAppInstall = onAppInstallOld
			onNetGetFile = onNetGetFileOld
			buttons.homepopup(1)
		end
	end
end

THID = thread.new("git/thread_net.lua")
