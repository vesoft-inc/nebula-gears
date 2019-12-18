/* Copyright (c) 2019 vesoft inc. All rights reserved.
 *
 * This source code is licensed under Apache 2.0 License,
 * attached with Common Clause Condition 1.0, found in the LICENSES directory.
 */

#include <fcntl.h>
#include <unistd.h>
#include <libelf.h>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <tuple>
#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <unordered_set>
#include <algorithm>


class ElfSizer final {
public:
    ElfSizer();
    ~ElfSizer();
    bool size_of(const char *path);

private:
    bool size_of_elf(Elf *elf);
    bool size_of_ar(Elf *elf);
    void print();
    bool is_special(const std::string &s) {
        return specials_.count(s) != 0;
    }
    void add_section(std::string s, size_t size);
    std::string section_name_abbr(const std::string &s);
    std::string bytes_format(size_t bytes);

private:
    using SectionInfo = std::tuple<std::string, size_t>;
    using SectionMap = std::map<std::string, SectionInfo>;
    int                         fd_ = -1;
    size_t                      total_size_ = 0;
    SectionMap                  sections_;
    std::unordered_set<std::string> specials_;
};


ElfSizer::ElfSizer() {
    specials_ = {
    };
}


ElfSizer::~ElfSizer() {
}


bool ElfSizer::size_of(const char *path) {
    if (elf_version(EV_CURRENT) == EV_NONE) {
        return false;
    }

    if (fd_ != -1) {
        ::close(fd_);
        fd_ = -1;
    }

    fd_ = ::open(path, O_RDONLY);
    if (fd_ == -1) {
        ::perror(path);
        return false;
    }

    Elf *elf = nullptr;
    auto ok = false;
    do {
        elf = elf_begin(fd_, ELF_C_READ, nullptr);
        if (elf == nullptr) {
            fprintf(stderr, "Failed to open ELF file\n");
            break;
        }

        auto kind = elf_kind(elf);
        if (kind == ELF_K_ELF) {
            ok = size_of_elf(elf);
            break;
        } else if (kind == ELF_K_AR) {
            ok = size_of_ar(elf);
            break;
        } else {
            fprintf(stderr, "Unknown file type\n");
            break;
        }
    } while (false);

    if (elf != nullptr) {
        elf_end(elf);
    }

    print();

    return ok;
}


bool ElfSizer::size_of_elf(Elf *elf) {
    auto ok = true;
    Elf_Scn *scn = nullptr;
    auto *ehdr = elf64_getehdr(elf);
    add_section("[ELF Headers]", ehdr->e_ehsize);
    while ((scn = elf_nextscn(elf, scn)) != nullptr) {
        auto *shdr = elf64_getshdr(scn);
        if (shdr == nullptr) {
            continue;
        }
        auto *sh_name = elf_strptr(elf, ehdr->e_shstrndx, shdr->sh_name);
        auto sh_size = shdr->sh_size;
        if (sh_size == 0) {
            continue;
        }
        if (shdr->sh_type == SHT_NOBITS) {
            sh_size = 0;
        }
        add_section(sh_name, sh_size);
    }

    return ok;
}


bool ElfSizer::size_of_ar(Elf *arf) {
    auto ok = true;
    while (auto *elf = elf_begin(fd_, ELF_C_READ, arf)) {
        auto *arhdr = elf_getarhdr(elf);
        if (arhdr == nullptr) {
            continue;
        }
        // Skip archive's symbol table
        if (::strcmp(arhdr->ar_name, "/") == 0) {
            add_section("[AR Symbol Table]", arhdr->ar_size);
            elf_next(elf);
            elf_end(elf);
            continue;
        }
        // Skip archive's string table
        if (::strcmp(arhdr->ar_name, "//") == 0) {
            add_section("[AR Symbol Table]", arhdr->ar_size);
            elf_next(elf);
            elf_end(elf);
            continue;
        }
        ok = size_of_elf(elf);
        elf_next(elf);
        elf_end(elf);
        if (!ok) {
            break;
        }
    }
    return ok;
}


void ElfSizer::print() {
    std::vector<SectionInfo> svec(sections_.size());
    std::transform(sections_.begin(), sections_.end(), svec.begin(), [] (auto &e) {
        return e.second;
    });
    std::sort(svec.begin(), svec.end(), [] (auto &l, auto &r) {
        return std::get<1>(r) < std::get<1>(l);
    });
    for (auto &s : svec) {
        if (!is_special(std::get<0>(s)) && std::get<1>(s) * 100.0 / total_size_ < 0.1) {
            continue;
        }
        fprintf(stdout, "%-24s%9s%6.1lf%%\n",
                section_name_abbr(std::get<0>(s)).c_str(),
                bytes_format(std::get<1>(s)).c_str(),
                std::get<1>(s) * 100.0 / total_size_);
    }
    fprintf(stdout, "%-24s%9s%6.1lf%%\n",
            "TOTAL",
            bytes_format(total_size_).c_str(),
            total_size_ * 100.0 / total_size_);
}


void ElfSizer::add_section(std::string s, size_t size) {
    auto &info = sections_[s];
    std::get<0>(info) = s;
    std::get<1>(info) += size;
    total_size_ += size;
}


std::string ElfSizer::section_name_abbr(const std::string &s) {
    if (s.size() < 24) {
        return s;
    }
    auto copy = s;
    copy.resize(20);
    copy += "...";
    return copy;
}


std::string ElfSizer::bytes_format(size_t bytes) {
    char buf[64];
    auto *unit = "B";
    auto len = snprintf(buf, sizeof(buf), "%lu%s", bytes, unit);

    double value = bytes;
    if ((bytes >> 20) != 0) {
        value = bytes * 1.0 / (1UL << 20);
        unit = "MB";
    } else if ((bytes >> 10) != 0) {
        value = bytes * 1.0 / (1UL << 10);
        unit = "KB";
    } else {
        return std::string(buf, len);
    }

    int prec = 2;
    if (value >= 100.) {
        prec = 0;
    } else if (value >= 10.) {
        prec = 1;
    }

    len = snprintf(buf, sizeof(buf), "%.*lf%s", prec, value, unit);
    return std::string(buf, len);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "%s <elf|archive>...\n", argv[0]);
        return 1;
    }


    for (auto i = 1; i < argc; i++) {
        if (argc > 2) {
            auto headline = std::string(40, '-');
            fprintf(stdout, "%s\n", headline.c_str());
            fprintf(stdout, "%s\n", argv[i]);
            fprintf(stdout, "%s\n", headline.c_str());
        }
        ElfSizer disasm;
        disasm.size_of(argv[i]);
    }

    return 0;
}
