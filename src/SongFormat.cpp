#include "SongFormat.hpp"
#include <QDebug>
#include <QDir>

template<>
int InstanceCounter<SongFormat>::s_count;
template<>
int InstanceCounter<SongFormat>::s_maxCount;

SongFormat::SongFormat(int id,
                       QString const& name,
                       QString const& description,
                       int count,
                       double duration,
                       QObject *parent)
    : ItemGroupBase(id, name, count, duration, parent),
      m_description(description) {
}

SongFormat::~SongFormat() {
#ifdef VERBOSE_LOGGING
    qDebug() << "SongFormat::~SongFormat()";
#endif
}

QString const& SongFormat::description() const {
    return m_description;
}

QString SongFormat::iconPath() const {
    return getIconPath(static_cast<Format>(id()));
}

QString SongFormat::getIconPath(QString const& fileName) {
    return getIconPath(getFormatIdByFileName(fileName));
}

QString SongFormat::getIconPath(SongFormat::Format formatId) {
    QString appFolder(QDir::homePath());
    appFolder.chop(4); // remove data directory from end
    QString icons = QString("file://%1%2").arg(appFolder).arg("app/native/assets/images/formats");
    switch(formatId){
    case FORMAT_MOD:
        return QString("%1/icon_%2.png").arg(icons).arg("mod");
    case FORMAT_669:
        return QString("%1/icon_%2.png").arg(icons).arg("669");
    case FORMAT_IT:
        return QString("%1/icon_%2.png").arg(icons).arg("it");
    case FORMAT_MED:
        return QString("%1/icon_%2.png").arg(icons).arg("med");
    case FORMAT_MTM:
        return QString("%1/icon_%2.png").arg(icons).arg("mtm");
    case FORMAT_OCT:
        return QString("%1/icon_%2.png").arg(icons).arg("oct");
    case FORMAT_OKT:
        return QString("%1/icon_%2.png").arg(icons).arg("okt");
    case FORMAT_S3M:
        return QString("%1/icon_%2.png").arg(icons).arg("s3m");
    case FORMAT_STM:
        return QString("%1/icon_%2.png").arg(icons).arg("stm");
    case FORMAT_XM:
        return QString("%1/icon_%2.png").arg(icons).arg("xm");
    case FORMAT_AHX:
        return QString("%1/icon_%2.png").arg(icons).arg("ahx");
    case FORMAT_HVL:
        return QString("%1/icon_%2.png").arg(icons).arg("hvl");
    case FORMAT_MP3:
        return QString("%1/icon_%2.png").arg(icons).arg("mp3");
    case FORMAT_OGG:
        return QString("%1/icon_%2.png").arg(icons).arg("ogg");
    case FORMAT_FLAC:
        return QString("%1/icon_%2.png").arg(icons).arg("flac");
    case FORMAT_WAV:
        return QString("%1/icon_%2.png").arg(icons).arg("wav");
    case FORMAT_ASF:
        return QString("%1/icon_%2.png").arg(icons).arg("asf");
    case FORMAT_WMA:
        return QString("%1/icon_%2.png").arg(icons).arg("wma");
    case FORMAT_AAC:
        return QString("%1/icon_%2.png").arg(icons).arg("aac");
    case FORMAT_MP4:
        return QString("%1/icon_%2.png").arg(icons).arg("mp4");
    case FORMAT_M4A:
        return QString("%1/icon_%2.png").arg(icons).arg("m4a");
    case FORMAT_MKA:
        return QString("%1/icon_%2.png").arg(icons).arg("mka");
    case FORMAT_HTTP:
    default:
        return QString("%1/icon_unknown.png").arg(icons);
    }
}

QString SongFormat::getFormatByFormatId(SongFormat::Format formatId) {
    switch(formatId){
    case FORMAT_MOD:
        return "Amiga module file";
    case FORMAT_669:
        return "669 Mod Composer Module";
    case FORMAT_IT:
        return "Impulse Tracker Module";
    case FORMAT_MED:
        return "OctaMED Module";
    case FORMAT_MTM:
        return "MultiTracker Module";
    case FORMAT_OCT:
        return "OctaMED Module";
    case FORMAT_OKT:
        return "Oktalyzer Module";
    case FORMAT_S3M:
        return "ScreamTracker 3 Module";
    case FORMAT_STM:
        return "ScreamTracker 2 Module";
    case FORMAT_XM:
        return "FastTracker 2 Module";
    case FORMAT_AHX:
        return "Amiga Chiptune Module";
    case FORMAT_HVL:
        return "HivelyTracker Module";
    case FORMAT_MP3:
        return "MP3 Song";
    case FORMAT_OGG:
        return "Xiph.org Foundation OGG Song";
    case FORMAT_FLAC:
        return "Free Lossless Audio Codec Song";
    case FORMAT_WAV:
        return "Waveform Audio Format Song";
    case FORMAT_ASF:
        return "Advanced Systems Format Song";
    case FORMAT_WMA:
        return "Windows Media Audio Format Song";
    case FORMAT_AAC:
        return "Advanced Audio Coding Format Song";
    case FORMAT_MP4:
        return "MP4 Song";
    case FORMAT_M4A:
        return "M4A Song";
    case FORMAT_MKA:
        return "Matroska Audio Format Song";
    case FORMAT_HTTP:
        return "Internet Radio";
    default:
        return "Unknown format";
    }
}

