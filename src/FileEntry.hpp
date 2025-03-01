#ifndef FILEENTRY_HPP
#define FILEENTRY_HPP

#include <QObject>
#include <QMetaType>
#include <QString>

#include <dirent.h>
#include "InstanceCounter.hpp"

class FileEntry : public QObject,
                  public InstanceCounter<FileEntry> {
    Q_OBJECT
    Q_DISABLE_COPY(FileEntry)
    Q_PROPERTY(bool    isFile READ isFile NOTIFY isFileChanged FINAL)
    Q_PROPERTY(bool    isDirectory READ isDirectory NOTIFY isDirectoryChanged FINAL)
    Q_PROPERTY(int     fileSize READ fileSize NOTIFY fileSizeChanged FINAL)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileNameChanged FINAL)
    Q_PROPERTY(QString filePath READ filePath NOTIFY filePathChanged FINAL)
    Q_PROPERTY(QString fileType READ fileType NOTIFY fileTypeChanged FINAL)
    Q_PROPERTY(QString fileIcon READ fileIcon NOTIFY fileIconChanged FINAL)
public:
    FileEntry(QString const & path, struct stat64 const& stat, QObject * parent = 0);

    bool isDirectory() const;
    bool isFile() const;

    QString fileIcon() const;
    QString fileName() const;
    QString filePath() const;
    QString fileType() const;
    int     fileSize() const;

    using InstanceCounter<FileEntry>::getInstanceCount;
    using InstanceCounter<FileEntry>::getMaxInstanceCount;
signals:
    void isFileChanged();
    void isDirectoryChanged();
    void fileSizeChanged();
    void fileNameChanged();
    void filePathChanged();
    void fileTypeChanged();
    void fileIconChanged();
private:
    struct stat64 m_stat;
    QString m_path;
};

Q_DECLARE_METATYPE(FileEntry*);

#endif
