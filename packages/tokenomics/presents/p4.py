from present import Config, Timing, Present

present = Present(
    title="p4: varying block time (100% ocsliaction), varying proof time (200% ocsliaction)",
    desc="""

**About this config**

- block time varies (100%  ocsliaction)
- proof time varies (200%  ocsliaction) but eventually changes back to the initial value.

**What to verify**
- block fee stays constant.
- proof reward adapts to proof time changes.
- total supply change stablizes.


""",
    days=10,
    config=Config(
        max_blocks=2048, 
        lamda=2048,
        base_fee=100.0,
        base_fee_maf=1024,
        block_fee_min_ratio=0.5,
        prover_reward_max_ratio=4.0,
        prover_reward_burn_points=0.0,
        prover_reward_bootstrap=0,
        prover_reward_bootstrap_day=10,
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
