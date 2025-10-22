//
//  YPCameraView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia

internal class YPCameraView: UIView, UIGestureRecognizerDelegate {
    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    let previewViewContainer = UIView()
    let buttonsContainer = UIView()
    let flipButton = UIButton()
    let shotButton = UIButton()
    let flashButton = UIButton()
    let timeElapsedLabel = UILabel()
    let progressBar = UIProgressView()
    let zoomButtonsContainer = UIStackView()
    let zoomButton05x = UIButton()
    let zoomButton1x = UIButton()
    let zoomButton2x = UIButton()
    
    convenience init(overlayView: UIView? = nil) {
        self.init(frame: .zero)
        
        zoomButtonsContainer.addArrangedSubview(zoomButton05x)
        zoomButtonsContainer.addArrangedSubview(zoomButton1x)
        zoomButtonsContainer.addArrangedSubview(zoomButton2x)

        if let overlayView = overlayView {
            // View Hierarchy
            subviews(
                previewViewContainer,
                overlayView,
                progressBar,
                timeElapsedLabel,
                flashButton,
                flipButton,
                zoomButtonsContainer,
                buttonsContainer.subviews(
                    shotButton
                )
            )
        } else {
            // View Hierarchy
            subviews(
                previewViewContainer,
                progressBar,
                timeElapsedLabel,
                flashButton,
                flipButton,
                zoomButtonsContainer,
                buttonsContainer.subviews(
                    shotButton
                )
            )
        }
        
        // Layout
        let height = window?.windowScene?.screen.bounds.height ?? .zero
        let isIphone4 = height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        if YPConfig.onlySquareImagesFromCamera {
            layout(
                0,
                |-sideMargin-previewViewContainer-sideMargin-|,
                -2,
                |progressBar|,
                0,
                |buttonsContainer|,
                0
            )
            
            previewViewContainer.heightEqualsWidth()
        } else {
            layout(
                0,
                |-sideMargin-previewViewContainer-sideMargin-|,
                -2,
                |progressBar|,
                0
            )
            
            previewViewContainer.fillContainer()
            
            buttonsContainer.fillHorizontally()
            buttonsContainer.height(100)
            buttonsContainer.Bottom == previewViewContainer.Bottom - 50
        }
        
        overlayView?.followEdges(previewViewContainer)
        
        |-(15+sideMargin)-flashButton.size(42)
        flashButton.Bottom == previewViewContainer.Bottom - 15
        
        flipButton.size(42)-(15+sideMargin)-|
        flipButton.Bottom == previewViewContainer.Bottom - 15
        
        timeElapsedLabel-(15+sideMargin)-|
        timeElapsedLabel.Top == previewViewContainer.Top + 15

        shotButton.centerVertically()
        shotButton.size(84).centerHorizontally()

        zoomButtonsContainer.centerHorizontally()
        zoomButtonsContainer.Top == previewViewContainer.Top + 60

        // Style
        backgroundColor = YPConfig.colors.photoVideoScreenBackgroundColor
        previewViewContainer.backgroundColor = UIColor.ypLabel
        timeElapsedLabel.style { l in
            l.textColor = .white
            l.text = "00:00"
            l.isHidden = true
            l.font = YPConfig.fonts.cameraTimeElapsedFont
        }
        progressBar.style { p in
            p.trackTintColor = .clear
            p.tintColor = .ypSystemRed
        }
        flashButton.setImage(YPConfig.icons.flashOffIcon, for: .normal)
        flipButton.setImage(YPConfig.icons.loopIcon, for: .normal)
        shotButton.setImage(YPConfig.icons.capturePhotoImage, for: .normal)

        zoomButtonsContainer.axis = .horizontal
        zoomButtonsContainer.spacing = 8
        zoomButtonsContainer.distribution = .fillEqually

        [zoomButton05x, zoomButton1x, zoomButton2x].forEach { button in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.setTitleColor(.white.withAlphaComponent(0.55), for: .normal)
            button.setTitleColor(.ypLabel, for: .selected)
            button.backgroundColor = .clear
            button.layer.cornerRadius = 18
            button.widthAnchor.constraint(equalToConstant: 45).isActive = true
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }

        zoomButton05x.setTitle("0,5", for: .normal)
        zoomButton1x.setTitle("1×", for: .normal)
        zoomButton2x.setTitle("2×", for: .normal)

        zoomButton1x.isSelected = true
        zoomButton1x.backgroundColor = UIColor.white.withAlphaComponent(0.25)
    }

    func configureZoomButtons(hasUltraWide: Bool, hasTelephoto: Bool) {
        zoomButton05x.isHidden = !hasUltraWide
        zoomButton2x.isHidden = !hasTelephoto

        if !hasUltraWide && !hasTelephoto {
            zoomButtonsContainer.isHidden = true
        }
    }

    func updateZoomButtonSelection(_ selectedButton: UIButton) {
        [zoomButton05x, zoomButton1x, zoomButton2x].forEach { button in
            if button == selectedButton {
                button.isSelected = true
                button.backgroundColor = UIColor.white.withAlphaComponent(0.25)
            } else {
                button.isSelected = false
                button.backgroundColor = .clear
            }
        }
    }
}
