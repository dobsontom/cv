$pdf_mode = 1;
$out_dir = 'build';
@default_files = ('tom-dobson-cv.tex');
$pdflatex = 'pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 %O %S';
ensure_path('TEXINPUTS', './vendor/altacv//');
$warnings_as_errors = 1;
