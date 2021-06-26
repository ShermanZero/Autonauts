--[[
  ** Autonauts Advanced Audio Mod **

  author: Kieran Skvortsov (ShermanZero)
  website: https://shermanzero.com (currently under development)
  source: https://github.com/shermanzero/Autonauts/AdvancedAudio
  copyright: GNU General Public License v3.0
  description: This mod allows the user full customization over all
    audio events (sounds) in the game.
  comments: Due to the limited Autonauts API, the UI for this mod is
    not quite as intuitive as I would like, but it's the best I can
    do with the tools available to me.  I have also never used Lua
    before, so my programming is reflective of the one day I spent
    writing this mod :p so I'm sorry if there's some code that makes
    you scratch your head.  Please feel free to optimize it!

  ============
  useful links:
    (Lua JSON Library Used by Autonatus) -- https://www.moonsharp.org/additions.html
    (Autonauts Beginner's Guide) ---------- https://docs.google.com/document/d/1BHoLxj2d8nIy_JXhucQ-PBCyU0ctdXeptRZg7C5QM1M/edit
    (Autonauts API) ----------------------- http://www.denki.co.uk/autonauts/modding/index.html
      - ModBase
      - ModSound
      - ModSaveData
      - ModUI
]]

-- my linter is dumb :)
---@diagnostic disable: lowercase-global, undefined-global

------------------------------------------------------------------
--              * ========= Constants ========= *               --
------------------------------------------------------------------

local VERSION = "0.0.1"
local LAST_UPDATED = "06/26/21"

local LL_IMPORTANT = 1
local LL_DETAILED = 2
local LL_FULL = 3

--[[
  The default value of audio events.  `1` prevents data from
  being unnecessarily saved when it hasn't been changed.
]]
local DEFAULT_VALUE = "100"

--[[
  Specifies the prefix to search for in audio events in
  custom additions which affect all audio events in a group.
]]
local ALL_PREFIX = "All "

--[[
  Controls whether or not to reset all user-modified
  save-data.
]]
local reset = false

------------------------------------------------------------------
--           * ========= Other Variables ========= *            --
------------------------------------------------------------------

--[[
  Boolean value holding whether or not to display the
  confirmation after the game loads.
]]
local showConfirmation = true

--[[
  Integer value holding what level of detail to log.

  ```
    0: None,
    1: Important,
    2: Detailed,
    3: Full
  ```
]]
local logLevel = 0

