from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv
import numpy as np

def test_environment():
    # Initialize the Godot environment
    env = StableBaselinesGodotEnv(env_path=None, speedup=8) 
    
    print("Environment connected successfully!")
    
    # FIX 1: SB3 environments only return the observation on reset
    obs = env.reset()
    
    # Run for 100 steps to see what the data looks like
    for i in range(100):
        # Generate random actions for all 10 snakes
        random_actions = np.array([env.action_space.sample() for _ in range(env.num_envs)])
        
        # FIX 2: SB3 returns 4 values (obs, reward, done, info)
        obs, reward, done, info = env.step(random_actions)
        
        if i % 10 == 0:
            current_obs = obs["obs"][0] if isinstance(obs, dict) else obs[0]
            # We look at the first snake's reward
            print(f"Step {i} | Obs Length: {len(current_obs)} | Reward: {reward[0]}")
            
            # Check for corrupted data (NaN or Infinity)
            if np.isnan(current_obs).any() or np.isinf(current_obs).any():
                print("CRITICAL ERROR: Found NaN or Inf in observations!")
                break

    print("Sanity check complete. Closing environment.")
    env.close()

if __name__ == "__main__":
    test_environment()