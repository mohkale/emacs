# My Literate Emacs Configuration

<div align="right">
  <a href="https://www.gnu.org/software/emacs/">
    <img alt="emacs-version" src="https://img.shields.io/badge/emacs-v30.0.50_840c33-blue"/>
  </a>
  <a href="https://github.com/mohkale/.emacs.d/actions?query=workflow%3Abuild">
    <img src="https://github.com/mohkale/.emacs.d/workflows/build/badge.svg" />
  </a>
</div>

<div style="display: flex; justify-content: center;" align="center">
  <a href="./.github/main.png" target="_blank">
    <img alt="screenshot" src="./.github/main.png" style="max-width: 800px;" />
  </a>
</div>

## Requirements

This emacs configuration requires:

- emacs >= 28.0
- ruby >= 2.6 (optional)

## Building

1. Run `git clone "https://github.com/mohkale/.emacs.d" ~/.config/emacs`.
1. Open `init.org` in emacs and run `M-x org-babel-tangle` to tangle
   the configuration.
1. Restart emacs and everything should start installing.

### Faster

If you're hardware is having a hard time tangling my ~~admittedly massive~~
config file, try:

```bash
./bin/emacs-tangle -i -d lisp/+config.el
```

The script depends on ruby and automatically tangles an org file (and any
other dependent org files) when one of their tangle targets are out of date.

## Screenshots

I like to tinker with everything I use, so my emacs does everything I do. For an
abridged list of supported features, see my entry-point [config](./init.org#config).

<div>
  <div>
    <a href="./.github/dashboard.png" target="_blank">
      <img alt="dashboard" src="./.github/dashboard.png" title="dashboard" />
    </a>
  </div>

  <div>
    <a href="./.github/c-project.png" target="_blank">
      <img alt="c-project" src="./.github/c-project.png" title="C Project" />
    </a>
  </div>

  <div>
    <a href="./.github/python-project.png" target="_blank">
      <img alt="python-project" src="./.github/python-project.png" title="Python Project" />
    </a>
  </div>

  <div>
    <a href="./.github/magit.png" target="_blank">
      <img alt="magit" src="./.github/magit.png" title="Magit" />
    </a>
  </div>

  <div>
    <a href="./.github/notmuch-mail.png" target="_blank">
      <img alt="notmuch" src="./.github/notmuch-mail.png" title="Notmuch Mail" />
    </a>
  </div>
</div>
