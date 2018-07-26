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

concurrent_users=(1 2 50 100 300 500 700 1000)
#did for 
message_sizes=(50 400 1024 1600 10240) 
#50 1024 10240 102400

#########################
#Ballerina Host Machine 
#########################

host1_ip=127.0.0.1 #192.168.0.2
host1_port=8080
host1_username_ip=user@192.168.0.2
host1_password=user@19900119

##########################
#Client Machine 
##########################

file_host1_remote_commands=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/Echo-MsgSizes-PerformaneTests/1_Ballerina/BashScipts_Client/startBallerina.txt
file_host1_kill_ballerinaservice=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/Echo-MsgSizes-PerformaneTests/1_Ballerina/BashScipts_Client/killBallerina.txt

path_putty=E:/1_2018_Installed/putty/putty.exe
path_jmeter=E:/4_Year_1_Sem/SENG_Research/4_Software/apache-jmeter-4.0/apache-jmeter-4.0/bin

location_jtls=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/Echo-MsgSizes-PerformaneTests/1_Ballerina/jtl_Results_Round1
location_jmx_file=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/Echo-MsgSizes-PerformaneTests/1_Ballerina/Echo_Payload_Test.jmx
location_jtl_splitter_file=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/Echo-MsgSizes-PerformaneTests/1_Ballerina/jtl-splitter-0.1.1-SNAPSHOT.jar

location_payload_gen_file=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/Echo-MsgSizes-PerformaneTests/1_Ballerina/payload-generator-0.1.1-SNAPSHOT.jar
payloads_output_file_root=E:/4_Year_1_Sem/SENG_Research/5_Repos/PerformanceTests/Echo-MsgSizes-PerformaneTests/1_Ballerina/BashScipts_Client
payload_files_postfix=B
payload_files_extension=json

test_duration_seconds=900
split_time_min=5

:'
##########################
#Test for local machine
##########################
host1_ip=127.0.0.1
test_duration_seconds=120
split_time_min=1

for size in ${message_sizes[@]}
do
	#Generate payload
	echo "Generating ${size}B file"
	java -jar ${location_payload_gen_file} --size $size
	
	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		report_location=${location_jtls}/local/${size}_message/${total_users}_users
		echo "Report location is ${report_location}"
		mkdir -p $report_location
				
		# Start JMeter server
		message=$(<${payloads_output_file_root}/${size}${payload_files_postfix}.${payload_files_extension})
		
		${path_jmeter}/jmeter  -Jgroup1.threads=$u -Jgroup1.seconds=${test_duration_seconds} -Jgroup1.host=${host1_ip} -Jgroup1.port=${host1_port} -Jgroup1.data=${message} -n -t ${location_jmx_file} -l ${report_location}/results.jtl
		
		echo "Test for ${size}B message size and ${u} users completed"
	done
	
	echo "Test for ${size}B message size completed"
done
	
echo "Generating JTL files for local Completed"
'

##########################
#Test Begins
##########################

for size in ${message_sizes[@]}
do
	#Generate payload
	echo "Generating ${s}B file"
	java -jar ${location_payload_gen_file} --size $size
	
	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		report_location=${location_jtls}/${size}_message/${total_users}_users
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		# SSH
		echo "Begin SSH"
		Start ${path_putty} -ssh  ${host1_username_ip} -pw ${host1_password} -m ${file_host1_remote_commands} 
		sleep 8
		
		# Check service
		while true 
		do
			echo "Checking service"
				response_code=$(curl -s -o /dev/null -w "%{http_code}" http://${host1_ip}:${host1_port}/hello/sayHello)
				if [ $response_code -eq 200 ]; then
					echo "MS4j started"
					break
				else
					sleep 10
					echo "Trying Again"
					Start ${path_putty} -ssh  ${host1_username_ip} -pw ${host1_password} -m ${file_host1_remote_commands} 
				fi
		done
		
		# Start JMeter server
		message=$(<${payloads_output_file_root}/${size}${payload_files_postfix}.${payload_files_extension})
		
		${path_jmeter}/jmeter  -Jgroup1.threads=$u -Jgroup1.seconds=${test_duration_seconds} -Jgroup1.host=${host1_ip} -Jgroup1.port=${host1_port} -Jgroup1.data=${message} -n -t ${location_jmx_file} -l ${report_location}/results.jtl
		
		echo "Test for ${size}B message size and ${u} users completed"
	done
	
	echo "Test for ${size}B message size completed"
done
	
echo "Generating JTL files Completed"


echo "Splitting JTL files started"

for size in ${message_sizes[@]}
do
	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		jtl_file=${location_jtls}/${size}_message/${total_users}_users/results.jtl
		
		java -jar ${location_jtl_splitter_file} -f $jtl_file -t ${split_time_min} -d	
		
		echo "Splitting jtl file for ${size}B message size and ${u} users test completed"
	done
done

echo "Splitting JTL files Completed"

echo "Generating Dashboards"

for size in ${message_sizes[@]}
do
	for u in ${concurrent_users[@]}
	do	
		total_users=$(($u))
		report_location=${location_jtls}/${size}_message/${total_users}_users/Dashboard
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		${path_jmeter}/jmeter -g  ${location_jtls}/${size}_message/${total_users}_users/results-measurement.jtl -o $report_location	

		echo "Generating dashboard for ${size}B message size and ${u} users test completed"
	done
done

echo "Generating Dashboards Completed"

#Kill last opened instance of Ballerina and Closing putty
Start ${path_putty} -ssh  ${host1_username_ip} -pw ${host1_password} -m ${file_host1_kill_ballerinaservice}
sleep 5
powershell kill -n putty
echo "Killed last opened instance of Ballerina and Closed putty"

echo "Test Process Completed"