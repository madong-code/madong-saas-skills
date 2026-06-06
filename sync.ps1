<#
.SYNOPSIS
  Madong SaaS Skills 跨编辑器同步脚本
  将 SKILL.md 分发到各编辑器格式

.PARAMETER target
  指定要同步的编辑器，多个用逗号分隔。可选值：
    codebuddy, cursor, trae, copilot
  不传则同步全部。

.EXAMPLE
  # 同步全部（默认）
  powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1

  # 只同步 CodeBuddy
  powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1 -target codebuddy

  # 只同步 Trae（含 Skills + Rules）
  powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1 -target trae

  # 同步多个
  powershell -ExecutionPolicy Bypass -File madong-saas-skills\sync.ps1 -target codebuddy,cursor
#>

param(
    [string[]]$target
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$srcDir = $PSScriptRoot

# 解析目标
$rawTargets = if ($target) { $target } else { @() }
if ($rawTargets.Count -eq 0) {
    $targets = @('codebuddy', 'cursor', 'trae', 'copilot')
    $label = 'all'
} else {
    $targets = $rawTargets | ForEach-Object { $_.ToLower().Trim() }
    $label = "$($targets -join ', ')"
}

# 收集所有 SKILL.md 文件
$skills = Get-ChildItem -Recurse -Filter 'SKILL.md' -Path $srcDir | Where-Object {
    $_.DirectoryName -notmatch 'node_modules|\.git'
}

Write-Host "Found $($skills.Count) skill files" -ForegroundColor Green
Write-Host "Targets: $label" -ForegroundColor Gray
Write-Host ""

# 辅助函数：生成技能名称
function Get-SkillName($skillFile) {
    $relPath = $skillFile.FullName.Replace("$srcDir\", '').Replace("$srcDir/", '')
    return ($relPath -replace '[/\\]', '-') -replace '-SKILL\.md$', ''
}

function Write-Summary($label, $path, $count, $format) {
    Write-Host "$($label.PadRight(14)): $path ($count $format)" -ForegroundColor Cyan
}

# =============================================================
# 1. CodeBuddy
# =============================================================
if ($targets -contains 'codebuddy') {
    $cbDir = Join-Path $root '.codebuddy\skills'
    New-Item -ItemType Directory -Force -Path $cbDir | Out-Null

    foreach ($skill in $skills) {
        $name = Get-SkillName $skill
        $skillDir = Join-Path $cbDir $name
        New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
        $dest = Join-Path $skillDir 'SKILL.md'
        Copy-Item -Path $skill.FullName -Destination $dest -Force
        Write-Host "  [CodeBuddy] $name/SKILL.md" -ForegroundColor Cyan
    }
    Write-Host ""
}

# =============================================================
# 2. Cursor
# =============================================================
if ($targets -contains 'cursor') {
    $cursorDir = Join-Path $root '.cursor\rules'
    New-Item -ItemType Directory -Force -Path $cursorDir | Out-Null

    foreach ($skill in $skills) {
        $name = Get-SkillName $skill
        $skillDir = Join-Path $cursorDir $name
        New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
        $dest = Join-Path $skillDir 'rule.mdc'
        Copy-Item -Path $skill.FullName -Destination $dest -Force
        Write-Host "  [Cursor] $name/rule.mdc" -ForegroundColor Cyan
    }
    Write-Host ""
}

# =============================================================
# 3. Trae (Rules + Skills)
# =============================================================
if ($targets -contains 'trae') {

    # 3a. Trae Rules
    $traeDir = Join-Path $root '.trae\rules'
    New-Item -ItemType Directory -Force -Path $traeDir | Out-Null

    foreach ($skill in $skills) {
        $name = Get-SkillName $skill
        $skillDir = Join-Path $traeDir $name
        New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
        $dest = Join-Path $skillDir 'rule.md'

        $content = Get-Content $skill.FullName -Raw

        if ($content -match '(?s)^---\n(.*?)\n---\n(.*)$') {
            $frontmatter = $matches[1]
            $body = $matches[2]

            $desc = ''
            $globsList = @()
            foreach ($line in $frontmatter -split "`n") {
                if ($line -match '^description:\s*(.*)') {
                    $desc = $matches[1]
                }
                if ($line -match '^\s+-\s+"(.*)"') {
                    $globsList += $matches[1]
                }
            }

            $newFront = @()
            $newFront += 'alwaysApply: false'
            if ($desc) { $newFront += "description: $desc" }
            if ($globsList.Count -gt 0) {
                $newFront += 'globs: "' + ($globsList -join ', ') + '"'
            }

            $newContent = "---`n" + ($newFront -join "`n") + "`n---`n$body"
            [System.IO.File]::WriteAllText($dest, $newContent, [System.Text.UTF8Encoding]::new($false))
        } else {
            Copy-Item -Path $skill.FullName -Destination $dest -Force
        }

        Write-Host "  [Trae Rules] $name/rule.md" -ForegroundColor Cyan
    }

    # 3b. Trae Skills
    $traeSkillsDir = Join-Path $root '.agents\skills'
    New-Item -ItemType Directory -Force -Path $traeSkillsDir | Out-Null

    foreach ($skill in $skills) {
        $name = Get-SkillName $skill
        $skillDir = Join-Path $traeSkillsDir $name
        New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
        $dest = Join-Path $skillDir 'SKILL.md'
        Copy-Item -Path $skill.FullName -Destination $dest -Force
        Write-Host "  [Trae Skills] $name/SKILL.md" -ForegroundColor Cyan
    }
    Write-Host ""
}

# =============================================================
# 4. Copilot
# =============================================================
if ($targets -contains 'copilot') {
    $copilotDir = Join-Path $root '.github'
    New-Item -ItemType Directory -Force -Path $copilotDir | Out-Null
    $copilotDest = Join-Path $copilotDir 'copilot-instructions.md'

    $sb = New-Object System.Text.StringBuilder
    $null = $sb.AppendLine("# Madong SaaS Project Instructions")
    $null = $sb.AppendLine("")
    $null = $sb.AppendLine("Project-wide coding rules and conventions for the Madong SaaS project.")
    $null = $sb.AppendLine("")

    foreach ($skill in $skills) {
        $relPath = $skill.FullName.Replace("$srcDir\", '').Replace("$srcDir/", '')
        $category = ($relPath -split '[/\\]')[0]
        $skillName = (($relPath -replace '[/\\]', '-') -replace '-SKILL\.md$', '') -split '-' | Select-Object -Last 1

        $null = $sb.AppendLine("---")
        $null = $sb.AppendLine("")
        $null = $sb.AppendLine("## $category / $skillName")

        $content = Get-Content $skill.FullName -Raw
        $content = $content -replace '(?s)^---\n.*?\n---\n', ''
        $null = $sb.AppendLine("")
        $null = $sb.AppendLine($content.Trim())
        $null = $sb.AppendLine("")
    }

    [System.IO.File]::WriteAllText($copilotDest, $sb.ToString())
    Write-Host "  [Copilot] copilot-instructions.md" -ForegroundColor Cyan
    Write-Host ""
}

# =============================================================
# .gitignore (always, in skills source dir)
# =============================================================
$gitignorePath = Join-Path $srcDir '.gitignore'
if (-not (Test-Path $gitignorePath)) {
    @"
# Editor rule directories auto-generated by skills-sync.ps1
.cursor/
.trae/
.agents/
.github/copilot-instructions.md
"@ | Set-Content -Path $gitignorePath -Encoding UTF8
}

# =============================================================
# 结果汇总
# =============================================================
Write-Host "======= Sync Complete =======" -ForegroundColor Yellow
if ($targets -contains 'codebuddy') { Write-Summary 'CodeBuddy'    '.codebuddy/skills/{name}/'  $skills.Count 'SKILL.md' }
if ($targets -contains 'cursor')   { Write-Summary 'Cursor'       '.cursor/rules/{name}/'     $skills.Count 'rule.mdc'  }
if ($targets -contains 'trae')     { Write-Summary 'Trae Rules'   '.trae/rules/{name}/'       $skills.Count 'rule.md'   }
if ($targets -contains 'trae')     { Write-Summary 'Trae Skills'  '.agents/skills/{name}/'    $skills.Count 'SKILL.md'  }
if ($targets -contains 'copilot')  { Write-Summary 'Copilot'      '.github/'                  '1'           'aggregated' }
Write-Host "=============================" -ForegroundColor Yellow