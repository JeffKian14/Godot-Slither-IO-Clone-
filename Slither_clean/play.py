
from pathlib import Path
from stable_baselines3 import PPO
from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv

# Resolve the folder containing play.py
BASE_DIR = Path(__file__).resolve().parent

# Trained PPO model
MODEL_PATH = BASE_DIR / "model_4.zip"

# Connect to the running Godot environment
env = StableBaselinesGodotEnv(env_path=None)

# Load the trained AI brain
model = PPO.load(str(MODEL_PATH))

print("AI is connected and ready for battle!", flush=True)

# Initialise environment
obs = env.reset()

try:
    while True:
        # Predict actions using the trained model
        action, _ = model.predict(obs, deterministic=True)

        # Send actions to Godot AI agents
        obs, reward, done, info = env.step(action)

finally:
    env.close()
