#!/bin/bash
# ./dotfilter_runallchannels.sh levels location

array=( "PEM-EY_MAG_EBAY_SUSRACK_Z_DQ" "PEM-EY_MAG_EBAY_SUSRACK_Y_DQ" "PEM-CS_MAG_LVEA_VERTEX_Y_DQ" "PEM-CS_MAG_EBAY_SUSRACK_Z_DQ" "PEM-CS_MAG_LVEA_VERTEX_X_DQ" "PEM-EX_MAG_EBAY_SUSRACK_Y_DQ" "PEM-EX_MAG_EBAY_SUSRACK_X_DQ" "PEM-CS_MAG_EBAY_SUSRACK_X_DQ" "PEM-CS_MAG_LVEA_VERTEX_Z_DQ" "PEM-EX_MAG_EBAY_SUSRACK_Z_DQ" "PEM-CS_MAG_EBAY_SUSRACK_Y_DQ" "PEM-EY_MAG_EBAY_SUSRACK_X_DQ" "PEM-EX_ADC_0_12_OUT_DQ" "PEM-EY_ADC_0_12_OUT_DQ")
array2=( "8192" "8192" "8192" "8192" "8192" "8192" "8192" "8192" "8192" "8192" "8192" "8192" "2048" "2048" )

for i in "${!array[@]}"; do
    ./run_dotfilter_driver.sh /ldcg/matlab_r2020b $1 $2 false $2 8 ${array[i]} ${array2[i]} /home/sherman.thompson/FoldingAnalysis/O3 /home/sherman.thompson/FoldingAnalysis/foldfold_periods/Post-O2.csv
done