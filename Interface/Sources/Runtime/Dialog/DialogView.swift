//
//  DialogView.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public final class DialogView: ConfigurableHyperViewBase {
    private let contentContainer = ContainerView()
    internal let content: UIView
    
    public override var configuration: Configuration {
        didSet {
            contentContainer.configuration = configuration
            configuration.get(valueFor: Properties.Style.dialogContentContainer)(contentContainer)
            configuration.get(valueFor: Properties.Style.dialog)(self)
        }
    }
    
    public init(content: UIView) {
        self.content = content
        
        super.init()

        loadView()
        setupConstraints()
    }
    
    private func loadView() {
        addSubview(contentContainer)
        contentContainer.addSubview(content)
    }
    
    private func setupConstraints() {
        contentContainer.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(snp.leadingMargin)
            make.top.greaterThanOrEqualTo(snp.topMargin)
            make.trailing.greaterThanOrEqualTo(snp.trailingMargin)
            make.bottom.lessThanOrEqualTo(snp.bottomMargin)
            make.center.equalTo(self)
        }
        
        content.snp.makeConstraints { make in
            make.edges.equalTo(contentContainer)
        }
    }
}
#endif
