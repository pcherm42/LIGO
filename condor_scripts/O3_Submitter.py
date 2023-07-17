import DAG_maker_and_submitter

O3_MONTHS = ["April","May","June","July","August","September","November","December","January","February","March"]
O3_YEARS = ["2019","2019","2019","2019","2019","2019","2019","2019","2020","2020","2020"]

for month, year in zip(O3_MONTHS,O3_YEARS):
  print("Creating dags for " + month + year)
  names = DAG_maker_and_submitter.makeDags(month,year)
  print("Submitting " + month + year)
  DAG_maker_and_submitter.submitDAGS(names)
