workspace "OpenLimitAdjuster"
	configurations { "Release", "Debug", }
	platforms { "GTA3", "GTAVC", "GTASA" }
    location( "build" )
	startproject "OpenLimitAdjuster"
	files {
		"src/**",
        "doc/**",
	}

local function add_optional_postbuild(env_var, dest_file)
	postbuildcommands {
		"if not \"$(" .. env_var .. ")\"==\"\" copy /y \"$(TargetPath)\" \"$(" .. env_var .. ")\\scripts\\" .. dest_file .. "\"",
	}
end

newoption {
    trigger     = "with-version",
    value       = "STRING",
    description = "Current version"
}

project "OpenLimitAdjuster"
	kind "SharedLib"
	language "C++"
	targetextension ".asi"
	characterset ("MBCS")
	cppdialect "C++latest"
	linkoptions "/SAFESEH:NO"
	buildoptions { "-std:c++latest", "/permissive" }
	defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NON_CONFORMING_SWPRINTFS", "_USE_MATH_DEFINES", "RW", "_SILENCE_CXX23_ALIGNED_STORAGE_DEPRECATION_WARNING" }
	--disablewarnings { "4244", "4800", "4305", "4073", "4838", "4996", "4221", "4430", "26812", "26495", "6031" }
    flags { "NoPCH" }
    excludes { 
		"sample.cpp",
		"game_iii/CLinkList.h",
		"game_vc/CLinkList.h",
		"game_sa/CLinkList.h",
	}

    defines { "rsc_CompanyName=\"LimitAdjuster\"" }
    defines { "rsc_LegalCopyright=\"MIT License\""}
    defines { "rsc_InternalName=\"%{prj.name}\"", "rsc_ProductName=\"%{prj.name}\"", "rsc_OriginalFilename=\"%{cfg.buildtarget.name}\"" }
    defines { "rsc_FileDescription=\"This is a open source limit adjuster for Grand Theft Auto III, Vice City and San Andreas\"" }
    defines { "rsc_UpdateUrl=\"https://github.com/ThirteenAG/III.VC.SA.LimitAdjuster\"" }

    defines { "PLUGIN_SGV_10EN" }

    includedirs {
        "src/**.*",
		"$(PLUGIN_SDK_DIR)/shared/",
		"$(PLUGIN_SDK_DIR)/shared/game/",
		"$(PLUGIN_SDK_DIR)/injector/",
	}

    local major = os.date("%d")
    local minor = os.date("%m")
    local build = os.date("%Y")
    local revision = os.date("%H") .. os.date("%M")

    if _OPTIONS["with-version"] then
        local t = {}
        for i in _OPTIONS["with-version"]:gmatch("([^.]+)") do
            t[#t + 1], _ = i:gsub("%D+", "")
        end
        while #t < 4 do t[#t + 1] = 0 end
        major    = math.min(tonumber(t[1]), 255)
        minor    = math.min(tonumber(t[2]), 255)
        build    = math.min(tonumber(t[3]), 65535)
        revision = math.min(tonumber(t[4]), 65535)
    end

    local githash = ""
    local f = io.popen("git rev-parse --short HEAD")
    if f then
        githash = f:read("*a"):gsub("%s+", "")
        f:close()
    end

    local productVersion = major .. "." .. minor .. "." .. build .. "." .. revision
    if githash ~= "" then
        productVersion = productVersion .. "-" .. githash
    end

    defines { "rsc_FileVersion_MAJOR=" .. major }
    defines { "rsc_FileVersion_MINOR=" .. minor }
    defines { "rsc_FileVersion_BUILD=" .. build }
    defines { "rsc_FileVersion_REVISION=" .. revision }
    defines { "rsc_FileVersion=\"" .. major .. "." .. minor .. "." .. build .. "\"" }
    defines { "rsc_ProductVersion=\"" .. productVersion .. "\"" }
    defines { "rsc_GitSHA1=\"" .. githash .. "\"" }
    defines { "rsc_GitSHA1W=L\"" .. githash .. "\"" }

    flags {
        staticruntime "on",
        "NoImportLib",
        rtti ("Off"),
        "NoBufferSecurityCheck"
    }

    defines {
        "INJECTOR_GVM_HAS_TRANSLATOR",
        'INJECTOR_GVM_PLUGIN_NAME=\"Open Limit Adjuster\"'    -- (additional quotes needed for gmake)
    }

    defines {
        "_CRT_SECURE_NO_WARNINGS",
        "_SCL_SECURE_NO_WARNINGS"
    }

    includedirs {
        "src",
        "src/shared",
        --"src/shared/cpatch",
        "src/shared/structs",
    }

	libdirs { "$(PLUGIN_SDK_DIR)/output/lib" }

    filter "configurations:Debug*"
        symbols "On"

    filter "configurations:Release*"
        defines { "NDEBUG" }
        optimize "Speed"

    largeaddressaware "on"

    filter "action:vs*"
        buildoptions { "/arch:IA32" }           -- disable the use of SSE/SSE2 instructions

	filter "configurations:Debug"
		defines { "DEBUG" }
		symbols "on"

	filter "configurations:Release"
		defines { "NDEBUG" }
		symbols "on"
		optimize "speed"
		linktimeoptimization "on"
		inlining "auto"
		runtime "Release"

	filter { "configurations:Debug", "platforms:GTA3" }
		links { "plugin_iii_d" }

	filter { "configurations:Release", "platforms:GTA3" }
		links { "plugin_iii" }

	filter { "configurations:Debug", "platforms:GTAVC" }
		links { "plugin_vc_d" }

	filter { "configurations:Release", "platforms:GTAVC" }
		links { "plugin_vc" }

	filter { "configurations:Debug", "platforms:GTASA" }
		links { "plugin_d" }

	filter { "configurations:Release", "platforms:GTASA" }
		links { "plugin" }

	filter { "platforms:GTA3" }
		targetdir "output/bin/GTA3/"
		objdir ("output/bin/GTA3/GTA3/")
		targetname "III.OpenLimitAdjuster"
		defines { "III", "GTA3" }
		debugdir "$(GTA_III_DIR)"
		debugcommand "$(GTA_III_DIR)/gta3.exe"
		--debugcommand "D:/Projects/3D/GTA/Liberty City Countryside/GTA 3 UL/gta3.exe"
		--debugdir "D:/Projects/3D/GTA/Liberty City Countryside/GTA 3 UL"
		includedirs {
			"$(PLUGIN_SDK_DIR)/plugin_III/",
			"$(PLUGIN_SDK_DIR)/plugin_III/game_III/",
			"$(PLUGIN_SDK_DIR)/plugin_III/game_III/enums",
			"$(PLUGIN_SDK_DIR)/plugin_III/game_III/rw",
		}
		add_optional_postbuild("GTA_III_DIR", "III.OpenLimitAdjuster.asi")

	filter { "platforms:GTAVC" }
		targetdir "output/bin/GTAVC/"
		objdir ("output/bin/GTAVC/GTAVC/")
		targetname "VC.OpenLimitAdjuster"
		defines { "VC", "GTAVC" }
		debugdir "$(GTA_VC_DIR)"
		debugcommand "$(GTA_VC_DIR)/gtaVC.exe"
		includedirs {
        	"$(PLUGIN_SDK_DIR)/plugin_VC/",
			"$(PLUGIN_SDK_DIR)/plugin_VC/game_VC/",
			"$(PLUGIN_SDK_DIR)/plugin_VC/game_VC/enums",
			"$(PLUGIN_SDK_DIR)/plugin_VC/game_VC/rw",
		}
		add_optional_postbuild("GTA_VC_DIR", "VC.OpenLimitAdjuster.asi")

	filter { "platforms:GTASA" }
		targetdir "output/bin/GTASA/"
		objdir ("output/bin/GTASA/GTASA/")
		targetname "SA.OpenLimitAdjuster"
		defines { "DEBUG", "SA", "GTASA" }
		debugdir "$(GTA_SA_DIR)"
		debugcommand "$(GTA_SA_DIR)/gtasa.exe"
		includedirs {
        	"$(PLUGIN_SDK_DIR)/plugin_SA/",
			"$(PLUGIN_SDK_DIR)/plugin_SA/game_SA/",
			"$(PLUGIN_SDK_DIR)/plugin_SA/game_SA/enums",
			"$(PLUGIN_SDK_DIR)/plugin_SA/game_SA/rw",
		}
		add_optional_postbuild("GTA_SA_DIR", "SA.OpenLimitAdjuster.asi")
    
--    configuration "vs*"
--        buildoptions { "/arch:IA32" }           -- disable the use of SSE/SSE2 instructions
