from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv
from stable_baselines3 import PPO
from stable_baselines3.common.callbacks import CheckpointCallback

# 1. Setup the Checkpoint Callback
# This automatically saves a model file every 50,000 steps into a folder named "models"
checkpoint_callback = CheckpointCallback(
    save_freq=100000,
    save_path="./models/",
    name_prefix="slither_ppo_model"
)

# 2. Connect to the Godot Editor (env_path=None tells it to look for the open Godot editor)
env = StableBaselinesGodotEnv(env_path=None, show_window=True)

# 3. Initialize the PPO Algorithm
# "MultiInputPolicy" is required because your Action Space has both continuous (turning) and discrete (boosting).
model = PPO("MultiInputPolicy", env, verbose=1, tensorboard_log="./slither_tensorboard/")

# 4. Start Training!
print("Starting training... Watch Godot!")
# We pass the callback into the learn function here so it triggers while training
model.learn(total_timesteps=1000000, callback=checkpoint_callback)

# 5. Save the brain when done
model.save("slither_last.zip")
env.close()