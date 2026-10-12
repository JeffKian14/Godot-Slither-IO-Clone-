# Slither.io – Reinforcement Learning AI

A Slither.io-inspired game developed using Godot Engine, featuring **10 AI-controlled snakes trained using Proximal Policy Optimisation (PPO)**.

The project integrates Godot with Python-based Reinforcement Learning, allowing players to compete against trained AI agents in real time.

### Download & Play

**[Download the Windows Game Here](https://github.com/JeffKian14/Godot-Slither-IO-Clone-/releases/latest)**

1. Open the link above and download `Jeff-Slither-AI-Game.zip` under **Assets** (not Source code).
2. Extract the entire ZIP file.
3. Double-click `Jeff_Slither.exe` to launch the game.
4. Allow a few moments for the AI to initialise.
5. Click **START** and enjoy!

**To exit the game:** Press `Alt + F4`.

> Note: Windows 64-bit only. Keep all extracted files together, including the AI folder. No separate Godot or Python installation is required for the tested packaged release.

### Technologies Used

- **Game Engine:** Godot / GDScript
- **AI Framework:** Python, Stable-Baselines3
- **Algorithm:** Proximal Policy Optimisation (PPO)
- **Integration:** Godot RL Agents

### Project Highlights

- 10 trained AI opponents.
- Player-versus-AI gameplay.
- Automatic AI startup and synchronisation.
- Integrated AI training and inference pipeline.


### How the Game Works

A player competes against 10 AI-controlled snakes in a Slither.io-inspired environment, collecting food to grow while avoiding collisions.

The AI agents are trained using **Proximal Policy Optimisation (PPO)**. Godot communicates with Python through Godot RL Agents, allowing the trained model to receive game observations and return movement actions in real time.

### What I Implemented

- Developed the game environment, mechanics and player interactions using Godot and GDScript.
- Implemented a reinforcement learning training pipeline using Python and Stable-Baselines3.
- Integrated trained PPO agents into the Godot environment.
- Automated Python AI startup and synchronisation.
- Packaged the project into a playable Windows application.


---

*An academic/personal project developed to explore Reinforcement Learning in an interactive game environment.*
