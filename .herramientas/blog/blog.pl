#!/usr/bin/perl
# ==========================================================================
# Blog de abogadosyasesoresgranada.es · generador
#
#   perl .herramientas/blog/blog.pl                 regenera todo
#   perl .herramientas/blog/blog.pl publicar [FECHA] publica el siguiente de
#                                                    la cola (FECHA = AAAA-MM-DD,
#                                                    por defecto hoy) y regenera
#   perl .herramientas/blog/blog.pl estado          muestra publicados y cola
#
# Fuentes:   .herramientas/blog/fuentes/<slug>.html (artículo completo, con
#            todos los enlaces cruzados; la fecha de la fuente se sustituye)
# Calendario: .herramientas/blog/calendario.txt  ("slug fecha" = publicado;
#            "slug" sin fecha = en cola, por orden)
# La carpeta .herramientas no se publica (el deploy excluye ficheros ocultos).
#
# Genera: blog/<slug>.html, blog/index.html, entradas /blog/ de sitemap.xml,
# sección «Blog jurídico» de llms.txt, bloque «Artículos del blog» en la
# página de servicio de cada artículo y enlace «Blog jurídico» en el pie de
# todas las páginas. Los enlaces a artículos aún no publicados se ocultan.
# ==========================================================================
use strict; use warnings; use utf8;
use JSON::PP; use File::Basename qw(dirname); use Cwd qw(abs_path);
use File::Glob ':bsd_glob';   # glob() sin partir rutas con espacios
binmode STDOUT, ':encoding(UTF-8)'; binmode STDERR, ':encoding(UTF-8)';

my $HERR = dirname(abs_path($0));
my $ROOT = abs_path("$HERR/../..");
my $DOM  = 'https://abogadosyasesoresgranada.es';
my @MES  = qw(enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre);
my $J    = JSON::PP->new->utf8(0)->canonical(1);

sub leer { my $f = shift; open my $i, '<:encoding(UTF-8)', $f or die "$f: $!"; local $/; my $t = <$i>; close $i; $t }
sub escribir { my ($f, $t) = @_; my $old = -e $f ? leer($f) : '';
  return 0 if $old eq $t; open my $o, '>:encoding(UTF-8)', $f or die "$f: $!"; print $o $t; close $o; 1 }
