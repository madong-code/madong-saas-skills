#!/usr/bin/env bash
#
# Madong SaaS Skills 跨编辑器同步脚本（Unix/macOS/Linux 版）
# 将 SKILL.md 分发到各编辑器格式
#
# 用法:
#   ./sync.sh                          # 同步全部
#   ./sync.sh codebuddy                # 只同步 CodeBuddy
#   ./sync.sh cursor                   # 只同步 Cursor
#   ./sync.sh trae                     # 只同步 Trae (Skills + Rules)
#   ./sync.sh copilot                  # 只同步 Copilot
#   ./sync.sh codebuddy,cursor         # 同步多个

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

# 解析目标
RAW_TARGETS=()
if [ $# -gt 0 ]; then
    IFS=',' read -ra RAW_TARGETS <<< "$1"
fi

if [ ${#RAW_TARGETS[@]} -eq 0 ]; then
    TARGETS=("codebuddy" "cursor" "trae" "copilot")
    LABEL="all"
else
    TARGETS=()
    for t in "${RAW_TARGETS[@]}"; do
        TARGETS+=("$(echo "$t" | tr '[:upper:]' '[:lower:]' | xargs)")
    done
    LABEL="${TARGETS[*]}"
fi

# 收集所有 SKILL.md 文件
SKILL_FILES=()
while IFS= read -r -d '' f; do
    SKILL_FILES+=("$f")
done < <(find "$SRC_DIR" -name 'SKILL.md' -not -path '*/node_modules/*' -not -path '*/.git/*' -print0)

echo "Found ${#SKILL_FILES[@]} skill files"
echo "Targets: $LABEL"
echo ""

# 辅助函数：生成技能名称
get_skill_name() {
    local skill_file="$1"
    local rel_path="${skill_file#$SRC_DIR/}"
    echo "${rel_path//\//-}" | sed 's/-SKILL\.md$//'
}

# =============================================================
# 1. CodeBuddy
# =============================================================
if [[ " ${TARGETS[*]} " =~ " codebuddy " ]]; then
    CB_DIR="$ROOT/.codebuddy/skills"
    mkdir -p "$CB_DIR"

    for skill in "${SKILL_FILES[@]}"; do
        name=$(get_skill_name "$skill")
        skill_dir="$CB_DIR/$name"
        mkdir -p "$skill_dir"
        cp "$skill" "$skill_dir/SKILL.md"
        echo "  [CodeBuddy] $name/SKILL.md"
    done
    echo ""
fi

# =============================================================
# 2. Cursor
# =============================================================
if [[ " ${TARGETS[*]} " =~ " cursor " ]]; then
    CURSOR_DIR="$ROOT/.cursor/rules"
    mkdir -p "$CURSOR_DIR"

    for skill in "${SKILL_FILES[@]}"; do
        name=$(get_skill_name "$skill")
        skill_dir="$CURSOR_DIR/$name"
        mkdir -p "$skill_dir"
        cp "$skill" "$skill_dir/rule.mdc"
        echo "  [Cursor] $name/rule.mdc"
    done
    echo ""
fi

# =============================================================
# 3. Trae (Rules + Skills)
# =============================================================
if [[ " ${TARGETS[*]} " =~ " trae " ]]; then

    # 3a. Trae Rules
    TRAE_DIR="$ROOT/.trae/rules"
    mkdir -p "$TRAE_DIR"

    for skill in "${SKILL_FILES[@]}"; do
        name=$(get_skill_name "$skill")
        skill_dir="$TRAE_DIR/$name"
        mkdir -p "$skill_dir"
        dest="$skill_dir/rule.md"

        # 解析 frontmatter 并转换格式
        content=$(cat "$skill")
        if echo "$content" | head -1 | grep -q '^---$'; then
            # 提取 frontmatter
            frontmatter=$(echo "$content" | sed -n '1,/^---/p' | sed '1d;$d')
            body=$(echo "$content" | sed '1,/^---/d' | sed '1,/^---/d')

            desc=""
            globs_list=()
            while IFS= read -r line; do
                if [[ "$line" =~ ^description:\ *(.*) ]]; then
                    desc="${BASH_REMATCH[1]}"
                fi
                if [[ "$line" =~ ^\ +-\ +\"(.*)\" ]]; then
                    globs_list+=("${BASH_REMATCH[1]}")
                fi
            done <<< "$frontmatter"

            new_front=("alwaysApply: false")
            [ -n "$desc" ] && new_front+=("description: $desc")
            if [ ${#globs_list[@]} -gt 0 ]; then
                IFS=', '; new_front+=("globs: \"${globs_list[*]}\""); unset IFS
            fi

            {
                echo "---"
                printf '%s\n' "${new_front[@]}"
                echo "---"
                echo "$body"
            } > "$dest"
        else
            cp "$skill" "$dest"
        fi

        echo "  [Trae Rules] $name/rule.md"
    done

    # 3b. Trae Skills
    TRAE_SKILLS_DIR="$ROOT/.agents/skills"
    mkdir -p "$TRAE_SKILLS_DIR"

    for skill in "${SKILL_FILES[@]}"; do
        name=$(get_skill_name "$skill")
        skill_dir="$TRAE_SKILLS_DIR/$name"
        mkdir -p "$skill_dir"
        cp "$skill" "$skill_dir/SKILL.md"
        echo "  [Trae Skills] $name/SKILL.md"
    done
    echo ""
fi

# =============================================================
# 4. Copilot
# =============================================================
if [[ " ${TARGETS[*]} " =~ " copilot " ]]; then
    COPILOT_DIR="$ROOT/.github"
    mkdir -p "$COPILOT_DIR"
    COPILOT_DEST="$COPILOT_DIR/copilot-instructions.md"

    {
        echo "# Madong SaaS Project Instructions"
        echo ""
        echo "Project-wide coding rules and conventions for the Madong SaaS project."
        echo ""

        for skill in "${SKILL_FILES[@]}"; do
            rel_path="${skill#$SRC_DIR/}"
            category=$(echo "$rel_path" | cut -d'/' -f1)

            # 提取技能名（用最后一段路径）
            base=$(basename "$(dirname "$skill")")
            skill_name="$base"

            echo "---"
            echo ""
            echo "## $category / $skill_name"
            echo ""

            content=$(cat "$skill")
            # 去除 frontmatter
            if echo "$content" | head -1 | grep -q '^---$'; then
                content=$(echo "$content" | sed '1,/^---/d' | sed '1,/^---/d')
            fi
            echo "$content" | sed 's/^[[:space:]]*$//'
            echo ""
        done
    } > "$COPILOT_DEST"

    echo "  [Copilot] copilot-instructions.md"
    echo ""
fi

# =============================================================
# .gitignore (always, in skills source dir)
# =============================================================
GITIGNORE_PATH="$SRC_DIR/.gitignore"
if [ ! -f "$GITIGNORE_PATH" ]; then
    cat > "$GITIGNORE_PATH" << 'EOF'
# Editor rule directories auto-generated by skills-sync.sh
.cursor/
.trae/
.agents/
.github/copilot-instructions.md
EOF
fi

# =============================================================
# 结果汇总
# =============================================================
echo "======= Sync Complete ======="
if [[ " ${TARGETS[*]} " =~ " codebuddy " ]]; then echo "  CodeBuddy   : .codebuddy/skills/{name}/  ${#SKILL_FILES[@]} SKILL.md"; fi
if [[ " ${TARGETS[*]} " =~ " cursor " ]];   then echo "  Cursor      : .cursor/rules/{name}/     ${#SKILL_FILES[@]} rule.mdc"; fi
if [[ " ${TARGETS[*]} " =~ " trae " ]];     then echo "  Trae Rules  : .trae/rules/{name}/       ${#SKILL_FILES[@]} rule.md"; fi
if [[ " ${TARGETS[*]} " =~ " trae " ]];     then echo "  Trae Skills : .agents/skills/{name}/    ${#SKILL_FILES[@]} SKILL.md"; fi
if [[ " ${TARGETS[*]} " =~ " copilot " ]];  then echo "  Copilot     : .github/                  1 aggregated"; fi
echo "============================="