--[[
  Since Autonauts Lua configuration unfortunately does not allow for IO,
  storing the large string staticly in code is the best option.
]]
local audioString = [[{
  "Achievements": [
    "BadgeEarned1stPass",
    "BlueprintUnlocked1stPass",
    "BlueprintUnlockedEnd1stPass",
    "CeremonyFirstBot",
    "CeremonyFolkLevelUp1stPass",
    "CertificateAppear",
    "EraEnd1stPass",
    "EvolutionBandAppear",
    "EvolutionBandUnlocked1stPass",
    "EvolutionInfoAppear1stPass",
    "Go1stPass",
    "QuestEnd1stPass",
    "MainQuestEnd1stPass",
    "MissionComplete",
    "Plus11stPass",
    "Plus1Complete1stPass"
  ],
  "Actions": [
    "Ruffle",
    "Scanning"
  ],
  "Animals": [
    "BeeIdle",
    "BirdEating",
    "BirdScared",
    "ChickenCarried",
    "ChickenEating",
    "ChickenGrowing",
    "ChickenLaying",
    "ChickenMoving",
    "ChickenSurprise",
    "CowEating",
    "CowExcreting",
    "CowGrowing",
    "CowMilking",
    "CowScared",
    "DogAnswer",
    "SheepEating",
    "SheepGrowing",
    "SheepScared",
    "SheepShearing"
  ],
  "Bats": [
    "BatBallBatHit",
    "BatBallBlockHit",
    "BatBallGameStart",
    "BatBallOut",
    "BatBallWallHit"
  ],
  "Blueprints": [
    "BlueprintAdd",
    "BlueprintAddFail1stPass",
    "BlueprintDeleted",
    "BlueprintJump",
    "BlueprintMaking",
    "BlueprintMakingComplete1stPass",
    "BlueprintSwoosh"
  ],
  "Bots": [
    "BotGrouped",
    "BotServerIdle",
    "BotServerWorking",
    "BotUnGrouped"
  ],
  "Building": [
    "BuildingAdd",
    "BuildingAddBad1stPass",
    "BuildingDeleteFail1stPass",
    "BuildingMaking",
    "BuildingMakingComplete1stPass",
    "BuildingMakingComplete21stPass",
    "BuildingStageComplete1stPass"
  ],
  "Cart": [
    "CartMotion"
  ],
  "Catapult": [
    "CatapultRelease",
    "CatapultReset",
    "CatapultRewinding",
    "CatapultTargetSelected"
  ],
  "Crane": [
    "CraneDrop",
    "CraneMotion",
    "CranePickup"
  ],
  "Environment": [
    "AmbienceDayTime",
    "AmbienceNightTime",
    "AmbienceRain",
    "AmbienceWind",
    "CockCrow",
    "OwlHoot",
    "Thunder01",
    "Thunder02",
    "Thunder03",
    "Thunder04",
    "Waves"
  ],
  "Farming": [
    "CropGrowing",
    "FarmerDisengagedObject",
    "FarmerDrop",
    "FarmerEngagedObject",
    "FarmerJumpSeed",
    "FarmerPickUp",
    "FarmerStepSwamp",
    "FarmerStepWater",
    "FarmerThrow",
    "FertiliserUsed1stPass",
    "PloughMotion",
    "PloughMotionSoil",
    "Seeding"
  ],
  "Fireworks": [
    "FireworkExplode",
    "FireworkLauch"
  ],
  "Flowerpots": [
    "FlowerPotDead",
    "FlowerPotDying",
    "FlowerPotGrowing",
    "FlowerPotGrown",
    "FlowerPotSeeded"
  ],
  "Folks": [
    "FolkAppear",
    "FolkBadObject",
    "FolkClothed",
    "FolkCreateHeart",
    "FolkEating",
    "FolkGivenToy",
    "FolkHappy",
    "FolkHungry",
    "FolkLevelUp1stPass",
    "FolkPickedUp",
    "FolkSad1stPass",
    "FolkSeedPodMaking",
    "FolkTranscend"
  ],
  "Home": [
    "GateClose",
    "GateOpen",
    "HouseDestroyed",
    "HouseRepaired"
  ],
  "Ideas": [
    "Idea",
    "IdeaComplete"
  ],
  "Instruments": [
    "InstrumentCastanets",
    "InstrumentCowbell",
    "InstrumentGuiro",
    "InstrumentGuitar1",
    "InstrumentGuitar2",
    "InstrumentGuitar3",
    "InstrumentGuitar4",
    "InstrumentJawHarp",
    "InstrumentMaraca",
    "InstrumentTriangle"
  ],
  "Making": [
    "BasicMetalWorkbenchMaking",
    "BenchSaw2Making",
    "BenchSawMaking",
    "ButterChurnMaking",
    "CogBenchMaking",
    "FurnaceMaking",
    "HayBalerMaking",
    "LoomMaking",
    "MetalWorkbenchMaking",
    "QuernMaking",
    "RockingChairMaking",
    "SpinningJennyMaking",
    "SpinningWheelMaking",
    "StringWinderMaking",
    "TrackMaking"
  ],
  "Minecarts": [
    "MinecartConnect",
    "MinecartDisconnect",
    "MinecartHitBuffer",
    "MinecartMotion"
  ],
  "Misc": [
    "MusicDenkiThemeFanfare",
    "FanfareGoodSmall1stPass",
    "Tick1stPass",
    "TutorTalk",
    "TranscendBuildingConvert",
    "FurnaceIdle"
  ],
  "Objects": [
    "Confetti",
    "FireBurning",
    "ObjectCreated",
    "Rocket",
    "ScooterMove",
    "TreeFallen"
  ],
  "Player": [
    "PlayerActionFail1stPass",
    "PlayerClayMove",
    "PlayerHeavyLift",
    "PlayerInventoryCycleBackwards",
    "PlayerInventoryCycleForwards",
    "PlayerInventoryStow",
    "PlayerMove",
    "PlayerMovePath",
    "PlayerNoTool",
    "PlayerShout",
    "PlayerStoneMove",
    "PlayerUpgradeAdded"
  ],
  "Research": [
    "ResearchDissection",
    "ResearchFirst1stPass",
    "ResearchGrind",
    "ResearchHeating",
    "ResearchIdle",
    "ResearchImpact",
    "ResearchMaking",
    "ResearchMakingComplete1stPass",
    "ResearchSampleAdded",
    "ResearchSoaking",
    "ResearchUnlocked1stPass"
  ],
  "Scripts": [
    "ScriptPaused",
    "ScriptUndo",
    "ScriptUpdated",
    "ScriptingGoSelected",
    "ScriptClear",
    "ScriptInstructionAdded",
    "ScriptInstructionAreaIndicated",
    "ScriptInstructionDeleted",
    "ScriptInstructionDrag",
    "ScriptInstructionExecuted1",
    "ScriptInstructionExecuted2",
    "ScriptInstructionExecuted3",
    "ScriptInstructionIndicated",
    "ScriptInstructionRemoved",
    "ScriptInstructionForeverAdded",
    "ScriptInstructionForeverRemoved"
  ],
  "Ships": [
    "ShipClose",
    "ShipOpen"
  ],
  "SteamEngine": [
    "StationarySteamEngineConverting",
    "StationarySteamEngineRunning"
  ],
  "Structures": [
    "ZigguratDone",
    "ZigguratTransform",
    "StoneHengeActive"
  ],
  "Tickets": [
    "TicketsAdd",
    "TicketsTotal"
  ],
  "Tools": [
    "ToolAxeChop",
    "ToolBroken",
    "ToolBucketEmpty",
    "ToolDig",
    "ToolFlailUse",
    "ToolMalletHammer",
    "ToolPaddleSplash",
    "ToolPickaxeHit",
    "ToolPitchfork",
    "ToolReaping",
    "ToolSweepUse"
  ],
  "Trains": [
    "TrainIdle",
    "TrainMotion",
    "TrainRefuelling",
    "TrainStopped"
  ],
  "Transmitter": [
    "Transmitter",
    "TransmitterReward"
  ],
  "UI": [
    "AreaGrab",
    "AreaMove",
    "AreaRelease",
    "AreaScale",
    "LaunchButton",
    "OptionCancelled",
    "OptionIndicated",
    "OptionSelected",
    "OptionToggled",
    "Pause1stPass",
    "RolloverPopup",
    "SpacePortJobCancelled",
    "SpacePortJobDeleted",
    "StartButton",
    "TabReveal1stPass",
    "UIEditModeSelected",
    "UIEvolutionSelected",
    "UIIndustriesSelected",
    "UIOptionIndicated1stPass"
  ],
  "Whistles": [
    "WhistleBlown1",
    "WhistleBlown2",
    "WhistleBlown3",
    "WhistleBlown4",
    "WhistleCancel1",
    "WhistleCancel2",
    "WhistleCancel3",
    "WhistleCancel4",
    "WhistleDropAll1",
    "WhistleDropAll2",
    "WhistleDropAll3",
    "WhistleDropAll4",
    "WhistleToMe1",
    "WhistleToMe2",
    "WhistleToMe3",
    "WhistleToMe4"
  ],
  "Windmills": [
    "WindmillIdle",
    "WindmillMaking",
    "WindmillMakingComplete1stPass"
  ],
  "Workers": [
    "WorkerAcknowledgeLearn1stPass",
    "WorkerAssemblerMakingComplete1stPass",
    "WorkerClayMove",
    "WorkerConfirm1",
    "WorkerConfirm2",
    "WorkerConfirm3",
    "WorkerCrudeMove",
    "WorkerIndicated",
    "WorkerLowEnergy1stPass",
    "WorkerMove",
    "WorkerNoEnergy",
    "WorkerNoTool",
    "WorkerRestarted",
    "WorkerSelected",
    "WorkerShout1stPass",
    "WorkerSteamMove",
    "WorkerStoneMove",
    "WorkerStop",
    "WorkerStuck",
    "WorkerThrow",
    "WorkerUpgradeAdded1stPass",
    "WorkerWinding",
    "WorkerWorking",
    "WorkerWorkingClockwork"
  ]
}]]

