/* Copyright (c) 2018 vesoft inc. All rights reserved.
 *
 * This source code is licensed under Apache 2.0 License,
 * attached with Common Clause Condition 1.0, found in the LICENSES directory.
 */

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "utils/fs.h"

namespace nebula {
namespace fs {

static const int32_t kMaxPathLen = 1024;

StatusOr<std::string> readLink(const char *path) {
    char buffer[kMaxPathLen];
    auto len = ::readlink(path, buffer, kMaxPathLen);
    if (len == -1) {
        return Status::Error("readlink %s: %s", path, ::strerror(errno));
    }
    return std::string(buffer, len);
}


std::string dirname(const char *path) {
    assert(path != nullptr && *path != '\0');
    if (::strcmp("/", path) == 0) {     // root only
        return "/";
    }
    static const std::regex pattern("(.*)/([^/]+)/?");
    std::cmatch result;
    if (std::regex_match(path, result, pattern)) {
        if (result[1].first == result[1].second) {    // "/path" or "/path/"
            return "/";
        }
        return result[1].str();     // "/path/to", "path/to", or "path/to/"
    }
    return ".";
}


std::string basename(const char *path) {
    assert(path != nullptr && *path != '\0');
    if (::strcmp("/", path) == 0) {
        return "";
    }
    static const std::regex pattern("(/*([^/]+/+)*)([^/]+)/?");
    std::cmatch result;
    std::regex_match(path, result, pattern);
    return result[3].str();
}


const char* getFileTypeName(FileType type) {
    static const char* kTypeNames[] = {
        "Unknown",
        "NotExist",
        "Regular",
        "Directory",
        "SoftLink",
        "CharDevice",
        "BlockDevice",
        "FIFO",
        "Socket"
    };

    return kTypeNames[static_cast<int>(type)];
}


size_t fileSize(const char* path) {
    struct stat st;
    if (lstat(path, &st)) {
        perror("lstat");
        return 0;
    }

    return st.st_size;
}


FileType fileType(const char* path) {
    struct stat st;
    if (lstat(path, &st)) {
        if (errno == ENOENT) {
            return FileType::NOTEXIST;
        } else {
            return FileType::UNKNOWN;
        }
    }

    if (S_ISREG(st.st_mode)) {
        return FileType::REGULAR;
    } else if (S_ISDIR(st.st_mode)) {
        return FileType::DIRECTORY;
    } else if (S_ISLNK(st.st_mode)) {
        return FileType::SYM_LINK;
    } else if (S_ISCHR(st.st_mode)) {
        return FileType::CHAR_DEV;
    } else if (S_ISBLK(st.st_mode)) {
        return FileType::BLOCK_DEV;
    } else if (S_ISFIFO(st.st_mode)) {
        return FileType::FIFO;
    } else if (S_ISSOCK(st.st_mode)) {
        return FileType::SOCKET;
    }

    return FileType::UNKNOWN;
}


int64_t fileLastUpdateTime(const char* path) {
    struct stat st;
    if (lstat(path, &st)) {
        // Failed to get file stat
        return -1;
    }
    return st.st_mtime;
}


bool isStdinTTY() {
    return isFdTTY(::fileno(stdin));
}


bool isStdoutTTY() {
    return isFdTTY(::fileno(stdout));
}


bool isStderrTTY() {
    return isFdTTY(::fileno(stderr));
}


bool isFdTTY(int fd) {
    return ::isatty(fd) == 1;
}


Iterator::Iterator(std::string path, const std::regex *pattern)
    : path_(std::move(path)) {
    pattern_ = pattern;
    openFileOrDirectory();
    if (status_.ok()) {
        next();
    }
}


Iterator::~Iterator() {
    if (fstream_ != nullptr && fstream_->is_open()) {
        fstream_->close();
    }
    if (dir_ != nullptr) {
        ::closedir(dir_);
        dir_ = nullptr;
    }
}


void Iterator::next() {
    assert(valid());
    assert(type_ != FileType::UNKNOWN);
    while (true) {
        if (type_ == FileType::DIRECTORY) {
            dirNext();
        } else {
            fileNext();
        }
        if (!status_.ok()) {
            return;
        }
        if (pattern_ != nullptr) {
            if (!std::regex_search(entry_, matched_, *pattern_)) {
                continue;
            }
        }
        break;
    }
}


void Iterator::dirNext() {
    assert(type_ == FileType::DIRECTORY);
    assert(dir_ != nullptr);
    struct dirent *dent;
    while ((dent = ::readdir(dir_)) != nullptr) {
        if (dent->d_name[0] == '.') {
            continue;
        }
        break;
    }
    if (dent == nullptr) {
        status_ = Status::Error("EOF");
        return;
    }
    entry_ = dent->d_name;
}


void Iterator::fileNext() {
    assert(type_ == FileType::REGULAR);
    assert(fstream_ != nullptr);
    if (!std::getline(*fstream_, entry_)) {
        status_ = Status::Error("EOF");
    }
}


void Iterator::openFileOrDirectory() {
    type_ = fileType(path_.c_str());
    if (type_ == FileType::DIRECTORY) {
        if ((dir_ = ::opendir(path_.c_str())) == nullptr) {
            status_ = Status::Error("opendir `%s': %s", path_.c_str(), ::strerror(errno));
            return;
        }
    } else if (type_ == FileType::REGULAR) {
        fstream_ = std::make_unique<std::ifstream>();
        fstream_->open(path_);
        if (!fstream_->is_open()) {
            status_ = Status::Error("open `%s': %s", path_.c_str(), ::strerror(errno));
            return;
        }
    } else {
        status_ = Status::Error("Filetype not supported `%s': %s",
                                path_.c_str(), getFileTypeName(type_));
        return;
    }
    status_ = Status::OK();
}

}  // namespace fs
}  // namespace nebula

