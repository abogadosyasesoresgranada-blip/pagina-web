# CONTEXTO DEL PROYECTO — abogadosyasesoresgranada.es

> Documento vivo. Se actualiza en cada sesión de trabajo con decisiones, cambios y pendientes.
> Creado: 2026-11-12 · Copia de trabajo: `c:\ROBLE\Robledillo Herrera Abogados 12-11-2026\`

---

## 1. El negocio

| Dato | Valor |
|---|---|
| Marca | **Robledillo & Herrera Abogados** (marca antigua: «F&F Abogados», web WordPress en Avda. de la Constitución) |
| Letrado | **Fernando José Robledillo Melguizo** — colegiado n.º 6631 ICAGR, ejerciendo desde 01-10-2010 (+16 años, +1.000 procedimientos). Licenciado en Derecho (UGR). También Turno de Oficio y Asistencia al Detenido |
| Estructura | **Unipersonal**: único abogado, sin pasantes ni sustituciones (argumento diferencial clave) |
| Dirección | C. Torre de Machuca, 4, local 1 · Zaidín-Vergeles · 18007 Granada (junto a Palacio de Deportes, Nuevo Los Cármenes y PTS; fuera de la ZBE; Metro Palacio de Deportes 5 min, bus línea 8) |
| Teléfono despacho | +34 958 19 46 63 (cita previa) |
| Urgencias 24 h / WhatsApp | +34 610 18 49 63 |
| Email | el del despacho (en `contacto.html`) |
| Ámbito | Juzgados de Granada (La Caleta, Plaza Nueva), Audiencia Provincial, TSJA y partidos judiciales de la provincia (Santa Fe, Loja, Motril, Almuñécar, Órgiva, Guadix, Baza, Huéscar) |
| Reputación | 4,9★ en Google (según meta description de la home) |

### Modelo de honorarios (IVA incluido)
- 1ª valoración telefónica **gratis** si no hace falta ver documentación.
- Consulta de estudio documental: **100 € + IVA** (no IVA incluido; los demás precios sí lo incluyen), descontables si encarga el asunto.
- Si el caso no es viable o no compensa, **no se acepta** ("honestidad radical").
- Hoja de encargo por escrito con presupuesto cerrado; pago fraccionado (50 % + resto).
- Referencias: contratos desde 100 € + IVA · detenido 24 h desde 300 € · procedimiento penal desde 1.000 € · divorcio mutuo acuerdo 1.500 €.

### Materias
**SÍ:** Penal (detenidos 24 h) · Familia y Divorcios · Herencias y Sucesiones · Civil e Inmobiliario · Administrativo/Contencioso.
**NO:** Derecho bancario · reclamaciones por accidentes de tráfico · multas de tráfico. (Los *delitos* de tráfico — alcoholemia, etc. — **sí**, dentro de Penal.)

### Tono de voz
**Tono neutro, sin primera persona (ni singular ni plural: nada de "le digo" ni "nos ocupamos")** en TODA la web (decidido 2026-11-13: "se le dice", "el despacho", "el mismo abogado"). Ni un despacho de varios letrados ni uno de uno solo: evitar sujeto cuando se pueda. Las preguntas de las FAQ sí van en la voz del cliente ("¿Quién llevará mi caso?"). Siempre trato de **usted**, directo, transparente con precios y viabilidad, referencias concretas a juzgados y normas de Granada/Andalucía (MASC LO 1/2025, arts. CC/LEC/LECrim/CP).

---

## 2. Stack técnico

- **Web estática** HTML + CSS + JS vanilla. Sin CMS, sin build, sin repositorio git.
- Servidor **Apache** (`.htaccess`).
- CSS: `bootstrap.min.css?v=1.2`, `default.css?v=1.2`, `style.css?v=2.2`, `lectura.css?v=1.0` + bloques `<style>` inline (2–5 por página). Iconos: `flaticon`.
- Fuentes locales precargadas: **Nunito** (400/700) y **Lora** (400–700), woff2.
- JS: `assets/js/main.js?v=2.1` — menú móvil, banner de cookies RGPD (localStorage `cookieConsent`), carga diferida de **GA4 `G-M2P2728TZL`** solo con consentimiento, evento `generar_contacto` (método: telefono / whatsapp / email / formulario + página).
- **No hay formulario de contacto**: la conversión es por teléfono, WhatsApp (`wa.me/34610184963`) y email. El único `<form>` es el de preferencias de cookies.
- Imágenes en **WebP** (`assets/img/`, logos de portales en `assets/img/portales/`).
- Versionado de caché vía `?v=` → **al modificar CSS/JS hay que subir la versión** en todas las páginas (caché `immutable` de 6 meses).

### `.htaccess` (resumen)
- Canonización a `https://abogadosyasesoresgranada.es` (sin www) + HTTPS; `/index.html` → `/`.
- 301 permanentes (NO borrar): URLs antiguas, plurales → singular (oct-2026), divorcio → `familia#divorcio`, bancario → civil, drogas/salud pública → penal, `blog-conflicto-vecinos` → `civil#conflictos-vecinales`, WordPress antiguo (`/contacto/`, `/abogados-en-granada/`).
- **410 Gone**: `abogado-accidentes-trafico.html`, `abogados-accidentes-trafico-granada.html`, todo `/pdf/` (documentos judiciales retirados por secreto profesional/RGPD; `/pdf/` fuera de robots.txt a propósito).
- Cabeceras de seguridad (HSTS preload, nosniff, X-Frame-Options, Referrer-Policy, Permissions-Policy), Brotli/Gzip, caché larga para estáticos, HTML `no-cache`.