--[[
  The following pseudo-json code is a representation of how the actual
  'audioJson' is decoded.

  ```
  "groupName": {
    "eventName",
    "eventName2",
    ...
  },
  "groupName2": {
    "eventName",
    ...
  }
  ```
]]
local audioJson = {}

--[[
  `audioChanges` holds all audio events and their corresponding altered
  volume values in a Lua table.

  ```
  "sound1": 24,
  "sound2": 59,
  "sound3": 97,
  ...
  ```
]]
local audioChanges = {}

------------------------------------------------------------------
--           * ========= Helper Functions ========= *           --
------------------------------------------------------------------

--[[
  Helper function to pass data to the Autonauts log function.
]]
---@param str string The string to print
---@param level number The log-level of the log (message)
---@param err boolean If the log should display as an error
local function _log(str, level, err)
  if level > logLevel then
    return
  end

  if not err then
    ModDebug.Log("[AA] ✓\t"..str)
  else
    ModDebug.Log("[AA] ✘\t"..str)
  end
end

--[[
  Helper function to pass data to the Autonauts log function.
]]
---@param str string The string to print
---@param level number The log-level of the log (message)
---@param err boolean If the log should display as an error (defaults to false)
local function log(str, level, err)
  err = err or false
  _log(str, level, err)
end

