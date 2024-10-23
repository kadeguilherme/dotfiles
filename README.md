# Minha configuração do VSCode

## Tema
[Github Theme](https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme) - Estilo `Github Dark Default`

![](https://user-images.githubusercontent.com/378023/132220037-3cd3e777-55a6-445f-9a2e-da6020ebd78d.png)

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
