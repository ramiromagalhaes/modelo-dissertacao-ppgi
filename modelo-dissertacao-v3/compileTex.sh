#!/bin/bash
# Script used for compiling main.tex, a file created by: 
# lucasribeiro@ufrj.br / Federal University of Rio de Janeiro


# Instructions for compiling on linux( Tested on Ubuntu 10.04 ):
# 1) Open terminal ( crtl + alt + control )
# 2) Navegate to the folder where compileTex.sh is in using the command:
# $ cd <path-to-compileTex.sh>
# Where <path-to-compileTex.sh> could be ~/MyFiles/latex resulting in the command:
# $ cd ~/MyFiles/latex
# 3) Now that you are in folder where compileTex.sh resides, you must change the permission
# of the file, so that you can execute it. To do that you can use the command chmod. For example
# use like this:
# $ sudo chmod 777 compileTex.sh
# 4) Now you can run the script by doing this:
# $ ./compileTex.sh
# 5) The pdf generated will be at same folder as script file compileTex.sh (root folder)
# 
# Obs.: To clean up all files generated by latex, use the parameter clean as:
# $ ./compileTex.sh clean


# BEG - Functions declarations
function checkCompilation {
  if [[ "$1" != 0 ]]; then
    echo "Fail to compile $2"
    exit $$1
  fi
}
# BEG - Functions declarations


# Checks whether is there a directory named obj or not.
# In case does not exist, create it.
if [ ! -d "obj" ]; then
  mkdir obj
fi


############ START SCRIPTS (clean and compilation) #############

# To clean obj files, to use it just run
#$./compileTex.sh clean
if [ "clean" == "$1" ]; then

   extToClean=(aux blg bbl dvi lof lot log ps toc bib)
   
   echo "Cleanning"

   for ext in ${extToClean[@]}; do
      fullPath=./obj/*.${ext}
      
      for file in ${fullPath}; do
        if [ -e ${file} ]
        then
          rm ${file}
        fi
      done
   done

   echo "Clean"
   exit 0
fi



# Defining variables
file_name="main"
bibtexFolder=./post-text
bibtexFile="referencias"
bibtexStyle="abnt-ufrgs"
texStuffFolder=./latex-stuff

# BEG - Setting searching path
export TEXINPUTS=${TEXINPUTS}:.:${texStuffFolder}
# END - Setting searching path

echo "Compiling $file_name.tex"

# Compilation splited into two parts:
# 1rst Part - Latex to DVI: After processing a .tex file, the output is a .dvi file.
# latex -> bibtex -> latex -> latex
# 2nd  Part - DVI to PDF: After processing a .dvi file, the output is a .pdf file.
# Sequence of transformation
# file.dvi -> file.ps -> file.pdf

# Compiling with latex
latex -halt-on-error -output-directory=./obj $file_name.tex
checkCompilation $? $file_name.tex

# Copying the bibtex file to the obj directory
cp ${bibtexFolder}/$bibtexFile.bib obj
cp ${texStuffFolder}/$bibtexStyle.bst obj

# Run bibtex in the obj directory
cd obj ; bibtex $file_name

# Compiling with latex again to get references
cd ..
latex -halt-on-error -output-directory=./obj $file_name.tex
checkCompilation $? $file_name.tex
latex -halt-on-error -output-directory=./obj $file_name.tex
checkCompilation $? $file_name.tex

# Compiling dvi to ps
dvips -o ./obj/$file_name.ps -t a4 ./obj/$file_name.dvi

# Compiling ps to pdf
ps2pdf ./obj/$file_name.ps ./$file_name.pdf

echo "Done! Look out for $file_name.pdf in the root directory"
exit 0
