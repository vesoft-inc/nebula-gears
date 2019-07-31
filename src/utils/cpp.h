/* Copyright (c) 2018 vesoft inc. All rights reserved.
 *
 * This source code is licensed under Apache 2.0 License,
 * attached with Common Clause Condition 1.0, found in the LICENSES directory.
 */

#pragma once

#define MUST_USE_RESULT                 __attribute__((warn_unused_result))
#define DONT_OPTIMIZE                   __attribute__((optimize("O0")))

#define ALWAYS_INLINE                   __attribute__((always_inline))
#define ALWAYS_NO_INLINE                __attribute__((noinline))

#define BEGIN_NO_OPTIMIZATION           _Pragma("GCC push_options") \
                                        _Pragma("GCC optimize(\"O0\")")
#define END_NO_OPTIMIZATION             _Pragma("GCC pop_options")

#define NEBULA_STRINGIFY(STR)           NEBULA_STRINGIFY_X(STR)
#define NEBULA_STRINGIFY_X(STR)         #STR

#ifndef UNUSED
#define UNUSED(x) (void)(x)
#endif  // UNUSED

#ifndef COMPILER_BARRIER
#define COMPILER_BARRIER()              asm volatile ("":::"memory")
#endif  // COMPILER_BARRIER


namespace nebula {

// Useful type traits

// Tell if `T' is copy-constructible
template <typename T>
static constexpr auto is_copy_constructible_v = std::is_copy_constructible<T>::value;

// Tell if `T' is move-constructible
template <typename T>
static constexpr auto is_move_constructible_v = std::is_move_constructible<T>::value;

// Tell if `T' is copy or move constructible
template <typename T>
static constexpr auto is_copy_or_move_constructible_v = is_copy_constructible_v<T> ||
                                                        is_move_constructible_v<T>;

// Tell if `T' is constructible from `Args'
template <typename T, typename...Args>
static constexpr auto is_constructible_v = std::is_constructible<T, Args...>::value;

// Tell if `U' could be convertible to `T'
template <typename U, typename T>
static constexpr auto is_convertible_v = std::is_constructible<U, T>::value;

}  // namespace nebula
