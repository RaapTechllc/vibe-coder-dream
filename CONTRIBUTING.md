# Contributing to Vibe Coder's Dream

Thank you for your interest in contributing! This guide will help you get started.

---

## Code of Conduct

Be respectful. Be helpful. Focus on shipping.

---

## How to Contribute

### Reporting Bugs

1. Check existing issues first
2. Create a new issue with:
   - Clear title
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Node version)

### Suggesting Features

1. Check existing issues/discussions
2. Create a feature request with:
   - Use case description
   - Proposed solution
   - Alternative approaches considered

### Submitting Code

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Test your changes
5. Submit a pull request

---

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/vibe-coder-dream.git
cd vibe-coder-dream

# Create a test project
bash setup.sh test-app
cd test-app

# Start development
npm run dev        # Terminal 1
npx convex dev     # Terminal 2
```

---

## Project Structure

```
vibe-coder-dream/
├── agents/          # AI agent definitions
├── skills/          # Reusable code patterns
├── templates/       # File templates
├── setup.sh         # Project generator
├── CLAUDE.md        # AI coding guidelines
├── cloud.md         # AI orchestration
└── README.md        # Documentation
```

---

## Contribution Areas

### High Priority

- **Bug fixes** in setup script
- **Documentation** improvements
- **New skills** for common patterns
- **Agent improvements** for better AI assistance

### Good First Issues

Look for issues labeled `good first issue` or `help wanted`.

---

## Writing Skills

Skills are reusable code patterns. To add a new skill:

1. Create folder: `skills/[skill-name]/`
2. Add `SKILL.md` with:
   - Purpose and triggers
   - Code patterns with examples
   - Best practices
3. Add `README.md` for quick reference
4. Test patterns work correctly

### Skill Template

```markdown
# [Skill Name] Skill

**Purpose**: [What this skill does]
**Triggers**: "[keyword1]", "[keyword2]"

---

## Pattern 1: [Name]

\`\`\`typescript
// Code example
\`\`\`

---

## Best Practices

### Always Do
- [Practice 1]
- [Practice 2]

### Never Do
- [Anti-pattern 1]
- [Anti-pattern 2]
```

---

## Writing Agents

Agents define AI behavior for specific tasks. To modify an agent:

1. Edit the agent file in `agents/`
2. Test with real tasks
3. Document changes in PR

### Agent Structure

```markdown
# [Agent Name]

**Purpose**: [What this agent does]
**Trigger**: [Commands/keywords]
**Mode**: [fast/surgical/careful/aesthetic]

## Behavior
[How the agent works]

## Rules
[What the agent must/must not do]

## Handoff Protocol
[How it receives and sends context]
```

---

## Commit Guidelines

Use conventional commits:

```
feat: add user profile skill
fix: resolve middleware redirect loop
docs: update troubleshooting guide
chore: update dependencies
```

### Commit Message Format

```
<type>: <short description>

[optional body with more details]

[optional footer with breaking changes or issue references]
```

---

## Pull Request Process

1. **Title**: Clear, descriptive title
2. **Description**: What changed and why
3. **Testing**: Describe how you tested
4. **Screenshots**: For UI changes
5. **Breaking changes**: Note any breaking changes

### PR Template

```markdown
## Summary
[Brief description of changes]

## Changes
- [Change 1]
- [Change 2]

## Testing
- [ ] Tested setup script
- [ ] Tested with Claude Code
- [ ] Tested generated project

## Screenshots
[If applicable]
```

---

## Testing

Before submitting:

```bash
# Test setup script creates working project
bash setup.sh test-project
cd test-project
npm run dev  # Should start without errors

# Test TypeScript compiles
npm run typecheck

# Test linting passes
npm run lint
```

---

## Style Guide

### Markdown

- Use ATX-style headers (`#`, `##`, `###`)
- Use fenced code blocks with language tags
- Add blank lines between sections
- Keep lines under 100 characters when possible

### Code Examples

- Use TypeScript
- Include imports
- Show complete, runnable examples
- Add comments for non-obvious parts

### Documentation

- Be concise
- Use examples over explanations
- Keep it scannable (headers, bullets, tables)
- Link to external docs when appropriate

---

## Questions?

- Open a discussion on GitHub
- Check existing issues
- Read the documentation first

---

## Recognition

Contributors are recognized in:
- README acknowledgments
- Release notes
- GitHub contributor graph

Thank you for helping make Vibe Coder's Dream better!

---

*Ship fast. Stay type-safe. Zero friction.*
