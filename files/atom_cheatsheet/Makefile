LATEX="/usr/bin/latex"
PDFLATEX="/usr/bin/pdflatex"
DVIPDF="/usr/bin/dvipdf"
DVISVGM="/usr/bin/dvisvgm"
FILE=atom_cheatsheet

all: ${FILE}.dvi

dvi: ${FILE}.dvi

ps: ${FILE}.ps

pdf: ${FILE}.pdf

svg: ${FILE}.svg

clean:
	rm -f ${FILE}.aux
	rm -f ${FILE}.blg
	rm -f ${FILE}.bbl
	rm -f ${FILE}.dvi 
	rm -f ${FILE}.log
	rm -f *.log
	rm -f ${FILE}.lot
	rm -f ${FILE}.lof
	rm -f ${FILE}.ps
	rm -f ${FILE}.pdf
	rm -f ${FILE}.out
	rm -f ${FILE}.toc
	rm -f ${FILE}.brf
	rm -f ${FILE}.idx
	rm -f ${FILE}.ind
	rm -f ${FILE}.ilg
	rm -f ${FILE}.svg 
	rm -Rf ${FILE}

${FILE}.ps: ${FILE}.dvi
	dvips ${FILE}.dvi

${FILE}.pdf: ${FILE}.tex
	${PDFLATEX} ${FILE}.tex
#	${PDFLATEX} ${FILE}.tex
	convert -density 300x300 ${FILE}.pdf  -quality 90 ${FILE}.jpg
	
${FILE}.dvi: ${FILE}.tex 
	${LATEX} ${FILE}.tex
#	${LATEX} ${FILE}.tex

${FILE}.svg: ${FILE}.tex
	${LATEX} ${FILE}.tex
	${DVISVGM} -n ${FILE}.dvi
