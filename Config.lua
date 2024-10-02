---@class Config
local addonName, addon = ...
local Config = {}
addon.Config = Config

---@type table
Config.eventGroups = {
    general = {"ADDON_LOADED", "CVAR_UPDATE", "PLAYER_LOGOUT", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "PLAYER_SPECIALIZATION_CHANGED", "GROUP_ROSTER_UPDATE", "PLAYER_TARGET_CHANGED", "RUNE_POWER_UPDATE"},
    unit = {"UNIT_HEALTH", "UNIT_POWER_UPDATE", "UNIT_DISPLAYPOWER", "UNIT_LEVEL", "UNIT_NAME_UPDATE", "UNIT_PET", "UNIT_TARGET", "UNIT_POWER_FREQUENT", "UNIT_MAXPOWER", "UNIT_ABSORB_AMOUNT_CHANGED"}
}

---@type table
Config.unitTypes = {"player", "target", "targettarget", "pet", "pettarget"}

---@type table
Config.classColors = {
    DEFAULT = {0, 1, 0, 1},
    WARRIOR = {0.78, 0.61, 0.43},
    PALADIN = {0.96, 0.55, 0.73},
    HUNTER = {0.67, 0.83, 0.45},
    ROGUE = {1.0, 0.96, 0.41},
    PRIEST = {1.0, 1.0, 1.0},
    DEATHKNIGHT = {0.77, 0.12, 0.23},
    SHAMAN = {0.0, 0.44, 0.87},
    MAGE = {0.41, 0.8, 0.94},
    WARLOCK = {0.58, 0.51, 0.79},
    MONK = {0.0, 1.00, 0.59},
    DRUID = {1.0, 0.49, 0.04},
    DEMONHUNTER = {0.64, 0.19, 0.79},
    EVOKER = {0.20, 0.58, 0.50}
}

---@type table
Config.powerColors = {
    DEFAULT = {1, 1, 1},
    MANA = {0.30, 0.50, 0.85},
    RAGE = {0.90, 0.20, 0.30},
    FOCUS = {1.0, 0.50, 0.25},
    ENERGY = {1.0, 0.85, 0.10},
    RUNIC_POWER = {0.35, 0.45, 0.60},
    LUNAR_POWER = {0.30, 0.52, 0.90},
    MAELSTROM = {0.00, 0.50, 1.00},
    INSANITY = {0.40, 0, 0.80},
    FURY = {0.788, 0.259, 0.992},
    PAIN = {1, 0, 0}
}

---@type table
Config.media = {
    textures = {
        Blizzard = "Interface\\TargetingFrame\\UI-StatusBar",
        Aluminium = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Aluminium",
        Armory = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Armory",
        BantoBar = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\BantoBar",
        Glaze2 = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Glaze2",
        Gloss = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Gloss",
        Graphite = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Graphite",
        Grid = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Grid",
        Healbot = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Healbot",
        LiteStep = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\LiteStep",
        Minimalist = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Minimalist",
        normTex = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\normTex",
        Otravi = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Otravi",
        Outline = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Outline",
        Perl = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Perl",
        Round = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Round",
        Smooth = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Textures\\Smooth"
    },
    fonts = {
        FrizQuadrataTT = "Fonts\\FRIZQT__.TTF",
        ABF = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Fonts\\ABF.ttf",
        AccidentalPresidency = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Fonts\\Accidental Presidency.ttf",
        Adventure = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Fonts\\Adventure.ttf",
        Avqest = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Fonts\\Avqest.ttf",
        VeraSe = "Interface\\AddOns\\MinimalUnitFrames\\Media\\Fonts\\VeraSe.ttf"
    },
    fontStyles = {
        OUTLINE = "OUTLINE",
        MONOCHROME = "MONOCHROME",
        NONE = "NONE"
    },
    stratas = {
        BACKGROUND = "BACKGROUND",
        LOW = "LOW",
        MEDIUM = "MEDIUM",
        HIGH = "HIGH",
        DIALOG = "DIALOG"
    },
    anchorPoints = {
        TOP = "TOP",
        BOTTOM = "BOTTOM",
        LEFT = "LEFT",
        RIGHT = "RIGHT",
        CENTER = "CENTER",
        TOPLEFT = "TOPLEFT",
        TOPRIGHT = "TOPRIGHT",
        BOTTOMLEFT = "BOTTOMLEFT",
        BOTTOMRIGHT = "BOTTOMRIGHT"
    }
}

