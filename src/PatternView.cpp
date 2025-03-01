#include <QDebug>
#include <bb/cascades/Image>
#include <bb/cascades/ImagePaint>
#include <bb/cascades/Container>
#include <bb/cascades/Color>
#include <bb/cascades/ImageView>
#include <bb/cascades/DockLayout>
#include <bb/cascades/AbsoluteLayout>
#include <bb/cascades/AbsoluteLayoutProperties>
#include <bb/cascades/StackLayout>
#include "PatternView.hpp"
#include "SongFormat.hpp"

using namespace bb::cascades;

template<>
int InstanceCounter<PatternView>::s_count;
template<>
int InstanceCounter<PatternView>::s_maxCount;

const int PatternView::m_charsPerChannel = 14;
const int PatternView::m_indent = 3;
const int PatternView::m_fontScale = 2;
const int PatternView::m_fontWidth = 6;
const int PatternView::m_fontHeight = 8;

#define MAKE_RGBA(R,G,B,A) ((A << 24) + (B << 16) + (G << 8) + (R << 0))
static const unsigned int rownumber_foreground_color = MAKE_RGBA(0x00, 0x00, 0x00, 0xff);
static const unsigned int line_foreground_color = MAKE_RGBA(0x00, 0x00, 0x00, 0xff);

static const unsigned int note_active_foreground_color = MAKE_RGBA(0x00, 0x06, 0x7A, 0xff);
static const unsigned int instrument_active_foreground_color = MAKE_RGBA(0x0b, 0x63, 0x63, 0xff);
static const unsigned int volume_foreground_color = MAKE_RGBA(0x0c, 0xc6, 0xff, 0xff);
static const unsigned int effect_foreground_color = MAKE_RGBA(0x2b, 0x96, 0x07, 0xff);
static const unsigned int idle_foreground_color = MAKE_RGBA(0xB0, 0xB0, 0xB0, 0xff);

static const unsigned int rownumber_background_color = MAKE_RGBA(0x00, 0x00, 0x00, 0x00);
static const unsigned int active_background_color = MAKE_RGBA(0x00, 0x00, 0x00, 0x00);
static const unsigned int muted_background_color = MAKE_RGBA(0x90, 0x90, 0x90, 0xff);

static const unsigned int fill_color = MAKE_RGBA(0x00, 0x00, 0x00, 0x00);
#undef MAKE_RGBA

static const unsigned char NOTE_NONE = 0;
static const unsigned char NOTE_MIN = 1;
static const unsigned char NOTE_MAX = 120;
static const unsigned char NOTE_KEYOFF = 0xff;
static const unsigned char NOTE_NOTECUT = 0xfe;
static const unsigned char NOTE_FADE = 0xfd;
static const unsigned char NOTE_PC = 0xfc;
static const unsigned char NOTE_PCS = 0xfb;

static const char * NoteNames[NOTE_MAX] = {
    "C-0", "C#0", "D-0", "D#0", "E-0", "F-0", "F#0", "G-0", "G#0", "A-0", "A#0", "B-0", // [00..11]
    "C-1", "C#1", "D-1", "D#1", "E-1", "F-1", "F#1", "G-1", "G#1", "A-1", "A#1", "B-1", // [12..23]
    "C-2", "C#2", "D-2", "D#2", "E-2", "F-2", "F#2", "G-2", "G#2", "A-2", "A#2", "B-2", // [24..35]
    "C-3", "C#3", "D-3", "D#3", "E-3", "F-3", "F#3", "G-3", "G#3", "A-3", "A#3", "B-3", // [36..47]
    "C-4", "C#4", "D-4", "D#4", "E-4", "F-4", "F#4", "G-4", "G#4", "A-4", "A#4", "B-4", // [48..59]
    "C-5", "C#5", "D-5", "D#5", "E-5", "F-5", "F#5", "G-5", "G#5", "A-5", "A#5", "B-5", // [60..71]
    "C-6", "C#6", "D-6", "D#6", "E-6", "F-6", "F#6", "G-6", "G#6", "A-6", "A#6", "B-6", // [72..83]
    "C-7", "C#7", "D-7", "D#7", "E-7", "F-7", "F#7", "G-7", "G#7", "A-7", "A#7", "B-7", // [84..95]
    "C-8", "C#8", "D-8", "D#8", "E-8", "F-8", "F#8", "G-8", "G#8", "A-8", "A#8", "B-8", // [96..107]
    "C-9", "C#9", "D-9", "D#9", "E-9", "F-9", "F#9", "G-9", "G#9", "A-9", "A#9", "B-9", // [108..119]
};

