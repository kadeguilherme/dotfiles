  #!/usr/bin/env bash
  #
  # ai-backend.sh — escolhe o backend de IA: Claude Code, caindo para o OpenCode.
  #
  # Não é executável de propósito. É sourceado pelo git-ai-commit e pelo git-ai-pr,
  # os dois scripts que precisam gerar texto. Ficar num arquivo só evita que um
  # conserto na detecção de credencial valha para um script e não para o outro.
  #
  # O Claude é o preferido. Se ele não estiver instalado, não estiver autenticado,
  # ou a chamada falhar (rede, limite de uso, erro do provider), o OpenCode assume
  # — a ideia é nunca travar o trabalho por causa do backend.
  #
  # Contrato de quem sourceia, tudo definido ANTES do source:
  #   erro(), info()   as funções de saída do script
  #   AI_BACKEND       auto | claude | opencode
  #   AI_MODEL         modelo do Claude
  #   AI_MODEL_OC      modelo do OpenCode, provider/modelo (vazio = default dele)
  #   AI_VAR_BACKEND   nome da variável de ambiente que alimentou AI_BACKEND, só
  #                    para o erro citar a variável que o usuário de fato mexeu
  #
  # Depois do source: chame `escolher_backend` uma vez e gere com `ia_gerar`.

  case "$AI_BACKEND" in
    auto|claude|opencode) ;;
    *) erro "$AI_VAR_BACKEND inválido: '$AI_BACKEND' (use auto, claude ou opencode)" ;;
  esac

  # Estar no PATH não basta: o `claude -p` só responde se houver credencial. Checar
  # antes evita gastar uma tentativa perdida e o usuário ver um erro de auth quando
  # o OpenCode daria conta na hora.
  claude_utilizavel() {
    command -v claude >/dev/null || return 1
    [ -n "${ANTHROPIC_API_KEY:-}${ANTHROPIC_AUTH_TOKEN:-}" ] && return 0
    [ -n "${CLAUDE_CODE_USE_BEDROCK:-}${CLAUDE_CODE_USE_VERTEX:-}" ] && return 0
    [ -s "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.credentials.json" ] && return 0
    # No macOS o login do Claude Code fica no Keychain, não em arquivo.
    if [ "$(uname -s)" = "Darwin" ]; then
      security find-generic-password -s "Claude Code-credentials" >/dev/null 2>&1 && return 0
    fi
    return 1
  }

  opencode_utilizavel() { command -v opencode >/dev/null; }

  # Define AI_BACKEND_ATUAL. Não devolve por stdout de propósito: `erro` aqui
  # precisa derrubar o script, e dentro de $( ) o exit morreria no subshell.
  AI_BACKEND_ATUAL=""
  escolher_backend() {
    case "$AI_BACKEND" in
      # Com backend fixo exigimos o escolhido em vez de cair para o outro sem
      # avisar: quem fixou quer aquele, e o silêncio esconderia o problema.
      claude)
        claude_utilizavel && { AI_BACKEND_ATUAL=claude; return; }
        command -v claude >/dev/null || erro "$AI_VAR_BACKEND=claude, mas o claude não está instalado"
        erro "$AI_VAR_BACKEND=claude, mas não achei credencial do claude — rode 'claude' e faça login"
        ;;
      opencode)
        opencode_utilizavel && { AI_BACKEND_ATUAL=opencode; return; }
        erro "$AI_VAR_BACKEND=opencode, mas o opencode não está instalado"
        ;;
    esac

    if claude_utilizavel; then
      AI_BACKEND_ATUAL=claude
    elif opencode_utilizavel; then
      if command -v claude >/dev/null; then
        info "o claude está instalado mas sem credencial — usando o opencode"
      else
        info "o claude não está instalado — usando o opencode"
      fi
      AI_BACKEND_ATUAL=opencode
    else
      erro "nenhum backend disponível — instale o claude ou o opencode"
    fi
  }

  chamar_claude() {
    claude -p \
      --model "$AI_MODEL" \
      --output-format text \
      --disallowed-tools "Bash Edit Write Read Glob Grep WebFetch WebSearch Task NotebookEdit" 2>/dev/null
  }

  # O agente 'plan' do opencode é somente-leitura — o equivalente do
  # --disallowed-tools acima. Aqui não queremos que ele resolva nada por conta
  # própria, só que escreva o texto pedido.
  chamar_opencode() {
    local args=(run --agent plan)
    [ -n "$AI_MODEL_OC" ] && args+=(--model "$AI_MODEL_OC")
    opencode "${args[@]}" 2>/dev/null
  }

  rotulo_backend() {
    case "$AI_BACKEND_ATUAL" in
      claude) printf 'Claude (%s)' "$AI_MODEL" ;;
      *)      printf 'OpenCode (%s)' "${AI_MODEL_OC:-modelo default do opencode}" ;;
    esac
  }

  # ia_gerar "$prompt" — define AI_SAIDA com a resposta do modelo.
  #
  # Não devolve por stdout de propósito: o fallback precisa mudar AI_BACKEND_ATUAL
  # no shell de verdade, senão a tentativa seguinte repetiria o backend que acabou
  # de falhar.
  ia_gerar() {
    local prompt="$1"
    AI_SAIDA=""

    if [ "$AI_BACKEND_ATUAL" = claude ]; then
      if AI_SAIDA=$(printf '%s\n' "$prompt" | chamar_claude) && [ -n "$AI_SAIDA" ]; then
        return 0
      elif [ "$AI_BACKEND" = auto ] && opencode_utilizavel; then
        # Instalado e autenticado, mas a chamada morreu (rede, limite de uso, erro
        # do provider). Trocamos de backend e não voltamos mais nesta execução.
        info "a chamada ao claude falhou — caindo para o opencode"
        AI_BACKEND_ATUAL=opencode
        AI_SAIDA=""
      else
        printf 'a chamada ao claude falhou\n' >&2
        return 1
      fi
    fi

    AI_SAIDA=$(printf '%s\n' "$prompt" | chamar_opencode) || {
      printf 'a chamada ao opencode falhou\n' >&2
      return 1
    }
    [ -n "$AI_SAIDA" ] || { printf 'o opencode devolveu resposta vazia\n' >&2; return 1; }
  }