### `robots.txt`
Permite buscadores e IA que citan (incl. CCBot). Bloquea scrapers sin cita (Bytespider, Diffbot, Omgili, ImagesiftBot, Timpibot, cohere-training-data-crawler). Declara sitemap.

### `llms.txt`
Ficha estructurada para LLMs (identidad, E-E-A-T, honorarios, materias, enlaces). **Mantener sincronizado** con cualquier cambio de precios, materias o datos de contacto.

---

## 3. Arquitectura de páginas

| URL | Title | Indexa | ~Palabras | FAQ (schema) | Anclas internas |
|---|---|---|---|---|---|
| `/` (index.html) | Abogado en Granada \| Robledillo & Herrera Abogados | sí | 2.500 | 11 | `#portales-marquee`, noticias |
| `abogado-penalista-granada.html` | Abogado penalista en Granada \| Detenidos 24h | sí | **8.560** | 15 | `#protocolo-detencion` |
| `abogado-de-familia-granada.html` | Abogado de familia en Granada \| divorcios y custodias | sí | 4.200 | 25 | `#divorcio` (destino de 301) |
| `abogado-herencias-granada.html` | Abogado herencias Granada \| Tramitación integral | sí | 2.700 | 11 | `#bonificacion-sucesiones` |
| `abogado-civil.html` | Abogado civil e inmobiliario en Granada \| Contratos | sí | 3.070 | 10 | `#rentabilidad`, `#conflictos-vecinales`, `#procedimiento-monitorio` |
| `abogado-derecho-administrativo.html` | Abogado en derecho administrativo Granada | sí | 2.200 | 12 | — |
| `contacto.html` | Contacto y cita previa \| Robledillo & Herrera Abogados | sí | 420 | — | — |
| `aviso-legal.html`, `politica-privacidad.html`, `politica-cookies.html` | — | **noindex, follow** | — | — | — |

- Todas las páginas tienen canonical propio, meta description (126–154 car.), OG/Twitter, sección "Otras materias…" (`#servicios-relacionados`) y FAQ (`#preguntas-frecuentes`).
- **Schema JSON-LD** en `@graph`: LegalService, Organization, Person (con credencial ICAGR y UGR), WebSite, WebPage, Service + OfferCatalog/Offer, FAQPage, BreadcrumbList (interiores), ContactPage, ReserveAction, GeoCoordinates. `dateModified` = 2026-11-02.
- `sameAs`: Instagram, X, TikTok, LinkedIn, Pinterest, Facebook, YouTube + directorios (abogadosdegranada, lexdir, melendos, lawandtrends, lexgoapp, legalrank, cronoshare, andalucía.org, Trustpilot, Yelp, elabogado).
- `sitemap.xml`: 7 URLs indexables, todas con `lastmod` 2026-11-02.

---

## 4. Historial de decisiones conocidas (extraído del código)