enum VolumeCommands
{
    VOLCMD_NONE             = 0,
    VOLCMD_VOLUME           = 1,
    VOLCMD_PANNING          = 2,
    VOLCMD_VOLSLIDEUP       = 3,
    VOLCMD_VOLSLIDEDOWN     = 4,
    VOLCMD_FINEVOLUP        = 5,
    VOLCMD_FINEVOLDOWN      = 6,
    VOLCMD_VIBRATOSPEED     = 7,
    VOLCMD_VIBRATODEPTH     = 8,
    VOLCMD_PANSLIDELEFT     = 9,
    VOLCMD_PANSLIDERIGHT    = 10,
    VOLCMD_TONEPORTAMENTO   = 11,
    VOLCMD_PORTAUP          = 12,
    VOLCMD_PORTADOWN        = 13,
    VOLCMD_DELAYCUT         = 14, //currently unused
    VOLCMD_OFFSET           = 15, //rewbs.volOff
    MAX_VOLCMDS             = 16
};

enum EffectCommands
{
    CMD_NONE                = 0,
    CMD_ARPEGGIO            = 1,
    CMD_PORTAMENTOUP        = 2,
    CMD_PORTAMENTODOWN      = 3,
    CMD_TONEPORTAMENTO      = 4,
    CMD_VIBRATO             = 5,
    CMD_TONEPORTAVOL        = 6,
    CMD_VIBRATOVOL          = 7,
    CMD_TREMOLO             = 8,
    CMD_PANNING8            = 9,
    CMD_OFFSET              = 10,
    CMD_VOLUMESLIDE         = 11,
    CMD_POSITIONJUMP        = 12,
    CMD_VOLUME              = 13,
    CMD_PATTERNBREAK        = 14,
    CMD_RETRIG              = 15,
    CMD_SPEED               = 16,
    CMD_TEMPO               = 17,
    CMD_TREMOR              = 18,
    CMD_MODCMDEX            = 19,
    CMD_S3MCMDEX            = 20,
    CMD_CHANNELVOLUME       = 21,
    CMD_CHANNELVOLSLIDE     = 22,
    CMD_GLOBALVOLUME        = 23,
    CMD_GLOBALVOLSLIDE      = 24,
    CMD_KEYOFF              = 25,
    CMD_FINEVIBRATO         = 26,
    CMD_PANBRELLO           = 27,
    CMD_XFINEPORTAUPDOWN    = 28,
    CMD_PANNINGSLIDE        = 29,
    CMD_SETENVPOSITION      = 30,
    CMD_MIDI                = 31,
    CMD_SMOOTHMIDI          = 32, //rewbs.smoothVST
    CMD_DELAYCUT            = 33,
    CMD_XPARAM              = 34, // -> CODE#0010 -> DESC="add extended parameter mechanism to pattern effects" -! NEW_FEATURE#0010
    CMD_NOTESLIDEUP         = 35, // IMF Gxy / PTM Jxy (Slide y notes up every ticks)
    CMD_NOTESLIDEDOWN       = 36, // IMF Hxy / PTM Kxy (Slide y notes down every ticks)
    CMD_NOTESLIDEUPRETRIG   = 37, // PTM Lxy (Slide y notes up every ticks + retrigger note)
    CMD_NOTESLIDEDOWNRETRIG = 38, // PTM Mxy (Slide y notes down every ticks + retrigger note)
    CMD_REVERSEOFFSET       = 39, // PTM Nxx Revert sample + offset
    MAX_EFFECTS             = 40
};

static const char * VolumeNames = " vpcdabuhlrgfe?o";
static const char * EffectNames[2] = {
    " 0123456789ABCDRFFTE???GHK?YXPLZ\\?#?????",
    " JFEGHLKRXODB?CQATI?SMNVW?UY?P?Z\\?#?????"
};

