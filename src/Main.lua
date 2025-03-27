-- Main.lua - Primary entry point for the addon
local addonName, ST = ...

-- This file should be loaded first in the TOC file
-- It will establish the addon table and load order

-- Initialize the ST (Stats Tracker) table
ST = ST or {}

-- Module loading order should be:
-- 1. Config.lua - Contains configuration definitions and functions
-- 2. Utils.lua - Utility functions used by multiple modules
-- 3. StatBar.lua - Definition of the stat bar objects
-- 4. TitleBar.lua - Title bar creation
-- 5. Core.lua - Core addon functionality
-- 6. Bars.lua - Bar management
-- 7. Events.lua - Event handling
-- 8. SlashCommands.lua - Command registration

-- The above files should be listed in this order in the TOC file