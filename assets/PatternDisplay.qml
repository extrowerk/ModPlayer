import bb.cascades 1.3
import player 1.0
import "functions.js" as Global

Container {
    layout: DockLayout {}
    horizontalAlignment: HorizontalAlignment.Fill
    PatternView {
        id: patternView
        song: app.player.currentSong
        visibleChannels: app.screenWidth > 1300 ? 8 : 4
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
    }
    ImageView {
        visible: patternView.visibleChannels < app.player.currentSong.channels
        imageSource: patternView.previousChannelEnabled ? "asset:///images/objects/left-arrow.png" : "asset:///images/objects/left-arrow-disabled.png"
        horizontalAlignment: HorizontalAlignment.Left
        verticalAlignment: VerticalAlignment.Center
        preferredHeight: 65
        preferredWidth: 65
        onTouch: {
            if(event.isDown()) {
                patternView.previousChannel()
            }
        }
    }
    ImageView {
        visible: patternView.visibleChannels < app.player.currentSong.channels
        imageSource: patternView.nextChannelEnabled ? "asset:///images/objects/right-arrow.png" : "asset:///images/objects/right-arrow-disabled.png"
        horizontalAlignment: HorizontalAlignment.Right
        verticalAlignment: VerticalAlignment.Center
        preferredHeight: 65
        preferredWidth: 65
        onTouch: {
            if(event.isDown()) {
                patternView.nextChannel()
            }
        }
    }
}