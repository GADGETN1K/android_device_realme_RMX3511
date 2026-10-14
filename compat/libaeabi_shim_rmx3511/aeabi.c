/*
 * SPDX-FileCopyrightText: 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <stdint.h>

#define EXPORT __attribute__((visibility("default")))

/* armv8-a AArch32 has udiv in hardware, so these don't recurse. */
EXPORT unsigned int __aeabi_uidiv(unsigned int n, unsigned int d) {
    return n / d;
}

/* AAPCS returns a 64-bit value in r0:r1: quotient in r0, remainder in r1. */
EXPORT uint64_t __aeabi_uidivmod(unsigned int n, unsigned int d) {
    unsigned int q = n / d;
    unsigned int r = n - q * d;
    return ((uint64_t)r << 32) | q;
}
