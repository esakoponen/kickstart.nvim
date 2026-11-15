"""Generate the keybinding cheatsheet wallpaper: a 3840x2400 SVG.

Usage:
    python cheatsheet/generate.py OUT.svg [--data FILE.json] [--fonts DIR]

The content (panels, keys, descriptions) comes from keybindings.json next to this script; the
layout, colours and fonts are set here. The output is deterministic: the same data, script and
font files give a byte-identical SVG. Nothing random, no timestamps, LF line endings.

Text is measured with Pillow against the fonts the SVG names (Segoe UI and Cascadia Mono, shipped
with Windows 11), so that every size can scale with one factor S: the largest that fits all columns
above the taskbar with no text overflowing its panel. Panels are assigned to columns automatically.

Requires Python 3 and Pillow (`pip install pillow`).
"""
import argparse
import json
import os
import re
import sys
from xml.sax.saxutils import escape

from PIL import ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))

W, H = 3840, 2400
MX = 150        # side margin
TOP = 90        # first panel row
BOTTOM = 2235   # keep clear of the taskbar
GUT = 40        # gutter between columns / panels
NCOL = 4
COLW = (W - 2 * MX - (NCOL - 1) * GUT) / NCOL
# In keycaps, what is not a typed character: a modifier (C- Ctrl, S- Shift, A- or M- Alt) or a
# named key. Drawn in the leader's colour, so C-c (Ctrl+c) never reads as C (Shift+c) and c.
SPECIAL = re.compile(r'(?<![\w-])[CSAM]-(?=\S)'
                     r'|(?<![A-Za-z])(?:Tab|Esc|Enter|Space|BS|Del|F1[0-2]|F[1-9])(?![A-Za-z0-9])')
LEADER = '\u2423'  # ␣, drawn as an open box

C = dict(
    bg0='#070c18', bg1='#0c1426', panel='#0e182d', stroke='#1f3056', rule='#1a2847',
    head='#d5ddff', desc='#aab4d8', dim='#66739a', cap='#16233f', capstroke='#2f4778',
    keytext='#e0e8ff', leader='#7dcfff', cmd='#b4c6f5',
)
ACCENTS = dict(blue='#7aa2f7', cyan='#7dcfff', teal='#5fd7c8', purple='#a99cf5', sky='#89b4fa', rose='#c49cf0')

# The font files the SVG's font-family names resolve to on Windows.
FONT_FILES = ('CascadiaMono.ttf', 'segoeui.ttf', 'segoeuii.ttf', 'seguisb.ttf')


def parse_args():
    p = argparse.ArgumentParser(description='Generate the keybinding cheatsheet SVG.')
    p.add_argument('out', help='output SVG, e.g. nvim-keybindings-v5.svg')
    p.add_argument('--data', default=os.path.join(HERE, 'keybindings.json'), help='panel data (default: %(default)s)')
    p.add_argument('--fonts', default=os.environ.get('CHEATSHEET_FONTS'),
                   help='directory holding ' + ', '.join(FONT_FILES) +
                        ' (default: $CHEATSHEET_FONTS, C:/Windows/Fonts, or /mnt/c/Windows/Fonts under WSL)')
    return p.parse_args()


def font_dir(given):
    candidates = [given] if given else ['C:/Windows/Fonts', '/mnt/c/Windows/Fonts']
    for d in candidates:
        if d and all(os.path.isfile(os.path.join(d, f)) for f in FONT_FILES):
            return d.rstrip('/\\') + '/'
    sys.exit('fonts not found: need ' + ', '.join(FONT_FILES) + ' in ' + ' or '.join(c for c in candidates if c))


def key_text(s):
    """<leader> and <Space> are both drawn as the open-box symbol."""
    return s.replace('<leader>', LEADER).replace('<Space>', LEADER)


def load_panels(path):
    """Read the JSON data into (title, hint, accent colour, rows) tuples, in reading order.

    Row tuples: (keys, desc[, note])  ('#', label[  keys])  ('~', text)  ('$', command, note)
    """
    with open(path, encoding='utf-8') as fh:
        data = json.load(fh)
    panels = []
    for i, p in enumerate(data['panels']):
        where = f'panel {i + 1} ({p.get("title", "?")})'
        if p.get('accent') not in ACCENTS:
            sys.exit(f'{where}: accent must be one of {", ".join(ACCENTS)}')
        rows = []
        for j, r in enumerate(p['rows']):
            if 'section' in r:
                rows.append(('#', r['section'] + ('  ' + key_text(r['keys']) if r.get('keys') else '')))
            elif 'comment' in r:
                rows.append(('~', r['comment']))
            elif 'command' in r:
                rows.append(('$', r['command'], r.get('note', '')))
            elif 'keys' in r and 'desc' in r:
                rows.append((key_text(r['keys']), r['desc']) + ((r['note'],) if 'note' in r else ()))
            else:
                sys.exit(f'{where}, row {j + 1}: expected keys+desc, section, comment or command: {r}')
        panels.append((p['title'], key_text(p.get('hint', '')), ACCENTS[p['accent']], rows))
    if not panels:
        sys.exit(f'{path}: no panels')
    return panels


