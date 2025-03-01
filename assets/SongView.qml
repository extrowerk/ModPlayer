import bb.cascades 1.3
import player 1.0
import "functions.js" as Global

Page {
    id: songView
    property variant song
    property variant navigationPane
    Container {
        layout: DockLayout {
        }
        WallpaperView {
        }
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

                    visible: song != null
                    horizontalAlignment: HorizontalAlignment.Fill

                    SongMainInfo {
                        song: songView.song
                    }
                    SongArtistInfo {
                        song: songView.song
                    }
                    SongPersonalInfo {
                        song: songView.song
                        navigationPane: songView.navigationPane
                    }
                    SongPublicInfo {
                        song: songView.song
                        visible: songView.song && songView.song.isTrackerSong && songView.song.id > 0
                    }
                    SongParametersInfo {
                        song: songView.song
                        visible: songView.song && songView.song.isTrackerSong
                    }
                    SongAlbumArt {
                        id: albumArt
                        song: songView.song
                    }
                    Animation {
                        gestureHandlers: [
                            TapHandler {
                                onTapped: {
                                    mouse.showMouse()
                                }
                            }
                        ]
                        animations: [
                            ParallelAnimation {
                                id: logoAnimation
                                ScaleTransition {
                                    fromX: 0
                                    fromY: 0
                                    toX: 1.0
                                    toY: 1.0
                                    duration: 500
                                    easingCurve: StockCurve.CubicIn
                                }
                                FadeTransition {
                                    fromOpacity: 0.0
                                    toOpacity: 1.0
                                    duration: 650
                                    easingCurve: StockCurve.CubicIn
                                }
                            }
                        ]
                    }
                }
            }
        }
        SleepTimerDisplay {}
        PlaylistControl {
            navigationPane: songView.navigationPane
        }
        Mouse {
            id: mouse
        }
    }
    function load(songId) {
        song = app.player.catalog.resolveModuleById(songId, songView)
        if(song) {
            app.analytics.view(song.id, Global.fileNameOnly(song.fileName))
            logoAnimation.play()
        } else {
            console.log("Could not resolve song, id=" + songId)
        }
    }
    function showPlayer() {
        var view = songPlayer.createObject()
        if(view) {
          view.navigationPane = navigationPane
          navigationPane.push(view)
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
        var thisMainTabPane = mainTabPane
        var thisObject = songView
        app.player.requestPlayerView.connect(function() {
            if(thisMainTabPane.activePane == thisObject.navigationPane && thisObject.navigationPane.top == thisObject) {
                thisObject.showPlayer()
            }
        })
        addBuyButton()
    }
    attachedObjects: [
        ComponentDefinition {
            id: buyAppComponentDefinition
            source: "BuyActionItem.qml"
        },
        ComponentDefinition {
            id: songPlayer
            source: "SongPlayer.qml"
        }
    ]
    actions: [ 
        ActionItem {
            title: qsTr("Play") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/actions/icon_play.png"
            enabled: song != null
            ActionBar.placement: ActionBarPlacement.Signature
            shortcuts: Shortcut {
                key: "p"
            } 
            onTriggered: {
                if(song) {
                    app.player.playlist.assign(song.id)
                    app.player.playPlaylist()
                }
            }
        },
        AppendPlaylistActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
            currentSong: song
            songList: null
        },
        PauseActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        PreviousActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        NextActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        PlayerActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            navigationPane: songView.navigationPane
        },
        SameArtistActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            currentSong: song
            navigationPane: songView.navigationPane
        },
        SameAlbumActionItem {
            currentSong: song
            navigationPane: songView.navigationPane 
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        AddFavouriteActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            currentSong: song
        },
        RemoveFavouriteActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            currentSong: song
        },
        SaveSongActionItem{
            ActionBar.placement: ActionBarPlacement.InOverflow
            currentSong: song ? song.fileName : ""
        },
        ImportSongsActionItem{
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