- **jul-2026** — Página de divorcio fusionada en Familia (anti-canibalización).
- **ago-2026** — Hiperespecialización: se abandonan accidentes de tráfico y derecho bancario.
- **oct-2026** — URLs pasan a singular (`abogado-…`); accidentes de tráfico de 301 a **410** (evitar soft-404 y arrastre de consultas a la home); blog de conflictos vecinales retirado → 301 a civil; se permite CCBot.
- **02-11-2026** — Última actualización de contenidos/sitemap.

---

## 5. Observaciones iniciales (por revisar, no son cambios aprobados)

1. **Horario en schema 24/7** (`openingHoursSpecification` 00:00–23:59 todos los días) en el LegalService: coherente con urgencias penales pero puede chocar con el horario real del despacho y con la ficha de Google Business Profile. Valorar separar horario de oficina y contacto de urgencias.
2. **`sameAs` de lawandtrends** conserva el slug de la marca antigua (`f-f-abogados-y-asesores-granada`). Revisar si la ficha puede renombrarse.
3. **Marca "& Herrera"** vs. despacho unipersonal: la web lo explica, pero conviene vigilar la coherencia de NAP/marca en directorios y GBP.
4. **Desequilibrio de contenido**: Penal ~8.500 palabras frente a 2.200–4.200 en el resto.
5. **ID de sección con tildes y mayúsculas** en la home (`Noticias-jurídicas-y-casos-de-éxito-…`): ancla poco limpia.
6. CSS inline repetido en cada página (2–5 bloques `<style>`): candidato a consolidar en `style.css`/`lectura.css`.
7. `lastmod` idéntico en todo el sitemap: actualizar por página solo cuando cambie de verdad.
8. Sin formulario de contacto (decisión aparente; todo por teléfono/WhatsApp/email).

---

## 6. Herramientas disponibles para el proyecto

- **DinoRANK** (MCP): visibilidad, keyword research, tracking, canibalizaciones, content gap, Search Console, Analytics, SEO local, auditoría.
- Skill **auditar-ficha-gbp** (ficha de Google Business Profile vs. la web).
- Skill **whatsapp-clientes-nuevos** (análisis de mensajes de posibles clientes).
- Skills de marketing: seo-audit, content-creation, competitive-brief, etc.

---

## 7. Reglas de trabajo

- No eliminar las redirecciones 301/410 marcadas como permanentes en `.htaccess`.
- Al cambiar precios, materias o datos de contacto → actualizar **a la vez**: HTML visible, JSON-LD de todas las páginas, `llms.txt` y meta descriptions afectadas.
- Al tocar CSS/JS → subir `?v=` en todas las páginas.
- Al cambiar contenido de una página → actualizar su `dateModified` y su `lastmod` en `sitemap.xml`.
- Mantener trato de usted. Toda la web en tono neutro, sin 1ª persona (ver «Tono de voz»).
- No reintroducir materias descartadas (bancario, accidentes de tráfico, multas).

### Flujo de cambios, commits y despliegue (acordado 2026-11-12)
- Repositorio git: rama `main` → `origin` = `github.com/abogadosyasesoresgranada-blip/pagina-web`.
- **Autorizado** hacer commits y push a `main` para nuevas funcionalidades.
- **Siempre confirmar antes de cada modificación** (editar archivos, commit, push o deploy).
- **Siempre facilitar un enlace localhost** (servidor local de la web estática) para revisar los cambios antes de publicarlos.
- Secuencia: proponer cambio → OK → editar en local → previsualizar en `http://localhost:PUERTO/` → revisar que no afecta a otras páginas → OK → commit + push a `main` → OK → `ssh abogados-vps` + `deploy-abogados` → verificar que termina sin errores y comprobar la web en producción.
- Conservar la estructura de la web: HTML, CSS, JavaScript y jQuery.

### Servidor de producción (VPS)
- Ubuntu 24.04 + **HestiaCP**, servidor web **Nginx**. Acceso: alias SSH **`abogados-vps`** (usuario `abogados`).
- Repositorio en el VPS: `/home/abogados/repositories/pagina-web` (rama `main`).
- Directorio público: `/home/abogados/web/abogadosyasesoresgranada.es/public_html`
- Comando de despliegue: **`deploy-abogados`** (`/usr/local/bin/deploy-abogados`). Qué hace:
  1. Falla si el repositorio del VPS tiene cambios locales.
  2. `git pull --ff-only origin main`.
  3. Comprueba que existe `index.html`.
  4. Copia de seguridad de `public_html` en `/home/abogados/deploy/backups/AAAAMMDD-HHMMSS/`.
  5. `rsync --delete` del repositorio a `public_html`, **excluyendo** `.git/`, `.github/`, `.htaccess`, cualquier fichero oculto (`.*`), `*.md`, `pdf/` y `*.sh`.
