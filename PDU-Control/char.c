#include "char.h"

bool is_ws(int _c) {
    return _c == ' ' || _c == '\t' || _c == '\n' || _c == '\r';
}

bool is_digit(int _c) {
    return _c >= '0' && _c <= '9';
}

bool is_hex(int _c) {
    return (_c >= '0' && _c <= '9') || (_c >= 'a' && _c <= 'f') || (_c >= 'A' && _c <= 'F');
}

bool is_alpha(int _c) {
    return (_c >= 'a' && _c <= 'z') || (_c >= 'A' && _c <= 'Z');
}