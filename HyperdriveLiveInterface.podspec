Pod::Spec.new do |spec|
    spec.name             = 'HyperdriveLiveInterface'
    spec.version          = '2.0.0-alpha.1'
    spec.summary          = 'Live reloading of ReactantUI XML files.'
    spec.description      = <<-DESC
                            HyperdriveLiveInterface adds live reloading capabilities to Hyperdrive Interface.
                            DESC
    spec.homepage         = 'https://www.hyperdrive.app'
    spec.license          = 'MIT'
    spec.author           = {
        'Tadeas Kriz' => 'tadeas@brightify.org',
        'Matous Hybl' => 'matous@brightify.org',
        'Filip Dolnik' => 'filip@brightify.org'
    }
    spec.source           = {
        :git => 'https://github.com/Brightify/ReactantUI.git',
        :tag => spec.version.to_s
    }
    spec.social_media_url = 'https://twitter.com/BrightifyOrg'
    spec.requires_arc = true

    spec.ios.deployment_target = '11.0'
    spec.tvos.deployment_target = '11.0'
    spec.pod_target_xcconfig = {
        'OTHER_SWIFT_FLAGS' => '-D HyperdriveRuntime'
    }
    spec.dependency 'SnapKit'
    spec.dependency 'HyperdriveInterface' #, '> 2.0'
    spec.dependency 'RxCocoa'
    spec.source_files = [
        'Interface/Sources/Common/**/*.swift',
        'Interface/Sources/Tokenizer/**/*.swift',
        'LiveInterface/Sources/**/*.{swift,h,m}',
        'Interface/Sources/Runtime/Core/Utils/Internal/AssociatedObject.swift',
    ]
end
