import bb.cascades 1.3
import player 1.0
import "functions.js" as Global

Page {
    id: songListPage
    property variant navigationPane
    property int maxResults
    property int requestId: 0
    property int listId: 0
    titleBar: PlayerTitleBar {
        id: titleBar
        title: {
            var c = songs.dataModel ? songs.dataModel.size() : 0
            if (c > maxResults) {
                c = "%1+".arg(maxResults)
            }
            if (songs.mode == 'recent') return qsTr("Recently Played Songs (%1)").arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'myFavourite') return qsTr("My Favourite Songs (%1)").arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'myLocal') return qsTr("Songs on My Device (%1)").arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'mostPlayed') return qsTr("Most Played Songs (%1)").arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'topFavourited') return qsTr("Top Favourited Songs (%1)").arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'topScored') return qsTr("Top Scored Songs (%1)").arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'topDownloads') return qsTr("Top Downloaded Songs (%1)").arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'format') return qsTr("%1 Songs (%2)").arg(songs.modelName).arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'genre') return qsTr("%1 Songs (%2)").arg(songs.modelName).arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'artist') return qsTr("Songs by %1 (%2)").arg(songs.modelName).arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'playlist') return qsTr("%1 Playlist Songs (%2)").arg(songs.modelName).arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'songAlbum') return qsTr("%1 Album Songs (%2)").arg(songs.modelName).arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'album') return qsTr("%1 Album Songs (%2)").arg(songs.modelName).arg(c) + Retranslate.onLanguageChanged
            if (songs.mode == 'search') {
                if (searchArea.searchTerm.length > 0) {
                    return qsTr("Search Songs (%1) - '%2'").arg(c).arg(searchArea.searchTerm) + Retranslate.onLanguageChanged
                }
                return qsTr("Search Songs (%1)").arg(c) + Retranslate.onLanguageChanged
            }
            return qsTr("All Songs (%1)").arg(c) + Retranslate.onLanguageChanged
        }
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {
            TitleBarText {
                title: titleBar.title
            }
            expandableArea {
                content: SearchArea {
                    id: searchArea
                    hintText: qsTr("search songs") + Retranslate.onLanguageChanged
                    onSearch: {
                        songListPage.unload()
                        songListPage.load()
                    }
                }
                expanded: true
                indicatorVisibility: TitleBarExpandableAreaIndicatorVisibility.Visible
                toggleArea: TitleBarExpandableAreaToggleArea.EntireTitleBar
            }
        }
    }
    Container {
        layout: DockLayout {}
        WallpaperView {}
        HorizontalContainer {
            id: listEmpty
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layout: DockLayout {}
            Label {
                text: qsTr("No songs in this list") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle {
                    fontWeight: FontWeight.Bold
                    fontSize: FontSize.Large
                    color: Color.White
                }
            }
        }
        ProgressComponent {
            id: progress
        }
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            leftPadding: 15
            rightPadding: 15
            ListView {
                id: songs
                property string mode
                property string modelName
                visible: false
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: 20
                bottomPadding: 20

                function updateList() {
                    if (mode == 'playlist') {
                        loadSongsByPlaylist(listId, modelName)
                    } else if (mode == 'album') {
                        loadSongsByAlbum(listId, modelName)
                    }
                }
                function playSong(song) {
                    app.player.playlist.assign(song.id)
                    app.player.playPlaylist()
                }
                function addFavourite(song) {
                    app.catalog.addFavourite(song)
                }
                function removeFavourite(song) {
                    app.catalog.removeFavourite(song)
                }
                function deleteSongFromPlaylist(song) {
                    app.catalog.deleteSongFromPlaylist(listId, song.id)
                }
                function getRootObject() {
                    return app
                }
                multiSelectAction: MultiSelectActionItem {
                }
                multiSelectHandler {
                    actions: [
                        AppendPlaylistActionItem {
                            songList: songs
                            rootObject: songs.getRootObject()
                        }
                    ]
                    status: qsTr("No songs in this list") + Retranslate.onLanguageChanged
                }
                onSelectionChanged: {
                    multiSelectHandler.status = qsTr("%1 songs").arg(selectionList().length)
                }
                listItemComponents: [
                    ListItemComponent {
                        ModPlayerListItem {
                            id: songEntry
                            playing: {
                                return ListItem !== undefined && 
                                        ListItem.data !== undefined && 
                                        ListItem.view !== undefined && 
                                        ListItem.data.id == ListItem.view.getRootObject().player.currentSong.id && 
                                        ListItem.view.getRootObject().player.state == Player.Playing
                            }
                            paused: {
                                return ListItem !== undefined && 
                                       ListItem.data !== undefined && 
                                       ListItem.view !== undefined && 
                                       ListItem.data.id == ListItem.view.getRootObject().player.currentSong.id && 
                                       ListItem.view.getRootObject().player.state == Player.Paused
                            }
                            showAsSelected: ListItem.selected
                            implicitLayoutAnimationsEnabled: false
                            favouriteScore: ListItem.data.myFavourite
                            title: ListItem.data.title
                            description: Global.fileNameOnly(ListItem.data.fileName)
                            text: "%1   (%2)".arg(ListItem.data.songLengthText).arg(Global.getSizeKb(ListItem.data.fileSize))
                            upperStatus: {
                                var mode = ListItem.view.mode
                                if (ListItem.data) {
                                    if (mode == "recent") {
                                        if (ListItem.data.lastPlayed > 0) {
                                            return Global.formatTimeStamp(ListItem.data.lastPlayed)
                                        }
                                    }
                                    if (mode == "myFavourite" || 
                                        mode == "mostPlayed" || 
                                        mode == "myLocal") {
                                        if (ListItem.data.playCount > 0) {
                                            return "played " + (ListItem.data.playCount == 1 ? "once" : (ListItem.data.playCount + " times"))
                                        }
                                    }
                                    if (mode == "topFavourited") {
                                        if (ListItem.data.favourited > 0) {
                                            return qsTr("favourited %1 times").arg(ListItem.data.favourited) + Retranslate.onLanguageChanged
                                        }
                                    }
                                    if (mode == "topScored" || 
                                        mode == "format" || 
                                        mode == "genre" || 
                                        mode == "artist" || 
                                        mode == "playlist" ||
                                        mode == "album" ||
                                        mode == "songAlbum") {
                                        if (ListItem.data.score > 0) {
                                            return qsTr("score %1 of 10").arg(ListItem.data.score) + Retranslate.onLanguageChanged
                                        }
                                    }
                                    if (mode == "topDownloads" || mode == "search") {
                                        if (ListItem.data.downloads > 0) {
                                            return qsTr("%1 downloads").arg(ListItem.data.downloads) + Retranslate.onLanguageChanged
                                        }
                                    }
                                }
                                return ""
                            }
                            middleStatus: {
                                var mode = ListItem.view.mode
                                if (ListItem.data) {
                                    if (mode == "topDownloads" || 
                                        mode == "topFavourited" || 
                                        mode == "search") {
                                        if (ListItem.data.score > 0) {
                                            return qsTr("score %1 of 10").arg(ListItem.data.score) + Retranslate.onLanguageChanged
                                        }
                                    }
                                    if (mode == "topScored") {
                                        if (ListItem.data.downloads > 0) {
                                            return qsTr("%1 downloads").arg(ListItem.data.downloads) + Retranslate.onLanguageChanged
                                        }
                                    }
                                    if (mode == "format" || 
                                        mode == "genre" || 
                                        mode == "artist" || 
                                        mode == "playlist" || 
                                        mode == "album" ||
                                        mode == "songAlbum") {
                                        if (ListItem.data.favourited > 0) {
                                            return qsTr("favourited %1 times").arg(ListItem.data.favourited) + Retranslate.onLanguageChanged
                                        }
                                    }
                                }
                                return ""
                            }
                            lowerStatus: {
                                var mode = ListItem.view.mode
                                if (ListItem.data) {
                                    if (mode == "recent") {
                                        if (ListItem.data.playCount > 0) {
                                            return "played " + (ListItem.data.playCount == 1 ? "once" : (ListItem.data.playCount + " times"))
                                        }
                                    }
                                    if (mode == "myFavourite" || 
                                        mode == "mostPlayed" || 
                                        mode == "myLocal") {
                                        if (ListItem.data.lastPlayed > 0) {
                                            return Global.formatTimeStamp(ListItem.data.lastPlayed)
                                        }
                                    }
                                    if (mode == "topFavourited" || 
                                        mode == "format" || 
                                        mode == "genre" || 
                                        mode == "artist" || 
                                        mode == "playlist" || 
                                        mode == "album" ||
                                        mode == "songAlbum") {
                                        if (ListItem.data.downloads > 0) {
                                            return qsTr("%1 downloads").arg(ListItem.data.downloads) + Retranslate.onLanguageChanged
                                        }
                                    }
                                    if (mode == "topScored" || 
                                        mode == "topDownloads" || 
                                        mode == "search") {
                                        if (ListItem.data.favourited > 0) {
                                            return qsTr("favourited %1 times").arg(ListItem.data.favourited) + Retranslate.onLanguageChanged
                                        }
                                    }
                                }
                                return ""
                            }
                            imageSource: ListItem.data ? ListItem.data.iconPath : ""
                            contextActions: [
                                ActionSet {
                                    title: songEntry.ListItem.data.title
                                    subtitle: Global.fileNameOnly(songEntry.ListItem.data.fileName)
                                    actions: [
                                        ActionItem {
                                            title: qsTr("Play") + Retranslate.onLanguageChanged
                                            imageSource: "asset:///images/actions/icon_play.png"
                                            onTriggered: {
                                                songEntry.ListItem.view.playSong(songEntry.ListItem.data)
                                            }
                                        },
                                        AppendPlaylistActionItem {
                                            currentSong: songEntry.ListItem.data
                                            songList: null
                                            rootObject: songEntry.ListItem.view.getRootObject()
                                        },
                                        ActionItem {
                                            title: qsTr("Add to Favourites") + Retranslate.onLanguageChanged
                                            imageSource: "asset:///images/actions/icon_like.png"
                                            onTriggered: {
                                                songEntry.ListItem.view.addFavourite(songEntry.ListItem.data)
                                            }
                                        },
                                        ActionItem {
                                            title: qsTr("Remove from Favourites") + Retranslate.onLanguageChanged
                                            imageSource: "asset:///images/actions/icon_unlike.png"
                                            onTriggered: {
                                                songEntry.ListItem.view.removeFavourite(songEntry.ListItem.data)
                                            }
                                        },
                                        DeleteActionItem {
                                            enabled: songEntry.ListItem.view.mode == 'playlist'
                                            onTriggered: {
                                                songEntry.ListItem.view.deleteSongFromPlaylist(songEntry.ListItem.data)
                                                songEntry.ListItem.view.updateList()
                                            }
                                        }
                                    ]
                                }
                            ]
                            function viewInitialized(initialized) {
                                if(initialized) {
                                    scaleX = 0
                                    scaleY = 0
                                    listItemAnimation.play()
                                }
                            }
                            onCreationCompleted: {
                                ListItem.initializedChanged.connect(viewInitialized)
                            }
                            animations: [
                                ParallelAnimation {
                                    id: listItemAnimation
                                    FadeTransition {
                                        fromOpacity: 0.0
                                        toOpacity: 1.0
                                        duration: 600
                                        easingCurve: StockCurve.Linear
                                    }
                                    ScaleTransition {
                                        toX: 1.0
                                        toY: 1.0
                                        fromX: 0.0
                                        fromY: 0.0
                                        duration: 600
                                        easingCurve: StockCurve.CubicInOut
                                    }
                                }
                            ]
                        }
                    }
                ]
                onTriggered: {
                    var chosenItem = dataModel.data(indexPath)
                    var view = songView.createObject()
                    if(view) {
                        view.navigationPane = navigationPane
                        view.load(chosenItem.id)
                        navigationPane.push(view)
                    } else {
                        console.log("Could not create SongView")
                    }
                }
                attachedObjects: [
                    ComponentDefinition {
                        id: songView
                        source: "SongView.qml"
                    }
                ]
                animations: [
                    ParallelAnimation {
                        id: listAnimation
                        TranslateTransition {
                            fromY: 1200.0
                            toY: 0.0
                            duration: 500
                            easingCurve: StockCurve.CircularOut
                        }
                        FadeTransition {
                            fromOpacity: 0.0
                            toOpacity: 1.0
                            duration: 300
                            easingCurve: StockCurve.Linear
                        }
                    }
                ]
            }
        }
        SleepTimerDisplay {}
        PlaylistControl {
            navigationPane: songListPage.navigationPane
        }
        FirstLaunchHint{}
    }
    function unload() {
        progress.start()
        songs.visible = false
        listEmpty.visible = false
        if (songs.dataModel) {
            songs.dataModel.clear()
        }
        songs.resetDataModel()
    }
    function load() {
        unload();
        maxResults = searchArea.searchTerm.length > 0 ? 500 : app.maxViewSongs
        requestId = {
            search: function(searchTerm, queryId, limit) {
                return app.player.catalog.searchSongsAsync(searchTerm, limit)
            },
            recent: function(searchTerm, queryId, limit) {
                return app.player.catalog.findRecentlyPlayedSongsAsync(searchTerm, limit)
            },
            myFavourite: function(searchTerm, queryId, limit) {
                return app.player.catalog.findMyFavouriteSongsAsync(searchTerm, limit)
            },
            myLocal: function(searchTerm, queryId, limit) {
                return app.player.catalog.findMyLocalSongsAsync(searchTerm, limit)
            },
            mostPlayed: function(searchTerm, queryId, limit) {
                return app.player.catalog.findMostPlayedSongsAsync(searchTerm, limit)
            },
            topFavourited: function(searchTerm, queryId, limit) {
                return app.player.catalog.findMostFavouritedSongsAsync(searchTerm, limit)
            },
            topScored: function(searchTerm, queryId, limit) {
                return app.player.catalog.findMostScoredSongsAsync(searchTerm, limit)
            },
            topDownloads: function(searchTerm, queryId, limit) {
                return app.player.catalog.findMostDownloadedSongsAsync(searchTerm, limit)
            },
            format: function(searchTerm, queryId, limit) {
                return app.player.catalog.findSongsByFormatIdAsync(searchTerm, queryId, limit)
            },
            genre: function(searchTerm, queryId, limit) {
                return app.player.catalog.findSongsByGenreIdAsync(searchTerm, queryId, limit)
            },
            artist: function(searchTerm, queryId, limit) {
                return app.player.catalog.findSongsByArtistIdAsync(searchTerm, queryId, limit)
            },
            playlist: function(searchTerm, queryId, limit) {
                return app.player.catalog.findSongsByPlaylistIdAsync(searchTerm, queryId, limit)
            },
            album: function(searchTerm, queryId, limit) {
                return app.player.catalog.findSongsByAlbumIdAsync(searchTerm, queryId, limit)
            },
            songAlbum: function(searchTerm, queryId, limit) {
                return app.player.catalog.findSongsBySongAlbumIdAsync(searchTerm, queryId, limit)
            }
        }[songs.mode](searchArea.searchTerm, listId, maxResults)
    }
    function loadRecentlyPlayedSongs() {
        listId = 0
        songs.mode = "recent"
        songs.modelName = ""
        load()
    }
    function loadMyFavouriteSongs() {
        listId = 0
        songs.mode = "myFavourite"
        songs.modelName = ""
        load()
    }
    function loadMyLocalSongs() {
        listId = 0
        songs.mode = "myLocal"
        songs.modelName = ""
        load()
    }
    function loadMostPlayedSongs() {
        listId = 0
        songs.mode = "mostPlayed"
        songs.modelName = ""
        load()
    }
    function loadMostFavouritedSongs() {
        listId = 0
        songs.mode = "topFavourited"
        songs.modelName = ""
        load()
    }
    function loadMostScoredSongs() {
        listId = 0
        songs.mode = "topScored"
        songs.modelName = ""
        load()
    }
    function loadMostDownloadedSongs() {
        listId = 0
        songs.mode = "topDownloads"
        songs.modelName = ""
        load()
    }
    function loadSearchSongs() {
        listId = 0
        songs.mode = "search"
        songs.modelName = ""
        load()
    }
    function loadSongsByFormat(formatId, formatName) {
        listId = formatId
        songs.mode = "format"
        songs.modelName = formatName
        load()
    }
    function loadSongsByGenre(genreId, genreName) {
        listId = genreId
        songs.mode = "genre"
        songs.modelName = genreName
        load()
    }
    function loadSongsByArtist(artistId, artistName) {
        listId = artistId
        songs.mode = "artist"
        songs.modelName = artistName
        load()
    }
    function loadSongsBySongAlbum(songId) {
        listId = songId
        songs.mode = "songAlbum"
        songs.modelName = app.catalog.resolveAlbumNameBySongId(songId)
        load()
    }
    function loadSongsByPlaylist(playlistId, playlistName) {
        listId = playlistId
        songs.mode = "playlist"
        songs.modelName = playlistName
        load()
    }
    function loadSongsByAlbum(albumId, albumName) {
        listId = albumId
        songs.mode = "album"
        songs.modelName = albumName
        load()
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
        var thisObject = songListPage
        var thisSongs = songs
        var thisProgress = progress
        var thisListEmpty = listEmpty
        var thisListAnimation = listAnimation
        app.player.requestPlayerView.connect(function() {
            if(thisMainTabPane.activePane == thisObject.navigationPane && thisObject.navigationPane.top == thisObject) {
                thisObject.showPlayer()
            }
        })
        app.catalog.resultReady.connect(function(responseId, result) {
            if (responseId != thisObject.requestId)
                return
            thisObject.requestId = 0
            thisSongs.dataModel = result
            thisProgress.stop()
            thisSongs.visible = (thisSongs.dataModel.size() > 0)
            if(thisSongs.visible) {
                thisListAnimation.play()
            }
            thisListEmpty.visible = (thisSongs.dataModel.size() == 0)
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
        PlayerActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
            navigationPane: songListPage.navigationPane
        },
        PlayAllActionItem {
            id: playAllActionItem
            ActionBar.placement: ActionBarPlacement.Signature
            songList: songs.dataModel
        },
        PlayActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        NextActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        PreviousActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        PauseActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        AppendPlaylistActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            songList: songs
            currentSong: null
        },
        PlayModeActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        },
        ImportSongsActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            onCompleted: {
                load()
            }
        },
        OpenSongActionItem {
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
        AppWorldActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
        }
    ]
}
