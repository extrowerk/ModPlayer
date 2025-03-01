import bb.cascades 1.3
import player 1.0
import bb.cascades.pickers 1.0

VerticalContainer {
    horizontalAlignment: HorizontalAlignment.Center
    MultilineCheckBox {
        id: animationEnabled
        text: qsTr("Enable Background Animation") + Retranslate.onLanguageChanged
        checked: app.player.playback.configuration.animationEnabled
        visible: backgroundOption.isWallpaper
        onCheckedChanged: {
            app.player.playback.configuration.animationEnabled = checked
        }
    }
    PlusFeature {
        extendedVersion: VerticalContainer {
            DropDown {
                title: qsTr("Theme") + Retranslate.onLanguageChanged
                Option {
                    text: qsTr("Bright") + Retranslate.onLanguageChanged
                    value: VisualStyle.Bright
                    selected: Application.themeSupport.theme.colorTheme.style == VisualStyle.Bright 
                }
                Option {
                    text: qsTr("Dark") + Retranslate.onLanguageChanged
                    value: VisualStyle.Dark
                    selected: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark
                }
                onSelectedValueChanged: {
                    Application.themeSupport.setVisualStyle(selectedValue)
                }
            }
            SegmentedControl {
                id: backgroundOption
                property bool isWallpaper: selectedOption.value == 0
                property bool isColor: selectedOption.value == 1
                enabled: app.isExtendedVersion
                Option {
                    text: qsTr("Wallpaper") + Retranslate.onLanguageChanged
                    value: 0
                }
                Option {
                    text: qsTr("Color") + Retranslate.onLanguageChanged
                    value: 1
                }
                onCreationCompleted: {
                    selectedIndex = app.wallpaper.solidColor ? 1 : 0
                }
                onSelectedValueChanged: {
                    app.wallpaper.solidColor = (selectedValue == 1)
                }
            }
            VerticalContainer {
                horizontalAlignment: HorizontalAlignment.Center
                leftPadding: 20
                rightPadding: 20
                topMargin: 60
                DropDown {
                    title: qsTr("Background") + Retranslate.onLanguageChanged
                    enabled: app.isExtendedVersion
                    visible: backgroundOption.isWallpaper
                    property variant allWallpapers: [
                        {
                            name: "ModPlayer Classic",
                            path:"asset:///images/backgrounds/view_back.amd", 
                            repeatable: true, 
                            animatable: true
                        },
                        {
                            name: "Purple",
                            path:"asset:///images/wallpapers/purple.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Infinity",
                            path:"asset:///images/wallpapers/infinity.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Sparkle",
                            path:"asset:///images/wallpapers/sparkle.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Chroma",
                            path:"asset:///images/wallpapers/chroma.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Yellow",
                            path:"asset:///images/wallpapers/yellow.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Sound",
                            path:"asset:///images/wallpapers/sound.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Grid",
                            path:"asset:///images/wallpapers/grid.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Dark Grid",
                            path:"asset:///images/wallpapers/dark_grid.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Plaid Blue Modern",
                            path:"asset:///images/wallpapers/plaidbluemodern.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Denim",
                            path:"asset:///images/wallpapers/denim.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Rainbow",
                            path:"asset:///images/wallpapers/rainbow.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Aurora",
                            path:"asset:///images/wallpapers/aurora.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Digital",
                            path:"asset:///images/wallpapers/digital.jpg",
                            repeatable: false,
                            animatable: true
                        },
                        {
                            name: "Flower",
                            path:"asset:///images/wallpapers/flower.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Green Grass",
                            path:"asset:///images/wallpapers/grass.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Water",
                            path:"asset:///images/wallpapers/water.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Crystals",
                            path:"asset:///images/wallpapers/crystals.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Drops",
                            path:"asset:///images/wallpapers/drops.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Dawn",
                            path:"asset:///images/wallpapers/dawn.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Dolphins",
                            path:"asset:///images/wallpapers/dolphins.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Plasma",
                            path:"asset:///images/wallpapers/plasma.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Aluminium",
                            path:"asset:///images/wallpapers/aluminium.amd",
                            repeatable: true,
                            animatable: false
                        },
                        {
                            name: "Linen",
                            path:"asset:///images/wallpapers/linen.amd",
                            repeatable: true,
                            animatable: false
                        },
                        {
                            name: "Blueprint",
                            path:"asset:///images/wallpapers/blueprint.amd",
                            repeatable: true,
                            animatable: false
                        },
                        {
                            name: "Dark Tile",
                            path:"asset:///images/wallpapers/dark-tile.amd",
                            repeatable: true,
                            animatable: false
                        },
                        {
                            name: "Carbon",
                            path:"asset:///images/wallpapers/carbon.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Cork",
                            path:"asset:///images/wallpapers/cork.amd",
                            repeatable: true,
                            animatable: false
                        },
                        {
                            name: "Asphalt",
                            path:"asset:///images/wallpapers/asphalt.amd",
                            repeatable: true,
                            animatable: true
                        },
                        {
                            name: "Waves",
                            path:"asset:///images/wallpapers/waves.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Clouds",
                            path:"asset:///images/wallpapers/clouds.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Wood",
                            path:"asset:///images/wallpapers/wood.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Green",
                            path:"asset:///images/wallpapers/green.amd",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Blue",
                            path:"asset:///images/wallpapers/blue.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "ModPlayer",
                            path:"asset:///images/wallpapers/modplayer.amd",
                            repeatable: true,
                            animatable: true
                        },
                        {
                            name: "Abstract",
                            path:"asset:///images/wallpapers/abstract.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Jeans",
                            path:"asset:///images/wallpapers/jeans.amd",
                            repeatable: true,
                            animatable: false
                        },
                        {
                            name: "Rock",
                            path:"asset:///images/wallpapers/rock.amd",
                            repeatable: true,
                            animatable: true
                        },
                        {
                            name: "Techno",
                            path:"asset:///images/wallpapers/techno.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Stars",
                            path:"asset:///images/wallpapers/stars.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Metal Hole",
                            path:"asset:///images/wallpapers/metalhole.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Binary Code",
                            path:"asset:///images/wallpapers/binarycode.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Digital Space",
                            path:"asset:///images/wallpapers/digitalspace.jpg",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Stripes",
                            path:"asset:///images/wallpapers/stripes.amd",
                            repeatable: true,
                            animatable: true
                        },
                        {
                            name: "BlackBerry",
                            path:"asset:///images/wallpapers/bb.amd",
                            repeatable: true,
                            animatable: true
                        },
                        {
                            name: "BlackBerries",
                            path:"asset:///images/wallpapers/berries.png",
                            repeatable: false,
                            animatable: false
                        },
                        {
                            name: "Coffee",
                            path:"asset:///images/wallpapers/coffee.amd",
                            repeatable: true,
                            animatable: true
                        },
                        {
                            name: "Custom",
                            path:"",
                            repeatable: false,
                            animatable: false
                        }
                    ]
                    attachedObjects: [
                        ComponentDefinition {
                            id: optionDefinition
                            Option {
                                imageSource: "asset:///images/objects/wallpaper.png"
                            }
                        }
                    ]
                    onCreationCompleted: {
                        var items = allWallpapers.slice(0)
                        for(var i = 0; i < items.length; ++i) {
                            items[i].index = i
                        }
                        items.sort(function(a,b) { 
                            return a.name.localeCompare(b.name)
                        })
                        var selectedName = app.wallpaper.name
                        for(var i = 0; i < items.length; ++i) {
                            var newOption = optionDefinition.createObject()
                            newOption.text = items[i].name
                            if(newOption.text == "Custom") {
                                items[i].path = app.wallpaper.path
                            }
                            newOption.value = items[i].index
                            if(selectedName == items[i].name) {
                                newOption.selected = true
                            }
                            add(newOption)
                        }
                    }
                    onSelectedValueChanged: {
                        if(!app.wallpaper.solidColor) {
                            app.wallpaper.name = selectedOption.text
                            if(app.wallpaper.name == "Custom") {
                                app.wallpaper.repeatable = false
                                app.wallpaper.animatable = false
                            } else {
                                app.wallpaper.path = allWallpapers[selectedValue].path
                                app.wallpaper.repeatable = allWallpapers[selectedValue].repeatable
                                app.wallpaper.animatable = allWallpapers[selectedValue].animatable
                            }
                            app.wallpaper.solidColor = false
                            app.saveSettings()
                        }
                    }
                }
                DropDown {
                    title: qsTr("Scaling") + Retranslate.onLanguageChanged
                    enabled: app.isExtendedVersion
                    visible: backgroundOption.isWallpaper 
                    Option {
                        text: qsTr("Fill") + Retranslate.onLanguageChanged
                        value: 2
                        description: qsTr("Stretch wallpaper to fit whole screen") + Retranslate.onLanguageChanged
                        selected: app.wallpaper.stretchMode == 2 
                    }
                    Option {
                        text: qsTr("Aspect Fit") + Retranslate.onLanguageChanged
                        value: 0
                        description: qsTr("Fit wallpaper and preserve aspect ratio") + Retranslate.onLanguageChanged
                        selected: app.wallpaper.stretchMode == 0 
                    }
                    Option {
                        text: qsTr("Aspect Fill") + Retranslate.onLanguageChanged
                        value: 1
                        description: qsTr("Resize wallpaper preserve the aspect ratio") + Retranslate.onLanguageChanged
                        selected: app.wallpaper.stretchMode == 1 
                    }
                    Option {
                        text: qsTr("None") + Retranslate.onLanguageChanged
                        value: 3
                        description: qsTr("Do not scale wallpaper") + Retranslate.onLanguageChanged
                        selected: app.wallpaper.stretchMode == 3 
                    }
                    onSelectedValueChanged: {
                        app.wallpaper.stretchMode = selectedValue
                        app.saveSettings()
                    }
                }
                Button {
                    horizontalAlignment: HorizontalAlignment.Center
                    topMargin: 60
                    text: qsTr("Browse for wallpaper") + Retranslate.onLanguageChanged
                    enabled: app.isExtendedVersion
                    visible: backgroundOption.isWallpaper
                    onClicked: {
                        if(app.isExtendedVersion)
                            wallpaperBrowser.open()
                    }
                    attachedObjects: [
                        FilePicker {
                            id: wallpaperBrowser
                            type: FileType.Picture
                            title: qsTr("Browse for wallpaper") + Retranslate.onLanguageChanged
                            onFileSelected: {
                                if(selectedFiles.length == 1) {
                                    var fileName = selectedFiles[0]
                                    app.wallpaper.name = "Custom"
                                    app.wallpaper.path = "file://" + fileName
                                    app.wallpaper.repeatable = false
                                    app.wallpaper.animatable = false
                                    app.saveSettings()
                                }
                            }
                        }
                    ]
                }
                Container {
                    horizontalAlignment: HorizontalAlignment.Center
                    background: Color.Black
                    topMargin: 40
                    preferredHeight: 64
                    preferredWidth: 128
                    minWidth: 64
                    maxHeight: 128
                    visible: backgroundOption.isColor
                    topPadding: 4
                    bottomPadding: 4
                    rightPadding: 4
                    leftPadding: 4
                    enabled: app.isExtendedVersion
                    Container {
                        background: Color.create(app.wallpaper.color)
                        preferredHeight: 64
                        preferredWidth: 128
                        minWidth: 64
                        maxHeight: 128
                    }
                }
                Button {
                    horizontalAlignment: HorizontalAlignment.Center
                    topMargin: 40
                    text: qsTr("Browse for color") + Retranslate.onLanguageChanged
                    enabled: app.isExtendedVersion
                    visible: backgroundOption.isColor
                    onClicked: selectColorSheet.createObject().open()
                    attachedObjects: [
                        ComponentDefinition {
                            id: selectColorSheet
                            source: "SelectColor.qml"
                        }
                    ]
                }
            }
        }
    }
}
