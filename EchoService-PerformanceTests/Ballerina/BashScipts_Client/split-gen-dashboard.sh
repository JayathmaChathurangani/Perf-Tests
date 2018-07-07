#!/bin/bash
# Copyright 2018 WSO2 Inc. (http://wso2.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ----------------------------------------------------------------------------
# Run Performance Tests for Ballerina
# ----------------------------------------------------------------------------

echo "Start Testing"

concurrent_users=(1 2 10 50 100 200 300 400 500 600)

##########################
#Client Machine 
##########################

path_jmeter=E:/4_Year_1_Sem/SENG_Research/4_Software/apache-jmeter-4.0/apache-jmeter-4.0/bin/jmeter.sh

location_jtls=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/EchoService-PerformanceTests/1_Ballerina/jtl_Results_Round2
location_jtl_splitter_file=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/EchoService-PerformanceTests/1_Ballerina/jtl-splitter-0.1.1-SNAPSHOT.jar

split_time_min=5

echo "Splitting JTL files started"

	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		jtl_file=${location_jtls}/${total_users}_users/results.jtl
		
		java -jar ${location_jtl_splitter_file} -f $jtl_file -t ${split_time_min} -d	
		
		echo "Splitting jtl file for ${u} users test completed"
	done

echo "Splitting JTL files Completed"

echo "Generating Dashboards"

	for u in ${concurrent_users[@]}
	do	
		total_users=$(($u))
		report_location=${location_jtls}/${total_users}_users/Dashboard
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		${path_jmeter} -g  ${location_jtls}/${total_users}_users/results-measurement.jtl -o $report_location	

		echo "Generating dashboard for ${u} users test completed"
	done

echo "Generating Dashboards Completed"

echo "Process Completed"