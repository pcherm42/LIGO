#!/bin/bash
#This script creates the properly-named segment file. To run, type "./SegmentCreator.sh May 2019 June 2019" or "./SegmentCreator.sh December 2019 January 2020"
echo "Creating segment files for the month of $1 $2. The next month is $3 $4."



ligolw_segment_query_dqsegdb -t https://segments.ligo.org --query-segments -a H1:DMT-ANALYSIS_READY -b H1:DCH-MISSING_H1_HOFT_C00,H1:ODC-INJECTION_TRANSIENT  -s `lalapps_tconvert $1 01, $2 00:00:00 UTC` -e `lalapps_tconvert $3 01, $4 00:00:00 UTC` | ligolw_print -t segment -c start_time -c end_time -d ' ' > $2$1H1segsAnalysis.txt
sleep 2
ligolw_segment_query_dqsegdb -t https://segments.ligo.org --query-segments -a L1:DMT-ANALYSIS_READY -b L1:DCH-MISSING_L1_HOFT_C00,L1:ODC-INJECTION_TRANSIENT  -s `lalapps_tconvert $1 01, $2 00:00:00 UTC` -e `lalapps_tconvert $3 01, $4 00:00:00 UTC` | ligolw_print -t segment -c start_time -c end_time -d ' ' > $2$1L1segsAnalysis.txt

echo "Done!"