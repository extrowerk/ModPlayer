import bb.cascades 1.3
import player 1.0
import "functions.js" as Global

ImageView {
    property variant song
    visible: song && song.isHttpSong
    imageSource: song ? song.iconPath : ""
    horizontalAlignment: HorizontalAlignment.Left
    verticalAlignment: VerticalAlignment.Center
    scalingMethod: ScalingMethod.Fill
    loadEffect: ImageViewLoadEffect.FadeZoom
    preferredWidth: 128
    preferredHeight: 128
    minWidth: 128
    maxWidth: 128
    minHeight: 128
    maxHeight: 128
}