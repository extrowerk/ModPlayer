import bb.cascades 1.3
import bb.system 1.2
import player 1.0
import "functions.js" as Global

Page {
    id: songPlayer
    property variant navigationPane
    Container {
        layout: DockLayout {}
        WallpaperView {}
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            VerticalContainer {
                horizontalAlignment: HorizontalAlignment.Fill
                leftPadding: 20
                rightPadding: 20
                onCreationCompleted: {
                    headerAnimation.play()
                }
                animations: [
                    TranslateTransition {
                        id: headerAnimation
                        fromY: -200.0
                        toY: 0.0
                        duration: 800
                        easingCurve: StockCurve.BackOut
                    }
                ]
                VerticalContainer {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: 20
                    bottomPadding: 20
                    GroupContainer {
                        topMargin: 16
                        bottomMargin: 16
                        topPadding: 16
                        bottomPadding: 16
                        leftPadding: 16
                        rightPadding: 16 
                        background: vuPaint.imagePaint
                        horizontalAlignment: HorizontalAlignment.Center
                        LCDDisplay {
                            text: {
                                if(app.player.currentSong.title.length == 0) {
                                    if(app.player.currentSong.fileName.length > 0) {
                                        return Global.fileNameOnly(app.player.currentSong.fileName)
                                    } else {
                                        return "No song loaded"
                                    }
                                } else {
                                    return app.player.currentSong.title
                                }
                            }
                            bottomMargin: 10
                            horizontalAlignment: HorizontalAlignment.Center
                            gestureHandlers: [
                                TapHandler {
                                    onTapped: {
                                        mouse.showMouse()
                                    }
                                }
                            ]
                        }
                        VUMeter {
                            id: songVUMeter
                            topMargin: 10
                            horizontalAlignment: HorizontalAlignment.Center
                            visible: app.player.currentSong.songLoaded && app.player.currentSong.isTrackerSong && app.player.state == Player.Playing
                            song: app.player.currentSong
                        }
                        PlaybackSettings {}
                        SongProgressView {}
                        Label {
                            id: statusText
                            text: app.player.statusText
                            textFormat: TextFormat.Plain
                            textStyle {
                                fontWeight: FontWeight.W100
                                fontSize: FontSize.Large
                                color: Color.White
                            }
                            onTextChanged: {
                                opacity = 1.0
                                visible = true
                                if(app.player.state == Player.Playing) {
                                    fadeAway.play()
                                } else {
                                    fadeAway.stop()
                                }
                            }
                            animations: [
                                ParallelAnimation {
                                    id: fadeAway
                                    delay: 3000
                                    FadeTransition {
                                        duration: 2000
                                        easingCurve: StockCurve.CubicOut
                                        fromOpacity: 1.0
                                        toOpacity: 0.0
                                    }
                                    onEnded: {
                                        statusText.visible = false
                                    }
                                } 
                            ]
                        }
                        attachedObjects: [
                            ImagePaintDefinition {
                                id: vuPaint
                                repeatPattern: RepeatPattern.Fill
                                imageSource: "asset:///images/backgrounds/vu_back.amd"
                            }
                        ]
                    }
                }
            }
            ScrollView {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                VerticalContainer {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    leftPadding: 20
                    rightPadding: 20
                    GroupContainer {
                        topMargin: 16
                        bottomMargin: 16
                        topPadding: 16
                        bottomPadding: 16
                        leftPadding: 16
                        rightPadding: 16
                        visible: app.player.currentSong.songLoaded && app.player.currentSong.isTrackerSong
                        SegmentedControl {
                            id: viewOption
                            Option {
                                id: basicViewOption
                                text: qsTr("Basic") + Retranslate.onLanguageChanged
                                selected: true
                            }
                            Option {
                                id: patternViewOption
                                text: qsTr("Pattern") + Retranslate.onLanguageChanged
                                enabled: app.player.currentSong.isTrackerSong
                            }
                            Option {
                                id: samplesViewOption
                                text: qsTr("Samples") + Retranslate.onLanguageChanged
                                enabled: app.player.currentSong.isTrackerSong
                            }
                        }
                    }
                    VerticalContainer {
                        horizontalAlignment: HorizontalAlignment.Fill
                        visible: app.player.currentSong.songLoaded
                        SongMainInfo {
                            id: songMainInfo
                            song: app.player.currentSong
                            visible: app.player.currentSong.songLoaded && (viewOption.selectedOption == basicViewOption || !app.player.currentSong.isTrackerSong) 
                        }
                        SongArtistInfo {
                            id: songArtistInfo
                            song: app.player.currentSong
                            visible: app.player.currentSong.songLoaded && !app.player.currentSong.isTrackerSong
                        }
                        SongPublicInfo {
                            id: songPublicInfo
                            song: app.player.currentSong
                            visible: app.player.currentSong.songLoaded && app.player.currentSong.id != 0 && !app.player.currentSong.isLocal && viewOption.selectedOption == basicViewOption 
                        }
                        FallingBlocks {
                            visible: app.player.currentSong.isHttpSong
                            navigationPane: songPlayer.navigationPane
                        }
                        SongAlbumArt {
                            id: albumArt
                            song: app.player.currentSong
                        }
                        SongParametersInfo {
                            id: songParametersInfo
                            song: app.player.currentSong
                            visible: app.player.currentSong.songLoaded && app.player.currentSong.isTrackerSong && viewOption.selectedOption != samplesViewOption
                        }
                        SongDynamicInfo {
                            id: songDynamicInfo
                            song: app.player.currentSong
                            visible: app.player.currentSong.songLoaded && app.player.currentSong.isTrackerSong && viewOption.selectedOption != samplesViewOption
                        }
                        GroupContainer {
                            id: patternViewContainer
                            visible: app.player.currentSong.songLoaded && app.player.currentSong.isTrackerSong && viewOption.selectedOption == patternViewOption
                            PatternDisplay {}
                        }
                        InstrumentsView {
                            id: instrumentsView
                            navigationPane: songPlayer.navigationPane
                            visible: app.player.currentSong.songLoaded && app.player.currentSong.isTrackerSong && viewOption.selectedOption == samplesViewOption
                            maxHeight: 600
                            preferredHeight: 600
                        }
                    }
                }
            }
        }
        SleepTimerDisplay {}
        PlaylistControl {
            navigationPane: songPlayer.navigationPane
        }
        Mouse {
            id: mouse
        }
    }
    function addBuyButton() {
        if(!app.isExtendedVersion) {
            var buyActionItem = buyAppComponentDefinition.createObject()
            if(buyActionItem) {
                addAction(buyActionItem, ActionBarPlacement.InOverflow)
            }
        }
    }
    onCreationCompleted: {
        addBuyButton()
    }
    attachedObjects: [
        ComponentDefinition {
            id: buyAppComponentDefinition
            source: "BuyActionItem.qml"
        }
    ]
    actions: [
        PreviousActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        PlayActionItem {
            ActionBar.placement: ActionBarPlacement.Signature
        },
        NextActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        PauseActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        PlayModeActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        SameArtistActionItem {
            currentSong: app.player.currentSong
            navigationPane: songPlayer.navigationPane 
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        SameAlbumActionItem {
            currentSong: app.player.currentSong
            navigationPane: songPlayer.navigationPane 
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        InstrumentsActionItem {
            navigationPane: songPlayer.navigationPane
            enabled: app.player.currentSong.isTrackerSong
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        PatternsActionItem {
            navigationPane: songPlayer.navigationPane
            enabled: app.player.currentSong.isTrackerSong
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        AddFavouriteActionItem {
            currentSong: app.player.currentSong
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        RemoveFavouriteActionItem {
            currentSong: app.player.currentSong
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        AppendPlaylistActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            currentSong: app.player.currentSong
            songList: null
        },
        ShareSongActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            currentSong: app.player.currentSong
        },
        ImportSongsActionItem{
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        SaveSongActionItem{
            currentSong: app.player.currentSong.fileName
            enabled: app.player.currentSong.songLoaded && app.player.currentSong.id > 0
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        OpenSongActionItem{
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        EqualizerActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        SleepTimerActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        SettingsMenuAction {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        AppWorldActionItem{
            ActionBar.placement: ActionBarPlacement.InOverflow
        }
    ]
}
