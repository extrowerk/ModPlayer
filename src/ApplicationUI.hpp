#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <QVariant>
#include <QUrl>
#include <QSettings>
#include <bb/ProcessState>
#include "Wallpaper.hpp"
#include "PurchaseStore.hpp"
#include "FileSystem.hpp"
#include "Proximity.hpp"
#include "Shake.hpp"

namespace bb
{
    namespace cascades
    {
        class Application;
        class LocaleHandler;
    }
    namespace system
    {
        class InvokeManager;
        class InvokeRequest;
    }
}

class QTranslator;
class Analytics;
class Player;
class Catalog;
class Cache;
class Wallpaper;

class ApplicationUI : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(ApplicationUI)
    Q_PROPERTY(int screenWidth READ screenWidth NOTIFY screenWidthChanged FINAL)
    Q_PROPERTY(int screenHeight READ screenHeight NOTIFY screenHeightChanged FINAL)
    Q_PROPERTY(bool keepScreenAwake READ keepScreenAwake WRITE setKeepScreenAwake NOTIFY keepScreenAwakeChanged FINAL)
    Q_PROPERTY(bool isFirstLaunch READ isFirstLaunch WRITE setFirstLaunch NOTIFY isFirstLaunchChanged FINAL)
    Q_PROPERTY(bool isExtendedVersion READ isExtendedVersion NOTIFY isExtendedVersionChanged FINAL)
    Q_PROPERTY(bool isForeground READ isForeground NOTIFY isForegroundChanged FINAL)
    Q_PROPERTY(bool proximitySensorEnabled READ isProximitySensorEnabled WRITE setProximitySensorEnabled NOTIFY proximitySensorEnabledChanged FINAL)
    Q_PROPERTY(bool shakeSensorEnabled READ isShakeSensorEnabled WRITE setShakeSensorEnabled NOTIFY shakeSensorEnabledChanged FINAL)
    Q_PROPERTY(int maxViewSongs READ maxViewSongs WRITE setMaxViewSongs NOTIFY maxViewSongsChanged FINAL)
    Q_PROPERTY(int scrollAnimationType READ scrollAnimationType WRITE setScrollAnimationType NOTIFY scrollAnimationTypeChanged FINAL)
    Q_PROPERTY(QString initialView READ initialView WRITE setInitialView NOTIFY initialViewChanged FINAL)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged FINAL)
    Q_PROPERTY(QString version READ version NOTIFY versionChanged FINAL)
    Q_PROPERTY(Player* player READ player NOTIFY playerChanged FINAL)
    Q_PROPERTY(Catalog* catalog READ catalog NOTIFY catalogChanged FINAL)
    Q_PROPERTY(Cache* cache READ cache NOTIFY cacheChanged FINAL)
    Q_PROPERTY(Wallpaper* wallpaper READ wallpaper NOTIFY wallpaperChanged FINAL)
    Q_PROPERTY(PurchaseStore* store READ store NOTIFY storeChanged FINAL)
    Q_PROPERTY(FileSystem* fileSystem READ fileSystem NOTIFY fileSystemChanged FINAL)
    Q_PROPERTY(Analytics* analytics READ analytics NOTIFY analyticsChanged FINAL)
public:
    ApplicationUI(bb::cascades::Application *app);
    ~ApplicationUI();

    static ApplicationUI& instance();

    int screenWidth() const;
    int screenHeight() const;

    bool isFirstLaunch() const;
    bool isExtendedVersion();
    bool isForeground() const;

    // Proximity Sensor
    bool isProximitySensorEnabled() const;
    void setProximitySensorEnabled(bool value);

    // Shake Sensor
    bool isShakeSensorEnabled() const;
    void setShakeSensorEnabled(bool value);

    // Screen Dimming
    bool keepScreenAwake() const;
    void setKeepScreenAwake(bool value);

    int maxViewSongs() const;
    int scrollAnimationType() const;

    // Object Properties
    QString initialView() const;
    void setInitialView(QString const& view);

    QString title() const;
    QString version() const;
    Player * player() const;
    Catalog * catalog() const;
    Cache * cache() const;
    Analytics * analytics() const;
    Wallpaper * wallpaper();
    PurchaseStore * store();
    FileSystem * fileSystem();

    void setFirstLaunch(bool value);
    void setMaxViewSongs(int value);
    void setScrollAnimationType(int value);

    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void emailAuthor();
    Q_INVOKABLE void twit();
    Q_INVOKABLE void bbm();
    Q_INVOKABLE void appWorld();
    Q_INVOKABLE void shareSong(QString const& fileName);
    Q_INVOKABLE void updateScreen();
    Q_INVOKABLE void pleaseBuy();

    static const char * QmlNamespace;
Q_SIGNALS:
    void screenWidthChanged();
    void screenHeightChanged();
    void keepScreenAwakeChanged();
    void isFirstLaunchChanged();
    void isExtendedVersionChanged();
    void isForegroundChanged();
    void proximitySensorEnabledChanged();
    void shakeSensorEnabledChanged();
    void maxViewSongsChanged();
    void scrollAnimationTypeChanged();
    void initialViewChanged();
    void titleChanged();
    void versionChanged();
    void playerChanged();
    void catalogChanged();
    void cacheChanged();
    void wallpaperChanged();
    void storeChanged();
    void analyticsChanged();
    void fileSystemChanged();
private slots:
    void onInvoked(const bb::system::InvokeRequest& invoke);
    void onCloseProximity();
    void onShakeDetected();
    void onSystemLanguageChanged();
    void onCatalogChanged();
    void onCacheChanged();
    void onAboutToQuit();
    void onProcessStateChanged(bb::ProcessState::Type);
    void onPurchaseStateChanged();
private:
    void initScreen();
    void initPurchases();
    void initSignals();
    void initTypes();
    void initApp();
    void initCatalog();
    void initActiveCover();
    void initPlayer();
    void initProximity();
    void initShake();
    void initTranslator();
    void saveWallpaperSettings();
private:
    static ApplicationUI        *static_instance;
    bb::ProcessState::Type       m_appState;
    QSettings                    m_settings;
    QTranslator                 *m_pTranslator;
    PurchaseStore                m_purchaseStore;
    Wallpaper                    m_wallpaper;
    QSize                        m_screenPixelSize;
    bb::cascades::LocaleHandler *m_pLocaleHandler;
    bb::cascades::Application   *m_app;
    Player                      *m_player;
    Analytics                   *m_analytics;
    FileSystem                  *m_fileSystem;
    Proximity                   *m_proximity;
    Shake                       *m_shake;
    bb::system::InvokeManager   *m_invokeManager;
};

#endif
