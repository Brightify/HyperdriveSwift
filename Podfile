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
    kingfisher
end

def sharedTests
  quick
  nimble
  cuckoo
  rxNimble
  rxTest
end


class HyperdrivePlatform
    def initialize(podfile, name, platform, version)
        @podfile = podfile
        @name = name
        @platform = platform
        @version = version
    end

    def name
        @name
    end

    def apply()
        @podfile.platform @platform, @version
    end

    def self.ios(podfile)
        return HyperdrivePlatform.new(podfile, 'iOS', :ios, '11.0')
    end
    def self.macos(podfile)
        return HyperdrivePlatform.new(podfile, 'macOS', :osx, '10.13')
    end
    def self.tvos(podfile)
        return HyperdrivePlatform.new(podfile, 'tvOS', :tvos, '11.0')
    end

    def self.allPlatforms(podfile)
        return [ios(podfile), macos(podfile), tvos(podfile)]
    end
end

def allPlatforms
    HyperdrivePlatform.allPlatforms(self)
end

abstract_target 'Platform' do
    project 'Platform/Platform.xcodeproj'

    allPlatforms.each { |platform|
        target "Hyperdrive-#{platform.name}" do
            platform.apply()
        end
    }

    allPlatforms.each { |platform|
        target "RxHyperdrive-#{platform.name}" do
            platform.apply()
            shared
        end
    }

    abstract_target 'Tests' do
        sharedTests

        allPlatforms.each { |platform|
            target "HyperdriveTests-#{platform.name}" do
                platform.apply()
            end
        }

        allPlatforms.each { |platform|
            target "RxHyperdriveTests-#{platform.name}" do
                platform.apply()
                shared
            end
        }
    end
end

abstract_target 'Interface' do
    project 'Interface/Interface.xcodeproj'

    allPlatforms.each { |platform|
        target "HyperdriveInterface-#{platform.name}" do
            platform.apply()
            snapKit
            kingfisher
        end
    }

    abstract_target 'Tests' do
        sharedTests

        allPlatforms.each { |platform|
            target "HyperdriveInterfaceTests-#{platform.name}" do
                platform.apply()
                snapKit
                kingfisher
            end
        }
    end
end

abstract_target 'LiveInterface' do
    project 'LiveInterface/LiveInterface.xcodeproj'

    allPlatforms.each { |platform|
        target "HyperdriveLiveInterface-#{platform.name}" do
            platform.apply()
            snapKit
            rxSwift
            rxCocoa
        end
    }

    target 'HyperdriveInterfacePlayground' do
        HyperdrivePlatform.ios(self).apply
        snapKit
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



