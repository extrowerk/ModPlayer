import bb.cascades 1.3
import player 1.0

GroupContainer {
    id: modPlayerListItem
    property alias title: titleField.text
    property alias description: descriptionField.text
    property alias text: textField.text

    property alias upperStatus: statusUpperField.text
    property alias middleStatus: statusMiddleField.text
    property alias lowerStatus: statusLowerField.text
    property alias imageSource: imageView.imageSource

    property int   favouriteScore: 0
    property bool  playing: false
    property bool  paused: false

    leftPadding: 10
    rightPadding: 10

    semiTransparent: true

    VerticalContainer {
        HorizontalContainer {
            VerticalContainer {
                verticalAlignment: VerticalAlignment.Center
                ImageView {
                    id: imageView
                    visible: image!=null
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Center
                    scalingMethod: ScalingMethod.None
                    loadEffect: ImageViewLoadEffect.FadeZoom
                    preferredWidth: 128
                    preferredHeight: 128
                    minWidth: 128
                    maxWidth: 128
                    minHeight: 128
                    maxHeight: 128
                }
                ImageView {
                    id: animationView
                    visible: modPlayerListItem.playing || modPlayerListItem.paused
                    topMargin: 20
                    scaleX: 1.4
                    imageSource: visible ? "asset:///images/objects/music-playing.gif" : ""
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    scalingMethod: ScalingMethod.None
                    loadEffect: ImageViewLoadEffect.None
                    attachedObjects: [
                        ImageAnimator {
                            id: imageAnimator
                            animatedImage: animationView.image
                            started: true
                        }
                    ]
                }
            }
            VerticalContainer {
                horizontalAlignment: HorizontalAlignment.Fill
                HorizontalContainer {
                    horizontalAlignment: HorizontalAlignment.Fill
                    leftPadding: 10
                    rightPadding: 20
                    attachedObjects: [
                        ImageTracker {
                            id: badgeMyFavourite
                            imageSource: "asset:///images/badges/badge_myfavourite.png"
                        }
                    ]
                    BlackLabel {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 10
                        }
                        id: titleField
                        visible: text.length > 0
                        horizontalAlignment: HorizontalAlignment.Left
                        textStyle {
                            base: SystemDefaults.TextStyles.PrimaryText
                        }
                    }
                    ImageView {
                        id: favouriteImage5
                        visible: modPlayerListItem.favouriteScore > 4
                        image: badgeMyFavourite.image
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Center
                        scalingMethod: ScalingMethod.Fill
                        loadEffect: ImageViewLoadEffect.None
                        preferredWidth: 32
                        preferredHeight: 32
                    }
                    ImageView {
                        id: favouriteImage4
                        visible: modPlayerListItem.favouriteScore > 3
                        image: badgeMyFavourite.image
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Center
                        scalingMethod: ScalingMethod.Fill
                        loadEffect: ImageViewLoadEffect.None
                        preferredWidth: 32
                        preferredHeight: 32
                    }
                    ImageView {
                        id: favouriteImage3
                        visible: modPlayerListItem.favouriteScore > 2
                        image: badgeMyFavourite.image
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Center
                        scalingMethod: ScalingMethod.Fill
                        loadEffect: ImageViewLoadEffect.None
                        preferredWidth: 32
                        preferredHeight: 32
                    }
                    ImageView {
                        id: favouriteImage2
                        visible: modPlayerListItem.favouriteScore > 1
                        image: badgeMyFavourite.image
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Center
                        scalingMethod: ScalingMethod.Fill
                        loadEffect: ImageViewLoadEffect.None
                        preferredWidth: 32
                        preferredHeight: 32
                    }
                    ImageView {
                        id: favouriteImage1
                        visible: modPlayerListItem.favouriteScore > 0
                        image: badgeMyFavourite.image
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Center
                        scalingMethod: ScalingMethod.Fill
                        loadEffect: ImageViewLoadEffect.None
                        preferredWidth: 32
                        preferredHeight: 32
                    }
                }
                HorizontalContainer {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    leftPadding: 10
                    rightPadding: 10
                    bottomPadding: 5
                    VerticalContainer {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 10
                        }
                        verticalAlignment: VerticalAlignment.Bottom
                        rightPadding: 20
                        BlackLabel {
                            id: descriptionField
                            visible: text.length > 0
                            horizontalAlignment: HorizontalAlignment.Left
                            multiline: true
                            textStyle {
                                base: SystemDefaults.TextStyles.BodyText
                                fontWeight: FontWeight.W100
                            }
                        }
                        BlackLabel {
                            id: textField
                            visible: text.length > 0
                            horizontalAlignment: HorizontalAlignment.Left
                            textStyle {
                                base: SystemDefaults.TextStyles.SmallText
                                fontWeight: FontWeight.W100
                                fontStyle: FontStyle.Italic
                            }
                        }
                    }
                    
                    VerticalContainer {
                        verticalAlignment: VerticalAlignment.Center
                        attachedObjects: [
                            ImagePaintDefinition {
                                id: infoPaint
                                repeatPattern: RepeatPattern.Fill
                                imageSource: "asset:///images/backgrounds/infoback.amd"
                            },
                            TextStyleDefinition {
                                id: smallTextStyle
                                base: SystemDefaults.TextStyles.SubtitleText
                                fontWeight: FontWeight.W100
                                fontStyle: FontStyle.Italic
                            }
                        ]
                        Container {
                            visible: upperStatus.length > 0
                            horizontalAlignment: HorizontalAlignment.Right
                            background: infoPaint.imagePaint
                            bottomMargin: 10
                            topPadding: 4
                            bottomPadding: 8
                            leftPadding: 20
                            rightPadding: 16
                            BlackLabel {
                                id: statusUpperField
                                visible: text.length > 0
                                horizontalAlignment: HorizontalAlignment.Right
                                textStyle {
                                    base: smallTextStyle.style
                                }
                            }
                        }
                        Container {
                            visible: middleStatus.length > 0
                            horizontalAlignment: HorizontalAlignment.Right
                            background: infoPaint.imagePaint
                            topMargin: 10
                            bottomMargin: 10
                            topPadding: 4
                            bottomPadding: 8
                            leftPadding: 20
                            rightPadding: 16
                            BlackLabel {
                                id: statusMiddleField
                                visible: text.length > 0
                                horizontalAlignment: HorizontalAlignment.Right
                                textStyle {
                                    base: smallTextStyle.style
                                }
                            }
                        }
                        Container {
                            visible: lowerStatus.length > 0
                            horizontalAlignment: HorizontalAlignment.Right
                            background: infoPaint.imagePaint
                            topMargin: 10
                            topPadding: 4
                            bottomPadding: 8
                            leftPadding: 20
                            rightPadding: 16
                            BlackLabel {
                                id: statusLowerField
                                visible: text.length > 0
                                horizontalAlignment: HorizontalAlignment.Right
                                textStyle {
                                    base: smallTextStyle.style
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
