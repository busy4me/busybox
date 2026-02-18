# BusyBox — Internationalization (i18n) Documentation Plan

> **Structure and guidelines for multi-language documentation.**

---

## Current Status

| Language | Code | Status | Location |
|----------|------|--------|---------|
| 🇬🇧 English | `en` | ✅ **Active (primary)** | `docs/` (root) |
| 🇪🇸 Spanish | `es` | 🔲 Planned | `docs/i18n/es/` |
| 🇩🇪 German | `de` | 🔲 Planned | `docs/i18n/de/` |
| 🇫🇷 French | `fr` | 🔲 Planned | `docs/i18n/fr/` |
| 🇮🇹 Italian | `it` | 🔲 Planned | `docs/i18n/it/` |
| 🇷🇺 Russian | `ru` | 🔲 Planned | `docs/i18n/ru/` |
| 🇨🇳 Chinese (Simplified) | `zh-CN` | 🔲 Planned | `docs/i18n/zh-CN/` |
| 🇯🇵 Japanese | `ja` | 🔲 Planned | `docs/i18n/ja/` |
| 🇰🇷 Korean | `ko` | 🔲 Planned | `docs/i18n/ko/` |
| 🇹🇼 Chinese (Traditional) | `zh-TW` | 🔲 Planned | `docs/i18n/zh-TW/` |
| 🇵🇹 Portuguese (BR) | `pt-BR` | 🔲 Planned | `docs/i18n/pt-BR/` |
| 🇮🇳 Hindi | `hi` | 🔲 Planned | `docs/i18n/hi/` |

---

## Directory Structure

```
docs/
├── VISION.md                    ← EN (primary)
├── architecture/
│   └── ARCHITECTURE.md          ← EN (primary)
├── process/
│   └── PROCESS-FLOW.md          ← EN (primary)
├── plugins/
│   └── PLUGINS.md               ← EN (primary)
├── reference/
│   ├── initiv.md
│   └── commands/
└── i18n/                        ← All translations live here
    ├── README.md                ← This file (translation index)
    ├── es/                      ← Spanish
    │   ├── VISION.md
    │   ├── architecture/
    │   │   └── ARCHITECTURE.md
    │   ├── process/
    │   │   └── PROCESS-FLOW.md
    │   └── plugins/
    │       └── PLUGINS.md
    ├── de/                      ← German
    │   └── ...
    ├── fr/                      ← French
    │   └── ...
    ├── it/                      ← Italian
    │   └── ...
    ├── ru/                      ← Russian
    │   └── ...
    ├── zh-CN/                   ← Chinese Simplified
    │   └── ...
    ├── ja/                      ← Japanese
    │   └── ...
    └── ko/                      ← Korean
        └── ...
```

---

## Translation Priority (by document)

Documents to translate first (highest impact):

| Priority | Document | Reason |
|---------|----------|--------|
| 1 | `VISION.md` | First impression for new users |
| 2 | `README.md` (root) | GitHub landing page |
| 3 | `process/PROCESS-FLOW.md` | Essential for understanding the system |
| 4 | `architecture/ARCHITECTURE.md` | For developers |
| 5 | `plugins/PLUGINS.md` | For plugin developers |

---

## Translation Contribution Guidelines

### File Naming
- Keep **identical filenames** as English originals
- Only the **content** changes, not the structure
- Keep **code blocks in English** — do not translate commands, file paths, or code

### What to Translate
- ✅ Headings and descriptions
- ✅ Explanatory text
- ✅ Table cell content (non-technical values)
- ✅ Notes and warnings

### What NOT to Translate
- ❌ Code blocks (bash, yaml, python etc.)
- ❌ File paths (`/opt/busybox/`, `~/.config/`)
- ❌ Technical variable names (`DISPLAY`, `XAUTHORITY`)
- ❌ Command names (`screen`, `xdotool`, `vncserver`)
- ❌ Table headers (keep them in English for consistency)

### Header Block (add to every translated file)

```markdown
> 🌐 **Translation**: [English](../../VISION.md) | **Español** | [Deutsch](../de/VISION.md) | ...
> 📅 **Translated**: 2026-XX-XX | **Source version**: 1.1.23-beta
```

---

## Translation Workflow

### Step 1: Create language directory
```bash
mkdir -p docs/i18n/es/architecture
mkdir -p docs/i18n/es/process
mkdir -p docs/i18n/es/plugins
```

### Step 2: Copy English source
```bash
cp docs/VISION.md docs/i18n/es/VISION.md
```

### Step 3: Translate content, add header block

### Step 4: Submit PR with label `translation:es`

---

## Language-Specific Notes

### 🇨🇳 Chinese (Simplified) / 🇹🇼 Chinese (Traditional)

- Use Traditional Chinese for Taiwan/Hong Kong audience
- Use Simplified Chinese for Mainland China / Singapore
- CJK characters in headings are acceptable

### 🇯🇵 Japanese / 🇰🇷 Korean

- Technical terms can be kept in English with katakana pronunciation
- Example: `VNCサーバー` (VNC Server in Japanese)

### 🇷🇺 Russian

- Technical terms typically kept in English or standard Russian equivalents
- Maintain code blocks in Latin script

---

## Future: Machine Translation + Human Review Process

For initial translations:
1. Use AI translation (DeepL / GPT-4) for first draft
2. Native speaker review for technical accuracy
3. PR review with language-specific label
4. Merge and track version in translation header

---

**Author**: Dariusz Porczyński  
**Last Updated**: 2026-02-18
