#!/bin/sh

if [ $# -ne 1 ]
then
	echo "Error. Correct usage: ./WinFontsLaTeX.sh <font-name>"
	exit 1
fi

mkdir -p ttf
cp ttf/* ./

TEXMF="/usr/share/texmf-texlive"
encoding="T1-WGL4.enc"

for file in $1*.ttf
do
	filename="${file%.ttf}"
	ttf2tfm $file -q -T $encoding -v ec$filename.vpl rec$filename.tfm >> ttfonts.map
	vptovf ec$filename.vpl ec$filename.vf ec$filename.tfm
	ttf2afm -e $encoding -o rec$filename.afm $file
	afm2tfm rec$filename.afm -T $encoding rec$filename.tfm
	echo 'rec'$filename $filename '" T1Encoding ReEncodeFont " <'$filename'.ttf' $encoding >> winfonts.map
done

for file in $1.ttf $1bd.ttf
do
	filename="${file%.ttf}"
	ttf2tfm $file -q -T $encoding -s .167 -v ec${filename}o.vpl rec${filename}o.tfm >> ttfonts.map
	vptovf ec${filename}o.vpl ec${filename}o.vf ec${filename}o.tfm
	afm2tfm rec$filename.afm -T $encoding -s .167 rec${filename}o.tfm
	echo 'rec'$filename'o' $filename' " .167 SlantFont T1Encoding ReEncodeFont " <'$filename'.ttf' $encoding >> winfonts.map
done

for type in ttf tfm vpl vf afm
do
	mkdir -p $type
	mv *.$type $type/
	sudo mkdir -p $TEXMF/fonts/$type/ms/$1/
	sudo cp $type/*$1*.$type $TEXMF/fonts/$type/ms/$1/
done

mkdir -p $TEXMF/fonts/map/pdftex/base/
sudo cp *.map $TEXMF/fonts/map/pdftex/base/
mkdir -p $TEXMF/fonts/enc/dvips/base/
sudo cp $encoding $TEXMF/fonts/enc/dvips/base/

sudo update-texmf
sudo update-fmtutil
sudo update-updmap
sudo texhash
sudo updmap-sys --enable Map ttfonts.map
sudo updmap-sys --enable MixedMap winfonts.map