sub humana { my ($y, $m, $d) = split /-/, shift; ($d + 0) . " de $MES[$m-1] de $y" }
sub hoy { my @t = localtime; sprintf '%04d-%02d-%02d', $t[5] + 1900, $t[4] + 1, $t[3] }
sub texto { my $h = shift; $h =~ s/<[^>]+>//g;
  my %e = (amp => '&', lt => '<', gt => '>', quot => '"', nbsp => ' ', '#39' => "'");
  $h =~ s/&(amp|lt|gt|quot|nbsp|#39);/$e{$1}/g; $h =~ s/\s+/ /g; $h =~ s/^ | $//g; $h }

# ---------- calendario ----------
my $CAL = "$HERR/calendario.txt";
my (@pub, @cola, %fecha);
sub cargar_cal { @pub = @cola = (); %fecha = ();
  for (split /\n/, leer($CAL)) { s/#.*//; next unless /\S/; my ($s, $f) = split;
    die "fuente inexistente: $s\n" unless -e "$HERR/fuentes/$s.html";
    if ($f) { die "fecha mal escrita: $f\n" unless $f =~ /^\d{4}-\d\d-\d\d$/; push @pub, $s; $fecha{$s} = $f } else { push @cola, $s } } }
cargar_cal();

my $cmd = shift // 'generar';
if ($cmd eq 'estado') {
  print "Publicados:\n"; print "  $fecha{$_}  $_\n" for @pub;
  print "En cola:\n"; print "  $_\n" for @cola; exit }
if ($cmd eq 'publicar') {
  my $f = shift // hoy(); die "fecha mal escrita: $f\n" unless $f =~ /^\d{4}-\d\d-\d\d$/;
  die "No queda ningún artículo en la cola.\n" unless @cola;
  my $s = $cola[0]; my $t = leer($CAL);
  $t =~ s/^(\Q$s\E)[ \t]*$/sprintf('%-48s %s', $1, $f)/me or die "no se pudo actualizar el calendario\n";
  escribir($CAL, $t); print "Publicado: $s ($f)\n"; cargar_cal();
} elsif ($cmd ne 'generar') { die "Orden desconocida: $cmd\n" }

my %publicado = map { $_ => 1 } @pub;
for (glob "$HERR/fuentes/*.html") { my ($s) = m{([^/\\]+)\.html$}; warn "AVISO: $s está en fuentes pero no en el calendario\n" unless exists $fecha{$s} or grep { $_ eq $s } @cola }

# ---------- arreglos comunes de pie ----------
sub pie { my ($t, $blog) = @_;
  $blog and $t =~ s{(<h4>SERVICIOS</h4>\s*<ul>\s*<li><a href="/contacto\.html">Contacto y Cita Previa</a></li>)(\s*+)(?!<li><a href="/abogado-penalista-granada\.html">)}{$1$2<li><a href="/abogado-penalista-granada.html">Abogado penalista</a></li>$2};
  $t =~ s{(<h4>SERVICIOS</h4>\s*<ul>(?:(?!</ul>).)*?)(\s*</ul>)}{ my ($a, $b) = ($1, $2); $a =~ m{href="/blog/"} ? "$a$b" : "$a\n<li><a href=\"/blog/\">Blog jurídico</a></li>$b" }se;
  $t }

# ---------- artículos ----------
my (%meta, @avisos);
mkdir "$ROOT/blog" unless -d "$ROOT/blog";
for my $s (@pub) {
  my $t = leer("$HERR/fuentes/$s.html");
  # Enlaces al BOE: Código Civil usa #artNN; LECrim arts. 800-803 usan #asNNN
  $t =~ s{(BOE-A-1889-4763#)a(\d+\w*)"}{$1art$2"}g;
  $t =~ s{(BOE-A-1882-6036#)a(80[0-3])"}{$1as$2"}g;
  # Fecha
  my ($orig) = $t =~ /"datePublished":"(\d{4}-\d\d-\d\d)"/ or die "$s: sin datePublished\n";
  my $nueva = $fecha{$s};
  if ($orig ne $nueva) { my ($ho, $hn) = (humana($orig), humana($nueva)); $t =~ s/\Q$orig\E/$nueva/g; $t =~ s/\Q$ho\E/$hn/g }
  $t = pie($t, 1);
  # Enlaces a artículos aún no publicados
  my $oculto = sub { my $x = shift; $x ne $s && !$publicado{$x} };
  $t =~ s{<li><a href="/blog/([^"/]+)\.html">[^<]*</a></li>}{ $oculto->($1) ? '' : $& }ge;
  $t =~ s{<div class="rel-card"><a href="/blog/([^"/]+)\.html">.*?</div>}{ $oculto->($1) ? '' : $& }ge;
  $t =~ s{<a\b[^>]*href="/blog/([^"/]+)\.html"[^>]*>(.*?)</a>}{ $oculto->($1) ? $2 : $& }ge;
  $t =~ s{<div class="sidebar-relacionados"><p class="rel-titulo">[^<]*</p><ul></ul></div>}{}g;
  # FAQPage = texto de las FAQ visibles
  my @faq;
  while ($t =~ m{<details class="faq-item"><summary>(.*?)<span[^>]*class="faq-chevron"[^>]*>.*?</span></summary><div class="faq-body">(.*?)</div></details>}gs) {
    push @faq, { '@type' => 'Question', name => texto($1), acceptedAnswer => { '@type' => 'Answer', text => texto($2) } } }
  $t =~ s{(<script type="application/ld\+json">)(.*?)(</script>)}{
    my ($a, $j, $c) = ($1, $2, $3); my $d = $J->decode($j);
    my @g = grep { !($_->{'@type'} eq 'FAQPage' && !@faq) } @{ $d->{'@graph'} };
    $_->{mainEntity} = \@faq for grep { $_->{'@type'} eq 'FAQPage' } @g;
    $d->{'@graph'} = \@g; $a . $J->encode($d) . $c }se;
  # Datos para la portada, el sitemap y las páginas de servicio
  my ($h1)   = $t =~ m{<h1 class="hero-h1">(.*?)</h1>}s;
  my ($desc) = $t =~ m{<meta content="([^"]*)" name="description"/>};
  my ($sec)  = $t =~ m{<meta content="([^"]*)" property="article:section"/>};
  my ($land) = $t =~ m{Más información[^<]*<a class="enlace-tema" href="/([^"/]+\.html)"};
  push @avisos, "$s: no indica página de servicio («Más información…»)" unless $land;
  push @avisos, "$s: el título lleva raya (—)" if $h1 =~ /—/;
  # Texto opcional del enlace en la página de servicio (si no, el H1)
  my ($ancla) = $t =~ m{<meta content="([^"]*)" name="blog:ancla-servicio"/>};
  $meta{$s} = { h1 => $h1, desc => $desc, sec => $sec // 'Blog', land => $land, ancla => $ancla // $h1, n => scalar @faq };
  print "blog/$s.html", (escribir("$ROOT/blog/$s.html", $t) ? ' (actualizado)' : ''), "\n";
}
mkdir "$ROOT/blog" unless -d "$ROOT/blog";
for (glob "$ROOT/blog/*.html") { my ($x) = m{([^/\\]+)\.html$}; next if $x eq 'index' || $publicado{$x}; unlink $_; print "retirado: blog/$x.html\n" }

