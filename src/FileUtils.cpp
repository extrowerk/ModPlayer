#include "FileUtils.hpp"
#include <dirent.h>
#include <errno.h>
#include <QFile>
#include <QDebug>

#ifdef _DEBUG
//#define VERBOSE_LOGGING
#else
#endif

bool FileUtils::isAbsolute(QString const& fileName) {
    return fileName.startsWith('/');
}

bool FileUtils::isRelative(QString const& fileName) {
    return !fileName.isEmpty() && !isAbsolute(fileName);
}

QString FileUtils::fileNameOnly(QString const& fileName) {
    const int index = fileName.lastIndexOf('/');
    if(index < 0) {
        return fileName;
    } else {
        return fileName.mid(index + 1);
    }
}

QString FileUtils::fileNameOnlyWithoutExtension(QString const& fileName) {
    QString name = fileNameOnly(fileName);
    const int index = name.lastIndexOf('.');
    if(index < 0) {
        return name;
    } else {
        return name.mid(0, index);
    }
}

QString FileUtils::extension(QString const& fileName) {
    const int index = fileName.lastIndexOf('.');
    if(index < 0) {
        return "";
    } else {
        return fileName.mid(index);
    }
}

QString FileUtils::directoryOnly(QString const& fileName) {
    const int index = fileName.lastIndexOf('/');
    if(index < 0) {
        return fileName;
    } else {
        return fileName.left(index);
    }
}

QString FileUtils::joinPath(QString const& directory,
                            QString const& fileName) {
    if(isAbsolute(fileName)) {
        return fileName; // already absolute
    }

    QString result = directory;
    if(directory.endsWith('/')) {
        result += fileName;
    } else {
        result = result + "/" + fileName;
    }

    return result;
}

bool FileUtils::adjustPermissions(QString const& fileName) {
	return QFile::setPermissions(fileName,
                                 QFile::ReadOwner | QFile::WriteOwner |
                                 QFile::ReadUser | QFile::WriteUser |
                                 QFile::ReadGroup | QFile::WriteGroup |
                                 QFile::ReadOther | QFile::WriteOther);
}

bool FileUtils::fileExists(QString const& fileName) {
    struct stat64 st;
    return ::stat64(fileName.toUtf8().constData(), &st) == 0 && S_ISREG(st.st_mode);
}

bool FileUtils::directoryExists(QString const& directoryName) {
    struct stat64 st;
    return ::stat64(directoryName.toUtf8().constData(), &st) == 0 && S_ISDIR(st.st_mode);
}
