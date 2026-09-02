# Pins pdfTeX's timestamps to the last commit, so rebuilding a commit gives a byte-identical PDF.
# Set here rather than in the Makefile so an editor calling latexmk directly gets it too.
chomp(my $commit_time = `git log -1 --format=%ct 2>/dev/null`);
$ENV{'SOURCE_DATE_EPOCH'} //= $commit_time || time;

$pdf_mode = 1;
$out_dir = 'build';
@default_files = ('Tom-Dobson-CV.tex');
$pdflatex = 'pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 %O %S';
ensure_path('TEXINPUTS', './vendor/altacv//');
$warnings_as_errors = 1;
