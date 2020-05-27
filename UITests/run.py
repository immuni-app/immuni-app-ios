import subprocess
import sys
import os
import datetime
import plistlib

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
- the font size of the device, choose between: XS, S, M, L, XL, XXL, XXXL, BigM, BigL, BigXL, BigXXL, BigXXXL
- a list, space-separated of languages to test

E.g.:
python UITests/run.py ct-app Immuni.xcworkspace Immuni true 3 XL it en
"""

if len(sys.argv) > 0 and sys.argv[1] in ["-h", "--h", "--help", "-help"]:
	print(usage)
	quit()

if len(sys.argv) < 8:
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
font_size_arg = sys.argv[6]
languages = []

available_font_sizes = {
	'XS'     : 'UICTContentSizeCategoryXS',
	'S'      : 'UICTContentSizeCategoryS',
	'M'      : 'UICTContentSizeCategoryM',
	'L'      : 'UICTContentSizeCategoryL',
	'XL'     : 'UICTContentSizeCategoryXL',
	'XXL'    : 'UICTContentSizeCategoryXXL',
	'XXXL'   : 'UICTContentSizeCategoryXXXL',
	'BigM'   : 'UICTContentSizeCategoryAccessibilityM',
	'BigL'   : 'UICTContentSizeCategoryAccessibilityL',
	'BigXL'  : 'UICTContentSizeCategoryAccessibilityXL',
	'BigXXL' : 'UICTContentSizeCategoryAccessibilityXXL',
	'BigXXXL': 'UICTContentSizeCategoryAccessibilityXXXL'
}

if font_size_arg not in available_font_sizes:
	print('Selected font size {} is not a valid size, please choose between: XS, S, M, L, XL, XXL, XXXL, BigM, BigL, BigXL, BigXXL, BigXXXL.'.format(font_size))
	quit()

font_size = available_font_sizes[font_size_arg]

for i in range(7, len(sys.argv)):
	languages.append(sys.argv[i])

test_without_building_arg = 'test-without-building'
build_for_testing_arg = 'build-for-testing'

max_concurrent_simulator_arg = '-maximum-concurrent-test-simulator-destinations'
workspace_arg =	'-workspace'
scheme_arg = '-scheme'
destination_arg = '-destination'

for device in devices:
	# get the simulator's uuid
	list = subprocess.Popen('xcrun simctl list devices 13.5'.split(), stdout=subprocess.PIPE)
	device_grep = subprocess.Popen(['grep', '{} ('.format(device)], stdin=list.stdout, stdout=subprocess.PIPE)
	list.stdout.close()
	uuid_grep = subprocess.Popen('grep -E -o -i ([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})'.split(), stdin=device_grep.stdout, stdout=subprocess.PIPE)
	device_grep.stdout.close()
	simulator_uuid = uuid_grep.communicate()[0].decode().strip()

	simulator_fontSize_preferences_file = '{}/Library/Developer/CoreSimulator/Devices/{}/data/Library/Preferences/com.apple.UIKit.plist'.format(os.path.expanduser("~"), simulator_uuid)
	if os.path.exists(simulator_fontSize_preferences_file):
		# shutdown the simulator in case it is running
		print("Shutdown the {} simulator in case it is running".format(device))
		subprocess.call(["xcrun", "simctl", "shutdown", simulator_uuid])
        
		# set the simulator's font size
		print("Set the {} simulator\'s font size to {}".format(device, font_size))
		simulator_largerText_preferences_file = '{}/Library/Developer/CoreSimulator/Devices/{}/data/Library/Preferences/com.apple.preferences-framework.plist'.format(os.path.expanduser("~"), simulator_uuid)
		plistlib.writePlist({'largeTextUsesExtendedRange': True}, simulator_largerText_preferences_file) # enable larger text

		subprocess.call(['plutil', '-replace', 'UIPreferredContentSizeCategoryName',
		'-string', font_size, simulator_fontSize_preferences_file]) # set the size
        
		# boot the simulator
		print("Boot the {} simulator".format(device))
		subprocess.call(["xcrun", "simctl", "boot", simulator_uuid])
	else:
		print("Unable to set font size on the {} simulator. This happen if it's the first time you boot it, try it again.".format(device))
		subprocess.call(["xcrun", "simctl", "boot", device])
		quit()

	device_args += [destination_arg, "name={}".format(device)]

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