PatternView::PatternView(Container *parent)
    : CustomControl(parent),
      m_rootContainer(NULL),
      m_cursor(NULL),
      m_patternImage(NULL),
      m_song(NULL),
      m_canvas(NULL),
      m_touchHandler(NULL),
      m_firstChannel(0),
      m_numVisibleChannels(4)
{
    setRoot(NULL);
}

void PatternView::createPatternView() {
    if(m_song == NULL || !m_song->songLoaded()) {
        m_cursor = NULL;
        m_patternImage = NULL;
        m_touchHandler = NULL;
        if(m_rootContainer != NULL) {
            m_rootContainer->removeAll();
            m_rootContainer->setParent(NULL);
            delete m_rootContainer;
            m_rootContainer = NULL;
        }
        if(m_canvas != NULL) {
            m_canvas->setParent(0);
            delete m_canvas;
            m_canvas = NULL;
        }
    } else {
        if(m_rootContainer == NULL)
        {
            m_cursor = NULL;
            m_patternImage = NULL;
            m_touchHandler = NULL;
            m_rootContainer = Container::create().background(Color::Transparent)
                                                .horizontal(HorizontalAlignment::Center)
                                                .implicitLayoutAnimations(false)
                                                .top(0)
                                                .topMargin(0)
                                                .bottom(0)
                                                .bottomMargin(0)
                                                .left(0)
                                                .leftMargin(0)
                                                .right(0)
                                                .rightMargin(0)
                                                .layout(AbsoluteLayout::create());
            setRoot(m_rootContainer);
        }

        updateCanvas();

        if(m_canvas != NULL)
        {
            if(m_patternImage == NULL)
            {
                m_patternImage = ImageView::create()
                                        .topMargin(0)
                                        .bottomMargin(0)
                                        .leftMargin(0)
                                        .rightMargin(0)
                                        .loadEffect(ImageViewLoadEffect::None)
                                        .implicitLayoutAnimations(false)
                                        .scalingMethod(ScalingMethod::AspectFill)
                                        .layoutProperties(AbsoluteLayoutProperties::create().x(0).y(0));

                m_touchHandler = new TouchHandler(m_patternImage);

                bool rc;
                rc = QObject::connect(m_patternImage, SIGNAL(touch(bb::cascades::TouchEvent*)),
                                      m_touchHandler, SLOT(handle(bb::cascades::TouchEvent*)));
                Q_ASSERT(rc);

                rc = QObject::connect(m_touchHandler, SIGNAL(tap(int, int)),
                                      this,           SLOT(onPatternTap(int, int)));
                Q_ASSERT(rc);
                Q_UNUSED(rc);

                m_rootContainer->add(m_patternImage);
            }

            const int preferredWidth = (m_indent + m_charsPerChannel * std::min(m_song->channels(), visibleChannels())) * m_fontWidth * m_fontScale;
            const int preferredHeight = m_fontHeight * m_fontScale;

            if(m_cursor == NULL)
            {
                m_cursor = Container::create().background(Color::fromRGBA(0, 1.0, 0, 0.5))
                                            .horizontal(HorizontalAlignment::Fill)
                                            .implicitLayoutAnimations(false)
                                            .top(m_fontHeight)
                                            .bottom(m_fontHeight)
                                            .topMargin(0)
                                            .bottomMargin(0)
                                            .leftMargin(0)
                                            .rightMargin(0)
                                            .preferredWidth(preferredWidth)
                                            .preferredHeight(preferredHeight)
                                            .layoutProperties(AbsoluteLayoutProperties::create().x(0).y(0));
                m_rootContainer->add(m_cursor);
            }
            else
            {
                m_cursor->setPreferredSize(preferredWidth, preferredHeight);
            }

            m_patternImage->setImage(m_canvas->image());
        }
        else
        {
            m_cursor = NULL;
            m_patternImage = NULL;
            m_touchHandler = NULL;
            if(m_rootContainer != NULL)
            {
                setRoot(NULL);
                m_rootContainer->removeAll();
                m_rootContainer->setParent(NULL);
                delete m_rootContainer;
                m_rootContainer = NULL;
            }
        }
    }
}

