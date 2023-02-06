python3 run_task_generalization.py \
        --task_name g1 \
        --scene few-shot \
        --k 16 \
        --seed 21 \
        --data_dir data/k-shot-cross/g1/16-21 \
        --model_type roberta \
        --model_name_or_path roberta-large \
        --output_dir output \
        --do_train \
        --do_eval \
        --embed_size 1024 \
        --pet_per_gpu_train_batch_size 6 \
        --pet_per_gpu_eval_batch_size 2 \
        --pet_max_seq_length 128 \
        --pet_max_meta_steps 1000 \
        --pet_max_adaptation_steps 300 \
        --warmup_steps 100 \
        --eval_every_step 100 \
        --learning_rate 1e-4 \
        --overwrite_output_dir \
        --pattern_ids 1 \
        --cross_prompt

