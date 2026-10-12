
https://github.com/user-attachments/assets/79737a54-17ae-42ff-a59d-bc6cd5e72be1
# Slither.io – Reinforcement Learning AI

A Slither.io-inspired game developed using Godot Engine, featuring **10 AI-controlled snakes trained using Proximal Policy Optimisation (PPO)**.

The project integrates Godot with Python-based Reinforcement Learning, allowing players to compete against trained AI agents in real time.

## Gameplay Demo

Watch the gameplay demonstration below, featuring the trained PPO agents competing in the Godot environment.


https://github.com/user-attachments/assets/ba2408f0-9494-4a84-9734-cf8f80bc52d3



## How the Game Works

Players compete against 10 AI-controlled snakes, collecting food to grow while avoiding collisions.

The AI agents are trained using **PPO**. Godot communicates with Python through Godot RL Agents, allowing the trained model to receive game observations and return movement actions in real time.

## What I Implemented

- Developed the game environment, mechanics and player interactions using Godot and GDScript.
- Implemented a reinforcement learning training pipeline using Python and Stable-Baselines3.
- Integrated trained PPO agents into the Godot environment.
- Automated Python AI startup and synchronisation.
- Packaged the project into a playable Windows application.

## Technologies Used

| Component | Technology |
|---|---|
| Game Engine | Godot / GDScript |
| Programming Language | Python |
| RL Algorithm | Proximal Policy Optimisation (PPO) |
| AI Framework | Stable-Baselines3 |
| Integration | Godot RL Agents |

## Download & Play

**[Download the Windows Game Here](https://github.com/JeffKian14/Godot-Slither-IO-Clone-/releases/latest)**

1. Open the link above and download `Jeff-Slither-AI-Game.zip` under **Assets** (not Source code).
2. Extract the entire ZIP file.
3. Double-click `Jeff_Slither.exe` to launch the game.
4. Allow a few moments for the AI to initialise.
5. Click **START** and enjoy!

**To exit the game:** Press `Alt + F4`.

**Note:** Windows 64-bit only. Keep all extracted files together, including the AI folder. No separate Godot or Python installation is required for the tested packaged release.

## Acknowledgements & References

This project utilises the open-source **Godot RL Agents** framework developed by Ed Beeching and contributors to facilitate communication between Godot and Python-based reinforcement learning agents.

- **Original Repository:** [Godot RL Agents Plugin](https://github.com/edbeeching/godot_rl_agents_plugin/tree/main)
- **RL Algorithm:** Proximal Policy Optimisation (PPO)
- **Training Framework:** Stable-Baselines3

The game environment, gameplay mechanics, PPO training configuration, AI integration and Windows application packaging were implemented as part of this project.

---

*An academic/personal project developed to explore Reinforcement Learning in an interactive game environment.*
