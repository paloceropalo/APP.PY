"""Incrusta fuentes/consulta_personal.html dentro de gestion_forestal.html.

La pestaña «Consulta de personal» carga ese HTML desde la variable CONSULTA_HTML,
así solo hay que publicar y compartir gestion_forestal.html.
Uso (desde esta carpeta):  python3 incrustar_consulta.py
"""
import json, pathlib, re
aqui = pathlib.Path(__file__).parent
fuente = (aqui / 'fuentes' / 'consulta_personal.html').read_text(encoding='utf-8')
destino = aqui / 'gestion_forestal.html'
html = destino.read_text(encoding='utf-8')
# JSON seguro dentro de <script>: sin «</» ni separadores de línea Unicode
dato = json.dumps(fuente, ensure_ascii=False).replace('</', '<\\/').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')
bloque = '<script id="consulta-incrustada">/*CONSULTA:INICIO*/window.CONSULTA_HTML=' + dato + ';/*CONSULTA:FIN*/</script>'
patron = re.compile(r'<script id="consulta-incrustada">/\*CONSULTA:INICIO\*/.*?/\*CONSULTA:FIN\*/</script>', re.S)
if patron.search(html):
    html = patron.sub(lambda m: bloque, html, count=1)
else:
    cierre = html.rfind('</html>')
    html = html[:cierre] + bloque + '\n' + html[cierre:] if cierre >= 0 else html.rstrip() + '\n' + bloque + '\n'
destino.write_text(html, encoding='utf-8')
print('Consulta incrustada:', len(fuente), 'caracteres')