void PatternView::updateCanvas() {
    const int channels = m_song->channels();
    int lastChannel = m_firstChannel + visibleChannels();
    if(lastChannel > channels) {
        lastChannel = channels;
    }

    int rows = 0;
    const int pattern = m_song->currentPattern();
    ModPlugNote* data = m_song->getPattern(pattern, &rows);

    const int scaledFontWidth = m_fontWidth << (m_fontScale - 1);
    const int scaledFontHeight = m_fontHeight << (m_fontScale - 1);
    const int width = m_indent * scaledFontWidth +
                      (lastChannel - m_firstChannel) * scaledFontWidth * m_charsPerChannel; // 16 chars per channel
    const int height = (rows + 2) * scaledFontHeight;

    if(data == NULL || rows <= 0 || rows > 128 || channels <= 0)
    {
        if(m_canvas != NULL)
        {
            m_canvas->setParent(0);
            delete m_canvas;
            m_canvas = NULL;
        }
    }
    else
    {
        if(m_canvas != NULL)
        {
            if(m_canvas->width() != width ||
               m_canvas->height() != height)
            {
                m_canvas->setParent(0);
                delete m_canvas;
                m_canvas = NULL;
            }
        }

        if(m_canvas == NULL)
        {
            m_canvas = new Canvas(width, height, this);
        }

        m_canvas->fill(fill_color);

        char buffer[16];
        for(int row = 0; row < rows; ++row)
        {
            buffer[0] = ((row / 10) % 10) + '0';
            buffer[1] = (row % 10) + '0';
            buffer[2] = 0;

            m_canvas->print(0,
                            (row + 2) * scaledFontHeight,
                            rownumber_foreground_color,
                            rownumber_background_color,
                            m_fontScale,
                            buffer);

            for(int channel = m_firstChannel; channel < lastChannel; ++channel)
            {
                unsigned int foreground_color = idle_foreground_color;
                unsigned int background_color = m_song->isChannelMuted(channel) ?
                                                    muted_background_color :
                                                    active_background_color;
                const ModPlugNote &cell = data[row * channels + channel];

                const int offset_x = (channel - m_firstChannel) * m_charsPerChannel * scaledFontWidth + m_indent * scaledFontWidth;
                const int offset_y = (row + 2) * scaledFontHeight;

                // Note
                buffer[0] = buffer[1] = buffer[2] = '.';
                buffer[3] = ' ';
                buffer[4] = 0;

                switch(cell.Note)
                {
                case NOTE_NONE:
                    break;
                case NOTE_KEYOFF:
                    buffer[0] = buffer[1] = buffer[2] = '=';
                    foreground_color = note_active_foreground_color;
                    break;
                case NOTE_NOTECUT:
                    buffer[0] = buffer[1] = buffer[2] = '^';
                    foreground_color = note_active_foreground_color;
                    break;
                case NOTE_FADE:
                    buffer[0] = buffer[1] = buffer[2] = '~';
                    foreground_color = note_active_foreground_color;
                    break;
                case NOTE_PC:
                    buffer[0] = 'P';
                    buffer[1] = 'C';
                    buffer[2] = ' ';
                    foreground_color = note_active_foreground_color;
                    break;
                case NOTE_PCS:
                    buffer[0] = 'P';
                    buffer[1] = 'C';
                    buffer[2] = 'S';
                    foreground_color = note_active_foreground_color;
                    break;
                default:
                    if(cell.Note >= NOTE_MIN && cell.Note <= NOTE_MAX)
                    {
                        const char * noteString = NoteNames[cell.Note - NOTE_MIN];
                        buffer[0] = noteString[0];
                        buffer[1] = noteString[1];
                        buffer[2] = noteString[2];
                        foreground_color = note_active_foreground_color;
                    }
                    break;
                }

                m_canvas->print(offset_x,
                                offset_y,
                                foreground_color,
                                background_color,
                                m_fontScale,
                                buffer);

                // Instrument
                buffer[0] = buffer[1] = '.';
                buffer[2] = 0;

                if(cell.Instrument != 0)
                {
                    buffer[0] = (cell.Instrument / 10) + '0';
                    buffer[1] = (cell.Instrument % 10) + '0';
                    foreground_color = instrument_active_foreground_color;
                }
                else
                {
                    foreground_color = idle_foreground_color;
                }

                m_canvas->print(offset_x + 4 * scaledFontWidth,
                                offset_y,
                                foreground_color,
                                background_color,
                                m_fontScale,
                                buffer);

                // Volume
                buffer[0] = ' ';
                buffer[1] = buffer[2] = '.';
                buffer[3] = ' ';
                buffer[4] = 0;
                foreground_color = idle_foreground_color;

                if(cell.Note == NOTE_PC || cell.Note == NOTE_PCS) {
                    unsigned volume = (cell.VolumeEffect << 8) + cell.Volume;
                    buffer[1] = (volume / 10) + '0';
                    buffer[2] = (volume % 10) + '0';
                    foreground_color = volume_foreground_color;
                }
                else
                {
                    if(cell.VolumeEffect != VOLCMD_NONE && cell.Volume <= 99)
                    {
                        unsigned volcmd = cell.VolumeEffect;
                        char x;
                        if(volcmd >= MAX_VOLCMDS)
                        {
                            x = '?';
                        }
                        else
                        {
                            x = VolumeNames[volcmd];
                        }
                        buffer[0] = x;
                        buffer[1] = (cell.Volume / 10) + '0';
                        buffer[2] = (cell.Volume % 10) + '0';

                        foreground_color = volume_foreground_color;
                    }
                    else
                    {
                        foreground_color = idle_foreground_color;
                    }
                }

                m_canvas->print(offset_x + 6 * scaledFontWidth,
                                offset_y,
                                foreground_color,
                                background_color,
                                m_fontScale,
                                buffer);

                // Effect
                buffer[0] = buffer[1] = buffer[2] = '.';
                buffer[3] = 0;
                foreground_color = idle_foreground_color;

                if(cell.Note == NOTE_PC || cell.Note == NOTE_PCS)
                {
                    snprintf(buffer, sizeof(buffer), "%03u", (cell.Effect << 8) + cell.Parameter);
                    foreground_color = effect_foreground_color;
                }
                else
                {
                    char effect = '?';
                    if(cell.Effect != CMD_NONE)
                    {
                        if(cell.Effect >= MAX_EFFECTS)
                        {
                            effect = '?';
                        }
                        else {
                            switch(m_song->formatId())
                            {
                            case SongFormat::FORMAT_MOD:
                            case SongFormat::FORMAT_XM:
                                effect = EffectNames[0][cell.Effect];
                                break;
                            case SongFormat::FORMAT_S3M:
                            case SongFormat::FORMAT_IT:
                                effect = EffectNames[1][cell.Effect];
                                break;
                            default:
                                effect = EffectNames[0][cell.Effect];
                                break;
                            }
                        }
                        buffer[0] = effect;
                        foreground_color = effect_foreground_color;
                    }
                    else
                    {
                        buffer[0] = '.';
                    }

                    if(cell.Parameter != 0)
                    {
                        sprintf(&buffer[1], "%02X", cell.Parameter);
                        foreground_color = effect_foreground_color;
                    }
                    else
                    {
                        if(effect == '?')
                        {
                            buffer[1] = buffer[2] = '.';
                        }
                        else
                        {
                            buffer[1] = buffer[2] = '0';
                        }

                        if(foreground_color != effect_foreground_color)
                        {
                            foreground_color = idle_foreground_color;
                        }
                    }
                }

                m_canvas->print(offset_x + 10 * scaledFontWidth,
                                offset_y,
                                foreground_color,
                                background_color,
                                m_fontScale,
                                buffer);
            }
        }

        m_canvas->hline(0,
                        m_canvas->width(),
                        scaledFontHeight + (scaledFontHeight >> 1),
                        line_foreground_color);
        m_canvas->hline(0,
                        m_canvas->width(),
                        scaledFontHeight + (scaledFontHeight >> 1) - 4,
                        line_foreground_color);

        for(int channel = m_firstChannel; channel < lastChannel; ++channel)
        {
            m_canvas->vline(((channel - m_firstChannel) * m_charsPerChannel + m_indent) * scaledFontWidth - (scaledFontWidth >> 1),
                            0,
                            m_canvas->height(),
                            line_foreground_color);
            if(m_song->isChannelMuted(channel)) {
                strcpy(buffer, "Muted");
            } else {
                snprintf(buffer, sizeof(buffer), "Channel %d", channel + 1);
            }
            m_canvas->print(((channel - m_firstChannel) * m_charsPerChannel + m_indent + 2) * scaledFontWidth,
                            0,
                            line_foreground_color,
                            active_background_color,
                            m_fontScale,
                            buffer);
        }
    }
}

