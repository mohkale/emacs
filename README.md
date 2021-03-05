<div align="right">
  <a href="https://www.gnu.org/software/emacs/">
    <img alt="emacs-version" src="https://img.shields.io/badge/emacs-v27.1-blue"/>
  </a>
  <a href="https://github.com/mohkale/.emacs.d/actions?query=workflow%3Abuild">
    <img src="https://github.com/mohkale/.emacs.d/workflows/build/badge.svg" />
  </a>
</div>

# My Literate Emacs Configuration

<div style="display: flex; justify-content: center;" align="center">
  <a href="./.github/main.png" target="_blank">
    <img alt="screenshot" src="./.github/main.png" style="max-width: 800px;" />
  </a>
</div>

## Requirements
This emacs configuration requires:
- emacs >= 27.1
- ruby >= 2.6 (optional)

## Building
1. Run `git clone "https://github.com/mohkale/.emacs.d" ~/.emacs.d`.
2. Open `init.org` in emacs and run `M-x org-babel-tangle` to tangle
   the configuration.
3. Restart emacs and everything should start installing.

### Faster
If you're hardware is having a hard time tangling my ~~admittedly massive~~
config file, try:

```bash
./bin/tangle -i -d hydras.org -d etc/snippets.org'
```

The script depends on ruby and automatically tangles an org file (and any
other dependent org files) when one of their tangle targets are out of date.

## Screenshots
I like to tinker with everything I use, so my emacs does everything I do. For an
abridged list of supported features, see my entry-point [config](./init.org#config).
Some **cool** features include:


<div>
  <div>
    <a href="./.github/dired.png" target="_blank">
      <img alt="dired" src="./.github/dired.png" title="dired" />
    </a>
  </div>

  <div>
    <a href="./.github/magit.png" target="_blank">
      <img alt="magit" src="./.github/magit.png" title="magit" />
    </a>
  </div>

  <div>
    <a href="./.github/ivy.png" target="_blank">
      <img alt="ivy" src="./.github/ivy.png" title="ivy" />
    </a>
  </div>

  <div>
    <a href="./.github/rust.png" target="_blank">
      <img alt="rust" src="./.github/rust.png" title="rust" />
    </a>
  </div>
</div>
