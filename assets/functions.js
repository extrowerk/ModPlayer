function getRadioIcon(name) {
    if(/rockradio/.test(name)) {
        return "asset:///images/formats/icon-rockradio.png";
    } else if(/jazzradio/.test(name)) {
        return "asset:///images/formats/icon-jazzradio.png";
    } else if(/skyfm/.test(name)) {
        return "asset:///images/formats/icon-skyfm.png";
    } else if(/difm|diforfree/.test(name)) {
        return "asset:///images/formats/icon-difm.png";
    } else if(/fresca/.test(name)) {
        return "asset:///images/formats/icon-fresca.png";
    } else if(/[\/.]bbc/.test(name)) {
        return "asset:///images/formats/icon_bbc.png";
    }
    return "";
}

function isAbsolutePath(path) {
    return path.length > 0 && path.charAt(0) == '/';
}

function pathJoin(pathOne, pathTwo) {
    if(pathOne.length > 0) {
       if(pathOne.charAt(pathOne.length - 1) == '/') {
           return pathOne + pathTwo;
       } else {
           return pathOne + '/' + pathTwo;
       }
    }
    return pathTwo;
}

function fileNameOnly(path) {
    return path.replace(/.*\//, '');
}

function directoryOnly(path) {
    return path.substring(0, path.lastIndexOf('/'));
}

function replaceExtension(path, extension) {
    return path.substr(0, path.lastIndexOf(".")) + extension;
}

function getSizeKb(size) {
    var result;
    if(size < 1024) {
        result = qsTr("%1 bytes").arg(size) + Retranslate.onLanguageChanged;
    } else { 
        size /= 1024;
        if(size < 1024) {
            result = qsTr("%1 kB").arg(size.toFixed(2)) + Retranslate.onLanguageChanged;
        } else {
            size /= 1024;
            if(size < 1024) {
                result = qsTr("%1 MB").arg(size.toFixed(2)) + Retranslate.onLanguageChanged;
            } else {
                size /= 1024;
                result = qsTr("%1 GB").arg(size.toFixed(2)) + Retranslate.onLanguageChanged;
            }
        }
    }
    return result; 
}

function formatTimeStamp(unix_timestamp) {
    var date = new Date(unix_timestamp * 1000);
    var diff = (((new Date()).getTime() - date.getTime()) / 1000);
    var day_diff = Math.floor(diff / 86400);
    if(isNaN(day_diff))
        return qsTr("N/A") + Retranslate.onLanguageChanged;
    if(day_diff < 0)
        return qsTr("just now") + Retranslate.onLanguageChanged;
    return day_diff == 0 && (
           diff < 60 && qsTr("just now") + Retranslate.onLanguageChanged ||
           diff < 120 && qsTr("1 minute ago") + Retranslate.onLanguageChanged ||
           diff < 3600 && qsTr("%1 minutes ago").arg(Math.floor( diff / 60 )) + Retranslate.onLanguageChanged ||
           diff < 7200 && qsTr("1 hour ago") + Retranslate.onLanguageChanged ||
           diff < 86400 && qsTr("%1 hours ago").arg(Math.floor( diff / 3600 )) + Retranslate.onLanguageChanged) ||
           
           (day_diff == 1 && qsTr("yesterday") + Retranslate.onLanguageChanged ||
            day_diff < 7 && qsTr("%1 days ago").arg(day_diff) + Retranslate.onLanguageChanged ||
            day_diff < 31 && qsTr("%1 weeks ago").arg(Math.ceil(day_diff / 7)) + Retranslate.onLanguageChanged ||
            day_diff < 365 && qsTr("%1 months ago").arg(Math.ceil(day_diff / 12)) + Retranslate.onLanguageChanged) ||
           qsTr("long ago") + Retranslate.onLanguageChanged;
}

function formatDuration(duration) {
    duration = Math.floor(duration / 1000);
    var seconds = duration % 60;
    var minutes = Math.floor(duration / 60) % 60;
    var hours   = Math.floor(duration / (60*60)) % 24;
    var days    = Math.floor(duration / (60*60*24));
    if(seconds < 10) {
        seconds = "0" + seconds;
    } else {
        seconds = "" + seconds;
    }
    if(minutes < 10) {
        minutes = "0" + minutes;
    } else {
        minutes = "" + minutes;
    }
    hours = "" + hours;
    if(days == 0) {
        days = "";
    } else {
        days = "" + days + "d ";
    }
    if(hours == "0") {
        if(minutes == "00") {
            if(seconds == "00") {
                if(days.length == 0) {
                    return "0s";
                } else {
                    return days;
                }
            }
            if(days.length == 0) {
                return seconds + "s";
            } else {
                return days;
            }
        } else {
            if(seconds == "00") {
                if(days.length == 0) {
                    return minutes + "m";
                } else {
                    return days;
                }
            } else {
                if(days.length == 0) {
                    return minutes + "m " + seconds + "s";
                } else {
                    return days;
                }
            }
        }
    } else {
        if(days.length == 0) {
            return hours + "h " + minutes + "m " + seconds + "s";
        } else {
            return days + hours + "h " + minutes + "m " + seconds + "s";
        }
    }
}

var entityMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;"
};

function escapeHtml(string) {
    return String(string).replace(/[&<>]/g, function (s) {
        return entityMap[s];
    });
}