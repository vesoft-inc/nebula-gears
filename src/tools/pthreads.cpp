/**
 * Copyright @ 2016-present. All rights reserved by Alipay.
 * Author: Ganyu <ganyu.hfl@alibaba-inc.com>
 */
#include <errno.h>
#include <dirent.h>
#include <unistd.h>
#include <signal.h>
#include <string>
#include <vector>
#include <regex>
#include <cstdio>
#include <cassert>
#include "utils/fs.h"
#include "utils/string.h"

using nebula::fs::FileLineIterator;
using nebula::fs::DirEntryIterator;
using nebula::string::stringPrintf;

std::vector<int> listThreads(pid_t);
std::vector<std::string> getMetrics(pid_t, int);

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "%s <pid>\n", argv[0]);
        return 1;
    }
    pid_t pid = atoi(argv[1]);
    if (::kill(pid, 0) == -1 && errno == ESRCH) {
        fprintf(stderr, "%s\n", strerror(errno));
        return 1;
    }
    auto tids = listThreads(pid);
    if (tids.empty()) {
        return 1;
    }
    fprintf(stdout, "%5s %-12s %1s %8s %10s %10s %8s %3s %-s\n",
            "Tid", "Thread", "S", "PFaults",
            "User", "Sys", "iowait", "CPU", "WaitOn");
    for (auto tid : tids) {
        auto metrics = getMetrics(pid, tid);
        if (metrics.empty()) {
            continue;
        }
        fprintf(stdout, "%5d %-12.*s %1s %8s %10s %10s %8s %3s %-.*s\n",
                tid, 12, metrics[0].c_str(), metrics[1].c_str(),
                metrics[2].c_str(), metrics[3].c_str(),
                metrics[4].c_str(), metrics[6].c_str(), metrics[5].c_str(),
                18, metrics[7].c_str());
    }
    fprintf(stdout, "NOTE:\n\t"
            "Tid:       thread id.\n\t"
            "Thread:    thread name.\n\t"
            "S:         State of thread,\n\t"
            "           `S'(sleeping), `R'(running),\n\t"
            "           `D'(uninterruptible sleeping), `T'(stopped/suspended),\n\t"
            "           `Z'(zombie), `W'(paging in/out).\n\t"
            "PFaults:   occurrences of minor/major page faults.\n\t"
            "User/Sys:  CPU time in user/kernel space, minutes:seconds.centisecs.\n\t"
            "iowait:    time waiting for io completion, minutes:seconds.centisecs.\n\t"
            "CPU:       core id of CPU executed on last time.\n\t"
            "CSW:       occurrences of voluntary/involuntary context switches.\n\t"
            "WaitOn:    syscall the thread waiting on.\n\t");
    return 0;
}

std::vector<int> listThreads(pid_t pid) {
    std::vector<int> tids;
    std::regex regex("([0-9]+)");
    DirEntryIterator accessor(stringPrintf("/proc/%d/task", pid), &regex);
    while (accessor.valid()) {
        tids.emplace_back(atoi(accessor.matched()[1].str().c_str()));
        accessor.next();
    }
    return tids;
}

std::vector<std::string> getMetrics(pid_t pid, int tid) {
    std::vector<std::string> metrics;
    static std::regex stat_regex("(?:[0-9]+) [(](.+)[)] ([RSTDZWX]) (?:[-]?[0-9]+ ){6}"
            "([0-9]+) (?:[-]?[0-9]+) ([0-9]+) (?:[-]?[0-9]+) ([0-9]+) ([0-9]+) "
            "(?:[-]?[0-9]+ ){23}([0-9]+) (?:[-]?[0-9]+ ){2}([0-9]+).*");
    FileLineIterator stat_accessor(stringPrintf("/proc/%d/task/%d/stat", pid, tid), &stat_regex);

    auto trim = [] (const std::string &str) {
        char buf[64];
        auto n = atoll(str.c_str());
        if (n < 10000) {
            return str;
        }
        if (n < 10000000) {
            snprintf(buf, sizeof(buf), "%lldk", n / 1000);
            return std::string(buf);
        }
        snprintf(buf, sizeof(buf), "%lldm", n / 1000000);
        return std::string(buf);
    };

    auto ticks_to_time = [] (size_t ticks) {
        char buf[64];
        auto subsecond = ticks * 10 % 1000 / 10;
        auto second = ticks * 10 / 1000;
        auto minute = second / 60;
        second %= 60;
        if (minute != 0) {
            snprintf(buf, sizeof(buf),
                    "%lu:%lu.%lu", minute, second, subsecond);
        } else {
            snprintf(buf, sizeof(buf),
                    "%lu.%lu", second, subsecond);
        }
        return std::string(buf);
    };

    auto format_ticks = [ticks_to_time] (const std::string &str) {
        return ticks_to_time(atoll(str.c_str()));
    };

    if (!stat_accessor.valid()) {
        return metrics;
    }
    auto &sm = stat_accessor.matched();
    metrics.emplace_back(sm[1].str());                      // thread name
    metrics.emplace_back(sm[2].str());                      // state
    auto pgflts = trim(sm[3].str()) + "/" + trim(sm[4].str());
    metrics.emplace_back(std::move(pgflts));                // minor/major page faults
    metrics.emplace_back(format_ticks(sm[5].str()));        // user time
    metrics.emplace_back(format_ticks(sm[6].str()));        // sys time
    metrics.emplace_back(sm[7].str());                      // last cpu
    metrics.emplace_back(format_ticks(sm[8].str()));        // io delay

    FileLineIterator wchan_accessor(stringPrintf("/proc/%d/task/%d/wchan", pid, tid));
    std::string wchan;
    if (!wchan_accessor.valid()) {
        metrics.clear();
        return metrics;
    }
    metrics.emplace_back(wchan_accessor.entry());                 // current waiting channel

    return metrics;
}
