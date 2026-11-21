#!/usr/bin/perl
# ==========================================================================
# Menú principal (escritorio y móvil) de todas las páginas.
#   perl .herramientas/menu.pl
# Reescribe <nav id="desktop-nav"> y <nav id="mobileMenu"> en las páginas de
# la raíz, del blog y de las fuentes del blog, marca la página actual y fija
# las versiones de style.css y main.js. Es idempotente: ejecutarlo también
# después de regenerar una subpágina con su crear-*.pl.
# ==========================================================================
use strict; use warnings; use utf8;
use File::Basename qw(dirname); use Cwd qw(abs_path); use File::Glob ':bsd_glob';
binmode STDOUT, ':encoding(UTF-8)';
my $ROOT = abs_path(dirname(abs_path($0)) . '/..');
my $CSS_V = '2.5'; my $JS_V = '2.2';

# Menú: [url, texto, title, texto oculto, submenú [[url, texto]], id, páginas de la sección]
my @MENU = (
  ['/', 'El despacho', 'El despacho · Fernando J. Robledillo, abogado en Granada', ''],
  ['/abogado-penalista-granada.html', 'Penal', 'Abogado penalista en Granada', 'abogado penalista en Granada'],
  ['/abogado-de-familia-granada.html', 'Familia y divorcios', 'Abogado de familia en Granada', 'abogado de familia en Granada',
    [ ['/abogado-divorcios-granada.html', 'Divorcios'],
      ['/abogado-custodia-compartida-granada.html', 'Custodia compartida'],
      ['/abogado-pension-alimentos-granada.html', 'Pensión de alimentos'],
      ['/abogado-liquidacion-gananciales-granada.html', 'Liquidación de gananciales'],
      ['/abogado-regimen-visitas-granada.html', 'Régimen de visitas'],
      ['/abogado-modificacion-medidas-granada.html', 'Modificación de medidas'] ],
    'familia', 'Ver todo Derecho de Familia',
    [qw(abogado-divorcios-granada abogado-custodia-compartida-granada abogado-pension-alimentos-granada
        abogado-pension-alimentos-hijos-mayores-granada abogado-pension-compensatoria-granada abogado-visitas-abuelos-granada
        abogado-vivienda-familiar-granada abogado-patria-potestad-granada abogado-regimen-visitas-granada
        abogado-liquidacion-gananciales-granada abogado-modificacion-medidas-granada)] ],
  ['/abogado-herencias-granada.html', 'Herencias', 'Abogado de herencias en Granada', 'abogado de herencias en Granada',
    [ ['/abogado-herencia-sin-testamento-granada.html', 'Herencia sin testamento'] ],
    'herencias', 'Ver todo Herencias', [qw(abogado-herencia-sin-testamento-granada)] ],
  ['/abogado-civil.html', 'Civil', 'Abogado civil en Granada', 'abogado civil e inmobiliario en Granada'],
  ['/abogado-derecho-administrativo.html', 'Administrativo', 'Abogado de derecho administrativo en Granada', 'abogado de derecho administrativo en Granada'],
  ['/contacto.html', 'Contacto', 'Contactar con Robledillo &amp; Herrera Abogados', ''],
);
my $ACT = ' aria-current="page" style="color:var(--gold);"';
my $SEC = ' style="color:var(--gold);"';

sub menus { my $url = shift;   # $url = ruta de la página ("/", "/x.html", "/blog/…")
  my (@d, @m);
  for my $e (@MENU) {
    my ($href, $txt, $title, $sr, $sub, $id, $todo, $hijas) = @$e;
    my $srh = $sr ? qq{<span class="sr-only"> · $sr</span>} : '';
    my $en_seccion = $hijas && grep { "/$_.html" eq $url } @$hijas;
    my $marca = $url eq $href ? $ACT : $en_seccion ? $SEC : '';
    unless ($sub) {
      push @d, qq{<li><a href="$href"$marca title="$title">$txt$srh</a></li>};
      push @m, qq{<a href="$href"$marca>$txt$srh</a>}; next }
    my $sd = join "\n", (map { my ($u, $t) = @$_; my $a = $u eq $url ? ' aria-current="page"' : '';
      qq{<li><a href="$u"$a>$t</a></li>} } @$sub), qq{<li class="sub-todo"><a href="$href">$todo</a></li>};
    my $sm = join '', (map { my ($u, $t) = @$_; my $a = $u eq $url ? ' aria-current="page"' : '';
      qq{<a class="submenu-link" href="$u"$a>$t</a>} } @$sub), qq{<a class="submenu-link" href="$href">$todo</a>};
    my $abierto = ($url eq $href || $en_seccion) ? 1 : 0;
    push @d, qq{<li class="has-sub"><a href="$href"$marca title="$title">$txt$srh</a><button aria-controls="sub-$id" aria-expanded="false" aria-label="Mostrar apartados de $txt" class="sub-toggle" type="button"><span aria-hidden="true" class="chev"></span></button>\n<ul class="submenu" id="sub-$id">\n$sd\n</ul></li>};
    push @m, qq{<div class="mobile-group"><div class="mobile-group-row"><a href="$href"$marca>$txt$srh</a><button aria-controls="msub-$id" aria-expanded="} . ($abierto ? 'true' : 'false') . qq{" aria-label="Mostrar apartados de $txt" class="mobile-sub-toggle" type="button"><span aria-hidden="true" class="chev"></span></button></div><div class="mobile-submenu" id="msub-$id"} . ($abierto ? '' : ' hidden') . qq{>$sm</div></div>};
  }
  # Móvil: «Blog jurídico» al final (en escritorio va en la barra superior)
  my $mb = $url eq '/blog/' ? $ACT : $url =~ m{^/blog/} ? $SEC : '';
  push @m, qq{<a href="/blog/"$mb>Blog jurídico</a>};
  ("<ul>\n" . join("\n", @d) . "\n</ul>", join("\n", @m));
}

