#include "mp3lame/lame.h"
#include "modplug/modplug.h"
#include "Mp3Export.hpp"
#include "FileUtils.hpp"
#include <QFile>
#include <QDebug>
#include <QByteArray>
#include "MessageBox.hpp"

//#define VERBOSE_LOGGING
#undef WRITE_ID3V1_TAG

using namespace bb::system;

Mp3Export::Mp3Export(QObject * parent)
    : QObject(parent) {
}

Mp3Export::~Mp3Export() {
#ifdef VERBOSE_LOGGING
    qDebug() << "Mp3Export::~Mp3Export()";
#endif
}

bool Mp3Export::convert(PlaybackConfig &config,
                        QString const& inputFileName,
                        QString const& outputFileName) {
    bool result = false;
#ifdef VERBOSE_LOGGING
    qDebug() << "Starting converting" << inputFileName << "to" << outputFileName;
#endif
    QString comment = QString("Created by ModPlayer from %1").arg(FileUtils::fileNameOnly(inputFileName));
#ifdef VERBOSE_LOGGING
    qDebug() << "Comment:" << comment;
#endif
    QFile inputFile(inputFileName);
    if(!FileUtils::fileExists(inputFileName)) {
        qDebug() << "Input file" << inputFileName << "does not exist";
        return result;
    }
    if(!inputFile.open(QFile::ReadOnly)) {
        qDebug() << "Failed to open input file" << inputFileName;
        return result;
    }

    QFile outputFile(outputFileName);
    if(FileUtils::fileExists(outputFileName)) {
        qDebug() << "Deleting output file" << outputFileName;
        if(!outputFile.remove()) {
            qDebug() << "Failed to delete output file" << outputFileName;
            return result;
        }
    }

    if(!outputFile.open(QFile::WriteOnly)) {
        qDebug() << "Failed to open output file" << outputFileName;
        return result;
    }

    QByteArray data = inputFile.readAll();
    if(data.size() == 0) {
        qDebug() << "Failed to read file" << inputFileName;
        return result;
    }

#ifdef VERBOSE_LOGGING
    qDebug() << "Read" << data.size() << "bytes from file" << inputFileName;
#endif

    ModPlugFile* module = ::ModPlug_Load(data.data(), data.size());
    if(module == NULL) {
        qDebug() << "Failed to load module" << inputFileName;
        return result;
    }

#ifdef VERBOSE_LOGGING
    qDebug() << "Module" << inputFileName << " loaded successfully";
#endif

    const int numOrders = ::ModPlug_NumOrders(module);
    int currentOrder = 0;

    MessageBox message(tr("Creating MP3 file"),
                       tr("Creating %1").arg(FileUtils::fileNameOnly(outputFileName)),
                       false,
                       0);

    int readBytes;
    int writeBytes;
    const size_t BUFFER_SIZE = 1024*1024;

    QByteArray mod_buffer(BUFFER_SIZE, 0);
    QByteArray mp3_buffer(BUFFER_SIZE, 0);

    do {
        lame_t lame = ::lame_init();
        if(lame == NULL) {
            qDebug() << "Failed to initialize lame encoder";
            break;
        }
#ifdef VERBOSE_LOGGING
        qDebug() << "Lame encoder initialized successfully";
#endif
        const int frequency = config.frequency();
        const bool isStereo = config.stereo();
        const int sampleBitSize = config.sampleSize();
        const int numBytesPerSample = sampleBitSize >> 3;
        const int numChannels = (isStereo ? 2 : 1);
#ifdef VERBOSE_LOGGING
        qDebug().nospace()
                 << "Frequency: "
                 << frequency
                 << ", stereo: "
                 << isStereo
                 << ", channels: "
                 << numChannels
                 << ", bytes per sample: "
                 << numBytesPerSample;
        qDebug().space();
#endif
        if(-1 == ::lame_set_in_samplerate(lame, frequency)) {
            qDebug() << "Failed to set input sample rate:" << frequency;
            break;
        }

        if(-1 == ::lame_set_out_samplerate(lame, frequency)) {
            qDebug() << "Failed to set output sample rate:" << frequency;
            break;
        }

        if(-1 == ::lame_set_mode(lame, isStereo ? STEREO : MONO)) {
            qDebug() << "Failed to set mode:" << (isStereo ? STEREO : MONO);
            break;
        }

        if(-1 == ::lame_set_num_channels(lame, numChannels)) {
            qDebug() << "Failed to set number of channels:" << numChannels;
            break;
        }

        if(-1 == ::lame_set_quality(lame, 5)) {
            qDebug() << "Failed to set quality:" << 5;
            break;
        }

        if(-1 == ::lame_set_VBR(lame, vbr_default)) {
            qDebug() << "Failed to set variable bit rate";
            break;
        }
#ifdef WRITE_ID3V1_TAG
        if(title.length() > 0) {
            id3tag_set_title(lame, title.toAscii().constData());
        }

        if(comment.length() > 0) {
            id3tag_set_comment(lame, comment.toAscii().constData());
        }

        ::lame_set_write_id3tag_automatic(lame, 0);
#endif
        if(0 != ::lame_init_params(lame)) {
            qDebug() << "Failed to initialize lame encoder parameters";
            break;
        }
#ifdef VERBOSE_LOGGING
        qDebug().nospace()
                 << "Starting encoding, input buffer="
                 << mod_buffer.size()
                 << ", output buffer="
                 << mp3_buffer.size();
        qDebug().space();
#endif
        do {
            readBytes = ::ModPlug_Read(module,
                                       mod_buffer.data(),
                                       mod_buffer.size());
#ifdef VERBOSE_LOGGING
            qDebug() << "Read" << readBytes << "bytes";
#endif
            if (readBytes == 0) {
#ifdef VERBOSE_LOGGING
                qDebug() << "Flushing lame encoder";
#endif
                writeBytes = ::lame_encode_flush(lame,
                                                 reinterpret_cast<unsigned char*>(mp3_buffer.data()),
                                                 mp3_buffer.size());
            } else {
                const int numSamplesPerChannel = readBytes / (numBytesPerSample * numChannels);
                if(isStereo)
                {
                    switch(numBytesPerSample){
                    case 4:
                        writeBytes = ::lame_encode_buffer_interleaved_int(lame,
                                                                          reinterpret_cast<int*>(mod_buffer.data()),
                                                                          numSamplesPerChannel,
                                                                          reinterpret_cast<unsigned char*>(mp3_buffer.data()),
                                                                          mp3_buffer.size());
                        break;
                    case 2:
                        writeBytes = ::lame_encode_buffer_interleaved(lame,
                                                                      reinterpret_cast<short int*>(mod_buffer.data()),
                                                                      numSamplesPerChannel,
                                                                      reinterpret_cast<unsigned char*>(mp3_buffer.data()),
                                                                      mp3_buffer.size());
                        break;
                    case 1:
                        writeBytes = ::lame_encode_buffer_interleaved_char(lame,
                                                                           reinterpret_cast<char*>(mod_buffer.data()),
                                                                           numSamplesPerChannel,
                                                                           reinterpret_cast<unsigned char*>(mp3_buffer.data()),
                                                                           mp3_buffer.size());
                        break;
                    default:
                        break;
                    }
                }
                else
                {
                    // MONO
                    switch(numBytesPerSample){
                    case 4:
                        writeBytes = ::lame_encode_buffer_int(lame,
                                                              reinterpret_cast<int*>(mod_buffer.data()),
                                                              reinterpret_cast<int*>(mod_buffer.data()),
                                                              numSamplesPerChannel,
                                                              reinterpret_cast<unsigned char*>(mp3_buffer.data()),
                                                              mp3_buffer.size());
                        break;
                    case 2:
                        writeBytes = ::lame_encode_buffer(lame,
                                                          reinterpret_cast<short int*>(mod_buffer.data()),
                                                          reinterpret_cast<short int*>(mod_buffer.data()),
                                                          numSamplesPerChannel,
                                                          reinterpret_cast<unsigned char*>(mp3_buffer.data()),
                                                          mp3_buffer.size());
                        break;
                    case 1:
                        writeBytes = ::lame_encode_buffer_char(lame,
                                                               reinterpret_cast<char*>(mod_buffer.data()),
                                                               reinterpret_cast<char*>(mod_buffer.data()),
                                                               numSamplesPerChannel,
                                                               reinterpret_cast<unsigned char*>(mp3_buffer.data()),
                                                               mp3_buffer.size());
                        break;
                    default:
                        break;
                    }
                }
            }

            const int bytesWritten = outputFile.write(mp3_buffer.data(),
                                                      writeBytes);
            if(writeBytes != bytesWritten) {
                qDebug().nospace();
                qDebug() << "Failed to write" << writeBytes << "bytes, written:" << bytesWritten;
                qDebug().space();
                break;
            }
            if(!outputFile.flush()) {
                qDebug() << "Failed to flush";
                break;
            }
#ifdef VERBOSE_LOGGING
            qDebug() << "Wrote" << bytesWritten << "bytes";
#endif

            int order = ::ModPlug_GetCurrentOrder(module);
            if(order != currentOrder) {
                currentOrder = order;
                int progress = currentOrder * 100 / numOrders;
                message.setProgress(progress);
            }

        } while(readBytes > 0);
#ifdef WRITE_ID3V1_TAG
        writeBytes = ::lame_get_id3v1_tag(lame,
                                          reinterpret_cast<unsigned char*>(mp3_buffer.data()),
                                          mp3_buffer.size());
        if(writeBytes > 0) {
            const int bytesWritten = outputFile.write(mp3_buffer.data(),
                                                      writeBytes);
            if(writeBytes != bytesWritten) {
                qDebug() << "Failed to write idv3 tag" << writeBytes << "bytes, written:" << bytesWritten;
                break;
            }
            if(!outputFile.flush()) {
                qDebug() << "Failed to flush idv3 tag";
                break;
            }
        }
#endif
        if(0 != ::lame_close(lame)) {
            qDebug() << "Failed to close lame encoder";
            break;
        }

        result = true;
    } while(0);

    ::ModPlug_Unload(module);

    return result;
}
