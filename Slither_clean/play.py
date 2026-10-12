from stable_baselines3 import PPO
from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv

# 1. Connect to Godot
env = StableBaselinesGodotEnv(env_path=None)

# 2. Load the trained brain (Make sure 'model.zip' matches your actual file name!)
model = PPO.load("model_4.zip")

print("AI is connected and ready for battle!")

# 3. Start the game loop
# For Godot RL Vector Environments, reset() returns the exact observation dict directly.
obs = env.reset()

while True:
    # deterministic=True forces the AI to use its absolute best strategy
    action, _ = model.predict(obs, deterministic=True)
    
    # Send the actions to all 10 agents and get the new state
    obs, reward, done, info = env.step(action)