# Barra superior (escritorio y tableta): enlace al blog antes de la dirección
my $BLOG_TOP = q{<li><a href="/blog/"><svg aria-hidden="true" fill="currentColor" height="14" viewBox="0 0 16 16" width="14" xmlns="http://www.w3.org/2000/svg"><path d="M5 10.5a.5.5 0 0 1 .5-.5h2a.5.5 0 0 1 0 1h-2a.5.5 0 0 1-.5-.5zm0-2a.5.5 0 0 1 .5-.5h5a.5.5 0 0 1 0 1h-5a.5.5 0 0 1-.5-.5zm0-2a.5.5 0 0 1 .5-.5h5a.5.5 0 0 1 0 1h-5a.5.5 0 0 1-.5-.5zm0-2a.5.5 0 0 1 .5-.5h5a.5.5 0 0 1 0 1h-5a.5.5 0 0 1-.5-.5z"/><path d="M3 0h10a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2v-1h1v1a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1H3a1 1 0 0 0-1 1v1H1V2a2 2 0 0 1 2-2z"/><path d="M1 5v-.5a.5.5 0 0 1 1 0V5h.5a.5.5 0 0 1 0 1h-2a.5.5 0 0 1 0-1H1zm0 3v-.5a.5.5 0 0 1 1 0V8h.5a.5.5 0 0 1 0 1h-2a.5.5 0 0 1 0-1H1zm0 3v-.5a.5.5 0 0 1 1 0v.5h.5a.5.5 0 0 1 0 1h-2a.5.5 0 0 1 0-1H1z"/></svg> Blog jurídico</a></li>
};

my @files = (bsd_glob("$ROOT/*.html"), bsd_glob("$ROOT/blog/*.html"),
             bsd_glob("$ROOT/.herramientas/blog/fuentes/*.html"), bsd_glob("$ROOT/.herramientas/blog/aparcados/*.html"),
             "$ROOT/.herramientas/blog/plantilla-portada.html");
my ($cambiados, @avisos) = (0);
for my $f (@files) {
  open my $i, '<:encoding(UTF-8)', $f or die "$f: $!"; local $/; my $t = <$i>; close $i; my $o = $t;
  (my $rel = $f) =~ s{^\Q$ROOT\E}{}; $rel =~ s{\\}{/}g;
  my $url = $rel eq '/index.html' ? '/' : $rel =~ m{^/blog/index\.html$} ? '/blog/' : $rel;
  $url = '/blog/' . ($rel =~ m{([^/]+)$})[0] if $rel =~ m{^/\.herramientas/};   # fuentes: se publican en /blog/
  $url = '/blog/' if $rel =~ m{plantilla-portada\.html$};
  my ($dm, $mm) = menus($url);
  if ($t =~ m{<div class="top-bar[^"]*">(.*?)</ul>}s && $1 !~ m{href="/blog/"}) {
    $t =~ s{(<div class="top-bar[^"]*">(?:(?!</ul>).)*?)(<li class="d-none d-lg-block"><a[^>]*href="https://maps\.app)}{$1$BLOG_TOP$2}s
      or push @avisos, "$rel: no se pudo añadir el blog a la barra superior" }
  my $nd = ($t =~ s{(<nav[^>]*id="desktop-nav"[^>]*>).*?(</nav>)}{$1\n$dm\n$2}s);
  my $nm = ($t =~ s{(<nav[^>]*id="mobileMenu"[^>]*>)\s*(<button[^>]*id="closeMenuBtn".*?</button>).*?(</nav>)}{$1\n$2\n$mm\n$3}s);
  push @avisos, "$rel: menú de escritorio no encontrado" unless $nd;
  push @avisos, "$rel: menú móvil no encontrado" unless $nm;
  $t =~ s{/assets/css/style\.css\?v=[0-9.]+}{/assets/css/style.css?v=$CSS_V}g;
  $t =~ s{/assets/js/main\.js\?v=[0-9.]+}{/assets/js/main.js?v=$JS_V}g;
  next if $t eq $o;
  open my $w, '>:encoding(UTF-8)', $f or die; print $w $t; close $w; $cambiados++;
}
print "Páginas actualizadas: $cambiados de ", scalar @files, "\n";
print "AVISO: $_\n" for @avisos;
