#
# Be sure to run `pod lib lint ProjectBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
    spec.name             = 'HyperdrivePlatform'
    spec.version          = '2.0.0-alpha.1'
    spec.summary          = 'Hyperdrive is a reactive architecture for iOS, tvOS and macOS'

    spec.description      = <<-DESC
                            Hyperdrive is a foundation for rapid and safe iOS, tvOS and macOS development. It allows you to cut down your development costs by improving reusability, testability and safety of your code, especially your UI.
                            DESC
    spec.homepage         = 'https://www.reactant.tech'
    spec.license          = 'MIT'
    spec.author           = {
        'Tadeas Kriz' => 'tadeas@brightify.org',
        'Matous Hybl' => 'matous@brightify.org',
        'Filip Dolnik' => 'filip@brightify.org',
        'Matyas Kriz' => 'matyas@brightify.org'
    }
    spec.source           = {
        :git => 'https://github.com/Brightify/Reactant.git',
        :tag => spec.version.to_s
    }
    spec.social_media_url = 'https://twitter.com/BrightifyOrg'
    spec.requires_arc = true

    spec.module_name = 'Hyperdrive'
    spec.ios.deployment_target = '11.0'
    spec.tvos.deployment_target = '11.0'
    spec.osx.deployment_target = '10.12'
    spec.default_subspec = 'Core'

    def self.rxSwift(subspec)
        subspec.dependency 'RxSwift', '~> 5.0'
    end
    def self.rxCocoa(subspec)
        subspec.dependency 'RxCocoa', '~> 5.0'
    end
    def self.rxRelay(subspec)
        subspec.dependency 'RxRelay', '~> 5.0'
    end

    spec.subspec 'Core' do |subspec|
        subspec.ios.frameworks = 'UIKit'
        subspec.tvos.frameworks = 'UIKit'
        subspec.osx.frameworks = 'AppKit'

        subspec.source_files = [
            'Platform/Sources/Core/**/*.swift',
        ]
    end

    spec.subspec 'Interface' do |subspec|
        subspec.dependency 'HyperdriveInterface'
        subspec.source_files = [
            'Platform/InterfaceBridge/ExportHyperdriveInterface.swift'
        ]
    end

    spec.subspec 'Core+RxSwift' do |rxcore|
        rxcore.dependency 'HyperdrivePlatform/Core'
        rxcore.pod_target_xcconfig = {
            'OTHER_SWIFT_FLAGS' => '-DENABLE_RXSWIFT'
        }
        rxcore.source_files = [
            'Platform/RxSources/Core+RxSwift/**/*.swift',
            'Platform/RxSources/Utils+RxSwift/**/*.swift'
        ]

        rxSwift(rxcore)
        rxRelay(rxcode)
        rxCocoa(rxcore)
    end

    spec.subspec 'All-iOS' do |subspec|
        subspec.dependency 'HyperdrivePlatform/Core'
        subspec.dependency 'HyperdrivePlatform/Core+RxSwift'
        subspec.dependency 'HyperdrivePlatform/Interface'
    end

    spec.subspec 'All-tvOS' do |subspec|
        subspec.dependency 'HyperdrivePlatform/Core'
        subspec.dependency 'HyperdrivePlatform/Core+RxSwift'
        subspec.dependency 'HyperdrivePlatform/Interface'
    end

    spec.subspec 'All-macOS' do |subspec|
        subspec.dependency 'HyperdrivePlatform/Core'
        subspec.dependency 'HyperdrivePlatform/Core+RxSwift'
        subspec.dependency 'HyperdrivePlatform/Interface'
    end
end