ARGS = parse_args()
FONTS = font_dir(ARGS.fonts)
PANELS = load_panels(ARGS.data)


def truetype(name, size):
    # BASIC layout: plain advance widths, the same whether or not libraqm is installed.
    return ImageFont.truetype(FONTS + name, max(1, round(size)), layout_engine=ImageFont.Layout.BASIC)


def _best_split(heights):
    """Assign panels to columns minimising the tallest column (branch and bound).

    Panel 0 (Basics) is pinned to column 0; inside a column, panels keep their reading order.
    Returns a list of column indices, one per panel.
    """
    order = sorted(range(1, len(heights)), key=lambda i: -heights[i])
    best = [float('inf'), None]
    load, count, assign = [heights[0]] + [0.0] * (NCOL - 1), [1] + [0] * (NCOL - 1), [0] * len(heights)

    def go(k):
        cur = max(l + GUT * (c - 1) for l, c in zip(load, count) if c) if any(count) else 0
        if cur >= best[0]:
            return
        if k == len(order):
            best[0], best[1] = cur, assign[:]
            return
        i, seen = order[k], set()
        for c in range(NCOL):
            if (load[c], count[c]) in seen:
                continue  # an identical column was already tried
            seen.add((load[c], count[c]))
            load[c] += heights[i]; count[c] += 1; assign[i] = c
            go(k + 1)
            load[c] -= heights[i]; count[c] -= 1

    go(0)
    return best[1]


class Metrics:
    """All sizes for one scale factor, plus measuring fonts at those sizes."""

    def __init__(self, s):
        self.s = s
        r = lambda v: round(v * s, 1)
        self.key_fs, self.desc_fs, self.head_fs = r(30), r(31), r(38)
        self.sub_fs, self.note_fs, self.cmd_fs, self.hint_fs = r(22), r(25), r(27), r(26)
        self.key_h, self.key_padx, self.key_gap = r(44), r(12), r(30)
        self.row_h, self.head_h, self.sub_h, self.note_h = r(58), r(74), r(48), r(42)
        self.pad_top, self.pad_bottom, self.padx = r(12), r(20), 30
        self.mono = lambda size: truetype('CascadiaMono.ttf', size)
        self.sans = truetype('segoeui.ttf', self.desc_fs)
        self.note = truetype('segoeuii.ttf', self.note_fs)
        self.subf = truetype('seguisb.ttf', self.sub_fs)

    def run_width(self, text, size):
        m = self.mono(size)
        return sum(m.getlength('M') * 1.2 if ch == LEADER else m.getlength(ch) for ch in text)

    def keyw(self, tok):
        return self.run_width(tok, self.key_fs) + 2 * self.key_padx

    def keys_width(self, keys):
        toks = keys.split(' / ')
        return sum(self.keyw(t) for t in toks) + self.key_gap * (len(toks) - 1)

    def panel_height(self, rows):
        h = self.head_h + self.pad_top + self.pad_bottom
        for row in rows:
            h += self.sub_h if row[0] == '#' else self.note_h if row[0] == '~' else self.row_h
        return h

    def cmd_text(self, cmd):
        return cmd if cmd.startswith(':') else '$ ' + cmd

    def overflows(self):
        """List of (panel, row, pixels over) for text that would cross the panel's right edge."""
        bad = []
        inner = COLW - 2 * self.padx
        for col in PANELS:
            for title, hint, _, rows in col:
                key_col = max((self.keys_width(r[0]) for r in rows if r[0] not in '#~$'), default=0)
                head_w = truetype('seguisb.ttf', self.head_fs).getlength(title) + 4
                if hint and head_w + 40 + self.run_width(hint, self.hint_fs) > inner:
                    bad.append((title, 'hint', 0))
                for r in rows:
                    if r[0] == '~':
                        w = self.note.getlength(r[1])
                    elif r[0] == '$':
                        w = self.run_width(self.cmd_text(r[1]), self.cmd_fs) + (24 + self.note.getlength(r[2]) if r[2] else 0)
                    elif r[0] == '#':
                        continue
                    else:
                        w = key_col + 30 + self.sans.getlength(r[1])
                        if len(r) > 2:
                            w += 14 + self.note.getlength(r[2])
                    if w > inner - 6:
                        bad.append((title, r[0] if r[0] not in '~$' else r[1][:30], round(w - inner)))
        return bad

    def fits(self):
        tallest = max(sum(self.panel_height(p[3]) for p in col) + GUT * (len(col) - 1) for col in PANELS)
        return TOP + tallest <= BOTTOM, tallest


