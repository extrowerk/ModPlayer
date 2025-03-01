#ifndef PATTERNVIEW_HPP_
#define PATTERNVIEW_HPP_

#include <bb/cascades/CustomControl>
#include <bb/cascades/Image>
#include "Canvas.hpp"
#include "SongModule.hpp"
#include "TouchHandler.hpp"
#include "InstanceCounter.hpp"

namespace bb {
    namespace cascades {
        class Container;
        class ImageView;
        class TouchEvent;
    }
}

class PatternView : public bb::cascades::CustomControl,
                    public InstanceCounter<PatternView>
{
    Q_OBJECT
public:
    PatternView(bb::cascades::Container *parent = 0);

    Q_PROPERTY(QVariant song READ song WRITE setSong NOTIFY songChanged FINAL)
    Q_PROPERTY(int visibleChannels READ visibleChannels WRITE setVisibleChannels NOTIFY visibleChannelsChanged FINAL)
    Q_PROPERTY(int firstChannel READ firstChannel WRITE setFirstChannel NOTIFY firstChannelChanged FINAL)

    Q_PROPERTY(bool previousChannelEnabled READ previousChannelEnabled NOTIFY previousChannelEnabledChanged FINAL)
    Q_PROPERTY(bool nextChannelEnabled READ nextChannelEnabled NOTIFY nextChannelEnabledChanged FINAL)

    QVariant song() const;
    void setSong(QVariant value);

    int visibleChannels() const;
    void setVisibleChannels(int value);

    int firstChannel() const;
    void setFirstChannel(int value);

    bool previousChannelEnabled() const;
    bool nextChannelEnabled() const;

    Q_INVOKABLE void previousChannel();
    Q_INVOKABLE void nextChannel();

    using InstanceCounter<PatternView>::getInstanceCount;
    using InstanceCounter<PatternView>::getMaxInstanceCount;
Q_SIGNALS:
    void songChanged();
    void visibleChannelsChanged();
    void firstChannelChanged();
    void previousChannelEnabledChanged();
    void nextChannelEnabledChanged();
private slots:
    void onSongLoadedChanged();
    void onChannelsChanged();
    void onCurrentRowChanged();
    void onCurrentPatternChanged();
    void onPatternTap(int x, int y);
private:
    void createPatternView();
    void updateCanvas();
private:
    Q_DISABLE_COPY(PatternView)
    bb::cascades::Container * m_rootContainer;
    bb::cascades::Container * m_cursor;
    bb::cascades::ImageView * m_patternImage;
    SongModule * m_song;
    Canvas * m_canvas;
    TouchHandler * m_touchHandler;
    int m_firstChannel;
    int m_numVisibleChannels;

    static const int m_charsPerChannel;
    static const int m_indent;
    static const int m_fontScale;
    static const int m_fontWidth;
    static const int m_fontHeight;
};

Q_DECLARE_METATYPE(PatternView*);

#endif /* PATTERNVIEW_HPP_ */
