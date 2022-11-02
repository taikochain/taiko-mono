from present import Config, Timing, Present

present = Present(
    title="p1: constant block time, varying proof time (no ocsliaction)",
    desc="""

**About this config**

- block time set to a constant (no ocsliaction).
- proof time varies (no ocsliaction) but eventually changes back to the initial value.

**What to verify**
- block fee stays constant.
- proof reward adapts to proof time changes.
- total supply change stablizes.


""",
    days=7,
    config=Config(
        max_blocks=2048, 
        lamda=2048,
        base_fee=100.0,
        base_fee_maf=1024,
        fee_max_multiplier=4.0,
        prover_reward_burn_points=0.0,
        prover_reward_bootstrap=0,
        prover_reward_bootstrap_days=10,
        block_and_proof_time_maf=1024,
        block_time_sd_pctg=0,
        proof_time_sd_pctg=0,
        timing=[
            Timing(
                block_time_avg_second=15,
                proof_time_avg_minute=45,
            ),
            Timing(
                block_time_avg_second=15,
                proof_time_avg_minute=25,
            ),
            Timing(
                block_time_avg_second=15,
                proof_time_avg_minute=15,
            ),
            Timing(
                block_time_avg_second=15,
                proof_time_avg_minute=45,
            ),
        ],
    ),
)
