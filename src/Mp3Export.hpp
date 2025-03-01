#ifndef MP3EXPORT_HPP_
#define MP3EXPORT_HPP_

#include <QObject>
#include <QString>
#include "PlaybackConfig.hpp"

class Mp3Export : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(Mp3Export)
public:
    Mp3Export(QObject * parent = 0);
    ~Mp3Export();
    bool convert(PlaybackConfig &config,
                 QString const& inputFileName,
                 QString const& outputFileName);
};

Q_DECLARE_METATYPE(Mp3Export*);

#endif
