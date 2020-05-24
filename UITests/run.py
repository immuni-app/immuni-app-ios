import subprocess
import sys
import os
import datetime

"""
This script will help you running uitests in multiple languages on multiple devices
At the moment it runs on iPhone 11, iPhone 11 Pro, iPhone 8 Plus, iPhone 8 and iPhone SE
"""
usage = """
Usage:
To run this script, you must pass some parameters
- the bundleId of the app
- the workspace of the app, including the `.workspace` extension
- the schema to test
- whether the app needs to be rebuilt on the simulators
- the number of simulators on which run the test, if 0 the default will be used
- a list, space-separated of languages to test

E.g.:
python UITests/run.py ct-app Immuni.xcworkspace Immuni true 3 it en
"""

if sys.argv[1] in ["-h", "--h", "--help", "-help"]:
	print(usage)
	quit()

if len(sys.argv) < 6:
	print(usage)
	quit()

now = datetime.datetime.now()
command = "xcodebuild"

devices = [
	'iPhone 11', # 414 x 896
	'iPhone 11 Pro', # 375 x 812
	'iPhone 8 Plus', # 414 x 736
	'iPhone 8', # 375 x 667
	'iPhone SE (1st generation)', # 320 x 568
]

# boot all the simulators
device_args = []
bundleId = sys.argv[1]
workspace = sys.argv[2]
scheme = sys.argv[3]
forceReinstall = sys.argv[4]
max_simulators = int(sys.argv[5]) 
languages = []

for i in range(6, len(sys.argv)):
	languages.append(sys.argv[i])

test_without_building_arg = 'test-without-building'
build_for_testing_arg = 'build-for-testing'

max_concurrent_simulator_arg = '-maximum-concurrent-test-simulator-destinations'
workspace_arg =	'-workspace'
scheme_arg = '-scheme'
destination_arg = '-destination'

for device in devices:
	device_args += [destination_arg, "name={}".format(device)]
	subprocess.call(["xcrun", "simctl", "boot", device])

if forceReinstall == "true":
	# uninstall app on each simulator
	for device in devices:
		subprocess.call(["xcrun", "simctl", "uninstall", device, bundleId])

	# build the app for testing on each simulator
	subprocess.call([
		command,
		build_for_testing_arg,
		workspace_arg, workspace, 
		scheme_arg, scheme
	] + device_args)

# perform UI tests
for lang in languages:
	language_arg = '-testLanguage'
	args = [command, 
		test_without_building_arg, 
		max_concurrent_simulator_arg, str(max_simulators),
		workspace_arg, workspace, 
		scheme_arg, scheme,
		language_arg, lang,
		'-only-testing:Immuni UITests'] + device_args
	
	print("\n\n Calling xcodebuild for language "+lang)
	subprocess.call(args)

print("\n Test started at: "+now.strftime("%Y-%m-%d %H:%M"))
print("Test finished at: "+datetime.datetime.now().strftime("%Y-%m-%d %H:%M"))
