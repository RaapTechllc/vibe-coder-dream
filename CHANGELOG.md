# Changelog

All notable changes to Vibe Coder Dream are documented here.

---

## [2.1.0] - December 2025

### Added

- **Handoff Validation Protocol** for all 4 agents
  - Context validation before starting work
  - Required file checks
  - Missing information reporting
  - Resume capability with handoff context

- **Conflict Detection System**
  - File locking to prevent parallel conflicts
  - Job priority queue (fix > ship > vibe > style)
  - Auto-serialization for conflicting jobs
  - User alerts for queue issues

- **Timeout Policies** in cloud.md
  - Soft/hard timeouts per agent
  - Graceful degradation behavior
  - Emergency handoff generation

- **Retry Policy** in cloud.md
  - Network errors: 3x with exponential backoff
  - Build failures: 1x after fix attempt
  - Deploy failures: 1x then rollback
  - Auth errors: No retry, report to user

- **Job Queue Documentation**
  - Concurrency limits per command type
  - Priority ordering
  - Queue behavior specifications

- **LICENSE** file (MIT)
- **CONTRIBUTING.md** with contribution guidelines

- **Self-Healing Protocol** in cloud.md and fix-agent.md
  - Error classification (project-specific vs boilerplate-related)
  - Backtrack protocol for root cause analysis
  - Auto-update rules for boilerplate improvements
  - Continuous improvement loop diagram

### Removed (Fluff Cleanup)

- **ORCHESTRATOR_REVIEW.md** - Obsolete review document (recommendations implemented)
- **skills/*/README.md** - Redundant with SKILL.md files
- **templates/feature/README.md** - Duplicated patterns in skills

### Changed

- **README.md** completely rewritten for GitHub showcase
  - Added tech stack badges
  - Better project explanation
  - Clearer quick start
  - Agent features highlight

- **Agent definitions** enhanced with operational protocols
  - vibe-agent: Full handoff and conflict sections
  - fix-agent: Minimal change guarantee
  - ship-agent: Deployment lock and rollback protocol
  - style-agent: Design system compliance

### Documentation

- Skills verified as production-ready
- All 4 skills have comprehensive patterns

---

## [2.0.0] - December 2025

### Added

- **Improved setup script** with better error handling and progress indicators
- **Node.js version checking** (requires 18+)
- **Project name validation** (lowercase, no spaces)
- **Directory existence check** before creating project
- **Colored terminal output** for better readability
- **Template files** (package.json, tsconfig.json, .gitignore)
- **README.md** with quick start guide
- **TROUBLESHOOTING.md** with common issues and solutions
- **CHANGELOG.md** (this file)

### Changed

- Setup script now uses `npx shadcn@latest` (new CLI name)
- Better Convex initialization with `--configure=new` flag
- shadcn/ui setup now pre-creates `components.json` and `utils.ts`
- Improved error messages with specific solutions
- Git commit message includes version number

### Fixed

- shadcn init might fail silently - now has fallback
- Convex types not generated - now runs proper dev command
- Disk space check for Windows compatibility

### Documentation

- Added Getting Started section to README
- Added troubleshooting for common issues
- Added performance tips

---

## [1.0.0] - November 2025

### Initial Release

- Basic setup script for Next.js 14 + Clerk + Convex + shadcn/UI
- AI agent configurations (vibe, fix, style, ship)
- Skill modules (convex-crud, shadcn-forms, clerk-auth, realtime-sync)
- CLAUDE.md with coding patterns and conventions
- Basic boilerplate files generation

---

## Migration Guide: v1 to v2

### Breaking Changes

None - v2 is fully backward compatible.

### Recommended Updates

1. **Update setup script**:
   ```bash
   # Download new version
   curl -fsSL https://raw.githubusercontent.com/your-repo/setup.sh -o setup.sh
   ```

2. **For existing projects**, add these files:
   - Copy `TROUBLESHOOTING.md` to your project
   - Update `package.json` with new scripts if needed

3. **Update shadcn CLI** (in existing projects):
   ```bash
   # New CLI name
   npx shadcn@latest add [component]

   # Instead of
   npx shadcn-ui@latest add [component]
   ```

---

## Upcoming Features

Planned for future releases:

- [ ] Testing patterns (Vitest + Playwright)
- [ ] CI/CD workflow templates
- [ ] Rate limiting patterns
- [ ] Role-based access control (RBAC)
- [ ] File upload patterns
- [ ] Pagination patterns
- [ ] Multi-tenancy support

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 2.1.0 | Dec 2025 | Handoff validation, conflict detection, job queue |
| 2.0.0 | Dec 2025 | Improved setup, troubleshooting, better DX |
| 1.0.0 | Nov 2025 | Initial release |

---

*For detailed changes, see the git commit history.*
