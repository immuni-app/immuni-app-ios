ENV["COCOAPODS_DISABLE_STATS"] = "true"
INCLUDE_DEV_TOOLING = ENV["INCLUDE_DEV_TOOLING"] == 'TRUE'
OPEN_SOURCE = ENV["OPEN_SOURCE"]

source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!
platform :ios, '11.0'

# Dependencies are locked till the patch version as an extra
# precaution against unwanted updates of the 3rd party libraries

def shared_pods
  pod 'Katana', '= 3.2.0'
  pod 'Tempura', '= 4.3.1'
  pod 'Logging', '= 1.2.0'
  pod 'HydraAsync', '= 1.2.1'
  pod 'Alamofire', '= 5.1.0'
end

target 'Immuni' do
  pod 'BonMot', '= 5.4.1'
  pod 'lottie-ios', '= 3.1.8'
  pod 'PinLayout', '= 1.8.6'
  pod 'ZIPFoundation', '= 0.9.11'

  shared_pods

  target 'Immuni Tests' do
    inherit! :search_paths
  end

  target 'Immuni UITests' do
    inherit! :search_paths

    pod 'TempuraTesting', '~> 4.3'
  end
end

target 'Extensions' do
  shared_pods
end

target 'ImmuniExposureNotification' do
  shared_pods
end

target 'Models' do
  shared_pods
end

target 'Networking' do
  shared_pods
end

target 'Persistence' do
  shared_pods
end  

target 'PushNotification' do
  shared_pods
end

target 'StorePersistence' do
  shared_pods
end    

if INCLUDE_DEV_TOOLING
  target 'DebugMenu' do
    shared_pods
  end
end

# Add fstack-protector-all to the project. Note that the
# current implementation is Swift-only and this should not be
# necessary. However, adding it doesn't harm and prevents
# from weakening the app in case of an OBJC / C lib
# or code is added
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['OTHER_CFLAGS'] ||= ['$(inherited)']
        config.build_settings['OTHER_CFLAGS'] << '-fstack-protector-all'
    end
  end
end