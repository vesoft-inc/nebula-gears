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
#include <capstone/capstone.h>
#include <tuple>
#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <unordered_set>
#include <algorithm>


class Disassembler final {
public:
    Disassembler();
    ~Disassembler();
    bool disass(const char *path);
    void report();

private:
    bool disass_elf(Elf *elf);
    bool disass_ar(Elf *elf);

private:
    static constexpr auto kBaseGroupId = 1;
    int fd_ = -1;
    size_t insn_count_ = 0UL;
    std::map<uint32_t, std::unordered_set<std::string>> groups_;
    std::unordered_map<uint32_t, std::string> group_names_;
};


Disassembler::Disassembler() {
    group_names_ = {
        {kBaseGroupId, "BASE"},
        {128, "VT-x/AMD-V"},
        {129, "3DNow"},
        {130, "AES"},
        {131, "ADX"},
        {132, "AVX"},
        {133, "AVX2"},
        {134, "AVX512"},
        {135, "BMI"},
        {136, "BMI2"},
        {137, "CMOV"},
        {138, "F16C"},
        {139, "FMA"},
        {140, "FMA4"},
        {141, "FSGSBASE"},
        {142, "HLE"},
        {143, "MMX"},
        {144, "MODE32"},
        {145, "MODE64"},
        {146, "RTM"},
        {147, "SHA"},
        {148, "SSE1"},
        {149, "SSE2"},
        {150, "SSE3"},
        {151, "SSE41"},
        {152, "SSE42"},
        {153, "SSE4A"},
        {154, "SSSE3"},
        {155, "PCLMUL"},
        {156, "XOP"},
        {157, "CDI"},
        {158, "ERI"},
        {159, "TBM"},
        {160, "16BITMODE"},
        {161, "NOT64BITMODE"},
        {162, "SGX"},
        {163, "DQI"},
        {164, "BWI"},
        {165, "PFI"},
        {166, "VLX"},
        {167, "SMAP"},
        {168, "NOVLX"},
        {169, "FPU"},
    };
}


Disassembler::~Disassembler() {
    ::close(fd_);
}


void Disassembler::report() {
    for (auto &pair : groups_) {
        char list[4096];
        auto pos = 0;
        auto len = snprintf(list, sizeof(list), "%s\n      ", group_names_[pair.first].c_str());
        pos += len;
        auto current_width = len;
        auto first = true;
        for (auto &insn : pair.second) {
            if (current_width + insn.size() > 80) {
                first = true;
                len = snprintf(list + pos, sizeof(list) - pos, "\n      ");
                pos += len;
                current_width = len;
            }
            if (!first) {
                len = snprintf(list + pos, sizeof(list) - pos, ", ");
                current_width += len;
                pos += len;
            } else {
                first = false;
            }
            len = snprintf(list + pos, sizeof(list) - pos, "%s", insn.c_str());
            pos += len;
            current_width += len;
        }
        list[pos] = '\0';
        fprintf(stdout, "%s\n", list);
    }
    fprintf(stdout, "\n%lu instructions disassembled\n", insn_count_);
}


bool Disassembler::disass(const char *path) {
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
            ok = disass_elf(elf);
            break;
        } else if (kind == ELF_K_AR) {
            ok = disass_ar(elf);
            break;
        } else {
            fprintf(stderr, "Unknown file type\n");
            break;
        }
    } while (false);

    if (elf != nullptr) {
        elf_end(elf);
    }
    return ok;
}


bool Disassembler::disass_elf(Elf *elf) {
    auto ok = true;
    Elf_Scn *scn = nullptr;
    // auto *ehdr = elf64_getehdr(elf);
    while ((scn = elf_nextscn(elf, scn)) != nullptr) {
        auto *shdr = elf64_getshdr(scn);
        if (shdr == nullptr) {
            continue;
        }

        if ((shdr->sh_flags & SHF_EXECINSTR) == 0) {
            continue;
        }

        ::csh handle;
        if (::cs_open(CS_ARCH_X86, CS_MODE_64, &handle) != 0) {
            ok = false;
            break;
        }
        ::cs_option(handle, CS_OPT_DETAIL, CS_OPT_ON);
        auto *data = elf_rawdata(scn, nullptr);
        if (data == nullptr || data->d_size == 0) {
            continue;
        }

        auto code = (const uint8_t*)data->d_buf;
        auto vma = static_cast<uint64_t>(shdr->sh_addr);
        auto size = data->d_size;
        auto *insn = ::cs_malloc(handle);
        while (::cs_disasm_iter(handle, &code, &size, &vma, insn)) {
            ++insn_count_;
            auto *detail = insn->detail;
            if (detail == nullptr) {
                continue;
            }
            if (detail->groups_count == 0) {
                continue;
            }
            for (auto i = 0u; i < detail->groups_count; i++) {
                auto group = detail->groups[i];
                if (group < 128) {
                    group = kBaseGroupId;
                }
                groups_[group].emplace(insn->mnemonic);
            }
        }
        if (size != 0) {
            fprintf(stderr, "Warning: cannot disassemble instruction at 0x%lx, skip this section\n", vma);
            ok = false;
        }
        ::cs_free(insn, 1);
        ::cs_close(&handle);
        if (!ok) {
            break;
        }
    }

    return ok;
}


bool Disassembler::disass_ar(Elf *arf) {
    auto ok = true;
    while (auto *elf = elf_begin(fd_, ELF_C_READ, arf)) {
        auto *arhdr = elf_getarhdr(elf);
        if (arhdr == nullptr) {
            continue;
        }
        // Skip archive's symbol table
        if (::strcmp(arhdr->ar_name, "/") == 0) {
            elf_next(elf);
            elf_end(elf);
            continue;
        }
        // Skip archive's string table
        if (::strcmp(arhdr->ar_name, "//") == 0) {
            elf_next(elf);
            elf_end(elf);
            continue;
        }
        ok = disass_elf(elf);
        elf_next(elf);
        elf_end(elf);
        if (!ok) {
            break;
        }
    }
    return ok;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "%s <elf|archive>...\n", argv[0]);
        return 1;
    }

    Disassembler disasm;

    for (auto i = 1; i < argc; i++) {
        disasm.disass(argv[i]);
    }
    disasm.report();

    return 0;
}
