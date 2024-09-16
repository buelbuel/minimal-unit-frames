---@class Config
local addonName, addon = ...
local Config = {}
addon.Config = Config

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

    showPlayerBuffs = false,
    showTargetBuffs = true,
    showPlayerDebuffs = true,
    showTargetDebuffs = true,

    showPlayerPowerBar = true,
    showTargetPowerBar = true,
    showTargetoftargetPowerBar = false,
    showPetPowerBar = false,
    showPetTargetPowerBar = false,

    -- Frame Appearance
    showBorder = true,
    showFrameBackdrop = true,
    alpha = 1,
    width = 204,
    height = 64,
    barTexture = "Minimalist",

    useClassColorsPlayer = true,
    useClassColorsTarget = true,
    customColorPlayer = {0, 1, 0, 1},
    customColorTarget = {0, 1, 0, 1},

    -- Text Options
    font = "FrizQuadrataTT",
    fontSize = 12,
    fontStyle = "NONE",

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

    -- Frame Positioning
    strata = "MEDIUM",
    anchor = "CENTER",
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
    playerAnchor = "CENTER",
    targetAnchor = "CENTER",
    targetoftargetAnchor = "CENTER",
    petAnchor = "CENTER",
    petTargetAnchor = "CENTER",
    playerStrata = "MEDIUM",
    targetStrata = "MEDIUM",
    targetoftargetStrata = "MEDIUM",
    petStrata = "MEDIUM",
    petTargetStrata = "MEDIUM"
}

---@type table
addon.Config.frameBackdrop = {
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
        bg = {0, 0, 0, 0.5},
        bgHovered = {0.1, 0.1, 0.1, 0.8},
        border = {0.6, 0.6, 0.6, 1},
        borderHovered = {1, 1, 0, 1}
    }
}

---@type table
Config.classColors = {
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
Config.auraConfig = {
    buffs = {
        playerEnabled = addon.Config.defaultConfig.showPlayerBuffs,
        targetEnabled = addon.Config.defaultConfig.showTargetBuffs,
        maxRows = 2,
        perRow = 8,
        size = 28,
        showCooldownText = false
    },
    debuffs = {
        playerEnabled = addon.Config.defaultConfig.showPlayerDebuffs,
        targetEnabled = addon.Config.defaultConfig.showTargetDebuffs,
        maxRows = 2,
        perRow = 8,
        size = 36,
        showCooldownText = false
    }
}

---@type table
Config.classResourcesConfig = {
    enabled = true,
    showResourceBar = true
}

return Config
