import bb.cascades 1.3
import player 1.0

ImageView {
    property variant song
    verticalAlignment: VerticalAlignment.Center
    scalingMethod: song ? ScalingMethod.Fill : ScalingMethod.None
    imageSource: song ? song.iconPath : "asset:///images/formats/icon_unknown.png"
    loadEffect: ImageViewLoadEffect.FadeZoom
    preferredHeight: 128
    preferredWidth: 128
}