--[[
  Helper function to pass data to the Autonauts log function,
    displayed as an error.
]]
---@param str string The string to print
---@param level number The log-level of the log (message)
local function logErr(str, level)
  log(str, level, true)
end

--[[
  Parses data from `audioString` into JSON, which is then
    converted to nested tables by Lua.
]]
local function parseData()
  log("Attempting to parse audio events...", LL_DETAILED)
  audioJson = json.parse(audioString)

  if audioJson ~= nil and audioJson ~= {} then
    log("...all audio events parsed successfully", LL_DETAILED)
    for grpName, grp in pairs(audioJson) do
      local customAll = (ALL_PREFIX..grpName)

      --Add the custom 'All <Group Name>' as the first element in each group
      table.insert(grp, 1, customAll)
      log("Inserted "..customAll.." into "..grpName, LL_FULL)
    end
  else
    logErr("Failure parsing audio events", LL_IMPORTANT)
  end

end

------------------------------------------------------------------
--               * ========= Callbacks ========= *              --
------------------------------------------------------------------

--[[
  Callback function to when the user changes the
    `Log Level` option in-game.
]]
---@param level number The new level
local function adjustLogLevel(level)
  logLevel = level
  log("Log level adjusted to "..level, LL_FULL)
end

--[[
  Callback function to handle when the user toggles the
    `Reset to Default` option in-game.
]]
---@param doReset boolean The state of the toggle
local function initiateReset(doReset)
  --Only run when the `Reset to Default` option is toggled to true
  if doReset == true then
    --Callback handling the user choosing `confirm`
    local function onConfirm()
      reset = true
      ModUI.ShowPopup("Reset Complete", "Due to the limitations of the Autonauts API, the volume sliders will not reset their positions.  However, all audio events will remain reset until modifying them again.  Also, the 'Reset to Default' option will remain selected.  De-selecting this option before the next game-load will cancel the reset.")
    end

    --Calback handling the user choosing `cancel`
    local function onDeny()
      reset = false
    end

    ModUI.ShowPopupConfirm("Reset to Default", "This will reset all modified audio events back to default", onConfirm, onDeny)
  else
    --If the user chose to reset but de-selected `Reset to Default` before the actual reset
    if reset == true then
      reset = false
      ModUI.ShowPopup("Reset Cancelled", "If this wasn't your intention, just re-select 'Reset to Default'.")
    end
  end
