import DAG_maker_and_submitter

O4_MONTHS = ['May','June','July']
O4_YEARS = ['2023','2023','2023']

for month, year in zip(O4_MONTHS,O4_YEARS):
  print("Creating dags for " + month + year)
  names = DAG_maker_and_submitter.makeDags(month,year)
  print("Submitting " + month + year)
  DAG_maker_and_submitter.submitDAGS(names)