# Orden: más recientes primero; a igual fecha, el orden del calendario
my %pos; @pos{@pub} = 0 .. $#pub;
my @orden = sort { $fecha{$b} cmp $fecha{$a} || $pos{$a} <=> $pos{$b} } @pub;
my $ultima = @orden ? $fecha{$orden[0]} : hoy();
sub esc { my $x = shift; $x =~ s/&(?!amp;|lt;|gt;|quot;|#)/&amp;/g; $x }

# ---------- portada ----------
{ my $t = leer("$HERR/plantilla-portada.html");
  my $cards = join '', map { my $m = $meta{$_};
    my $tag = $m->{sec} =~ /penal/i ? 'tag-penal' : 'tag-familia';
    qq{<article class="blog-card"><span class="tag $tag">$m->{sec}</span><h2><a href="/blog/$_.html">$m->{h1}</a></h2><p>$m->{desc}</p><time datetime="$fecha{$_}">} . humana($fecha{$_}) . qq{</time></article>} } @orden;
  $t =~ s{(<div class="blog-grid">).*?(?=</div></div>\s*</main>)}{$1$cards}s or die "plantilla de portada sin blog-grid\n";
  $t =~ s{(<script type="application/ld\+json">)(.*?)(</script>)}{
    my ($a, $j, $c) = ($1, $2, $3); my $d = $J->decode($j);
    for my $n (@{ $d->{'@graph'} }) { next unless $n->{'@type'} eq 'Blog';
      $n->{blogPost} = [ map { { '@type' => 'BlogPosting', headline => texto($meta{$_}{h1}), url => "$DOM/blog/$_.html", datePublished => $fecha{$_} } } @orden ] }
    $a . $J->encode($d) . $c }se;
  $t = pie($t, 1);
  print "blog/index.html", (escribir("$ROOT/blog/index.html", $t) ? ' (actualizado)' : ''), "\n" }

# ---------- sitemap ----------
{ my $f = "$ROOT/sitemap.xml"; my $t = leer($f);
  $t =~ s{<url>\s*<loc>\Q$DOM\E/blog/[^<]*</loc>.*?</url>\s*}{}gs;
  my $u = sub { my ($loc, $d) = @_; "<url>\n<loc>$loc</loc>\n<lastmod>${d}T00:00:00+00:00</lastmod>\n<priority>0.60</priority>\n</url>\n" };
  my $add = $u->("$DOM/blog/", $ultima) . join '', map { $u->("$DOM/blog/$_.html", $fecha{$_}) } @orden;
  $t =~ s{</urlset>}{$add</urlset>} or die "sitemap sin </urlset>\n";
  print "sitemap.xml", (escribir($f, $t) ? ' (actualizado)' : ''), "\n" }

# ---------- llms.txt ----------
{ my $f = "$ROOT/llms.txt"; my $t = leer($f);
  my $sec = "## Blog jurídico\n\nArtículos divulgativos firmados por Fernando José Robledillo Melguizo ($DOM/blog/):\n\n"
    . join('', map { "- [" . texto($meta{$_}{h1}) . "]($DOM/blog/$_.html): " . texto($meta{$_}{desc}) . " Publicado el " . humana($fecha{$_}) . ".\n" } @orden) . "\n";
  $t =~ s{## Blog jurídico\n.*?(?=## )}{}s;
  $t =~ s{(?=## Páginas legales)}{$sec} or die "llms.txt sin «## Páginas legales»\n";
  print "llms.txt", (escribir($f, $t) ? ' (actualizado)' : ''), "\n" }

# ---------- páginas de la web: pie y bloque de artículos ----------
my %por_land; push @{ $por_land{ $meta{$_}{land} } }, $_ for grep { $meta{$_}{land} } @orden;
for my $f (glob "$ROOT/*.html") {
  my ($base) = $f =~ m{([^/\\]+\.html)$}; my $t = leer($f); my $o = $t;
  $t = pie($t);
  $t =~ s{\n?<!-- blog:inicio -->.*?<!-- blog:fin -->}{}s;
  if (my $arts = $por_land{$base}) {
    my $li = join '', map { qq{<li style="margin-bottom:8px"><a class="enlace-tema" href="/blog/$_.html">$meta{$_}{ancla}</a></li>} } @$arts;
    my $blk = qq{\n<!-- blog:inicio --><section aria-labelledby="articulos-blog-titulo" class="section-rh" id="articulos-blog" style="padding:8px 0 48px"><div class="container-rh"><h2 id="articulos-blog-titulo" style="text-align:center">Artículos del blog sobre este tema</h2><ul style="max-width:760px;margin:18px auto 0;padding-left:1.2rem;line-height:1.6">$li</ul><p style="text-align:center;margin-top:14px"><a class="enlace-tema" href="/blog/">Ver todos los artículos del blog jurídico</a></p></div></section><!-- blog:fin -->};
    $t =~ s{(id="servicios-relacionados".*?</section>)}{$1$blk}s or push @avisos, "$base: sin sección servicios-relacionados, no se ha añadido el bloque del blog";
  }
  print "$base (actualizado)\n" if $t ne $o and escribir($f, $t);
}

# ---------- comprobaciones ----------
for my $f ("$ROOT/blog/index.html", map { "$ROOT/blog/$_.html" } @pub) {
  my $t = leer($f);
  while ($t =~ m{<script type="application/ld\+json">(.*?)</script>}gs) { eval { $J->decode($1); 1 } or push @avisos, "$f: JSON-LD inválido" }
  while ($t =~ m{href="/blog/([^"/]+)\.html"}g) { push @avisos, "$f: enlaza a blog/$1.html, que no está publicado" unless $publicado{$1} }
  while ($t =~ m{href="/([^"/#?]+\.html)"}g) { push @avisos, "$f: enlace roto /$1" unless -e "$ROOT/$1" }
}
print "\nPublicados: ", scalar @pub, " · en cola: ", scalar @cola, ($cola[0] ? " · siguiente: $cola[0]" : ''), "\n";
print "AVISO: $_\n" for @avisos;
