# Set common variables

export output_directory="/Users/hrobjarturh/Documents/DTU/digitalocean/CMEMS-data-handling/data/copernicus"

# date ranges
export start_datetime="2018-01-01T00:00:00"
export end_datetime="2018-12-31T00:00:00"

echo "Start datetime: $start_datetime"
echo "End datetime: $end_datetime"

# # List of dataset IDs 
dataset_ids=(
    "cmems_mod_bal_bgc_my_P1D-m"
)

lat_min=55.57
lat_max=56.31
lon_min=9.82
lon_max=10.71


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
        --variable o2b \
        --overwrite \
        --username $CMEMS_USERNAME \
        --password $CMEMS_PASSWORD
    
    echo "Finished downloading dataset: $dataset_id"
    echo "--------------------------------------"
done