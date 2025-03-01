import bb.cascades 1.3
import QtQuick 1.0
import player 1.0

Container {
    property bool coverScreen: false
    layout: DockLayout {}
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    implicitLayoutAnimationsEnabled: false
    background: coverScreen ? backgroundPaintOuter.imagePaint : Color.create(app.wallpaper.color)
    ImageView {
        implicitLayoutAnimationsEnabled: false
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        visible: !app.wallpaper.solidColor && !coverScreen
        imageSource: app.wallpaper.path
        loadEffect: ImageViewLoadEffect.None
        scalingMethod: app.wallpaper.stretchMode
    }
    Container {
        visible: !coverScreen
        layout: AbsoluteLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        implicitLayoutAnimationsEnabled: false
        Container {
            id: block
            layoutProperties: AbsoluteLayoutProperties {
                positionX: -layoutHandler.layoutFrame.width/2
                positionY: -layoutHandler.layoutFrame.height/2
            }

            property double scalePhase: 0
            property double rotatePhase: 63
            property double angleX: 0.0
            property double angleY: 0.0

            property double scaleStep: 0.25
            property double rotateStep: 0.10
            property double angleStepX: 2.2
            property double angleStepY: 1.1

            property double rotateMin: -180.0
            property double rotateMax: 360

            property double scaleMax: 2.5
            property double scaleMin: 1.0

            preferredWidth: layoutHandler.layoutFrame.width * 2
            preferredHeight: layoutHandler.layoutFrame.height * 2

            background: backgroundPaint.imagePaint
            implicitLayoutAnimationsEnabled: false

            visible: app.wallpaper.animatable && !app.wallpaper.solidColor && !coverScreen

            translationX: app.player.playback.configuration.animationEnabled ? Math.sin(angleX * 0.01745329251) * 117 : 0
            translationY: app.player.playback.configuration.animationEnabled ? Math.cos(angleY * 0.01745329251) * 97 : 0

            rotationZ: app.player.playback.configuration.animationEnabled ? (Math.sin(rotatePhase * 0.01745329251) * (rotateMax - rotateMin)/2 + rotateMin) : 0 

            scaleX: app.player.playback.configuration.animationEnabled ? (Math.sin(scalePhase * 0.01745329251) + 1) * (scaleMax - scaleMin)/2 + scaleMin : 1.0
            scaleY: app.player.playback.configuration.animationEnabled ? (Math.sin(scalePhase * 0.01745329251) + 1) * (scaleMax - scaleMin)/2 + scaleMin : 1.0

            attachedObjects: [
                Timer {
                    id: rotozoomTimer
                    interval: 50
                    repeat: true
                    onTriggered: {
                        if(app.player.playback.configuration.animationEnabled &&
                           app.wallpaper.animatable &&
                          !app.wallpaper.solidColor) {
                            block.angleX += block.angleStepX
                            block.angleY += block.angleStepY
                            block.scalePhase += block.scaleStep
                            block.rotatePhase += block.rotateStep
                        }
                    }
                },
                ImplicitAnimationController {
                    enabled: false
                },
                ImagePaintDefinition {
                    id: backgroundPaint
                    repeatPattern: app.wallpaper.animatable ? RepeatPattern.XY : RepeatPattern.Fill
                    imageSource: app.wallpaper.path
                }
            ]
            function enableAnimationTimer() {
                if(app.player.playback.configuration.animationEnabled &&
                   app.wallpaper.animatable &&
                  !app.wallpaper.solidColor && 
                  !coverScreen) {
                    rotozoomTimer.start()
                }
            }
            function disableAnimationTimer() {
                rotozoomTimer.stop()
            }
            function initTimer() {
                if(app.player.playback.configuration.animationEnabled &&
                   app.wallpaper.animatable &&
                   !app.wallpaper.solidColor && 
                   !coverScreen) {
                    enableAnimationTimer()
                } else {
                    disableAnimationTimer()
                }
            }
            onCreationCompleted: {
                var thisObject = block
                Application.fullscreen.connect(function() {
                    thisObject.enableAnimationTimer()
                })
                Application.invisible.connect(function() {
                    thisObject.disableAnimationTimer()
                })
                Application.thumbnail.connect(function() {
                    thisObject.disableAnimationTimer()
                })
                app.player.playback.configuration.animationEnabledChanged.connect(function() {
                    thisObject.initTimer()
                })
                app.wallpaper.animatableChanged.connect(function() {
                    thisObject.initTimer()
                })
                initTimer()
            }
        }
        attachedObjects:[
            LayoutUpdateHandler {
                id: layoutHandler
            },
            ImagePaintDefinition {
                id: backgroundPaintOuter
                repeatPattern: app.wallpaper.repeatable ? RepeatPattern.XY : RepeatPattern.Fill
                imageSource: app.wallpaper.path
            }
        ]
    }
}
