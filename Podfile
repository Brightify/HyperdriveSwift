source 'https://github.com/CocoaPods/Specs.git'

install! 'cocoapods',
  :generate_multiple_pod_projects => true,
  :incremental_installation => true

workspace 'Hyperdrive'

use_frameworks!
inhibit_all_warnings!

def rxSwift
    pod 'RxSwift', '~> 4.0'
end

def rxCocoa
    pod 'RxCocoa', '~> 4.0'
end

def rxDataSources
    pod 'RxDataSources', '~> 3.0'
end

def rxOptional
    pod 'RxOptional', '~> 3.0'
end

def snapKit
    pod 'SnapKit', '~> 4.0'
end

def kingfisher
    pod 'Kingfisher', '~> 4.0'
end

def devHyperdriveUI
    pod 'HyperdriveInterface', :path => '.'
end

def devHyperdrive
    pod 'HyperdrivePlatform', :path => '.'
end

def shared
    rxSwift
    rxCocoa
    rxDataSources
    rxOptional
    snapKit
    kingfisher
end

def macos
    platform :osx, '10.13'
end

def ios
    platform :ios, '11.0'
end

def tvos
    platform :tvos, '11.0'
end

abstract_target 'CLI' do
  project 'CLI/CLI.xcodeproj'
  macos
end

abstract_target 'Platform' do
    project 'Platform/Platform.xcodeproj'

    target 'Hyperdrive-iOS' do
        ios

        snapKit
    end

    target 'Hyperdrive-macOS' do
        macos

        snapKit
    end

    target 'Hyperdrive-tvOS' do
        tvos

        snapKit
    end

    target 'RxHyperdrive-iOS' do
        ios

        shared
    end

    abstract_target 'Tests' do
        pod 'Quick', '~> 1.3'
        pod 'Nimble', '~> 7.1'
        pod 'Cuckoo', :git => 'https://github.com/Brightify/Cuckoo.git', :branch => 'master'
        pod 'RxNimble'
        pod 'RxTest'

        target 'HyperdriveTests' do
            snapKit
        end

        target 'RxHyperdriveTests' do
            shared
        end
    end
end

abstract_target 'Interface' do
    project 'Interface/Interface.xcodeproj'

    target 'Interface-iOS' do
        ios

        snapKit
        kingfisher
    end

    target 'Interface-macOS' do
        macos

        snapKit
    end
end

abstract_target 'LiveInterface' do
    project 'LiveInterface/LiveInterface.xcodeproj'

    target 'LiveInterface-iOS' do
        ios
    end

    target 'LiveInterface-tvOS' do
        tvos
    end

    target 'LiveInterface-macOS' do
        macos
    end
end

abstract_target 'Showcases' do
    target 'Showcase-iOS' do
        project 'Showcases/Showcase-iOS/Showcase-iOS.xcodeproj'

        ios
    end

    target 'Showcase-tvOS' do
        project 'Showcases/Showcase-tvOS/Showcase-tvOS.xcodeproj'

        tvos
    end

    
    target 'Showcase-macOS' do
        project 'Showcases/Showcase-macOS/Showcase-macOS.xcodeproj'

        macos
        devHyperdrive
        devHyperdriveUI
    end
end

