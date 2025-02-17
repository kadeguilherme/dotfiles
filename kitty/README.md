# 😼 Kitty Configurations

Este repositorio contem as configurações do meu terminal [kitty](https://sw.kovidgoyal.net/kitty/)

![Preview do kitty](./screenshots/kitty-preview.png)
---

## 📁 Estrutura

- `kitty.conf`: Arquivo de configuração do kitty.
- `kitty-icon`: Imagem do ícone do kitty. Baixe no diretório `~/.local/kitty.app/share/icons/hicolor/256x256/`

---

## 🛠️ Configurando o kitty

### 1. Instale o kitty
Siga as intruções da documentação para instalar o kitty: [instalação kitty](https://sw.kovidgoyal.net/kitty/binary/)

**Obs:** Caso necessário, execute o comando abaixo para corrigir o ícone do kitty:
```bash
sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty-dark.png|g" ~/.local/share/applications/kitty*.desktop
```


### 2. Instale o tema do kitty
Siga os passos da documentação para instalar o [kitty-themes](https://github.com/dexpota/kitty-themes)

Após baixar os temas do kitty, execute o seguinte comando para escolher o tema:

```bash
kitty +kitten themes <nome-do-tema>
```

### 3. Clone o repositorio
```bash
git clone git@github.com:kadeguilherme/my-setup.git
cd kitty
```

### 4. Copie as configurações para o diretorio do kitty
```bash
cp * ~/.config/kitty
```

---
### 5. 🖥️ Tab Bar Configuration (tab_bar.py)
O script tab_bar.py é responsável pela personalização da barra de abas no terminal Kitty. Ele permite modificar a aparência das abas, incluindo cores, estilo de fontes e comportamento.

#### Como usar:
Certifique-se de que o script tab_bar.py esteja no  ~/.config/kitty

---
## 📝 Contribuições
Sinta-se a vontade para enviar pull requiests com melhorias ou abrir issues

