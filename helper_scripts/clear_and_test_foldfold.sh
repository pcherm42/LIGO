#!/bin/bash
echo Clearing html, pdf, png, peak, spectra files, and condor log but current foldfold.dag, getting ready and submitting foldfold.dag.....
rm files/html/*
rm files/pdf/*
rm files/png/*
rm files/peakfiles/*
rm files/spectra/*
rm out/foldfold*
cd condor
rm foldfold.dag.condor.sub foldfold*.log foldfold*.out foldfold*.err foldfold*.metrics
condor_submit_dag foldfold.dag