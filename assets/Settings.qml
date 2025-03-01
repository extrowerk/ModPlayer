import bb.cascades 1.3
import bb.system 1.2
import player 1.0
import "functions.js" as Global

Sheet {
    id: settingsRoot
    property int groupSettingIndent: 40
    property variant configuration: app.player.playback.configuration
    onOpened: {
        app.analytics.settings(1)
    }
    onClosed: {
        app.analytics.settings(0)
        settingsRoot.destroy()
    }
    Page {
        titleBar: PlayerTitleBar {
            title: qsTr("Configuration") + Retranslate.onLanguageChanged
            dismissAction: ActionItem {
                title: qsTr("Close") + Retranslate.onLanguageChanged
                onTriggered: {
                    settingsRoot.close();
                }
            }
            acceptAction: ActionItem {
                title: qsTr("Apply") + Retranslate.onLanguageChanged
                onTriggered: {
                    app.player.playback.configure()
                    app.cache.maxSize = Math.round(maxCacheSize.value)
                    app.cache.maxFiles = Math.round(maxCacheSongs.value)
                    settingsRoot.close();
                }
            } 
        }
        Container {
            layout: DockLayout {}
            WallpaperView {}
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                ScrollView {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    VerticalContainer {
                        leftPadding: 20
                        rightPadding: 20
                        topPadding: 20
                        bottomPadding: 20
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: 20
                            semiTransparent: true
                            BlackLabel {
                                text: qsTr("Application") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    fontWeight: FontWeight.Bold
                                }
                            }
                            Animation {
                                gestureHandlers: [
                                    TapHandler {
                                        onTapped: {
                                            mouse.showMouse()
                                        }
                                    }
                                ]
                            }
                            BlackLabel {
                                horizontalAlignment: HorizontalAlignment.Center
                                text: qsTr("Version: <b>%1</b>").arg(app.version) + Retranslate.onLanguageChanged
                                textFormat: TextFormat.Html
                            }
                            HorizontalContainer {
                                ImageView {
                                    imageSource: "asset:///images/objects/cache.png"
                                    verticalAlignment: VerticalAlignment.Center
                                }
                                VerticalContainer {
                                    BlackLabel {
                                        id: catalogSongCount
                                        property int requestId
                                        textFormat: TextFormat.Html
                                        onCreationCompleted: {
                                            text = qsTr("Catalog songs: <b>%1</b>").arg("calculating...") + Retranslate.onLanguageChanged
                                            var thisObject = catalogSongCount
                                            app.catalog.resultReady.connect(function(responseId, result) {
                                                if(responseId == thisObject.requestId) {
                                                    thisObject.requestId = 0
                                                    thisObject.text = qsTr("Catalog songs: <b>%1</b>").arg(result) + Retranslate.onLanguageChanged
                                                }
                                            })
                                            catalogSongCount.requestId = app.catalog.songCountAsync()
                                        }
                                    }
                                    BlackLabel {
                                        id: personalSongCount
                                        property int requestId
                                        textFormat: TextFormat.Html
                                        onCreationCompleted: {
                                            var thisObject = personalSongCount
                                            app.player.importCompleted.connect(updateCount)
                                            app.catalog.resultReady.connect(function(responseId, result) {
                                                if(responseId == thisObject.requestId) {
                                                    thisObject.requestId = 0
                                                    thisObject.text = qsTr("Personal songs: <b>%1</b>").arg(result) + Retranslate.onLanguageChanged
                                                }
                                            })
                                            updateCount()
                                        }
                                        function updateCount() {
                                            text = qsTr("Personal songs: <b>%1</b>").arg("calculating...") + Retranslate.onLanguageChanged
                                            personalSongCount.requestId = app.catalog.personalSongCountAsync()
                                        }
                                    }
                                }
                            }
                            Button {
                                text: qsTr("Buy ModPlayer Plus") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                topMargin: 60
                                visible: !app.isExtendedVersion
                                onClicked: {
                                    buyView.createObject().open()
                                }
                                attachedObjects: [
                                    ComponentDefinition {
                                        id: buyView
                                        source: "Buy.qml"
                                    }
                                ]
                            }
                            BlackLabel {
                                text: qsTr("<a href='http://www.kosenkov.ca/policy.html'>Privacy Policy</a>") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                textFormat: TextFormat.Html
                            }
                        }
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            BlackLabel {
                                text: qsTr("Cache") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    fontWeight: FontWeight.Bold
                                }
                            }
                            HorizontalContainer {
                                ImageView {
                                    imageSource: "asset:///images/objects/memory.png"
                                    verticalAlignment: VerticalAlignment.Center
                                }
                                VerticalContainer {
                                    BlackLabel {
                                        text: qsTr("Cached Songs: <b>%1</b>").arg(app.player.cache.currentFiles) + Retranslate.onLanguageChanged
                                        textFormat: TextFormat.Html
                                    }
                                    BlackLabel {
                                        text: qsTr("Used Cache Size: <b>%1</b>").arg(Global.getSizeKb(app.player.cache.currentSize)) + Retranslate.onLanguageChanged
                                        textFormat: TextFormat.Html
                                    }
                                }
                            }
                            BlackLabel {
                                text: qsTr("Maximum Songs: %1").arg(Math.round(maxCacheSongs.value)) + Retranslate.onLanguageChanged
                            }
                            VerticalContainer {
                                leftPadding: groupSettingIndent
                                rightPadding: leftPadding
                                Slider {
                                    id: maxCacheSongs
                                    fromValue: 5
                                    toValue: app.isExtendedVersion ? 1000 : 100
                                    value: app.cache.maxFiles
                                }
                            }
                            BlackLabel {
                                text: qsTr("Maximum Cache Size: %1").arg(Global.getSizeKb(Math.round(maxCacheSize.value))) + Retranslate.onLanguageChanged
                            }
                            VerticalContainer {
                                leftPadding: groupSettingIndent
                                rightPadding: leftPadding
                                Slider {
                                    id: maxCacheSize
                                    fromValue: 5 * 1024 * 1024
                                    toValue: app.isExtendedVersion ? 1000 * 1024 * 1024 : 100 * 1024 * 1024
                                    value: app.cache.maxSize
                                }
                            }
                            Button {
                                text: qsTr("Purge Cache") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                topMargin: 40
                                bottomMargin: 40
                                enabled: app.cache.currentFiles > 0
                                onClicked: {
                                    confirmPurgingSongCache.show()
                                }
                                attachedObjects: [
                                    SystemDialog {
                                        id: confirmPurgingSongCache
                                        title: qsTr("Confirm") + Retranslate.onLanguageChanged
                                        body: qsTr("Confirm purging the song cache") + Retranslate.onLanguageChanged
                                        onFinished: {
                                            if (result == SystemUiResult.ConfirmButtonSelection) {
                                                app.analytics.purgeCache()
                                                app.cache.purge()
                                                cachePurgedToast.show()
                                            }
                                        }
                                    },
                                    SystemToast {
                                        id: cachePurgedToast
                                        body: qsTr("The song cache has been purged") + Retranslate.onLanguageChanged
                                    }
                                ]
                            }
                            ExportCacheButton {
                            }
                        }
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            BlackLabel {
                                text: qsTr("Device Screen") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    fontWeight: FontWeight.Bold
                                }
                            }
                            MultilineCheckBox {
                                id: keepScreenAwake
                                text: qsTr("Keep screen awake") + Retranslate.onLanguageChanged
                                checked: app.keepScreenAwake
                                onCheckedChanged: {
                                    app.keepScreenAwake = keepScreenAwake.checked
                                    app.updateScreen()
                                }
                            }
                        }
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            BlackLabel {
                                text: qsTr("Song List") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    fontWeight: FontWeight.Bold
                                }
                            }
                            InitialViewSelector {}
                            ScrollTypeSelector {}
                            PlusFeature {
                                extendedVersion: VerticalContainer {
                                    BlackLabel {
                                        text: qsTr("Maximum Songs: %1").arg(Math.round(app.maxViewSongs)) + Retranslate.onLanguageChanged
                                    }
                                    VerticalContainer {
                                        leftPadding: groupSettingIndent
                                        rightPadding: leftPadding
                                        Slider {
                                            id: maxViewSongs
                                            fromValue: 100
                                            toValue: 5000
                                            value: app.maxViewSongs
                                            onValueChanged: {
                                                app.maxViewSongs = Math.round(Math.round(value / 100) * 100)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        PlaylistSensorControl {}
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            BlackLabel {
                                text: qsTr("Personal") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    fontWeight: FontWeight.Bold
                                }
                            }
                            Button {
                                text: qsTr("Reset Play Counts") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                topMargin: 40
                                bottomMargin: 40
                                onClicked: {
                                    confirmResetPlayCounts.show()
                                }
                                attachedObjects: [
                                    SystemDialog {
                                        id: confirmResetPlayCounts
                                        title: qsTr("Confirm") + Retranslate.onLanguageChanged
                                        body: qsTr("Confirm resetting song play counts") + Retranslate.onLanguageChanged
                                        onFinished: {
                                            if (result == SystemUiResult.ConfirmButtonSelection) {
                                                app.catalog.resetPlayCounts()
                                                songPlayCountsToast.show()
                                            }
                                        }
                                    },
                                    SystemToast {
                                        id: songPlayCountsToast
                                        body: qsTr("Song play counts have been reset") + Retranslate.onLanguageChanged
                                    }
                                ]
                            }
                            Button {
                                text: qsTr("Reset My Favourites") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                topMargin: 40
                                bottomMargin: 40
                                onClicked: {
                                    confirmMyFavouritesReset.show()
                                }
                                attachedObjects: [
                                    SystemDialog {
                                        id: confirmMyFavouritesReset
                                        title: qsTr("Confirm") + Retranslate.onLanguageChanged
                                        body: qsTr("Confirm resetting my favoruites list") + Retranslate.onLanguageChanged
                                        onFinished: {
                                            if (result == SystemUiResult.ConfirmButtonSelection) {
                                                app.catalog.resetMyFavourites();
                                                myFavouritesResetToast.show()
                                            }
                                        }
                                    },
                                    SystemToast {
                                        id: myFavouritesResetToast
                                        body: qsTr("My favourites list is reset") + Retranslate.onLanguageChanged
                                    }
                                ]
                            }
                            ImportButton {
                            }
                        }
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            BlackLabel {
                                text: qsTr("Background") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    fontWeight: FontWeight.Bold
                                }
                            }
                            WallpaperSelector {}
                        }
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            BlackLabel {
                                text: qsTr("Mixer Configuration") + Retranslate.onLanguageChanged
                                horizontalAlignment: HorizontalAlignment.Center
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    fontWeight: FontWeight.Bold
                                }
                            }
                            DropDown {
                                id: output
                                title: qsTr("Output") + Retranslate.onLanguageChanged
                                Option {
                                    text: qsTr("Stereo") + Retranslate.onLanguageChanged
                                    value: 1
                                    selected: settingsRoot.configuration.stereo == true 
                                }
                                Option {
                                    text: qsTr("Mono") + Retranslate.onLanguageChanged
                                    value: 0
                                    selected: settingsRoot.configuration.stereo == false 
                                }
                                
                                onSelectedValueChanged: {
                                    settingsRoot.configuration.stereo = (selectedValue == 1)
                                }
                            }
                            DropDown {
                                id: bitsPerSample
                                title: qsTr("Bits per Sample") + Retranslate.onLanguageChanged
                                Option {
                                    text: "8"
                                    value: 8
                                    selected: settingsRoot.configuration.sampleSize == value
                                }
                                Option {
                                    text: "16"
                                    value: 16
                                    selected: settingsRoot.configuration.sampleSize == value
                                }
                                Option {
                                    text: "32"
                                    value: 32
                                    selected: settingsRoot.configuration.sampleSize == value
                                }
                                
                                onSelectedValueChanged: {
                                    settingsRoot.configuration.sampleSize = selectedValue
                                }
                            }
                            DropDown {
                                id: frequency
                                title: qsTr("Frequency") + Retranslate.onLanguageChanged
                                Option {
                                    text: "44100 Hz"
                                    description: qsTr("44100 Hz sampling rate") + Retranslate.onLanguageChanged
                                    value: 44100
                                    selected: settingsRoot.configuration.frequency == value
                                }
                                Option {
                                    text: "22050 Hz"
                                    description: qsTr("22050 Hz sampling rate") + Retranslate.onLanguageChanged
                                    value: 22050
                                    selected: settingsRoot.configuration.frequency == value
                                }
                                Option {
                                    text: "11025 Hz"
                                    description: qsTr("11025 Hz sampling rate") + Retranslate.onLanguageChanged
                                    value: 11025
                                    selected: settingsRoot.configuration.frequency == value
                                }
                                onSelectedValueChanged: {
                                    settingsRoot.configuration.frequency = selectedValue
                                }
                            }
                            DropDown {
                                id: resampling
                                title: qsTr("Resampling") + Retranslate.onLanguageChanged
                                Option {
                                    text: qsTr("Nearest") + Retranslate.onLanguageChanged
                                    description: qsTr("No interpolation (very fast)") + Retranslate.onLanguageChanged
                                    value: 0
                                    selected: settingsRoot.configuration.resamplingMode == value
                                }
                                Option {
                                    text: qsTr("Linear") + Retranslate.onLanguageChanged
                                    description: qsTr("Linear interpolation (fast, good quality)") + Retranslate.onLanguageChanged
                                    value: 1
                                    selected: settingsRoot.configuration.resamplingMode == value
                                }
                                Option {
                                    text: qsTr("Spline") + Retranslate.onLanguageChanged
                                    description: qsTr("Cubic spline interpolation (high quality)") + Retranslate.onLanguageChanged
                                    value: 2
                                    selected: settingsRoot.configuration.resamplingMode == value
                                }
                                Option {
                                    text: qsTr("FIR") + Retranslate.onLanguageChanged
                                    description: qsTr("8-tap fir filter (extremely high quality)") + Retranslate.onLanguageChanged
                                    value: 3
                                    selected: settingsRoot.configuration.resamplingMode == value
                                }
                                onSelectedValueChanged: {
                                    settingsRoot.configuration.resamplingMode = selectedValue
                                }
                            }
                        }
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            BlackLabel {
                                text: qsTr("Master Volume") + Retranslate.onLanguageChanged
                                textStyle {
                                    fontSize: FontSize.Large
                                }
                            }
                            VerticalContainer {
                                leftPadding: groupSettingIndent
                                rightPadding: leftPadding
                                Slider {
                                    id: masterVolume
                                    fromValue: 1
                                    toValue: 512
                                    value: settingsRoot.configuration.masterVolume
                                    onValueChanged: {
                                        app.player.playback.currentSong.masterVolume = masterVolume.value
                                        settingsRoot.configuration.masterVolume = masterVolume.value
                                    }
                                }
                            }
                            BlackLabel {
                                text: qsTr("Stereo Separation") + Retranslate.onLanguageChanged
                                textStyle {
                                    fontSize: FontSize.Large
                                }
                            }
                            VerticalContainer {
                                leftPadding: groupSettingIndent
                                rightPadding: leftPadding
                                Slider {
                                    id: stereoSeparation
                                    fromValue: 1
                                    toValue: 256
                                    value: settingsRoot.configuration.stereoSeparation
                                    onValueChanged: {
                                        settingsRoot.configuration.stereoSeparation = stereoSeparation.value
                                    }
                                }
                            }
                            MultilineCheckBox {
                                id: oversampling
                                text: qsTr("Enable Oversampling") + Retranslate.onLanguageChanged
                                checked: settingsRoot.configuration.oversamplingEnabled
                                onCheckedChanged: {
                                    settingsRoot.configuration.oversamplingEnabled = oversampling.checked
                                }
                            }
                            MultilineCheckBox {
                                id: noiseReduction
                                text: qsTr("Enable Noise Reduction") + Retranslate.onLanguageChanged
                                checked: settingsRoot.configuration.noiseReductionEnabled
                                onCheckedChanged: {
                                    settingsRoot.configuration.noiseReductionEnabled = noiseReduction.checked
                                }
                            }
                        }
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            MultilineCheckBox {
                                id: reverbEnabled
                                text: qsTr("Enable Reverb") + Retranslate.onLanguageChanged
                                checked: settingsRoot.configuration.reverbEnabled
                                onCheckedChanged: {
                                    settingsRoot.configuration.reverbEnabled = reverbEnabled.checked
                                }
                            }
                            VerticalContainer {
                                leftPadding: groupSettingIndent
                                rightPadding: leftPadding
                                BlackLabel {
                                    text: qsTr("Reverb Depth") + Retranslate.onLanguageChanged
                                    visible: reverbEnabled.checked
                                    textStyle {
                                        fontStyle: FontStyle.Italic
                                        fontWeight: FontWeight.W100
                                    }
                                }
                                Slider {
                                    id: reverbLevel
                                    visible: reverbEnabled.checked
                                    fromValue: 0
                                    toValue: 100
                                    value: settingsRoot.configuration.reverbLevel
                                    onValueChanged: {
                                        settingsRoot.configuration.reverbLevel = reverbLevel.value
                                    }
                                }
                                BlackLabel {
                                    text: qsTr("Reverb Delay") + Retranslate.onLanguageChanged
                                    visible: reverbEnabled.checked
                                    textStyle {
                                        fontStyle: FontStyle.Italic
                                        fontWeight: FontWeight.W100
                                    }
                                }
                                Slider {
                                    id: reverbDelay
                                    visible: reverbEnabled.checked
                                    fromValue: 40
                                    toValue: 200
                                    value: settingsRoot.configuration.reverbDelay
                                    onValueChanged: {
                                        settingsRoot.configuration.reverbDelay = reverbDelay.value
                                    }
                                }
                            }
                        }
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            MultilineCheckBox {
                                id: megabassEnabled
                                text: qsTr("Enable MegaBass") + Retranslate.onLanguageChanged
                                checked: settingsRoot.configuration.bassEnabled
                                onCheckedChanged: {
                                    settingsRoot.configuration.bassEnabled = megabassEnabled.checked
                                }
                            }
                            VerticalContainer {
                                leftPadding: groupSettingIndent
                                rightPadding: leftPadding
                                BlackLabel {
                                    text: qsTr("Bass Amount") + Retranslate.onLanguageChanged
                                    visible: megabassEnabled.checked
                                    textStyle {
                                        fontStyle: FontStyle.Italic
                                        fontWeight: FontWeight.W100
                                    }
                                }
                                Slider {
                                    id: megabassLevel
                                    visible: megabassEnabled.checked
                                    fromValue: 0
                                    toValue: 100
                                    value: settingsRoot.configuration.bassLevel
                                    onValueChanged: {
                                        settingsRoot.configuration.bassLevel = megabassLevel.value
                                    }
                                }
                                BlackLabel {
                                    text: qsTr("Bass Cutoff") + Retranslate.onLanguageChanged
                                    visible: megabassEnabled.checked
                                    textStyle {
                                        fontStyle: FontStyle.Italic
                                        fontWeight: FontWeight.W100
                                    }
                                }
                                Slider {
                                    id: megabassCutoff
                                    visible: megabassEnabled.checked
                                    fromValue: 10
                                    toValue: 100
                                    value: settingsRoot.configuration.bassCutOff
                                    onValueChanged: {
                                        settingsRoot.configuration.bassCutOff = megabassCutoff.value
                                    }
                                }
                            }
                        }
                        GroupContainer {
                            topPadding: 20
                            bottomPadding: 40
                            leftPadding: 20
                            rightPadding: leftPadding
                            semiTransparent: true
                            MultilineCheckBox {
                                id: surroundEnabled
                                text: qsTr("Enable Surround Sound") + Retranslate.onLanguageChanged
                                checked: settingsRoot.configuration.surroundEnabled
                                onCheckedChanged: {
                                    settingsRoot.configuration.surroundEnabled = surroundEnabled.checked
                                }
                            }
                            VerticalContainer {
                                leftPadding: groupSettingIndent
                                rightPadding: leftPadding
                                BlackLabel {
                                    text: qsTr("Surround Depth") + Retranslate.onLanguageChanged
                                    visible: surroundEnabled.checked
                                    textStyle {
                                        fontStyle: FontStyle.Italic
                                        fontWeight: FontWeight.W100
                                    }
                                }
                                Slider {
                                    id: surroundLevel
                                    visible: surroundEnabled.checked
                                    fromValue: 0
                                    toValue: 100
                                    value: settingsRoot.configuration.surroundLevel
                                    onValueChanged: {
                                        settingsRoot.configuration.surroundLevel = surroundLevel.value
                                    }
                                }
                                BlackLabel {
                                    text: qsTr("Surround Delay") + Retranslate.onLanguageChanged
                                    visible: surroundEnabled.checked
                                    textStyle {
                                        fontStyle: FontStyle.Italic
                                        fontWeight: FontWeight.W100
                                    }
                                }
                                Slider {
                                    id: surroundDelay
                                    visible: surroundEnabled.checked
                                    fromValue: 5
                                    toValue: 50
                                    value: settingsRoot.configuration.surroundDelay
                                    onValueChanged: {
                                        settingsRoot.configuration.surroundDelay = surroundDelay.value
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Mouse {
                id: mouse
            }
        }
    }
}
