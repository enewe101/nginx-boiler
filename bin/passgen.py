#!/usr/bin/env python3
#
# Substitutes all instances of "secret" in a template file with a strong 
# password.
#
# Basic Usage:
#
#     $ ./passgen.py template-file [password-length] > out-file
#
#     template-file: path to a file serving as a template.  The contents of
#        that file will be read in, and instances of the word "secret" will be
#        replaced with a strong password (each instance gets a distinct
#        password).
#
#     password-length: length of the passwords (number of characters) to be
#        generated.
# 
# Recommended usage: 
#
#     Combine this with encryption so that passwords never reach the filesystem
#     in cleartext:
#
#     $ ./passgen.py template-file [password-length] | gpg -co out-path
#


import re
import os
import sys
import string

CHARS = string.ascii_letters + string.digits + '_-'
DEFAULT_LENGTH = 16


def get_password(length):
    # Get length number of random characters from
    return ''.join([
        CHARS[ord(os.urandom(1)) % len(CHARS)] 
        for c in range(length)
    ])


def sub_in_passwords(template, length, slot_name='secret'):

    # Compile the slot_matcher pattern as a pattern
    slot_matcher = re.compile(slot_name)

    # Figure out how many occurrences there are
    num_occurrences = len(slot_matcher.findall(template))

    # Sub each occurrence with a randomly generated password
    template = slot_matcher.sub(lambda x: get_password(length), template)

    return template


if __name__ == '__main__':
    input_path = sys.argv[1]
    try:
        length = int(sys.argv[2])
    except IndexError:
        length = DEFAULT_LENGTH

    print(sub_in_passwords(open(input_path).read(), length))