QVariant PatternView::song() const {
    return QVariant::fromValue(m_song);
}

void PatternView::setSong(QVariant value) {
    SongModule * song = qobject_cast<SongModule*>(value.value<QObject*>());
    if(song != m_song) {
        m_song = song;

        emit songChanged();

        bool rc;
        if(m_song != NULL)
        {
            rc = QObject::connect(m_song, SIGNAL(songLoadedChanged()),
                                  this,   SLOT(onSongLoadedChanged()));
            Q_ASSERT(rc);

            rc = QObject::connect(m_song, SIGNAL(channelsChanged()),
                                  this,   SLOT(onChannelsChanged()));
            Q_ASSERT(rc);

            rc = QObject::connect(m_song, SIGNAL(currentPatternChanged()),
                                  this,   SLOT(onCurrentPatternChanged()));
            Q_ASSERT(rc);

            rc = QObject::connect(m_song, SIGNAL(currentRowChanged()),
                                  this,   SLOT(onCurrentRowChanged()));
            Q_ASSERT(rc);
            Q_UNUSED(rc);
        }

        createPatternView();
    }
    emit previousChannelEnabledChanged();
    emit nextChannelEnabledChanged();
}

void PatternView::onSongLoadedChanged() {
    createPatternView();
    emit previousChannelEnabledChanged();
    emit nextChannelEnabledChanged();
}

