# Project Brief: Zenvestor

## Executive Summary

Zenvestor is an opinionated stock trading and portfolio management application implementing disciplined, multi-stage trading through automated execution. The platform enforces systematic entry/exit strategies via Alpaca API integration, removing emotional decision-making from trading.

Core value: Gradual position building through price confirmation combined with predefined exits, portfolio risk management, and integrated journaling—transforming chaotic trading into systematic execution.

Target: Serious individual traders experienced with CAN SLIM methodology who value discipline and systematic approaches.

## Problem Statement

Current trading tools force compromises between strategy sophistication and practical execution, while human psychology sabotages performance at critical moments.

**Key Problems:**
- **Emotional exits** destroy returns—hard to sell when winning or losing
- **Manual constraints** limit to simple 3-lot entries when 10-lot strategies would reduce risk
- **Operational overwhelm** during rallies when multiple targets trigger across portfolios
- **Single-strategy exits** leave money on the table vs. multiple simultaneous strategies
- **Broken learning loop** from scattered Excel journals prevents systematic improvement
- **High stakes** in concentrated 8-stock portfolios where each decision materially impacts returns

## Proposed Solution

Zenvestor enables sophisticated strategies previously impossible to execute manually:

- **Automated pyramiding entries**: 3-10+ configurable lots with decreasing size as price rises
- **Multi-strategy exits**: Enforce multiple rules simultaneously without emotion
- **Portfolio analytics**: Real-time concentration, sector exposure, and risk metrics
- **Alpaca integration**: Direct order placement without constant monitoring
- **Integrated journaling**: Structured capture linked to specific decisions for pattern mining

## Target Users

**The Disciplined CAN SLIM Practitioner**
- Concentrated portfolios (4-8 stocks typical, up to 15-20 before culling)
- Account sizes from $1K to tens of millions
- 1-2 hours daily commitment (reducible to 15 minutes with Zenvestor)
- Currently using MarketSmith/ThinkorSwim + Excel + scattered journals
- Part of CAN SLIM community (IBD, O'Neil Report, Minervini circles)

## Goals & Success Metrics

**Primary Goal**: Make systematic CAN SLIM trading easier and more successful.

**Business Objectives**:
1. Build robust platform improving trading execution
2. Create community hub for systematic traders
3. Enable performance measurement and sharing
4. Advance systematic trading knowledge

**Success Metrics**:
- Time: 2 hours → 15 minutes daily
- Execution: Enable 5-10 lot strategies
- Adherence: 95%+ automated rule execution
- Performance: Track win rate, risk/reward, drawdowns vs. benchmarks

**Timeline**:
- Months 1-3: Personal trading platform
- Months 4-12: Platform hardening, advanced strategies
- Year 2+: Community features, social trading

## MVP Scope (2-3 months)

**Must Have**:
- Multi-portfolio support (2-3 portfolios)
- Stock database (symbol, name, sector/industry groups)
- Target management with pivots and multi-lot configuration
- Alpaca API integration for automated execution
- Real-time portfolio analytics
- Stop-loss exit strategy
- Trading history and performance tracking
- Decision journaling system
- Flutter + CLI interfaces

**Out of Scope**:
- Advanced indicators (ATR, RS)
- Multiple exit strategies
- Social features
- Import/export capabilities

## Post-MVP Vision

**Phase 2 (Months 4-12)**:
- Moving average and relative strength exit strategies
- Selling into strength with reinvestment queuing
- Polish UI/CLI interfaces
- Technical indicator calculations

**Phase 3 (Year 2+)**:
- Multi-tenant architecture
- Performance sharing and leaderboards
- Strategy marketplace
- Educational content
- Mobile optimization

**Long-term**: AI-powered journal insights, additional broker integrations, extensible platform.

## Technical Considerations

**Stack**: Dart/Serverpod backend, Flutter frontend, PostgreSQL, Bloc pattern
**Architecture**: Clean architecture with presentation/application/domain/infrastructure layers
**Priorities**: Maintainability first (automated testing, documentation), then rapid development
**Infrastructure**: Docker containers, future Serverpod Cloud consideration

## Constraints & Assumptions

**Constraints**:
- Serverpod patterns and authentication
- Alpaca API dependencies
- 2-3 month timeline
- US markets only
- CAN SLIM focus

**Assumptions**:
- Alpaca handles order monitoring reliably
- Trade history retained forever
- Users understand CAN SLIM
- AI-assisted development with structured patterns

## Risks & Open Questions

**Technical Risks**:
1. Alpaca API reliability
2. Real-time sync complexity
3. Order execution edge cases

**Business Risks**:
1. Scope creep potential
2. Single to multi-tenant scaling
3. Methodology lock-in

**Open Questions**:
- Offline/online sync strategy
- Corporate action handling approach
- Legal disclaimer requirements

## Next Steps

1. Review and finalize this brief
2. Save as `docs/project-brief.md`
3. Create PRD with Product Manager agent
4. Research Alpaca API specifics

### PM Handoff

This brief defines Zenvestor—a sophisticated CAN SLIM trading platform with:
- Multi-portfolio support (2-3)
- Pyramiding entries (3-10 lots)
- Alpaca automation
- Parallel CLI/Flutter development
- Clean architecture focus
- 2-3 month MVP timeline

Ready for PRD development with detailed epics and stories.