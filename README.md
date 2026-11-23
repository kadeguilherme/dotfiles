# dotfiles
Arquivos de configuração (dotfiles) do Guilherme para seu ambiente de desenvolvimento.

## Commit e PR com IA no lazygit

O `lazygit/config.yml` define dois comandos que chamam os scripts de `bin/`:

- `G` no painel de arquivos: `git-ai-commit` gera a mensagem de commit do que está staged.
- `P` no painel de branches: `git-ai-pr` gera a descrição e abre a PR (Bitbucket ou GitHub).

Os dois usam o Claude Code e caem para o OpenCode se ele falhar. Nada é commitado nem criado sem confirmação.

### Usando só o OpenCode

No modo padrão (`auto`), se o `claude` não estiver instalado ou não estiver logado, os scripts já usam o OpenCode sozinhos. Para nunca tentar o Claude (máquina pessoal, sem assinatura), fixe o backend no rc do shell (`~/.bashrc` ou `~/.zshrc`):

```sh
export AI_COMMIT_BACKEND=opencode
export AI_PR_BACKEND=opencode
```

Opcionalmente, escolha o modelo em vez do default do OpenCode (formato `provider/modelo`):

```sh
export AI_COMMIT_MODEL_OPENCODE=provider/modelo
export AI_PR_MODEL_OPENCODE=provider/modelo
```

Isso fica no rc de cada máquina, e não no `lazygit/config.yml`, porque o repositório é o mesmo em todas. O lazygit herda as variáveis do shell de onde foi aberto, então abra um terminal novo depois de editar o rc.

A descrição das teclas no lazygit diz "gerada pelo Claude" mesmo quando quem gera é o OpenCode; é só o rótulo.

### Instalação

Para instalar numa máquina nova, a partir da raiz do repositório:

```sh
./bin/install-git-ai
```

Ele cria os symlinks em `~/.local/bin`, aponta o `~/.config/lazygit/config.yml` para este repo e cria `~/.config/git-ai/credentials` a partir de `git-ai/credentials.example` (só usado pelo `git-ai-pr` no Bitbucket). Depois, `test-git-ai` roda a suíte offline dos scripts.
