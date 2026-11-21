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
  ("<ul>\n" . join("\n", @d) . "\n</ul>", join("\n", @m));
}

my @files = (bsd_glob("$ROOT/*.html"), bsd_glob("$ROOT/blog/*.html"),
             bsd_glob("$ROOT/.herramientas/blog/fuentes/*.html"), bsd_glob("$ROOT/.herramientas/blog/aparcados/*.html"),
             "$ROOT/.herramientas/blog/plantilla-portada.html");
my ($cambiados, @avisos) = (0);
for my $f (@files) {
  open my $i, '<:encoding(UTF-8)', $f or die "$f: $!"; local $/; my $t = <$i>; close $i; my $o = $t;
  (my $rel = $f) =~ s{^\Q$ROOT\E}{}; $rel =~ s{\\}{/}g;
  my $url = $rel eq '/index.html' ? '/' : $rel =~ m{^/blog/index\.html$} ? '/blog/' : $rel;
  $url = '/blog/' . ($rel =~ m{([^/]+)$})[0] if $rel =~ m{^/\.herramientas/};   # fuentes: se publican en /blog/
  my ($dm, $mm) = menus($url);
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
