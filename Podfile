source 'https://cdn.cocoapods.org/'

#install! 'cocoapods',
#  :generate_multiple_pod_projects => true,
#  :incremental_installation => true

workspace 'Hyperdrive'

use_frameworks!
inhibit_all_warnings!

def rxSwift
    pod 'RxSwift', '~> 5.0'
end

def rxCocoa
    pod 'RxCocoa', '~> 5.0'
end

def rxOptional
    pod 'RxOptional', '~> 3.0'
end

def snapKit
    pod 'SnapKit', '~> 5.0'
end

def kingfisher
    pod 'Kingfisher', '~> 5.0'
end

def quick
  pod 'Quick', '~> 2.0'
end

def nimble
  pod 'Nimble', '~> 8.0'
end

def cuckoo
  pod 'Cuckoo', :git => 'https://github.com/Brightify/Cuckoo.git', :branch => 'master'
end

def rxNimble
  pod 'RxNimble'
end

def rxTest
  pod 'RxTest'
end

def shared
    rxSwift
    rxCocoa
    rxOptional
    snapKit
    kingfisher
end

def sharedTests
  quick
  nimble
  cuckoo
  rxNimble
  rxTest
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
        sharedTests

        target 'HyperdriveTests-iOS' do
            ios
            snapKit
        end

        target 'RxHyperdriveTests-iOS' do
            ios
            shared
        end
    end
end

abstract_target 'Interface' do
    project 'Interface/Interface.xcodeproj'

    target 'HyperdriveInterface-iOS' do
        ios

        snapKit
        kingfisher
    end

    target 'HyperdriveInterface-macOS' do
        macos

        snapKit
    end
end

abstract_target 'LiveInterface' do
    project 'LiveInterface/LiveInterface.xcodeproj'

    target 'HyperdriveLiveInterface-iOS' do
        ios

        snapKit
        rxSwift
        rxCocoa
    end

    target 'HyperdriveLiveInterface-tvOS' do
        tvos

        snapKit
        rxSwift
        rxCocoa
    end

    target 'HyperdriveLiveInterface-macOS' do
        macos

        snapKit
        rxSwift
        rxCocoa
    end

    target 'HyperdriveInterfacePlayground' do
        ios
        shared
    end
end

#abstract_target 'Showcases' do
#    target 'Showcase-iOS' do
#        project 'Showcases/Showcase-iOS/Showcase-iOS.xcodeproj'
#
#        ios
#    end
#
#    target 'Showcase-tvOS' do
#        project 'Showcases/Showcase-tvOS/Showcase-tvOS.xcodeproj'
#
#        tvos
#    end
#
#
#    target 'Showcase-macOS' do
#        project 'Showcases/Showcase-macOS/Showcase-macOS.xcodeproj'
#
#        macos
#        devHyperdrive
#        devHyperdriveUI
#    end
#end