_flat = PANELS
_m = Metrics(1.0)
_a = _best_split([_m.panel_height(p[3]) for p in _flat])
PANELS = [[p for p, c in zip(_flat, _a) if c == col] for col in range(NCOL)]
print('columns:', [[p[0] for p in col] for col in PANELS])

s = 1.15
while True:
    M = Metrics(s)
    ok, tallest = M.fits()
    if ok and not M.overflows():
        break
    s = round(s - 0.01, 3)
    if s < 0.75:
        M = Metrics(0.75)
        break

out = []
a = out.append


def run(x, base, text, size, color=None, anchor_end=False, special=False):
    """Mono text with every ␣ drawn as an open-box leader symbol.

    With special (keycaps), what SPECIAL matches is drawn in the leader's colour.
    """
    m = M.mono(size)
    lw = m.getlength('M') * 1.2
    width = M.run_width(text, size)
    if anchor_end:
        x -= width
    hot = {i for mt in SPECIAL.finditer(text) for i in range(*mt.span())} if special else set()
    style = f' style="font-size:{size}px' + (f';fill:{color}' if color else '') + '"'
    parts, buf, bx, cx = [], '', x, x

    def flush():
        nonlocal buf
        if buf:
            buf = buf.replace('</tspan><tspan class="mod">', '')  # one span per highlighted run
            parts.append(f'<text class="key" x="{bx:.1f}" y="{base:.1f}"{style} xml:space="preserve">{buf}</text>')
        buf = ''

    for i, ch in enumerate(text):
        if ch == LEADER:
            flush()
            x0, x1 = cx + lw * 0.16, cx + lw * 0.84
            top, bot = base - size * 0.36, base + size * 0.02
            parts.append(f'<path d="M{x0:.1f},{top:.1f} V{bot:.1f} H{x1:.1f} V{top:.1f}" fill="none" stroke="{C["leader"]}" '
                         f'stroke-width="{max(2.2, size / 10):.1f}" stroke-linecap="round" stroke-linejoin="round"/>')
            cx += lw
        else:
            if not buf:
                bx = cx
            buf += f'<tspan class="mod">{escape(ch)}</tspan>' if i in hot else escape(ch)
            cx += m.getlength(ch)
    flush()
    return parts, width


def keycaps(x, y_mid, keys):
    parts = []
    toks = keys.split(' / ')
    for i, t in enumerate(toks):
        w = M.keyw(t)
        parts.append(f'<rect class="cap" x="{x:.1f}" y="{y_mid - M.key_h / 2:.1f}" width="{w:.1f}" height="{M.key_h}" rx="9"/>')
        parts.extend(run(x + M.key_padx, y_mid + M.key_fs / 3, t, M.key_fs, special=True)[0])
        x += w
        if i < len(toks) - 1:
            parts.append(f'<text class="sep" x="{x + M.key_gap / 2:.1f}" y="{y_mid + M.key_fs * 0.3:.1f}" text-anchor="middle">/</text>')
            x += M.key_gap
    return parts