- Consecuencias:
  - `context.md` y cualquier `.md` **no se publican** (comprobado: `/context.md` da 404).
  - **El `.htaccess` del repositorio NO se despliega y Nginx no lo lee.** Las redirecciones, los 410 y las cabeceras de producción deberían configurarse en Nginx/HestiaCP (fuera de nuestro alcance). **Comprobado el 2026-11-13: NO lo están** (ver registro de sesiones). Cualquier cambio de redirecciones o cabeceras hay que pedírselo al responsable del servidor. El `.htaccess` queda solo como documentación.
  - `--delete`: un archivo borrado del repositorio desaparece también de la web.

### Prohibido en el servidor
- Modificar la configuración de Nginx, HestiaCP, SSH, firewall o permisos.
- Usar root o sudo.
- Borrar copias de seguridad o tocar archivos fuera de los directorios del proyecto.
- Si una tarea requiere permisos de administrador → **avisar al responsable del servidor antes de continuar**.

### Estado en producción comprobado (2026-11-12)
- OK: http→https (301), `/index.html`→`/` (301), plurales→singular (301), accidentes de tráfico (410), `/pdf/` (410), HSTS, nosniff, X-Frame-Options, Referrer-Policy, `Cache-Control` del HTML.
- ⚠️ **`https://www.abogadosyasesoresgranada.es/` responde 200 en vez de redirigir con 301** al dominio sin www, así que hay contenido duplicado. Es configuración de Nginx: **hay que pedírselo al responsable del servidor.**

---

## 8. Objetivos de esta fase

_(Pendiente de definir con el cliente.)_

---

## 9. Registro de sesiones

### 2026-11-12
- Análisis inicial de la web local y creación de este `context.md`.
- Pendiente: definir objetivos y prioridades de trabajo.
- Acordado el flujo de trabajo: commits/push a `main` autorizados, confirmación previa a cada cambio, enlace localhost para revisar, y deploy por SSH al VPS más adelante (sección 7).
- Recibidos los datos del VPS (`abogados-vps`, `deploy-abogados`). Revisión en solo lectura: SSH OK y repositorio del VPS en `b7e7661`, igual que el local. Se ha analizado el script de deploy. Detectado el problema de www (pendiente de que lo corrija el administrador).

