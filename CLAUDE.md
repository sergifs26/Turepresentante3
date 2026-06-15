# CLAUDE.md — tu representante 3

Guía de contexto para Claude Code en este proyecto.

## Estado del proyecto

Proyecto **nuevo / vacío** de momento: todavía no hay código de aplicación.
Lo único que existe es el **sistema local de gestión de skills** (carpeta `skills-library/`),
montado para poder activar/desactivar skills descargadas sin que estén siempre cargadas.

Cuando se añada código de la aplicación, documentar aquí su stack, comandos y estructura.

## Sistema de skills (lo que hay montado)

### Concepto
- Claude Code solo carga skills que estén en `.claude/skills/`.
- Por eso se guarda una **biblioteca inactiva** en `skills-library/` (que Claude NO detecta).
- **Activar** una skill = copiarla a `.claude/skills/<skill>`.
- **Desactivar** = borrarla de `.claude/skills/<skill>`.

### Estructura
```
tu representante 3/
├── CLAUDE.md
├── .claude/
│   ├── settings.json        # configura la statusline del proyecto
│   └── skills/              # skills ACTIVAS (vacío = ninguna activa)
└── skills-library/          # biblioteca INACTIVA (138 skills, 7 paquetes)
    ├── INDICE.md            # catálogo con descripciones
    ├── README.md            # instrucciones de uso
    ├── activar.ps1          # activar/desactivar por comando
    ├── Panel-Skills.ps1     # panel gráfico (por paquete)
    ├── Panel de Skills.bat  # lanzador del panel (doble clic)
    ├── statusline-skills.ps1# alimenta la statusline
    ├── finance-skills/        (21 skills)
    ├── frontend-design/       (1)
    ├── impeccable/            (1)
    ├── ruflo/                 (81)
    ├── superpowers-dev/       (14)
    ├── taste-skill/           (13)
    └── ui-ux-pro-max-skill/   (7)
```

### Paquetes y origen
| Paquete | Skills | Repositorio GitHub |
|---------|-------:|--------------------|
| finance-skills | 21 | github.com/himself65/finance-skills |
| frontend-design | 1 | github.com/anthropics/claude-code |
| impeccable | 1 | github.com/pbakaus/impeccable |
| ruflo | 81 | github.com/ruvnet/ruflo |
| superpowers-dev | 14 | github.com/obra/superpowers |
| taste-skill | 13 | github.com/leonxlnx/taste-skill |
| ui-ux-pro-max-skill | 7 | github.com/nextlevelbuilder/ui-ux-pro-max-skill |
| **Total** | **138** | |

> Nota: los paquetes habilitados de forma global (vía `enabledPlugins` en
> `~/.claude/settings.json`) son independientes de esta biblioteca local.

### Cómo activar skills

**Opción A — Panel gráfico (recomendado, sin comandos):**
Doble clic en el acceso directo del Escritorio **"Panel de Skills"** (o en
`skills-library\Panel de Skills.bat`). Cada paquete tiene **"Activar todo"** /
**"Quitar todo"** — activa el conjunto entero con un clic.

**Opción B — Por comando (PowerShell, desde la raíz):**
```powershell
.\skills-library\activar.ps1 -Menu        # menú interactivo
.\skills-library\activar.ps1 -List        # listar todas + estado
.\skills-library\activar.ps1 -Status      # ver activas
.\skills-library\activar.ps1 design,brand # activar concretas
.\skills-library\activar.ps1 -Off design  # desactivar
```

Tras activar/desactivar, **recargar Claude Code** para que detecte los cambios.

### Statusline
`.claude/settings.json` define una statusline que muestra siempre, abajo, las skills
activas y el total disponible (ej. `Activas 3/138: design, brand, ...`). La alimenta
`skills-library/statusline-skills.ps1`, que lee `.claude/skills/`.

## Convenciones del entorno
- SO: Windows 11. Shell principal: PowerShell (5.1).
- Los scripts `.ps1` deben evitar caracteres no-ASCII (PS 5.1 los malinterpreta sin BOM).
- El proyecto vive en OneDrive: cuidado con la sincronización al mover carpetas grandes.