---@type table
Config.defaultConfig = {
    -- Frame Visibility
    showPlayerFrame = true,
    showTargetFrame = true,
    showTargetoftargetFrame = true,
    showPetFrame = true,
    showPetTargetFrame = false,
    showBlizzardPlayerFrame = false,
    showBlizzardTargetFrame = false,
    showBlizzardTargetoftargetFrame = false,
    showBlizzardPetFrame = false,
    showBlizzardPetTargetFrame = false,

    showPlayerPowerBar = true,
    showTargetPowerBar = true,
    showTargetoftargetPowerBar = false,
    showPetPowerBar = false,
    showPetTargetPowerBar = false,

    -- Module Visibility
    showPlayerBuffs = true,
    showPlayerDebuffs = true,
    showTargetBuffs = true,
    showTargetDebuffs = true,
    showPlayerCombatFeedback = true,
    showPlayerClassResources = true,

    -- Frame Appearance
    showBorder = true,
    showFrameBackdrop = true,
    barTexture = "Minimalist",

    frameBg = {0, 0, 0, 0.5},
    frameBgHovered = {0.1, 0.1, 0.1, 0.8},
    frameBorder = {0.6, 0.6, 0.6, 1},
    frameBorderHovered = {1, 1, 0, 1},

    useClassColorsPlayer = true,
    useClassColorsTarget = true,
    useClassColorsTargetoftarget = true,
    useClassColorsPet = true,
    useClassColorsPetTarget = true,

    -- Text Options
    font = "FrizQuadrataTT",
    fontSize = 12,
    fontStyle = Config.media.fontStyles.NONE,

    showPlayerFrameText = true,
    showTargetFrameText = true,
    showTargetoftargetFrameText = false,
    showPetFrameText = true,
    showPetTargetFrameText = false,
    showPlayerLevelText = true,
    showTargetLevelText = true,
    showTargetoftargetLevelText = false,
    showPetLevelText = false,
    showPetTargetLevelText = false,

    playerXPos = -200,
    playerYPos = -200,
    targetXPos = 200,
    targetYPos = -200,
    targetoftargetXPos = 350,
    targetoftargetYPos = -250,
    petXPos = 200,
    petYPos = -200,
    petTargetXPos = 200,
    petTargetYPos = -200,

    -- Frame-specific Settings
    playerWidth = 204,
    playerHeight = 100,
    targetWidth = 204,
    targetHeight = 100,
    targetoftargetWidth = 84,
    targetoftargetHeight = 32,
    petWidth = 102,
    petHeight = 48,
    petTargetWidth = 84,
    petTargetHeight = 32,

    playerAnchor = Config.media.anchorPoints.CENTER,
    targetAnchor = Config.media.anchorPoints.CENTER,
    targetoftargetAnchor = Config.media.anchorPoints.CENTER,
    petAnchor = Config.media.anchorPoints.CENTER,
    petTargetAnchor = Config.media.anchorPoints.CENTER,
    playerStrata = Config.media.stratas.MEDIUM,
    targetStrata = Config.media.stratas.MEDIUM,
    targetoftargetStrata = Config.media.stratas.MEDIUM,
    petStrata = Config.media.stratas.MEDIUM,
    petTargetStrata = Config.media.stratas.MEDIUM,

    targetAnchoredTo = "Screen"
}

---@type table
Config.frameBackdrop = {
    options = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    },
    colors = {
        bg = Config.defaultConfig.frameBg,
        bgHovered = Config.defaultConfig.frameBgHovered,
        border = Config.defaultConfig.frameBorder,
        borderHovered = Config.defaultConfig.frameBorderHovered
    }
}

---@type table
Config.auraConfig = {
    player = {
        verticalSpacing = 2,
        buffs = {
            enabled = Config.defaultConfig.showPlayerBuffs,
            maxRows = 2,
            perRow = 8,
            size = 28,
            showCooldownText = false,
            anchorPoint = Config.media.anchorPoints.TOPLEFT,
            xOffset = -2,
            yOffset = 2,
            maxDisplay = 16,
            showStackText = true,
            stackTextSize = 10,
            stackTextAnchor = "BOTTOMRIGHT",
            stackTextXOffset = -1,
            stackTextYOffset = 1
        },
        debuffs = {
            enabled = Config.defaultConfig.showPlayerDebuffs,
            maxRows = 2,
            perRow = 8,
            size = 36,
            showCooldownText = false,
            anchorPoint = Config.media.anchorPoints.TOPRIGHT,
            xOffset = -2,
            yOffset = -2,
            maxDisplay = 32,
            showStackText = true,
            stackTextSize = 10,
            stackTextAnchor = "BOTTOMRIGHT",
            stackTextXOffset = -1,
            stackTextYOffset = 1
        }
    },
    target = {
        verticalSpacing = 2,
        buffs = {
            enabled = Config.defaultConfig.showTargetBuffs,
            maxRows = 2,
            perRow = 8,
            size = 28,
            showCooldownText = false,
            anchorPoint = Config.media.anchorPoints.TOPLEFT,
            xOffset = 2,
            yOffset = 2,
            maxDisplay = 32,
            showStackText = true,
            stackTextSize = 10,
            stackTextAnchor = "BOTTOMRIGHT",
            stackTextXOffset = -1,
            stackTextYOffset = 1
        },
        debuffs = {
            enabled = Config.defaultConfig.showTargetDebuffs,
            maxRows = 2,
            perRow = 8,
            size = 36,
            showCooldownText = false,
            anchorPoint = Config.media.anchorPoints.TOPRIGHT,
            xOffset = 2,
            yOffset = -2,
            maxDisplay = 16,
            showStackText = true,
            stackTextSize = 10,
            stackTextAnchor = "BOTTOMRIGHT",
            stackTextXOffset = -1,
            stackTextYOffset = 1
        }
    }
}

---@type table
Config.classResourcesConfig = {
    playerEnabled = Config.defaultConfig.showPlayerClassResources
}

---@type table
Config.combatFeedbackConfig = {
    playerEnabled = Config.defaultConfig.showPlayerCombatFeedback,
    fontSize = 20,
    fontOutline = "NONE",
    duration = 2.0,
    fadeOutDuration = 0.5,
    xOffset = 0,
    yOffset = 0,
    anchorPoint = "CENTER",
    colors = {
        STANDARD = {
            r = 1,
            g = 1,
            b = 1
        },
        MISS = {
            r = 1,
            g = 1,
            b = 1
        },
        HEAL = {
            r = 0,
            g = 1,
            b = 0
        },
        ENERGIZE = {
            r = 0.41,
            g = 0.8,
            b = 0.94
        },
        DAMAGE = {
            r = 1,
            g = 0,
            b = 0
        }
    }
}

MinimalUnitFramesDB = MinimalUnitFramesDB or {}
for key, default in pairs(Config.defaultConfig) do
    if MinimalUnitFramesDB[key] == nil then
        MinimalUnitFramesDB[key] = default
    end
end

return Config
