#include "Playlist.hpp"
#include <cstdlib>
#include <algorithm>
#include <iterator>

template<>
int InstanceCounter<Playlist>::s_count;
template<>
int InstanceCounter<Playlist>::s_maxCount;

Playlist::Playlist(QObject * parent)
    : QObject(parent),
      m_mode(PlaylistOnce),
      m_position(0)
{}

Playlist::Playlist(Playlist::Mode mode, QObject * parent)
    : QObject(parent),
      m_mode(mode),
      m_position(0)
{}

Playlist::~Playlist() {
#ifdef VERBOSE_LOGGING
    qDebug() << "Playlist::~Playlist()";
#endif
}

bool Playlist::isRandom() const {
    return m_mode == PlaylistRandomCycle ||
           m_mode == PlaylistRandomOnce;
}

bool Playlist::isCyclic() const {
    return m_mode == PlaylistCycle ||
           m_mode == PlaylistRandomCycle ||
           m_mode == SongCycle;
}

QVariant Playlist::currentSong() const {
    if(m_songs.empty()) {
        return QVariant();
    } else {
        return m_songs[position()];
    }
}

int Playlist::position() const {
    if(m_position >= m_songs.size()) {
        return 0;
    }
    return m_position;
}

void Playlist::clear() {
    State state(this);
    m_songs.clear();
    m_position = 0;
    notify(state);
}

void Playlist::reset() {
    State state(this);
    m_position = 0;
    if(isRandom()) {
        std::random_shuffle(m_songs.begin(), m_songs.end());
        m_position = m_songs.empty() ? 0 : (std::rand() % m_songs.size());
    }
    notify(state);
}

void Playlist::addImpl(QVariant value) {
    if(value.canConvert<QVariantList>()) {
        QVariantList collection = value.value<QVariantList>();
        const int numItems = collection.length();
        for(int i = 0; i < numItems; i++) {
            QVariant const& p = collection[i];
            if(p.type() == QVariant::Int ||
               p.type() == QVariant::String) {
                m_songs.push_back(p);
            }
        }
    } else if(value.type() == QVariant::Int ||
              value.type() == QVariant::String) {
        m_songs.push_back(value);
    }
    if(m_position >= m_songs.size()) {
        m_position = 0;
    }
}

void Playlist::add(QVariant value) {
    State state(this);
    addImpl(value);
    notify(state);
}
void Playlist::assign(QVariant value) {
    State state(this);
    m_songs.clear();
    addImpl(value);
    m_position = 0;
    notify(state);
}

int Playlist::count() const {
    return m_songs.size();
}

int Playlist::remainingCount() const {
    if(m_songs.empty()) {
        return 0;
    }
    switch(m_mode) {
    case PlaylistOnce:
    case PlaylistRandomOnce:
        return m_position >= m_songs.size() ? 0 : (m_songs.size() - m_position - 1);
    case SongCycle:
        return 1;
    case PlaylistCycle:
    case PlaylistRandomCycle:
        return m_songs.size();
    default:
        return 0;
    }
}

QVariant Playlist::next() {
    State state(this);
    switch(m_mode) {
    case PlaylistOnce:
        if(!m_songs.empty()) {
            if(m_position < m_songs.size() - 1) {
                ++m_position;
            }
        }
        break;
    case SongCycle:
    case PlaylistCycle:
        if(!m_songs.empty()) {
            if(++m_position >= m_songs.size()) {
                m_position = 0;
            }
        }
        break;
    case PlaylistRandomOnce:
        if(!m_songs.empty()) {
            if(m_position < m_songs.size() - 1) {
                ++m_position;
            }
            std::vector<QVariant>::iterator i = m_songs.begin();
            std::advance(i, m_position);
            std::random_shuffle(i, m_songs.end());
        }
        break;
    case PlaylistRandomCycle:
        if(!m_songs.empty()) {
            if(++m_position >= m_songs.size()) {
                m_position = 0;
            }
            std::vector<QVariant>::iterator i = m_songs.begin();
            std::advance(i, m_position);
            std::random_shuffle(i, m_songs.end());
        }
        break;
    default:
        break;
    }
    notify(state);
    return currentSong();
}

QVariant Playlist::previous() {
    State state(this);
    switch(m_mode) {
    case PlaylistOnce:
        if(!m_songs.empty()) {
            if(m_position > 0) {
                --m_position;
            }
        }
        break;
    case SongCycle:
    case PlaylistCycle:
        if(!m_songs.empty()) {
            if(m_position == 0) {
                m_position = m_songs.size() - 1;
            } else {
                --m_position;
            }
        }
        break;
    case PlaylistRandomOnce:
        if(!m_songs.empty()) {
            if(m_position > 0) {
                --m_position;
            }
        }
        break;
    case PlaylistRandomCycle:
        if(!m_songs.empty()) {
            if(m_position == 0) {
                m_position = m_songs.size() - 1;
            } else {
                --m_position;
            }
        }
        break;
    default:
        break;
    }
    notify(state);
    return currentSong();
}

bool Playlist::previousAvailable() const {
    switch(m_mode) {
    case PlaylistOnce:
    case PlaylistRandomOnce:
        return m_songs.empty() ? false : (m_position > 0);
    case SongCycle:
    case PlaylistCycle:
    case PlaylistRandomCycle:
        return !m_songs.empty();
    default:
        return false;
    }
}

bool Playlist::nextAvailable() const {
    switch(m_mode) {
    case PlaylistOnce:
    case PlaylistRandomOnce:
        return m_songs.empty() ? false : (m_position < m_songs.size() - 1);
    case SongCycle:
    case PlaylistCycle:
    case PlaylistRandomCycle:
        return !m_songs.empty();
    default:
        return false;
    }
}

Playlist::Mode Playlist::mode() const {
    return m_mode;
}

void Playlist::setMode(Playlist::Mode mode) {
    switch(mode) {
    case PlaylistOnce:
    case PlaylistRandomOnce:
    case SongCycle:
    case PlaylistCycle:
    case PlaylistRandomCycle:
        break;
    default:
        mode = m_mode;
        break;
    }
    if(mode != m_mode) {
        State state(this);
        m_mode = mode;
        notify(state);
    }
}

void Playlist::notify(State const& state) {
    if(state.currentSong() != currentSong()) {
        emit currentSongChanged();
    }
    if(state.position() != position()) {
        emit positionChanged();
    }
    if(state.count() != count()) {
        emit countChanged();
    }
    if(state.remainingCount() != remainingCount()) {
        emit remainingCountChanged();
    }
    if(state.nextAvailable() != nextAvailable()) {
        emit nextAvailableChanged();
    }
    if(state.previousAvailable() != previousAvailable()) {
        emit previousAvailableChanged();
    }
    if(state.isRandom() != isRandom()) {
        emit isRandomChanged();
    }
    if(state.isCyclic() != isCyclic()) {
        emit isCyclicChanged();
    }
    if(state.mode() != mode()) {
        emit modeChanged();
    }
}

QDebug operator << (QDebug dbg, Playlist const &p) {
    dbg.nospace() << "Count: " << p.count()
                  << ", RemainingCount: " << p.remainingCount()
                  << ", PreviousAvailble: " << (p.previousAvailable() ? "true":"false")
                  << ", NextAvailable: " << (p.nextAvailable() ? "true":"false")
                  << ", IsRandom: " << (p.isRandom() ? "true":"false")
                  << ", IsCyclic: " << (p.isCyclic() ? "true":"false");
    return dbg.space();
}
