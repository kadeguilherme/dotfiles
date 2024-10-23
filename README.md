# Minha configuração do VSCode

## Tema
[Github Theme](https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme) - Estilo `Github Dark Default`

## Font-family
Uso a [JetBrains](https://www.jetbrains.com/lp/mono/) como fonte padrão.

Baixando JetBrains
```bash
$ wget -P /tmp/JetBrainsMono.zip https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip 
```
Unpack fonts para */usr/share/fonts*

```bash
$ sudo unzip /tmp/JetBrainsMono.zip -d /usr/share/fonts

$ fc-cache -f -v
```

Configurando no VsCode

```yaml
Editor: Font Family: 'JetBrains Mono'
```
