Pod::Spec.new do |spec|
    spec.name             = 'HyperdriveInterface'
    spec.version          = '2.0.0.alpha-1'
    spec.summary          = 'Hyperdrive extension for UI declaration in XML'
    spec.description      = <<-DESC
                            HyperdriveInterface is an extension for Hyperdrive allowing you to declare views and layout using XML. Don't worry, there's no runtime overhead, as all those declarations are precompiled into Swift.
                            DESC
    spec.homepage         = 'https://www.hyperdrive.app'
    spec.license          = 'MIT'
    spec.author           = {
        'Tadeas Kriz' => 'tadeas@brightify.org',
        'Matous Hybl' => 'matous@brightify.org',
        'Filip Dolnik' => 'filip@brightify.org'
    }
    spec.source           = {
        :git => 'https://github.com/Brightify/Hyperdrive.git',
        :tag => spec.version.to_s
    }
    spec.social_media_url = 'https://twitter.com/BrightifyOrg'
    spec.requires_arc = true

    spec.ios.deployment_target = '9.0'
    spec.tvos.deployment_target = '9.2'

    spec.frameworks = 'UIKit'
    spec.default_subspec = []

    # TODO Remove the dependency on Rx so that we don't force it on our users
    spec.dependency 'RxCocoa'
    spec.dependency 'RxDataSources'

    # TODO Remove the dependency on Kingfisher, or make StaticMap (that's where it's used) into an optional subspec
    spec.dependency 'Kingfisher'

    # TODO Remove the dependency on SnapKit so that we don't force it on our users
    spec.dependency 'SnapKit'
    spec.source_files = [
        'Interface/Sources/Common/**/*.swift',
        'Interface/Sources/Runtime/**/*.swift'
    ]
    spec.exclude_files = [
        'Interface/Sources/Runtime/StaticMap/**/*.swift',
        'Interface/Sources/Runtime/Dialog/**/*.swift',
        'Interface/Sources/Runtime/Extensions/**/*.swift',
    ]
    generator_name = 'hyperdrive'
    spec.preserve_paths = [
        'CLI/Sources/**/*',
        'Interface/Sources/**/*',
        'Package.swift',
        'Package.resolved',
    ]
    spec.prepare_command = <<-CMD
        curl -Lo #{generator_name} https://github.com/Brightify/Hyperdrive/releases/download/#{spec.version}/#{generator_name}
        chmod +x #{generator_name}
    CMD

    spec.subspec 'Dialog' do |subspec|
        subspec.source_files = [
            'Interface/Sources/Runtime/Dialog/**/*.swift',
        ]
    end

    spec.subspec 'Extensions' do |subspec|
        subspec.subspec 'All' do |subspec|
            subspec.dependency 'HyperdriveInterface/Extensions/LayoutStack'
        end

        subspec.subspec 'LayoutStack' do |subspec|
            subspec.source_files = [
                'Interface/Sources/Runtime/'
            ]
        end
    end
end