end

--[[
  Callback function to when the user toggles the
    `Show Confirmation` option in-game.
]]
---@param confirm boolean The state of the toggle
local function adjustConfirmation(confirm)
  showConfirmation = confirm
end

--[[
  Exposes all audio events to the user in-game.
]]
---@param tableName string The name of the table
---@param tableContents table The contents of the table
local function exposeAudioEvents(tableName, tableContents)
  local selectedEvent = tableContents[0] or "n/a"

  ---Callback function to change the selected event in code to correspond
  ---to what the user selected.
  ---@param index number The index of the currently selected audio event
  local function selected(index)
    if index ~= nil then
      --Not sure why index doesn't follow convention, but nevertheless if not set to `index+1` the code will fail
      selectedEvent = tableContents[index+1]
      log("Selected event set to "..selectedEvent, LL_FULL)
    end
  end

  ---Callback function to change the volume of the selected event to
  ---correspond to what the user chose.
  ---@param volume string The volume to set the selected audio event to
  local function adjustVolume(volume)
    volume = tostring(volume)

    --If the volume is not the default value
    if volume ~= DEFAULT_VALUE then
      volume = (tonumber(volume)/100.0)

      audioChanges[selectedEvent] = volume
      log("Adjusted volume of "..selectedEvent.." to "..volume, LL_FULL)

      --If the currently selected event is ALL, then adjust all audio events in the group
      if selectedEvent:find(ALL_PREFIX) ~= nil then
        for _, audioEvent in pairs(tableContents) do
          audioChanges[audioEvent] = volume
        end
      end
    end
  end

  --Basically "hide" (make extremely small) the text while providing a unique ID.
  local title = "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t"..tableName

  --Expose the entire list of audio events in the group as a dropdown.
  ModBase.ExposeVariableList(tableName, tableContents, 1, selected)
  log("Exposed variables inside "..tableName, LL_FULL)

  --Expose the volume slider which will adjust the volume for whichever
  --audio event is currently selected.
  ModBase.ExposeVariable(title, 100, adjustVolume, 0, 100)
  log("Exposed volume slider for "..tableName, LL_FULL)
end

------------------------------------------------------------------
--           * ========= Loading & Saving ========= *           --
------------------------------------------------------------------


--[[
  Loads all user-modified audio events from game-storage into `audioChanges`.
]]
local function loadSavedData()
  --Retrieve each group name (string) and group (table) in `audioJson`.
  for grpName, grp in pairs(audioJson) do
    --Retrieve each _ (number) and [audio] event (string) in the group (table).
    for _, event in pairs(grp) do
      --Attempt to load the value from existing save-data.  On fail, return DEFAULT_VALUE.
      local value = ModSaveData.LoadValue(event, DEFAULT_VALUE)
      log("Value assigned after attempted load of "..event..": "..value, LL_FULL)

      --If there was a saved, non-default audio event
      if value ~= DEFAULT_VALUE then
        --If the user has not changed the volume of the audio event during this game-session
        if audioChanges[event] == DEFAULT_VALUE then
          audioChanges[event] = value
          log("[LOADED] "..event..": "..value, LL_IMPORTANT)
        end
      end
    end
  end

  --Newline for easy reading :)
  if audioChanges ~= {} then
    log("", LL_IMPORTANT)
  end
end

--[[
  "Clears" the save-data related to this mod by
  resetting all audio events to their default (100).
]]
local function clearSaveData()
  audioChanges = {}

  log("[RESET] executing...", LL_IMPORTANT)

  --Retrieve each group name (string) and group (table) in `audioJson`.
  for grpName, grp in pairs(audioJson) do
    --Retrieve each _ (number) and [audio] event (string) in the group (table).
    for _, event in pairs(grp) do
      if ModSaveData.SaveValue(event, DEFAULT_VALUE) then
        log("[RESET] "..event, LL_DETAILED)
      else
        logErr("[ERROR] resetting "..(event or "[unknown]"), LL_IMPORTANT)
      end
    end
  end

  reset = false
  log("[RESET] ...complete", LL_IMPORTANT)
