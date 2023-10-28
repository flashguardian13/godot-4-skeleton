# Flash's Game Skeleton

Everyone has one. A skeleton, I mean.

The idea here is that there are certain game components which are so ubiquitous that you'll want them in just about any game that you make. Maybe there are some exceptions, but they're not worth redoing the same work over and over every time you start a new game project. So you do the common stuff once, save your work, and reuse that work in each new game. That's what this project is: the common stuff, already done.

## Installation

First, you'll need Godot, since this skeleton is written for Godot. If you don't have it, start [here](https://godotengine.org/). You can also get it through [Steam](https://store.steampowered.com/app/404790/Godot_Engine/).

Next, you'll need to install the game source on your machine. GitHub should offer you several options. Click the green "<> Code" button and go from there. If you have Git, you can check it out as normal. Or you can download the source as a Zip file and extract it somewhere.

Finally, open up Godot. From the "Project Manager" screen, click "Import", click "Browse", navigate to the folder where the source is installed, select the "project.godot" file, then click "Open." (Or you can enter the path to the file directly, if you wish.) Finally, click "Import & Edit" to open the game skeleton in your editor.

## Demo the Game

The only way to play the game is to launch it from the Godot editor. Because this is a skeleton - meant to be extended to create your own game - there won't be any playable releases.

## Make My Own Game

Use my skeleton as you see fit. You can copy it and modify it to be your own game, or you can start a new project and copy into it only the pieces of the skeleton that you need. Or use my skeleton as a reference and do it yourself.

Note the MIT open source license, same as Godot's at time of writing. There are some exceptions:
* This skeleton may contain images, sounds, and other assets which are governed by different licensing agreements. I do not recommend reusing any such assets. Do your own due diligence. See the Credits section for additional details.
* The "Shuriken" logo is copyright to Shuriken Games and may not be reused or modified without permission. Replace it with your own studio's logo.

## Feature Requests

Found a problem? Want to see something added? You can use GitHub to open a work ticket. Go to [Issues](https://github.com/flashguardian13/godot-4-skeleton/issues), then click "New issue".

## Contribute to the Skeleton

You will need Git to collaborate on this project. At this time, you do not need to make your changes in a fork of the project, you can push your own branches to the project directly. This ability may be revoked if abused.
1. Check out a new branch. (Don't use main for development!)
1. Make your changes.
1. When happy, commit your changes, then push your branch to GitHub.
1. On GitHub, go to [Pull Requests](https://github.com/flashguardian13/godot-4-skeleton/pulls) and open a "New Pull request".

Please follow the [Godot Style Guide](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html#style-guide).

You are encouraged to follow the existing file and folder layout, as follows:
* assets: A place for all media and related content: images, audio, models, etc. This includes localization files.
    * fonts
    * images
    * music
    * sounds
* scenes: Keep all your Godot scenes (.tscn files) in here. If a scene has an attached script (.gd), store it adjacent to the scene.
    * components: General-use partial scenes that don't belong to any particular screen, popup, or otherwise.
    * popups: Scenes intended to be shown over other game elements such as confirmation prompts or file selectors.
    * screens: Scenes intended for gameplay, program flow, and the like. Typically fullscreen. Analogous to the individual pages that make up a website.
    * transitions: Animated scenes which briefly obscure an old screen, then reveal a new one.
* singletons: Back-end code, globally accessible. Not usually tied to any given scene. These can serve as APIs into key game functions.
* themes: UI styling configurations (.tres)

Scenes which are a sub-component of another scene should be stored in a subfolder of the parent scene's folder. You should Name the subfolder the same as the parent scene. For example, say we have a settings popup upon which there are multiple volume sliders. The file and folder layout should be as such:
* scenes
    * popups
        * settings
            * volume_slider.tscn
        * settings.tscn

## Credits

I don't need credit, but I wouldn't object either.

### Fonts

* Aantara Distance: wepfont, www.fontspace.com
* Eraser (Dust, Regular): David Rakowski, 1001fonts.com
* Fought Knight: Chequered Ink, 1001fonts.com

### Sounds

Button sounds are derived from sounds provided by Idalize of [freesound.org](freesound.org).

Tic-tac-toe marking and erasing sounds provided by [zapsplat.com](www.zapsplat.com).

### Music

All music provided by [zapsplat.com](www.zapsplat.com).

## Skeleton Components

Here I provide an overview of key features of the skeleton that you can incorporate into your game. For more information, refer to the comments in the source code.

Most importantly, have a look at `scenes\main` (`.gd` and `.tscn` in the editor), which serves as the backbone for many of the game's features, providing some root-level scene tree nodes that provide important functionality and keep the game's visual elements nicely layered.

### Music Player

Using the Music singleton, you can easily cross-fade to and from background music songs. A good place to do this is the `_ready()` function of the scene you are transitioning to. You'll need to provide the path to the audio resource to transition to.

```
const BG_MUSIC_PATH:String = "res://assets/music/background_music_01.mp3"
Music.get_player().cross_fade_to(BG_MUSIC_PATH)
```

**Key Files:**
* scenes\components\music_player
* singletons\music

**Usage Examples:**
* scenes\screens\main_menu
* scenes\screens\tic_tac_toe

### User Settings

Persistent game settings (those not tied to a specific instance of gameplay) can be easily handled by the use of the Config singleton. Settings are accessed as key/value pairs, much like a Dictionary. They are loaded from file automatically on startup, but must be saved to file manually in response to program quit requests and/or as desired.

```
# Get a config value
var music_volume:float = Config.get_value("volume.Music")

# Set a config value
Config.set_value("volume.Sound", 0.5)

# Only pre-programmed keys are recognized. To add a new configuration key, add
# it to the list of valid keys in singletons\config.
var valid_keys:Array = [
    ...
    "your.new.config.key",
    ...
]

# Save game configuration
Config.save()
```

**Key Files:**
* singletons\config

**Usage Examples:**
* scenes\main
* scenes\popups\settings
* scenes\popups\settings\volume_slider
* singletons\popups

### Saved Games

This feature makes use of two singletons: GameState and Saves.

GameState holds all data relating to a game in progress. Because it is a singleton, we can access game information from anywhere in our code. There are also helper functions for accessing this data, starting a new game, serializing the game state to a JSON-compatible structure, and restoring the game's state from such a structure. To save additional game data, add it to the JSON returned by the `to_json()` function, then modify the `from_json()` function to make use of that data (perhaps assigning some kind of useful default in case the data is absent).

*TODO: Currently, there are a bunch of functions specific to the tic-tac-toe game in here. Perhaps these should be separated out in some way.*

Saves is our interface to the saved game states on disk. It can tell us what saved games are present, get basic information about those saved games, load a saved game from file into the GameState singleton, and save the current game state to file. Saved game states are stored in JSON format. In your code, you should refer to saved games by their names (an identifier similar to the filename).

The skeleton provides a number of popups relating to loading and saving that should offer the user a familiar and friendly experience. These are recommended.

```
# Get a list of all saved games
var names:Array = Saves.get_save_names()

# Saving a game
Saves.save_by_name("my saved game")

# Loading a game
Saves.load_from_file("my other saved game")

# Get basic information about a saved game
Saves.get_save_info("a different saved game")
```

**Key Files:**
* singletons\game_state
* singletons\saves

**Usage Examples:**
* scenes\popups\confirm_action
* scenes\popups\save_as
* scenes\popups\save_first
* scenes\popups\save_select
* scenes\popups\save_select\saved_game
* scenes\screens\main_menu
* singletons\popups

### Screen Transitions

Handles smooth visual transitions between game screens. Transitions and screens are both Godot scenes, each built with certain requirements. At a high level, to perform a screen transition, you'll need to pass two resource paths to the Transitions singleton. The first is the transition, the second is the screen you want to switch to.

```
Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/tic_tac_toe.tscn")
```

It is recommended to define commonly-used transitions and scenes as constants at the top of the Transitions source so they can be referred to everywhere.

```
Transitions.start_transition(Transitions.TRANSITION_FADE_TO_BLACK, Transitions.SCREEN_TIC_TAC_TOE)
```

To understand how this is implemented, you may first want to look at `scenes/main.tscn` in the editor. At its root is a Main MarginContainer (fullscreen) with a number of CanvasLayers as children: Background, Stage, UI, Transition, and Popups. Screens are added as children of the Stage CanvasLayer, while transitions are added to the Transition layer.

When a transition is called for with `Transitions.start_transition()`, the order of events is as follows:
* The scene tree is paused. (Transitions are never paused.)
* A new instance of the transition scene is added to the Transition layer.
* The transition starts animating, gradually obscuring the window.
* When the transition has obscured the entire window, it emits a "screen_obscured" signal.
* The Transitions singleton, on receiving the "screen_obscured" signal, removes ALL children from the Stage layer, then adds a new instance of the desired screen to the Stage layer.
* The transition continues to animate, revealing the new screen.
* When the transition has finished revealing the new screen, it emits a "transition_complete" signal.
* The Transitions singleton, on receiving the "transition_complete" signal, removes ALL children from the Transition layer.
* The scene tree is unpaused.

Note how I said above that transitions and screens are **instanced**. They do not need to be added to the Main scene in the Godot editor; they will be created as needed and then removed automatically. Do not rely on screen scenes to store game state; instead, store game state information in the GameState singleton.

You can and should make your own screen scenes: a main menu, world maps, levels, chapters, inventory interfaces, minigames, etc. There's no special requirement for these, just make them as you would any other Godot scene.

You can create your own transition scenes. A transition should define and emit the following two signals, as described in the order of events above.

```
signal screen_obscured
signal transition_complete
```

**Key Files:**
* scenes\main
* scenes\transitions\fade_to_black
* singletons\transitions

**Usage Examples:**
* scenes\screens\main_menu
* scenes\screens\splash
* scenes\screens\tic_tac_toe

### Button Sounds

This largely automated singleton decorates all in-game buttons with sound effects that play when the mouse enters them or they are pressed. Buttons are discovered automatically, once when the Singleton is instantiated, and later when those Buttons are added to the scene tree. When discovered, the Singleton listens for the appropriate Button signals and plays sounds as desired.

It should be possible to have different Buttons play different sets of sounds based on their type, any assigned labels, or other logic. In theory, you could have the buttons on your battle screen play sword swooshes and strikes while the buttons on your main menu play short blips and chimes, and similar. To do this, modify the `_add_sounds_to_button()` function in the ButtonSounds singleton, connecting it to different sound-playing functions based on that button's properties, labels, etc.

**Key Files:**
* singletons\button_sounds