a(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
a(f'''<defs>
  <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="{C['bg1']}"/><stop offset="1" stop-color="{C['bg0']}"/>
  </linearGradient>
  <radialGradient id="glowA" cx="0.12" cy="0.05" r="0.6">
    <stop offset="0" stop-color="#1f4f9a" stop-opacity="0.42"/><stop offset="1" stop-color="#1f4f9a" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="glowB" cx="0.92" cy="0.95" r="0.55">
    <stop offset="0" stop-color="#3a2f7a" stop-opacity="0.38"/><stop offset="1" stop-color="#3a2f7a" stop-opacity="0"/>
  </radialGradient>
  <pattern id="dots" width="48" height="48" patternUnits="userSpaceOnUse">
    <circle cx="2" cy="2" r="1.6" fill="#8fb4ff" fill-opacity="0.07"/>
  </pattern>
  <style>
    .key  {{ font-family: 'Cascadia Mono', Consolas, monospace; font-size: {M.key_fs}px; fill: {C['keytext']}; }}
    .mod  {{ fill: {C['leader']}; }}
    .desc {{ font-family: 'Segoe UI', sans-serif; font-size: {M.desc_fs}px; fill: {C['desc']}; }}
    .note {{ font-family: 'Segoe UI', sans-serif; font-style: italic; font-size: {M.note_fs}px; fill: {C['dim']}; }}
    .sep  {{ font-family: 'Segoe UI', sans-serif; font-size: {M.key_fs * 0.87:.1f}px; fill: {C['dim']}; }}
    .head {{ font-family: 'Segoe UI Variable Display', 'Segoe UI', sans-serif; font-weight: 600; font-size: {M.head_fs}px; fill: {C['head']}; }}
    .sub  {{ font-family: 'Segoe UI', sans-serif; font-weight: 600; font-size: {M.sub_fs}px; letter-spacing: 3px; }}
    .cap  {{ fill: {C['cap']}; stroke: {C['capstroke']}; stroke-width: 1.5; }}
  </style>
</defs>''')
for fill in ('bg', 'glowA', 'glowB', 'dots'):
    a(f'<rect width="{W}" height="{H}" fill="url(#{fill})"/>')

heights = []
for ci, col in enumerate(PANELS):
    px = MX + ci * (COLW + GUT)
    py = TOP
    for title, hint, accent, rows in col:
        ph = M.panel_height(rows)
        right = px + COLW - M.padx
        a(f'<rect x="{px:.1f}" y="{py:.1f}" width="{COLW:.1f}" height="{ph:.1f}" rx="20" '
          f'fill="{C["panel"]}" fill-opacity="0.82" stroke="{C["stroke"]}" stroke-width="2"/>')
        a(f'<rect x="{px:.1f}" y="{py + M.head_h * 0.33:.1f}" width="6" height="{M.head_h * 0.44:.1f}" rx="3" fill="{accent}"/>')
        a(f'<text class="head" x="{px + M.padx + 4:.1f}" y="{py + M.head_h * 0.71:.1f}">{escape(title)}</text>')
        if hint:
            out.extend(run(right, py + M.head_h * 0.69, hint, M.hint_fs, color=accent, anchor_end=True)[0])
        a(f'<line x1="{px + M.padx:.1f}" y1="{py + M.head_h:.1f}" x2="{right:.1f}" y2="{py + M.head_h:.1f}" '
          f'stroke="{C["rule"]}" stroke-width="2"/>')

        key_col = max((M.keys_width(r[0]) for r in rows if r[0] not in '#~$'), default=0)
        dx = px + M.padx + key_col + 30
        y = py + M.head_h + M.pad_top
        for r in rows:
            if r[0] == '#':
                label, _, pre = r[1].partition('  ')
                label = label.upper()
                base = y + M.sub_h * 0.7
                a(f'<text class="sub" x="{px + M.padx:.1f}" y="{base:.1f}" fill="{accent}" fill-opacity="0.8">{escape(label)}</text>')
                end = px + M.padx + M.subf.getlength(label) + 3 * len(label)
                if pre:
                    parts, pw = run(end + 18, base, pre, M.sub_fs * 1.1, color=accent)
                    out.extend(parts)
                    end += 18 + pw
                a(f'<line x1="{end + 22:.1f}" y1="{base - M.sub_fs * 0.3:.1f}" x2="{right:.1f}" y2="{base - M.sub_fs * 0.3:.1f}" '
                  f'stroke="{C["rule"]}" stroke-width="1.5"/>')
                y += M.sub_h
            elif r[0] == '~':
                a(f'<text class="note" x="{px + M.padx:.1f}" y="{y + M.note_h * 0.7:.1f}">{escape(r[1])}</text>')
                y += M.note_h
            elif r[0] == '$':
                text = M.cmd_text(r[1])
                mid = y + M.row_h / 2
                base = mid + M.cmd_fs / 3
                if not r[1].startswith(':'):
                    a(f'<text class="key" x="{px + M.padx:.1f}" y="{base:.1f}" style="font-size:{M.cmd_fs}px;fill:{C["dim"]}">$</text>')
                    parts, w = run(px + M.padx + M.run_width('$ ', M.cmd_fs), base, r[1], M.cmd_fs, color=C['cmd'])
                    w += M.run_width('$ ', M.cmd_fs)
                else:
                    parts, w = run(px + M.padx, base, r[1], M.cmd_fs, color=C['cmd'])
                out.extend(parts)
                if r[2]:
                    a(f'<text class="note" x="{px + M.padx + w + 24:.1f}" y="{base:.1f}">{escape(r[2])}</text>')
                y += M.row_h
            else:
                mid = y + M.row_h / 2
                out.extend(keycaps(px + M.padx, mid, r[0]))
                t = f'<text class="desc" x="{dx:.1f}" y="{mid + M.desc_fs / 3:.1f}">{escape(r[1])}'
                if len(r) > 2:
                    t += f'<tspan class="note" dx="14">{escape(r[2])}</tspan>'
                a(t + '</text>')
                y += M.row_h
        py += ph + GUT
    heights.append(round(py - GUT - TOP))

a('</svg>')
with open(ARGS.out, 'w', encoding='utf-8', newline='\n') as fh:
    fh.write('\n'.join(out))
print(f'scale={M.s} row_h={M.row_h} key_fs={M.key_fs} column heights={heights} limit={BOTTOM - TOP}')
for b in M.overflows():
    print('OVERFLOW', b)
