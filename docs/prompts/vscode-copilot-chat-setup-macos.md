# VS Code Copilot Chat setup on macOS

## Table of Contents

- [VS Code Copilot Chat setup on macOS](#vs-code-copilot-chat-setup-on-macos)
  - [Table of Contents](#table-of-contents)
  - [Scope](#scope)
  - [Expert non-default settings](#expert-non-default-settings)
    - [Version checked](#version-checked)
    - [Copy block for `settings.json` (JSONC)](#copy-block-for-settingsjson-jsonc)
    - [Notes](#notes)
  - [Keyboard symbols](#keyboard-symbols)

## Scope

- OS: macOS
- VS Code: 1.109.x (current stable line)
- Copilot: GitHub Copilot Chat extension

## Expert non-default settings

The following options are worth adding if you want better AI outcomes and faster flow in VS Code `1.109.x`.

These are **non-default** values only.

### Version checked

This proposal was checked against:

- VS Code **1.109.3** (stable, macOS)
- GitHub Copilot in VS Code settings reference (current docs for 1.109 line)

References:

- [VS Code 1.109 release notes](https://code.visualstudio.com/updates/v1_109)
- [Copilot settings reference](https://code.visualstudio.com/docs/copilot/reference/copilot-settings)

### Copy block for `settings.json` (JSONC)

```jsonc
{
  // Better steering during long-running requests (default: "steer")
  "chat.requestQueuing.defaultAction": "queue",

  // Allow deeper autonomous runs before stopping (default: 25)
  "chat.agent.maxRequests": 100,

  // Improve file discovery when using #codebase (default: false)
  "github.copilot.chat.codesearch.enabled": true,

  // Improve inline edit context across recently touched files (default: false)
  "github.copilot.chat.editor.temporalContext.enabled": true,

  // Allow custom orchestration with specialised subagents (default: false)
  "chat.customAgentInSubagent.enabled": true,

  // Follow linked instruction files automatically (default: false)
  // CAREFUL: can lead to long-running sessions if instructions link to each other in a loop
  "chat.includeReferencedInstructions": true,

  // Enable folder-level AGENTS.md rules in monorepos (default: false)
  "chat.useNestedAgentsMdFiles": true,

  // Safer, lower-friction terminal execution (default: false)
  "chat.tools.terminal.sandbox.enabled": true, // NOTE: Docker won't run in sandbox
  "chat.tools.terminal.sandbox.macFileSystem": {
    "allowWrite": ["."],
    "denyWrite": ["./.git/"],
    "denyRead": ["~/.ssh/", "~/.aws/"],
  },
  "chat.tools.terminal.sandbox.network": {
    "allowedDomains": ["api.github.com", "registry.npmjs.org", "pypi.org"],
  },

  // Auto-approve request + response for trusted documentation and package URLs (default: [])
  "chat.tools.urls.autoApprove": {
    "https://docs.github.com/": {
      "approveRequest": true,
      "approveResponse": true,
    },
    "https://github.com": {
      "approveRequest": false,
      "approveResponse": true,
    },
    "https://go.dev": {
      "approveRequest": true,
      "approveResponse": true,
    },
    "https://nodejs.org": {
      "approveRequest": true,
      "approveResponse": true,
    },
    "https://pnpm.io": {
      "approveRequest": true,
      "approveResponse": true,
    },
    "https://pypi.org": {
      "approveRequest": true,
      "approveResponse": true,
    },
    "https://python.org": {
      "approveRequest": true,
      "approveResponse": true,
    },
    "https://raw.githubusercontent.com": {
      "approveRequest": true,
      "approveResponse": true,
    },
    "https://rust-lang.org": {
      "approveRequest": true,
      "approveResponse": true,
    },
    "https://typescriptlang.org": {
      "approveRequest": true,
      "approveResponse": true,
    },
    "https://visualstudio.com/": {
      "approveRequest": true,
      "approveResponse": true,
    },
  },

  // Add explicit allow-rules for common read-only commands (default has deny-rules only)
  "chat.tools.terminal.autoApprove": {
    // Allow
    "/^docker\\s+(container|image|network|volume|context|system)\\s+(ls|ps|inspect|history|show|df|info)\\b/": true,
    "/^docker\\s+(ps|images|info|version|inspect|logs|top|stats|port|diff|search|events)\\b/": true,
    "/^docker\\s+compose\\s+(ps|ls|top|logs|images|config|version|port|events)\\b/": true,
    "/^git(\\s+(-C\\s+\\S+|--no-pager))*\\s+branch\\b/": true,
    "/^git(\\s+(-C\\s+\\S+|--no-pager))*\\s+diff\\b/": true,
    "/^git(\\s+(-C\\s+\\S+|--no-pager))*\\s+grep\\b/": true,
    "/^git(\\s+(-C\\s+\\S+|--no-pager))*\\s+log\\b/": true,
    "/^git(\\s+(-C\\s+\\S+|--no-pager))*\\s+ls-files\\b/": true,
    "/^git(\\s+(-C\\s+\\S+|--no-pager))*\\s+show\\b/": true,
    "/^git(\\s+(-C\\s+\\S+|--no-pager))*\\s+status\\b/": true,
    "/^npm\\s+audit$/": true,
    "/^npm\\s+cache\\s+verify\\b/": true,
    "/^npm\\s+config\\s+(list|get)\\b/": true,
    "/^npm\\s+(ls|list|outdated|view|info|show|explain|why|root|prefix|bin|search|doctor|fund|repo|bugs|docs|home|help(-search)?)\\b/": true,
    "/^npm\\s+pkg\\s+get\\b/": true,
    "/^npm\\s+test\\b/": true,
    "/^pnpm\\s+audit\\b(?!.*\\bfix\\b)/": true,
    "/^pnpm\\s+config\\s+(list|get)\\b/": true,
    "/^pnpm\\s+install\\s+--frozen-lockfile\\b/": true,
    "/^pnpm\\s+licenses\\b/": true,
    "/^pnpm\\s+(ls|list|outdated|why|root|bin|doctor)\\b/": true,
    "/^xxd$/": true,
    "/^xxd\\b(\\s+-\\S+)*\\s+[^-\\s]\\S*$/": true,
    "/^yarn\\s+audit\\b(?!.*\\bfix\\b)/": true,
    "/^yarn\\s+cache\\s+dir\\b/": true,
    "/^yarn\\s+config\\s+(list|get)\\b/": true,
    "/^yarn\\s+install\\s+--frozen-lockfile\\b/": true,
    "/^yarn\\s+licenses\\b/": true,
    "/^yarn\\s+(list|outdated|info|why|bin|help|versions)\\b/": true,
    "basename": true,
    "cat": true,
    "cd": true,
    "cmp": true,
    "column": true,
    "cut": true,
    "date": true,
    "df": true,
    "dirname": true,
    "du": true,
    "echo": true,
    "file": true,
    "find": true,
    "grep": true,
    "head": true,
    "ls": true,
    "make lint": true,
    "make test": true,
    "nl": true,
    "npm ci": true,
    "od": true,
    "pwd": true,
    "readlink": true,
    "realpath": true,
    "rg": true,
    "sed": true,
    "sleep": true,
    "sort": true,
    "stat": true,
    "tail": true,
    "tree": true,
    "tr": true,
    "wc": true,
    "which": true,
    // Deny
    "/^column\\b.*\\s-c\\s+[0-9]{4,}/": false,
    "/^date\\b.*\\s(-s|--set)\\b/": false,
    "/^find\\b.*\\s-(delete|exec|execdir|fprint|fprintf|fls|ok|okdir)\\b/": false,
    "/^git(\\s+(-C\\s+\\S+|--no-pager))*\\s+branch\\b.*\\s-(d|D|m|M|-delete|-force)\\b/": false,
    "/^rg\\b.*\\s(--pre|--hostname-bin)\\b/": false,
    "/^sed\\b.*\\s(-[a-zA-Z]*(e|f)[a-zA-Z]*|--expression|--file)\\b/": false,
    "/^sed\\b.*;W/": false,
    "/^sed\\b.*s\\/.*\\/.*\\/[ew]/": false,
    "/^sort\\b.*\\s-(o|S)\\b/": false,
    "/^tree\\b.*\\s-o\\b/": false,
    "chmod": false,
    "chown": false,
    "curl": false,
    "dd": false,
    "eval": false,
    "jq": false,
    "kill": false,
    "ps": false,
    "rm": false,
    "rmdir": false,
    "top": false,
    "wget": false,
    "xargs": false,
  },
}
```

### Notes

- Some settings above are marked _Experimental_ or _Preview_ in VS Code and can change in future releases.
- If you work on highly sensitive codebases, keep URL and terminal approvals strict, and avoid broad auto-approval patterns.

## Keyboard symbols

- Fn (Function) or Globe
- Control (or Ctrl) `⌃`
- Option (or Alt) `⌥`
- Shift `⇧`
- Command (or Cmd) `⌘`
- Esc (Escape) `⎋`
- Return `⏎`