end

--[[
  Saves all user-modified audio events stored in `audioChanges`
  into game-storage.
]]
local function saveData()
  if audioChanges == nil or audioChanges == {} then
    log("[WARN] There was no data to save", LL_DETAILED)
    return
  end

  --Iterate through all key, value pairs of audio events and their volumes
  --in the `audioChanges` table and save them to game-storage.
  for event, volume in pairs(audioChanges) do
    if ModSaveData.SaveValue(event, volume) then
      log("[SAVED] "..event..": "..volume, LL_IMPORTANT)
    else
      logErr("[ERROR] saving "..(event or "[unknown]"), LL_IMPORTANT)
    end
  end
  --Newline for easy reading :)
  log("", LL_IMPORTANT)
end

------------------------------------------------------------------
--      * ========= Global Overriden Functions ========= *      --
------------------------------------------------------------------

---Sets up the mod with Steam.
function SteamDetails()
  -- Set steam details
  ModBase.SetSteamWorkshopDetails("AdvancedAudio", "Ever wanted more than just SFX and Music audio options?  This does it all.", {"audio"}, "logo.png")
end

---Exposes variables to the game UI.
function Expose()
  --Delete any existing log files.
  ModDebug.ClearLog()

  --Parse all data.
  parseData()

  --Expose the `Log Level` option.
  ModBase.ExposeVariableList("Log Level", {"None", "Important", "Detailed", "Full"}, 1, adjustLogLevel)

  --Expose the `Reset to Default` option.
  ModBase.ExposeVariable("Reset to Default", reset, initiateReset)

  --Expose the `Show Confirmation` option.
  ModBase.ExposeVariable("Show Confirmation", showConfirmation, adjustConfirmation)

  log("Attempting to expose audio events...", LL_DETAILED)

  --Iterate through each table in `audioJson` and expose all nested audio events.
  for grpName, grp in pairs(audioJson) do
    log("Attempting to expose group: "..grpName.."...", LL_FULL)
    exposeAudioEvents(grpName, grp)
  end

  log("...successfully exposed audio events", LL_DETAILED)
end

---Initial load function of game.  Called when user
---either starts a new game or loads an existing game.
---This is ***not*** called during Autonauts startup.
function BeforeLoad()
  --This makes sure that if the player leaves their game (not quits the game)
  --and re-enters, the confirmation will show again if enabled in the UI
  showConfirmation = ModBase.GetExposedVariable("Show Confirmation")

  --Re-load all modified audio events.
  if reset then
    log("[RESET] reset queued; skipping load", LL_IMPORTANT)
    return
  end

  loadSavedData()

  --Apply all modified audio events to the game.
  for event, volume in pairs(audioChanges) do
    ModSound.ChangeVolume(event, tonumber(volume))
    log("[CHANGED] "..event..": "..volume, LL_IMPORTANT)
  end

  --Newline for easy reading :)
  log("", LL_IMPORTANT)
end

---Called after game finishes its important loading.
function AfterLoad()
  if reset then
    --Clear save data.
    clearSaveData()
  else
  --Save all modified audio events.  Can't be called elsewhere.
    saveData()
  end
end

---Called every frame render.
function OnUpdate(deltaTime)
  if showConfirmation then
    local changes = 0

    --Count the number of changes made.
    for _, audioEvent in pairs(audioChanges) do
      changes = changes + 1
    end

    --If there weren't any audio changes applied.
    if changes == 0 then
      showConfirmation = false
      return
    end

    local info = "AdvancedAudio v"..VERSION.." ("..LAST_UPDATED..")"
    local change = "Successfully dug through the inner workings of Autonauts and made "..changes.." changes to audio levels for you!\n\n"
    local hint = "Hint: You can disable this message in the mod's options.\n\n"
    local description = (change..hint)

    ModUI.ShowPopup(info, description)

    --Prevent popup from being shown again.
    showConfirmation = false
  end
end