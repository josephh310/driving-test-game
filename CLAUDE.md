# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Roblox driving game where players navigate obstacle courses to pass driving tests and earn licenses. Built with Luau using a service-oriented architecture.

## Build & Tooling Commands

- `npm run build:rojo` — regenerates `default.project.json` from source tree (runs `Scripts/genRojoTree.js`)
- `npm run watch:rojo` — watches `Source/` and auto-regenerates the Rojo project file on changes
- `wally install` — install Luau packages to `Packages/`
- `rojo serve` — start Rojo live sync with Roblox Studio

Toolchain is managed via Rokit (`rokit.toml`): Rojo 7.7.0-rc.1, Wally 0.3.2, wally-package-types 1.6.2.

**Important:** `default.project.json` is auto-generated — do not edit it manually. Modify `Scripts/genRojoTree.js` instead.

## Architecture

### Service Pattern

Services live in `Source/Services/<ServiceName>/` and follow a client-server split:

| File | Runs on | Mapped to |
|------|---------|-----------|
| `<Name>Server.luau` | Server | `ServerScriptService.Services.<Name>/` |
| `<Name>Client.luau` | Client | `ReplicatedStorage.Shared.Services.<Name>/` |
| `Shared.luau` | Both | `ReplicatedStorage.Shared.Services.<Name>/` |
| `Utils.luau` | Varies | Same as parent |

Services communicate via **Networker** (RPC/events). Each service exposes an `:init()` method called from the startup scripts.

**Initialization order matters.** Server: Data → Badge → Marketplace → Physics → Skip → Vehicle → Obstacle → Camera → Conch. Client: Data → Marketplace → Vehicle → Obstacle → Skip → Music → Interface → Camera → Conch.

### Component System

Tag-based components in `Source/Modules/Components/Server/` and `Source/Modules/Components/Client/`. Each component module exports a function that receives an Instance and returns a cleanup function. Components are registered via `Observers.observeTag()` and loaded by ObstacleService.

### Data Flow

PlayerData is defined in `DataService/Shared.luau` as a template. Server persists via ProfileStore (mock mode in Studio). Changes sync to client via Networker, and UI reacts through `connect_to_value_changed()` on DataServiceClient.

### UI System

`Source/Interface/` contains GameScreens (full screens), GameHUD (overlay elements), and Components (tag-based UI behaviors). The Interface module initializes all sub-modules on client startup.

### Rojo Mapping

`genRojoTree.js` handles file-to-Roblox mapping automatically with these rules:
- Files/folders named `Server` → `ServerScriptService`
- Everything else → `ReplicatedStorage.Shared`
- `Interface/` and `Startup/` are mapped manually (blacklisted from auto-generation)

## Code Conventions

- **File headers:** `--[[ @Title, @Author, @Description ]]` docstring blocks
- **Naming:** snake_case for functions/variables, PascalCase for modules/types, SCREAMING_SNAKE_CASE for constants
- **Types:** Use Luau type annotations; export types with `export type`
- **Cleanup:** Components and observers return cleanup functions; use Trove for resource management
- **Signals:** Use sleitnick/Signal for custom events