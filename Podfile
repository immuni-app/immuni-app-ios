ENV["COCOAPODS_DISABLE_STATS"] = "true"
INCLUDE_DEV_TOOLING = ENV["EXCLUDE_DEV_TOOLING"] != '1'

source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!
platform :ios, '13.0'

# Dependencies are locked till the patch version as an extra
# precaution against unwanted updates of the 3rd party libraries

def shared_pods
  pod 'Katana', '= 3.2.0'
  pod 'Tempura', '= 4.4.0'
  pod 'Logging', '= 1.2.0'
  pod 'HydraAsync', '= 1.2.2'
  pod 'Alamofire', '= 5.2.1'
end

target 'Immuni' do
  pod 'BonMot', '= 5.5.1'
  pod 'lottie-ios', '= 3.1.8'
  pod 'PinLayout', '= 1.8.13'
  pod 'ZIPFoundation', '= 0.9.11'

  shared_pods

  target 'Immuni Tests' do
    inherit! :search_paths
  end

  target 'Immuni UITests' do
    inherit! :search_paths

    pod 'TempuraTesting', '= 5.0.1'
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

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        # Add fstack-protector-all to the project. Note that the
        # current implementation is Swift-only and this should not be
        # necessary. However, adding it doesn't harm and prevents
        # from weakening the app in case of an OBJC / C lib
        # or code is added
        config.build_settings['OTHER_CFLAGS'] ||= ['$(inherited)']
        config.build_settings['OTHER_CFLAGS'] << '-fstack-protector-all'

        config.build_settings['OTHER_CPLUSPLUSFLAGS'] ||= ['$(inherited)']
        config.build_settings['OTHER_CPLUSPLUSFLAGS'] << '-fstack-protector-all'

        # Bitcode must be disabled to allow reproducible builds.
        # If we delegate Apple's server to perform some additional
        # steps to build the final IPA, then doing a reproducible build
        # becomes way harder (or even impossible?)
        config.build_settings['ENABLE_BITCODE'] = 'NO'

        config.build_settings['TARGETED_DEVICE_FAMILY'] = 1
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 13.0
    end
  end
end