# Set common variables

export output_directory="data/copernicus"

# date ranges
export start_datetime="2015-01-01T00:00:00"
export end_datetime="2016-12-31T00:00:00"

echo "Start datetime: $start_datetime"
echo "End datetime: $end_datetime"

# # List of dataset IDs 
dataset_ids=(
    "cmems_mod_arc_phy_my_topaz4_P1M"
)

# Variables to download
echo "Variables to download: mlotst, siconc, sisnthick, so, thetao, vxsi, vysi"

# Loop through each dataset and download
for dataset_id in "${dataset_ids[@]}"; do
    echo "Downloading dataset: $dataset_id"
    
    copernicusmarine subset \
        --dataset-id=$dataset_id \
        --file-format "netcdf" \
        --output-directory $output_directory/$dataset_id \
        --start-datetime $start_datetime \
        --end-datetime $end_datetime \
        --variable mlotst \
        --variable siconc \
        --variable sisnthick \
        --variable so \
        --variable thetao \
        --variable vxsi \
        --variable vysi \
        --overwrite \
        --username $CMEMS_USERNAME \
        --password $CMEMS_PASSWORD
    
    echo "Finished downloading dataset: $dataset_id"
    echo "--------------------------------------"
done