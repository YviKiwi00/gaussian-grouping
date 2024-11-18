#!/bin/bash


# Check if the user provided an argument
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <dataset_name>"
    exit 1
fi

cd grouping

dataset_name="$1"
scale="$2"
prompt="$3"
dataset_folder="../data/$dataset_name"

if [ ! -d "$dataset_folder" ]; then
    echo "Error: Folder '$dataset_folder' does not exist."
    exit 2
fi

# 1. DEVA anything mask
cd Tracking-Anything-with-DEVA/

if [ "$scale" = "1" ]; then
    img_path="../${dataset_folder}/images"
else
    img_path="../${dataset_folder}/images_${scale}"
fi

# colored mask for visualization check
python demo/demo_with_text.py \
  --chunk_size 4 \
  --img_path "$img_path" \
  --prompt "$prompt" \
  --amp \
  --temporal_setting semionline \
  --size 480 \
  --output "./example/output_gaussian_dataset/${dataset_name}" \


mv ./example/output_gaussian_dataset/${dataset_name}/Annotations ./example/output_gaussian_dataset/${dataset_name}/Annotations_color

# gray mask for training
python demo/demo_with_text.py \
  --chunk_size 4 \
  --img_path "$img_path" \
  --prompt "$prompt" \
  --amp \
  --temporal_setting semionline \
  --size 480 \
  --output "./example/output_gaussian_dataset/${dataset_name}" \
  --use_short_id  \

# 2. copy gray mask to the correponding data path
cp -r ./example/output_gaussian_dataset/${dataset_name}/Annotations ../${dataset_folder}/object_mask
cd ..