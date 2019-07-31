/* Copyright (c) 2018 vesoft inc. All rights reserved.
 *
 * This source code is licensed under Apache 2.0 License,
 * attached with Common Clause Condition 1.0, found in the LICENSES directory.
 */

#include <cstdarg>
#include "utils/string.h"

namespace nebula::string {

std::string stringPrintf(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    char buf[4096];
    auto n = vsnprintf(buf, sizeof(buf), fmt, args);
    va_end(args);
    return std::string(buf, n);
}

}   // namespace nebula::string
