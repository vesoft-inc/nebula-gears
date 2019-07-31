/* Copyright (c) 2018 vesoft inc. All rights reserved.
 *
 * This source code is licensed under Apache 2.0 License,
 * attached with Common Clause Condition 1.0, found in the LICENSES directory.
 */

#pragma once

#include <dirent.h>
#include <cassert>
#include <regex>
#include <fstream>
#include "utils/StatusOr.h"

namespace nebula {
namespace fs {

enum class FileType {
    UNKNOWN = 0,
    NOTEXIST,
    REGULAR,
    DIRECTORY,
    SYM_LINK,
    CHAR_DEV,
    BLOCK_DEV,
    FIFO,
    SOCKET
};


// Get the directory part of a path
std::string dirname(const char *path);
// Get the base part of a path
std::string basename(const char *path);
// Get the content of a symbol link
StatusOr<std::string> readLink(const char *path);

// return the size of the given file
size_t fileSize(const char* path);
// return the type of the given file
FileType fileType(const char* path);
// Return the file type name
const char* getFileTypeName(FileType type);
// Return the last update time for the given file (UNIX Epoch time)
time_t fileLastUpdateTime(const char* path);

// Tell if stdin attached to a TTY
bool isStdinTTY();
// Tell if stdout atached to a TTY
bool isStdoutTTY();
// Tell if stderr attached to a TTY
bool isStderrTTY();
// Tell if the given fd attached to a TTY
bool isFdTTY(int fd);

/**
    * class Iterator works like other iterators,
    * which iterates over lines in a file or entries in a directory.
    * Additionally, if offered a pattern, Iterator filters out lines or entry names
    * that matches the pattern.
    *
    * NOTE Iterator is not designed to be used in the performance critical situations.
    */
class Iterator;
using DirEntryIterator = Iterator;
using FileLineIterator = Iterator;
class Iterator final {
public:
    /**
        * @path    path to a regular file or directory
        * @pattern optional regex pattern
        */
    explicit Iterator(std::string path, const std::regex *pattern = nullptr);
    ~Iterator();

    // Whether this iterator is valid
    bool valid() const {
        return status_.ok();
    }

    // Step to the next line or entry
    void next();
    // Step to the next line or entry
    // Overload the prefix-increment operator
    Iterator& operator++() {
        next();
        return *this;
    }

    // Forbid the overload of postfix-increment operator
    Iterator operator++(int) = delete;

    // Line or directory entry
    // REQUIRES:    valid() == true
    std::string& entry() {
        assert(valid());
        return entry_;
    }

    // Line or directory entry
    // REQUIRES:    valid() == true
    const std::string& entry() const {
        assert(valid());
        return entry_;
    }

    // The matched result of the pattern
    // REQUIRES:    valid() == true && pattern != nullptr
    std::smatch& matched() {
        assert(valid());
        assert(pattern_ != nullptr);
        return matched_;
    }

    // The matched result of the pattern
    // REQUIRES:    valid() == true && pattern != nullptr
    const std::smatch& matched() const {
        assert(valid());
        assert(pattern_ != nullptr);
        return matched_;
    }

    // Status to indicates the error
    const Status& status() const {
        return status_;
    }

private:
    void openFileOrDirectory();
    void dirNext();
    void fileNext();

private:
    std::string                         path_;
    FileType                            type_{FileType::UNKNOWN};
    std::unique_ptr<std::ifstream>      fstream_;
    DIR                                *dir_{nullptr};
    const std::regex                   *pattern_{nullptr};
    std::string                         entry_;
    std::smatch                         matched_;
    Status                              status_;
};

}  // namespace fs
}  // namespace nebula
