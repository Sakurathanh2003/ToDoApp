platform :ios, '13.0'
use_frameworks!

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
         end
    end
  end
end


target 'ToDoApp' do
  use_frameworks!

  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RealmSwift'
  pod 'YYImage'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'SwiftLint'  
  pod 'TLLogging'
  pod 'SVProgressHUD'
  pod 'lottie-ios'
  pod 'FLAnimatedImage'
  pod 'DifferenceKit'
  pod 'SkeletonView'
  pod 'Zip', '~> 2.1'
  pod 'SDWebImage'

end