SongFormat::Format SongFormat::getFormatIdByFileName(QString const& fileName) {
    int len = fileName.length();
    if(len > 0) {
        switch(fileName[0].unicode()) {
        case 'h': case 'H': // http
            if(len > 1) {
                switch(fileName[1].unicode()) {
                case 't': case 'T':
                    if(len > 2) {
                        switch(fileName[2].unicode()) {
                        case 't': case 'T':
                            if(len > 3) {
                                switch(fileName[3].unicode()) {
                                case 'p': case 'P':
                                    if(len > 4) {
                                        switch(fileName[4].unicode()) {
                                        case ':':
                                            return FORMAT_HTTP;
                                        }
                                        break;
                                    }
                                    break;
                                }
                                break;
                            }
                            break;
                        }
                        break;
                    }
                    break;
                }
            }
            break;
        }
        switch(fileName[len - 1].unicode()) {
        case 'c': case 'C': // .flac .aac
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'a': case 'A':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'l': case 'L':
                            if(len > 3) {
                                switch(fileName[len - 4].unicode()) {
                                case 'f': case 'F':
                                    if(len > 4 && fileName[len - 5] == '.') {
                                        return FORMAT_FLAC;
                                    }
                                    break;
                                }
                            }
                            break;
                        case 'a': case 'A':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_AAC;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case 'x': case 'X': // .ahx
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'h': case 'H':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'a': case 'A':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_AHX;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case 'l': case 'L': // .hvl
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'v': case 'V':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'h': case 'H':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_HVL;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case 'g': case 'G': // .ogg
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'g': case 'G':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'o': case 'O':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_OGG;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case 'd': case 'D': // .mod, .med
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'o': case 'O':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'm': case 'M':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_MOD;
                            }
                            break;
                        }
                    }
                    break;
                case 'e': case 'E':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'm': case 'M':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_MED;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case 'f': case 'F': // .asf
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 's': case 'S':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'a': case 'A':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_ASF;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case 'v': case 'V': // .wav
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'a': case 'A':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'w': case 'W':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_WAV;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case 'a': case 'A': // .wma .m4a .mka
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'm': case 'M':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'w': case 'W':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_WMA;
                            }
                            break;
                        }
                    }
                    break;
                case '4':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'm': case 'M':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_M4A;
                            }
                            break;
                        }
                    }
                    break;
                case 'k': case 'K':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'm': case 'M':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_MKA;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case 't': case 'T': // .it .oct .okt
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'i': case 'I':
                    if(len > 2 && fileName[len - 3] == '.') {
                        return FORMAT_IT;
                    }
                    break;
                case 'c': case 'C':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'o': case 'O':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_OCT;
                            }
                            break;
                        }
                    }
                    break;
                case 'k': case 'K':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'o': case 'O':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_OKT;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case '3': // .mo3 .mp3
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'o': case 'O':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'm': case 'M':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_MO3;
                            }
                            break;
                        }
                    }
                    break;
                case 'p': case 'P':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'm': case 'M':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_MP3;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case '4': // .mp4
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'p': case 'P':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'm': case 'M':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_MP4;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case '9': // .669
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case '6':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case '6':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_669;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        case 'm': case 'M': // .mtm .stm .s3m .xm
            if(len > 1) {
                switch(fileName[len - 2].unicode()) {
                case 'x': case 'X':
                    if(len > 2 && fileName[len - 3] == '.') {
                        return FORMAT_XM;
                    }
                    break;
                case 't': case 'T':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 'm': case 'M':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_MTM;
                            }
                            break;
                        case 's': case 'S':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_STM;
                            }
                            break;
                        }
                    }
                    break;
                case '3':
                    if(len > 2) {
                        switch(fileName[len - 3].unicode()) {
                        case 's': case 'S':
                            if(len > 3 && fileName[len - 4] == '.') {
                                return FORMAT_S3M;
                            }
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        }
    }
    return FORMAT_UNKNOWN;
}

QString SongFormat::getFormatByFileName(QString const& fileName) {
    return getFormatByFormatId(getFormatIdByFileName(fileName));
}

bool SongFormat::isMp3Song() const {
    return id() == FORMAT_MP3;
}

bool SongFormat::isMp3Song(QString const& fileName) {
    return SongFormat::isMp3Song(SongFormat::getFormatIdByFileName(fileName));
}

bool SongFormat::isMp3Song(SongFormat::Format formatId) {
    return formatId == FORMAT_MP3;
}

bool SongFormat::isTrackerSong() const {
    return SongFormat::isTrackerSong(static_cast<Format>(id()));
}

bool SongFormat::isTrackerSong(QString const& fileName) {
    return SongFormat::isTrackerSong(SongFormat::getFormatIdByFileName(fileName));
}

bool SongFormat::isTrackerSong(SongFormat::Format formatId) {
    switch(formatId) {
    case FORMAT_MOD:
    case FORMAT_669:
    case FORMAT_IT:
    case FORMAT_MED:
    case FORMAT_MTM:
    case FORMAT_OCT:
    case FORMAT_OKT:
    case FORMAT_S3M:
    case FORMAT_STM:
    case FORMAT_XM:
        return true;
    default:
        return false;
    }
}

bool SongFormat::isHttpSong() const {
    return id() == FORMAT_HTTP;
}

bool SongFormat::isHttpSong(QString const& fileName) {
    return SongFormat::isHttpSong(SongFormat::getFormatIdByFileName(fileName));
}

bool SongFormat::isHttpSong(SongFormat::Format formatId) {
    return formatId == FORMAT_HTTP;
}

QDebug operator << (QDebug dbg, SongFormat const &format) {
    dbg.nospace() << "(SongFormat:"
                  << "id=" << format.id()
                  << ",name=" << format.name()
                  << ",description=" << format.description()
                  << ",count=" << format.count()
                  << ",duration=" << format.duration()
                  << ")";
    return dbg.space();
}
