# btop-theme-damin

> Two-color btop theme in the damin palette (`#98ABCC` blue / `#E890B0` pink, `#C09EBE` mauve mid) on `#1e1e1e`. Pairs with [`miniex/dotfiles.tmux`](https://github.com/miniex/dotfiles.tmux), [`miniex/dotfiles.kitty`](https://github.com/miniex/dotfiles.kitty), [`miniex/dotfiles.nvim`](https://github.com/miniex/dotfiles.nvim), and [`miniex/fish-theme-damin`](https://github.com/miniex/fish-theme-damin).

## Preview

```
       ╭── cpu ─────────────────────╮   ╭── mem ─────────────────────╮
       │   ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁          │   │  used   ████████░░  62 %   │
       │   blue → mauve → pink      │   │  free   ██████████   38 %  │
       ╰────────────────────────────╯   ╰────────────────────────────╯
                  ✿  blue cools  ·  pink warms  ❥
```

## Palette

| Role                        | Color     |
|-----------------------------|-----------|
| Background                  | `#1e1e1e` |
| Foreground                  | `#ffffff` |
| Blue (outlines, low / cool) | `#98ABCC` |
| Pink (titles, high / warm)  | `#E890B0` |
| Mauve (gradient midpoint)   | `#C09EBE` |
| Meter trough                | `#2a2a2a` |
| Divider                     | `#3a3a3a` |
| Inactive text               | `#555555` |

Reds for danger and greens for safety are intentionally absent — heat / load is signalled by saturation drifting from blue toward pink, not by a third hue.

## Install

**One-liner:**

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/miniex/btop-theme-damin/main/install.sh)"
```

The installer copies `damin.theme` into `~/.config/btop/themes/` and, if you confirm, sets `color_theme = "damin"` in `~/.config/btop/btop.conf`. Survives `curl | sh` — no prompt on stdin loss.

**Manual:**

```bash
mkdir -p ~/.config/btop/themes
curl -fsSL https://raw.githubusercontent.com/miniex/btop-theme-damin/main/damin.theme \
  -o ~/.config/btop/themes/damin.theme
```

Then pick `damin` under btop's <kbd>Esc</kbd> → **Options** → **color_theme**, or set `color_theme = "damin"` in `~/.config/btop/btop.conf` directly. btop reads the config at startup — restart it (or pick from the menu live) to see the change.

## Highlights

- **Load / heat gradients** — `cpu`, `temp`, `download`, `upload`, `process` all run **blue → mauve → pink**. Higher reads warmer.
- **Used / occupied** lives in the **pink family** (`#A3677D` → `#F5B2C8`) — keeps "occupied" visually distinct from "loaded".
- **Free / cached / available** stay in the **blue family** — abundance reads as calm.
- **Box outlines** uniformly blue; pink reserved for titles and the selected row. Same convention as the tmux pane borders.
- **Process state** — pause dims to `div_line`, follow tints blue, banner mauve, followed row pink (same as selected).
- **No reds, no greens** — danger and safety are signalled by hue drift, not a third hue.

## Companion repos

- [fish-theme-damin](https://github.com/miniex/fish-theme-damin) — fish prompt
- [dotfiles.tmux](https://github.com/miniex/dotfiles.tmux) — tmux config
- [dotfiles.kitty](https://github.com/miniex/dotfiles.kitty) — kitty terminal config
- [dotfiles.nvim](https://github.com/miniex/dotfiles.nvim) — Neovim config

## Contributing

Personal dotfiles — outside contributions are not accepted. Fork instead. Bug reports for the published behavior are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © 2026 Han Damin.