void PatternView::onChannelsChanged() {
    createPatternView();
    emit previousChannelEnabledChanged();
    emit nextChannelEnabledChanged();
}

void PatternView::onCurrentRowChanged() {
    if(m_cursor != NULL && m_song != NULL) {
        int row = m_song->currentRow();
        if(row < 0) {
            row = 0;
        }
        AbsoluteLayoutProperties * p = qobject_cast<AbsoluteLayoutProperties*>(m_cursor->layoutProperties());
        p->setPositionY((row + 2) * m_fontHeight * m_fontScale);
    }
}

void PatternView::onCurrentPatternChanged() {
    createPatternView();
}

void PatternView::onPatternTap(int x, int y) {
    Q_UNUSED(y)
    if(m_song != NULL) {
        const int channel_width = m_canvas->width() / visibleChannels();
        const int channel = x / channel_width + m_firstChannel;
        m_song->muteChannel(channel, !m_song->isChannelMuted(channel));
        if(m_patternImage != NULL) {
            updateCanvas();
            if(m_canvas != NULL) {
                m_patternImage->setImage(m_canvas->image());
            }
        }
    }
}

void PatternView::previousChannel() {
    if(previousChannelEnabled()) {
        setFirstChannel(firstChannel() - 1);
    }
}

void PatternView::nextChannel() {
    if(nextChannelEnabled()) {
        setFirstChannel(firstChannel() + 1);
    }
}

int PatternView::visibleChannels() const {
    return m_numVisibleChannels;
}

void PatternView::setVisibleChannels(int value) {
    if(value < 0) {
        value = 0;
    }
    if(value != m_numVisibleChannels) {
        m_numVisibleChannels = value;
        createPatternView();
        emit visibleChannelsChanged();
        emit previousChannelEnabledChanged();
        emit nextChannelEnabledChanged();
    }
}

int PatternView::firstChannel() const {
    return m_firstChannel;
}

void PatternView::setFirstChannel(int value) {
    if(value < 0) {
        value = 0;
    }
    if(m_firstChannel != value) {
        m_firstChannel = value;
        emit firstChannelChanged();
        createPatternView();
        emit previousChannelEnabledChanged();
        emit nextChannelEnabledChanged();
    }
}

bool PatternView::previousChannelEnabled() const {
    return m_song != NULL &&
           m_song->songLoaded() &&
           m_song->isTrackerSong() &&
           m_firstChannel > 0 &&
           m_song->channels() > 0;
}

bool PatternView::nextChannelEnabled() const {
    return m_song != NULL &&
           m_song->songLoaded() &&
           m_song->isTrackerSong() &&
           m_firstChannel < m_song->channels() - visibleChannels();
}