### 2026-11-13
- `abogado-de-familia-granada.html`: corregida estructura HTML (faltaban cierres de `container-rh`/`main-layout`; FAQ y bloques finales quedaban dentro de la rejilla). Caja del autor movida bajo «¿No sabe qué camino le conviene?». Reducidos huecos entre secciones finales. Quitado el recuadro «En resumen». Más separación entre cajas de «Abogado divorcios Granada» y clase `servicio-card` añadida a las 5 cajas que venían de la guía (título subrayado y mismo tamaño).
- Reescritos con enfoque en puntos de dolor: 3 «razones», ficha lateral del abogado, tarjetas mutuo acuerdo/contencioso, «Otras materias relacionadas» y meta description (sin precio).
- FAQ reducida de 24 a 15 preguntas orientadas a búsquedas en IA; HTML y schema FAQPage generados desde la misma fuente (idénticos). Añadidos arts. 86, 92, 93, 97 y 105 CC.
- **Precio aclarado: los 1.500 € del mutuo acuerdo son honorarios de abogado, IVA incluido; el procurador NO está incluido.** Actualizado en tarjeta, hero, FAQ y `llms.txt`.
- «Última actualización» y `dateModified` → 2026-11-13 en civil, familia, administrativo, herencias y penal; `lastmod` del sitemap igual. Inicio y contacto siguen con `dateModified` 2026-11-02.
- Mismo tratamiento (textos de dolor, FAQ orientada a IA sincronizada con FAQPage, meta description sin precio, revisión de código) en herencias (13 FAQ), administrativo (12 FAQ; sin «multas», materia descartada), penal (13 FAQ; quitado «En resumen»), home (13 FAQ; H2 orientados a «despacho de abogados en Granada») y civil (13 FAQ; tarjetas y «¿Vale la pena demandar?» a todo el ancho). Todo publicado.
- Las FAQ se generan desde un único texto fuente para que HTML y schema sean idénticos.
- Quitado «En resumen» en todas las páginas y el párrafo de introducción de civil. MASC en el monitorio: criterio mayoritario de juntas de jueces/LAJ = sí se exige para la petición inicial (salvo monitorio europeo), no en el ordinario tras oposición; un simple requerimiento de pago puede no bastar. Añadido a la FAQ de civil.
- Contacto: código revisado sin errores; su meta description (contacto/horario) no canibaliza con la de la home. Todas las páginas con dateModified/lastmod 2026-11-13.
- DinoRANK keyword research «abogados granada»: abogados (en) granada 2.400/mes; penalistas 1.000; divorcios 480; despacho(s) de abogados ≈1.100 en total; bufete ≈630.
- DinoRANK LLMs: 9 prompts de familia añadidos por el cliente. Ninguna IA menciona el despacho ni a competidores; ChatGPT aún sin respuestas. Pendiente revisarlas en unos días. Off-page recomendado: reseñas GBP y alta en LexGo, Legaloo, abogados.es y directorio ICAGR.
- Home: reescritos con enfoque en puntos de dolor la intro («Una citación judicial…» / «En muchos despachos grandes…») y las 5 tarjetas de especialidades. **Toda la home pasada a tono neutro, sin primera persona**: hero, H2 de especialidades («áreas de especialidad»), tarjeta «¿Cuál es su situación jurídica?», bio de Fernando, FAQ (HTML y FAQPage sincronizados), descripción del JSON-LD, bloque de ubicación y banner de cookies. JSON-LD validado.
- El equipo no tiene Python ni Node: para previsualizar en local usar la extensión Live Server de VS Code.
- Bio de Fernando en la home reescrita con datos del CV: socio fundador, licenciatura UGR 2010 con matrículas de honor, Título de Experto Superior en Derecho Urbanístico, Promoción Inmobiliaria y Derecho Medioambiental de Andalucía (Escuela Internacional de Posgrado de la UGR), negociación/mediación, asesor externo de otros despachos. **No usar** el «porcentaje de absoluciones» (publicidad de resultados) ni las medallas rechazadas (decisión del cliente). Schema Person de las 7 páginas: jobTitle «Abogado y socio fundador…» + credencial de Experto Superior (no es un máster); mantener igual en todas.
- **Precio corregido: la consulta de estudio documental es 100 € + IVA** (antes ponía «IVA incluido»). Cambiado en las 7 páginas (HTML + JSON-LD) y en `llms.txt`. Contratos también «desde 100 € + IVA» (confirmado por el cliente). El resto de precios (penal, divorcio…) siguen con IVA incluido.
- FAQ home revisada con DinoRANK: «abogado de oficio (en) granada» 210+210/mes con AI Overview, «cuánto cuesta una consulta a un abogado» 140+50, «abogado primera consulta gratis» 210, «cuánto cuesta un abogado para divorcio» 110+110, «penalista» 90+90. Cambios: preguntas «¿Cuánto cuesta una consulta con un abogado en Granada?» y «¿Cómo pedir un abogado de oficio en Granada y quién tiene derecho?» (añadido coste si se deniega, art. 17 Ley 1/1996); primeras frases que se entienden solas y con «Robledillo & Herrera Abogados». IPREM 2026 verificado: 600 €/mes, 8.400 €/año (14 pagas). HTML y FAQPage verificados idénticos (13/13).
- **No poner precio del procurador** (el cliente no lo conoce; arancel).
- DinoRANK LLMs (27 registros = 9 prompts × ChatGPT/Claude/Gemini): el despacho no aparece en ninguno; ChatGPT sin respuestas aún. Gemini, para «mejores abogados de granada», remite al ICAGR, abogados.es y LexGoApp → prioridad off-page. La API no permite dar de alta prompts: hacerlo a mano en el panel.
- Penal y herencias pasadas a tono neutro (≈50 frases en penal, 10 en herencias; también el plural «nos ocupamos», «le decimos»…). Descripción del despacho en el JSON-LD (LegalService) unificada en neutro en las 7 páginas. FAQ de ambas verificadas idénticas a su FAQPage (13/13). Botón «Acceder a Google Maps» de la home centrado.
- Civil (≈40 frases), familia (15), administrativo (3) y contacto (2) pasadas a tono neutro. **Toda la web queda en tono neutro.** JSON-LD válido en las 10 páginas; FAQ = FAQPage en las 6 páginas con FAQ (civil 13, familia 15, admin 12, penal 13, herencias 13, home 13).
- **Revisión técnica completa (13/11):** las 10 páginas sin errores de código (etiquetas equilibradas, 1 H1 por página, sin IDs duplicados, anclas internas correctas, recursos locales existentes, JSON-LD válido, CSS sin llaves desparejadas, title/description/canonical/lang en todas). robots.txt y sitemap.xml correctos e idénticos a producción; las legales (noindex) fuera del sitemap a propósito. `.htaccess` correcto para Apache, pero **en producción no se usa**.
- ⚠️ **Producción (Nginx), comprobado con curl el 13/11:** TODAS las URLs antiguas del `.htaccess` (301 y 410: delitos-salud-publica, reclamaciones-bancarias, abogado-divorcio-granada, plurales abogados-*, /contacto/, /abogados-en-granada/, /pdf/…) devuelven **404**. `www.` y `/index.html` devuelven **200** (duplicado; lo mitiga el canonical). Faltan las cabeceras de seguridad (HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy) y el Cache-Control del HTML. Todo es configuración de Nginx/HestiaCP → **pedírselo al responsable del servidor** pasándole las reglas del `.htaccess`.
- **Decisión del cliente (13/11):** las URLs antiguas que dan 404 en producción se dejan así: prefiere que Google deje de posicionarlas, sobre todo las de materias que ya no lleva (accidentes de tráfico, bancario). No hace falta pedir sus 301/410 en Nginx (esas URLs ya no reciben visitas, según el cliente). Siguen pendientes de pedir al responsable del servidor: redirección `www` → sin www y cabeceras de seguridad.
- Search Console (13/11): «La propiedad única está duplicada» en la home → `alumniOf` repetido en el Person (lo añadí sin ver que ya existía). Corregido. **Ojo:** `ConvertFrom-Json` de PowerShell no detecta claves duplicadas; al tocar JSON-LD revisar también duplicados dentro del mismo objeto.
- **Servidor resuelto (13/11, comprobado con curl):** `www` → 301 al dominio sin www (conservando ruta), `/index.html` → 301 a `/`, cabeceras de seguridad activas en HTML y estáticos (HSTS sin includeSubDomains), HTML con `Cache-Control: no-cache, must-revalidate`. Detalle menor: `http://www` hace 2 saltos (→ `https://www` → sin www); no es un problema. Las URLs antiguas siguen en 404 a propósito.
- 14/11: meta description home → «¿Un problema legal le quita el sueño? En unos minutos y gratis sabrá si tiene solución y cuánto cuesta. Abogado en Granada con excelentes reseñas.» (sin cifra de valoración para que no caduque; nada de superlativos tipo «el mejor»). Título home → «Despacho de abogados en Granada | Sin letra pequeña».
- ⚠️ Incidente 14/11: una sustitución con `perl` (delimitador `|` con `\|` en el patrón) duplicó texto en el `<title>`, `WebPage.name` y `Person.jobTitle` de la home y dejó el JSON-LD inválido; se publicó (d21bc8e) y se corrigió restaurando desde 970c1c7 (c5468f6). **Lecciones:** no usar `|` como delimitador si el texto lleva `|`; hacer estos cambios con el editor; NO encadenar el deploy en el mismo comando que la validación: validar, revisar el diff y solo después publicar. Tras un deploy, Nginx puede servir 1-2 min la versión anterior (caché de ficheros).
- 14/11: descripción de la ficha GBP actualizada por el cliente a la versión neutra alineada con el schema (744 car., sin precio por normas de GBP, con «sin delegar en pasantes» y ubicación Palacio de Deportes/aparcamiento/fuera de ZBE). Si se cambia la descripción del LegalService en la web, revisar también la de GBP.
- GBP (14/11): categorías revisadas y **se mantienen** (decisión del cliente: Abogado + Bufete + Servicios legales + Gestión de divorcios + matrimonialista + familia + civil + penalista + administrativo + sucesiones, igual que los despachos mejor posicionados). Servicios: casi todos en 1ª persona; correcciones pendientes en el divorcio exprés (procurador y notaría aparte), drogas («defensa», no «asesoramiento a clubes cannábicos») y alcoholemias (sin «accidentes de tráfico»).
