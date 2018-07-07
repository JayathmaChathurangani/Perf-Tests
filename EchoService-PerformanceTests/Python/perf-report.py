import sys
from random import randint
import csv

def readDashboard(dashboard_js_file):
	dashboard = open(dashboard_js_file)
	stat_table = ""
	content = dashboard.readlines()
	for line in content:
		if '#statisticsTable' in line:
			stat_table = line
			break
	stat_table = stat_table.strip().split(",")
	jtl_stat = {}
	jtl_stat["error"] = stat_table[5].strip()
	jtl_stat["average"] = stat_table[6].strip()
	jtl_stat["min"] = stat_table[7].strip()
	jtl_stat["max"] = stat_table[8].strip()
	jtl_stat["percentile_90"] = stat_table[9].strip()
	jtl_stat["percentile_95"] = stat_table[10].strip()
	jtl_stat["percentile_99"] = stat_table[11].strip()
	jtl_stat["throughput"] = stat_table[12].strip()
	return jtl_stat

concurrent_users = [1,10,50,100,200,300,400,500]

dashboard_files_root = sys.argv[1]
output_csv_file = sys.argv[2]

csv_file_records = []
headers = ['user', 'average_latency', 'min_latency', 'max_latency', 'percentile_90', 'percentile_95', 'percentile_99', 'throughput', 'error_rate']
csv_file_records.append(headers)

for user in concurrent_users:
	dashboard_file_name = dashboard_files_root+"\\"+str(user)+"_users\\Dashboard\\content\\js\\dashboard.js"
	
	jtl_stat = readDashboard(dashboard_file_name)

	average_latency = jtl_stat["average"]
	min_latency = jtl_stat["min"]
	max_latency = jtl_stat["max"]
	percentile_90= jtl_stat["percentile_90"]
	percentile_95 = jtl_stat["percentile_95"]
	percentile_99 = jtl_stat["percentile_99"]
	throughput = jtl_stat["throughput"]
	error_rate = jtl_stat["error"]

	row = [user, average_latency, min_latency, max_latency, percentile_90, percentile_95, percentile_99, throughput, error_rate]
	csv_file_records.append(row)

with open(output_csv_file, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records:
        writer.writerow(line)







