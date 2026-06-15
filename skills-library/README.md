# skills-library

Biblioteca local de **138 skills** descargadas de 7 marketplaces de GitHub.

> **Importante:** Las skills aquí están **INACTIVAS**. Claude Code solo detecta skills
> en `.claude/skills/` del proyecto (o globales), **no** en esta carpeta `skills-library/`.
> Por eso nada de esto se carga hasta que tú actives una skill explícitamente.

## Estructura

```
skills-library/
├── INDICE.md          <- catálogo de las 138 skills con descripción
├── activar.ps1        <- script para activar/desactivar
├── README.md
├── finance-skills/        (21 skills)
├── frontend-design/       (1)
├── impeccable/            (1)
├── ruflo/                 (81)
├── superpowers-dev/       (14)
├── taste-skill/           (13)
└── ui-ux-pro-max-skill/   (7)
```

## Cómo activar / desactivar

Desde la raíz del proyecto, en PowerShell:

```powershell
# Ver todas las skills y cuáles están activas
.\skills-library\activar.ps1 -List

# Activar una (se copia a .claude\skills\)
.\skills-library\activar.ps1 design

# Activar varias a la vez
.\skills-library\activar.ps1 design,brutalist-skill,ui-ux-pro-max

# Ver qué hay activo ahora
.\skills-library\activar.ps1 -Status

# Desactivar (se borra de .claude\skills\)
.\skills-library\activar.ps1 -Off design
```

Tras activar/desactivar, **recarga Claude Code** para que detecte el cambio.

## Origen de cada paquete

| Paquete | Repositorio |
|---------|-------------|
| finance-skills | github.com/himself65/finance-skills |
| frontend-design | github.com/anthropics/claude-code |
| impeccable | github.com/pbakaus/impeccable |
| ruflo | github.com/ruvnet/ruflo |
| superpowers-dev | github.com/obra/superpowers |
| taste-skill | github.com/leonxlnx/taste-skill |
| ui-ux-pro-max-skill | github.com/nextlevelbuilder/ui-ux-pro-max-skill |
