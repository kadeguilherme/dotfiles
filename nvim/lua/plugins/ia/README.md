# IA no Neovim

Três plugins, cada um com um papel:

| Arquivo | Plugin | Papel | Estado |
|---|---|---|---|
| `copilot.lua` | copilot.lua | Texto cinza que completa enquanto você digita | Ligado |
| `sidekick.lua` | sidekick.nvim | Próxima edição com `<Tab>` + abrir opencode/Claude Code no nvim | Ligado |
| `minuet.lua` | minuet-ai.nvim | Substituto do Copilot usando Mistral (Codestral) | Desligado |

## Preparar a máquina

1. Neovim 0.11.2 ou mais novo.
2. Node e npm instalados (o Mason usa para baixar o servidor do Copilot).
3. `opencode` e/ou `claude` no PATH. Só o que estiver instalado funciona.
4. `tmux` é opcional: com ele, a conversa com o agente continua viva se o nvim fechar.
5. Abra o nvim e espere o Lazy e o Mason terminarem de instalar.
6. Faça login no Copilot: `:Copilot auth`.
7. Confira: `:checkhealth sidekick`. A seção "Copilot LSP" deve estar OK.
   Se pedir login, rode `:LspCopilotSignIn`.

## Atalhos

`<leader>` é a tecla espaço.

### Enquanto digita (Copilot)

| Tecla | Ação |
|---|---|
| `Alt+l` | Aceita a sugestão inteira |
| `Alt+w` | Aceita só a próxima palavra |
| `Alt+j` | Aceita só a linha |
| `Alt+n` / `Alt+p` | Próxima / anterior alternativa |
| `Alt+d` | Descarta |
| `<leader>uc` | Liga/desliga a sugestão automática no buffer |

### Próxima edição (sidekick)

| Tecla | Ação |
|---|---|
| `<Tab>` | 1ª vez: pula até a edição sugerida. 2ª vez: aplica |
| `<Esc>` | Ignora a sugestão |

### Agentes (sidekick)

| Tecla | Ação |
|---|---|
| `<leader>ao` | Abre/fecha o opencode |
| `<leader>ac` | Abre/fecha o Claude Code |
| `<leader>aa` | Abre/fecha o último agente usado |
| `<leader>as` | Escolhe um agente da lista |
| `<leader>at` | Envia o trecho sob o cursor (ou a seleção) |
| `<leader>av` | Envia a seleção (modo visual) |
| `<leader>af` | Envia o arquivo atual |
| `<leader>ap` | Prompts prontos (explicar, corrigir erros, revisar, testes) |
| `<leader>ad` | Desanexa a sessão (ela continua no tmux) |

## No dia a dia

- **Mudou algo que se repete** (renomeou um campo, trocou uma assinatura):
  aperte `<Tab>` para ir até o próximo lugar e `<Tab>` de novo para aplicar.
- **Quer delegar uma tarefa:** selecione o código, `<leader>at`, escreva o pedido
  no agente e dê Enter. Os arquivos que ele editar recarregam sozinhos.
- **Erro que você não entende:** `<leader>ap` e escolha o prompt de diagnósticos.
- **Revisar o que o agente mudou:** gitsigns (`<leader>h`) ou lazygit (`<leader>l`).

## Quando o plano do Copilot acabar

O texto cinza e a próxima edição param. Os agentes continuam funcionando.

1. Crie uma chave do Codestral em https://console.mistral.ai (menu Codestral).
2. No `~/.bashrc`: `export CODESTRAL_API_KEY="sua-chave"`.
3. Em `minuet.lua`: troque `enabled = false` por `enabled = true`.
4. Em `copilot.lua`: adicione `enabled = false` no spec.
5. Em `lua/plugins/coding/lsp.lua`: remova a linha `copilot = {},`.
6. Reabra o nvim e rode `:Lazy sync`.

Os atalhos `Alt+l`, `Alt+j`, `Alt+n`, `Alt+p`, `Alt+d` e `<leader>uc` continuam
iguais. O `Alt+w` (aceitar palavra) não existe no minuet, e o `<Tab>` volta a ser
um tab comum.

## Problemas comuns

| Sintoma | O que olhar |
|---|---|
| `<Tab>` nunca sugere nada | `:checkhealth sidekick`; depois `:LspCopilotSignIn` |
| Agente não abre | O comando (`opencode` / `claude`) está no PATH? |
| Texto cinza não aparece | `:Copilot status`; `<leader>uc` pode ter desligado no buffer |
| Minuet não sugere | `echo $CODESTRAL_API_KEY` no terminal onde o nvim foi aberto |
