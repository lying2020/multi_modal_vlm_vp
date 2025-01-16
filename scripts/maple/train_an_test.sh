#!/bin/bash

# Define the datasets and seeds
datasets=("imagenet" "caltech101" "food101" "dtd" "ucf101" "oxford_flowers" "oxford_pets" "fgvc_aircraft" "stanford_cars" "sun397" "eurosat")
datasets_xd=("imagenetv2" "imagenet_sketch" "imagenet_a" "imagenet_r")
seeds=(1 2 3)

# Function to run base2new commands
run_base2new() {
  for dataset in "${datasets[@]}"; do
    for seed in "${seeds[@]}"; do
      echo "Processing dataset: $dataset with seed: $seed"
      
      # Train and evaluate on base classes
      bash scripts/maple/base2new_train_maple.sh "$dataset" "$seed" || echo "Training failed for $dataset with seed $seed, continuing..."
      
      # Evaluate on novel classes
      bash scripts/maple/base2new_test_maple.sh "$dataset" "$seed" || echo "Testing failed for $dataset with seed $seed, continuing..."
    done
  done
}


# Function to run xd commands
run_xd() {
  for seed in "${seeds[@]}"; do
    echo "Running xd_train_maple.sh for imagenet with seed: $seed"
    bash scripts/maple/xd_train_maple.sh imagenet "$seed" || echo "xd training failed for imagenet with seed $seed, continuing..."
  done

  for dataset in "${datasets[@]}"; do
    for seed in "${seeds[@]}"; do
      echo "Running xd_test_maple.sh for $dataset with seed: $seed"
      bash scripts/maple/xd_test_maple.sh "$dataset" "$seed" || echo "xd test failed for $dataset with seed $seed, continuing..."
    done
  done

  for dataset in "${datasets_xd[@]}"; do
    for seed in "${seeds[@]}"; do
      echo "Running xd_test_maple.sh for $dataset with seed: $seed"
      bash scripts/maple/xd_test_maple.sh "$dataset" "$seed" || echo "xd test failed for $dataset with seed $seed, continuing..."
    done
  done

}

# Main logic to decide which function to run
if [ -z "$1" ] || [ "$1" == "base2new" ]; then
  run_base2new | tee -a run_base2new.log
else
  run_xd | tee -a run_xd.log
fi