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

concurrent_users=(100 500 1000)

#########################
#Ballerina Host Machine 
#########################

host1_ip=192.168.0.2
host1_port=8080
host1_username_ip=user@192.168.0.2
host1_password=user

##########################
#Client Machine 
##########################

file_host1_remote_commands=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/EchoService-PerformanceTests/Ballerina/BashScipts_Client/startHelloBallerina.txt
file_host1_kill_ballerinaservice=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/EchoService-PerformanceTests/Ballerina/BashScipts_Client/killHelloBallerina.txt

path_putty=E:/1_2018_Installed/putty/putty.exe
path_jmeter=E:/4_Year_1_Sem/SENG_Research/4_Software/apache-jmeter-4.0/apache-jmeter-4.0/bin/jmeter.sh

location_jtls=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/EchoService-PerformanceTests/Ballerina/jtl_Results_Round1
location_jmx_file=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/EchoService-PerformanceTests/Ballerina/Ballerina_Echo_Service_Test.jmx
location_jtl_splitter_file=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/EchoService-PerformanceTests/Ballerina/jtl-splitter-0.1.1-SNAPSHOT.jar

test_duration_seconds=200
split_time_min=1

##########################
#Test Begins
##########################

	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		report_location=${location_jtls}/${total_users}_users
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		# SSH
		echo "Begin SSH"
		Start ${path_putty} -ssh  ${host1_username_ip} -pw ${host1_password} -m ${file_host1_remote_commands} 
		sleep 5
		
		# Check service
		while true 
		do
			echo "Checking service"
				response_code=$(curl -s -o /dev/null -w "%{http_code}" http://${host1_ip}:${host1_port}/hello/sayHello)
				if [ $response_code -eq 200 ]; then
					echo "Ballerina started"
					break
				else
					sleep 10
					echo "Trying Again"
					Start ${path_putty} -ssh  ${host1_username_ip} -pw ${host1_password} -m ${file_host1_remote_commands} 
				fi
		done
		
		# Start JMeter server
        ${path_jmeter}  -Jgroup1.threads=$u -Jgroup1.seconds=${test_duration_seconds} -n -t ${location_jmx_file} -l ${report_location}/results.jtl
		
		echo "Test for ${u} users completed"
	done
	
echo "Generating JTL files Completed"

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

#Kill last opened instance of Ballerina and Closing putty
Start ${path_putty} -ssh  ${host1_username_ip} -pw ${host1_password} -m ${file_host1_kill_ballerinaservice}
sleep 5
powershell kill -n putty
echo "Killed last opened instance of Ballerina and Closed putty"

echo "Test Process Completed"