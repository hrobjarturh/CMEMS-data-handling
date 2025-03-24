# Set common variables
export lat_min=55.0
export lat_max=80.0
export lon_min=-40.0
export lon_max=20.0
export output_directory="data/copernicus"

# date ranges
export start_datetime="2010-01-01T00:00:00"
export end_datetime="2010-06-30T00:00:00"

echo "Start datetime: $start_datetime"
echo "End datetime: $end_datetime"

# # List of dataset IDs (This is the hindsight dataset)
dataset_ids=(
    "cmems_mod_glo_phy_my_0.083deg_P1D-m"
    "cmems_mod_glo_bgc_my_0.25deg_P1D-m"
)

# Loop through each dataset and download
for dataset_id in "${dataset_ids[@]}"; do
    echo "Downloading dataset: $dataset_id"
    
    copernicusmarine subset \
        --dataset-id=$dataset_id \
        --minimum-longitude $lon_min \
        --maximum-longitude $lon_max \
        --minimum-latitude $lat_min \
        --maximum-latitude $lat_max \
        --file-format "netcdf" \
        --output-directory $output_directory/$dataset_id \
        --start-datetime $start_datetime \
        --end-datetime $end_datetime \
        --overwrite \
        --username $CMEMS_USERNAME \
        --password $CMEMS_PASSWORD

    echo "Finished downloading dataset: $dataset_id"
    echo "--------------------------------------"
done