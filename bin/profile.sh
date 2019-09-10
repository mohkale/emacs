#!/usr/bin/bash
# run profile-dotemacs.el
# it also converts the init file path from it's default value of
# ~/.emacs to ~/.emacs.d/init.el (if it isn't already that).

PROFILE_SCRIPT=~/.emacs.d/bin/misc/profile-dotemacs.el
OLD_SRC_REGEX='\(profile-dotemacs-file\) "~\/.emacs"'

if [ ! -r ~/.emacs.d/init.el ]; then
    echo "failed to find user configuration file" >&2
    exit 1
fi

cat "${PROFILE_SCRIPT}" | if grep "${OLD_SRC_REGEX}" 2>/dev/null 1>&2; then
    sed -e s/"${OLD_SRC_REGEX}"/'\1 "~\/.emacs.d\/init.el"'/ --in-place "${PROFILE_SCRIPT}"
fi

emacs -Q -l "${PROFILE_SCRIPT}" -f profile-dotemacs
