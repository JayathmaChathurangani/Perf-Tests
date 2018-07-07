import sys
import csv
import os.path

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
output_root = sys.argv[2]

output_csv_summary = output_root+"\\summaryReport.csv"
dirname = os.path.dirname(output_csv_summary)
if not os.path.exists(dirname):
	os.makedirs(dirname)

output_csv_avg = output_root+"\\avgReport.csv"
output_csv_min = output_root+"\\minReport.csv"
output_csv_max = output_root+"\\maxReport.csv"
output_csv_percentile_90 = output_root+"\\percentile_90Report.csv"
output_csv_percentile_95 = output_root+"\\percentile_95Report.csv"
output_csv_percentile_99 = output_root+"\\percentile_99Report.csv"
output_csv_throughput = output_root+"\\throughputReport.csv"
output_csv_error_rate = output_root+"\\errorrateReport.csv"

csv_file_records = []
csv_file_records_avg = []
csv_file_records_min = []
csv_file_records_max = []
csv_file_records_percentile_90 = []
csv_file_records_percentile_95 = []
csv_file_records_percentile_99 = []
csv_file_records_throughput = []
csv_file_records_error_rate = []

headers = ['user', 'average_latency', 'min_latency', 'max_latency', 'percentile_90', 'percentile_95', 'percentile_99', 'throughput', 'error_rate']
headers_avg = ['user', 'average_latency']
headers_min = ['user', 'min_latency']
headers_max = ['user', 'max_latency']
headers_percentile_90 = ['user', 'percentile_90']
headers_percentile_95 = ['user', 'percentile_95']
headers_percentile_99 = ['user', 'percentile_99']
headers_throughput = ['user', 'throughput']
headers_error_rate = ['user', 'error_rate']

csv_file_records.append(headers)
csv_file_records_avg.append(headers_avg)
csv_file_records_min.append(headers_min)
csv_file_records_max.append(headers_max)
csv_file_records_percentile_90.append(headers_percentile_90)
csv_file_records_percentile_95.append(headers_percentile_95)
csv_file_records_percentile_99.append(headers_percentile_99)
csv_file_records_throughput.append(headers_throughput)
csv_file_records_error_rate.append(headers_error_rate)

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
	row_average_latency = [user, average_latency]
	row_min_latency = [user, min_latency]
	row_max_latency = [user, max_latency]
	row_percentile_90= [user, percentile_90]
	row_percentile_95 = [user, percentile_95]
	row_percentile_99 = [user, percentile_99]
	row_throughput = [user, throughput]
	row_error_rate = [user, error_rate]
	
	csv_file_records.append(row)
	csv_file_records_avg.append(row_average_latency)
	csv_file_records_min.append(row_min_latency)
	csv_file_records_max.append(row_max_latency)
	csv_file_records_percentile_90.append(row_percentile_90)
	csv_file_records_percentile_95.append(row_percentile_95)
	csv_file_records_percentile_99.append(row_percentile_99)
	csv_file_records_throughput.append(row_throughput)
	csv_file_records_error_rate.append(row_error_rate)

with open(output_csv_summary, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records:
        writer.writerow(line)

with open(output_csv_avg, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records_avg:
        writer.writerow(line)

with open(output_csv_min, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records_min:
        writer.writerow(line)

with open(output_csv_max, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records_max:
        writer.writerow(line)

with open(output_csv_percentile_90, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records_percentile_90:
        writer.writerow(line)

with open(output_csv_percentile_95, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records_percentile_95:
        writer.writerow(line)

with open(output_csv_percentile_99, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records_percentile_99:
        writer.writerow(line)

with open(output_csv_throughput, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records_throughput:
        writer.writerow(line)

with open(output_csv_error_rate, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records_error_rate:
        writer.writerow(line)

